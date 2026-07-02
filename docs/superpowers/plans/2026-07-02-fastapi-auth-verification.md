# FastAPI Auth Verification Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add Supabase JWT verification and student-ownership checks to every parent/student-data
route in the Nmimes FastAPI backend, plus the minimum new endpoints (`POST /parents/me`,
`POST /students`, `POST /students/verify-access-code`) needed to create parent/student records and
authenticate a child via access code.

**Architecture:** A FastAPI dependency (`get_current_parent`) verifies the Supabase JWT (ES256,
verified against Supabase's JWKS) on every protected route and returns `parent_id: UUID`. A
companion function (`verify_student_ownership`) checks that a given `student_id` belongs to that
`parent_id` before any route touches session/teach-it-back data. `POST /students/verify-access-code`
is additionally rate-limited via the existing Redis service.

**Tech Stack:** FastAPI, PyJWT with the `cryptography` extra (ES256 verification), bcrypt (PIN
hashing), httpx (JWKS fetch), the existing `services/supabase_client.py` and
`services/redis_client.py`.

## Global Constraints

- Supabase project uses ES256 (asymmetric, `ECC (P-256)`) — verification MUST use JWKS, not a
  shared HS256 secret.
- `parent_id` for a verified token is the JWT's `sub` claim (`auth.uid()`).
- `GET /leaderboard/weekly` stays public — do not add auth to `routers/leaderboard.py`.
- `POST /webhooks/stripe` stays authenticated via Stripe's signature only — do not add JWT auth to
  `routers/webhooks.py`.
- No automated test suite in this pass — verification is manual, against the live Supabase project
  `vebmbkbmmglgpwwmwevk`, using a real test parent + JWT.
- Raw access-code PINs are never persisted or logged — only `bcrypt` hashes ever reach
  `students.access_code_hash`.
- `POST /students/verify-access-code` is rate limited: 10 attempts per `parent_id` per 15 minutes
  (900 seconds), returning `429` once exceeded. A failed attempt counts toward the limit.
- Invalid/expired/malformed JWT → `401`. Valid JWT but student not owned by that parent → `403`.
  No match in `verify-access-code` → `404`.

---

### Task 1: Redis rate-limit helper with expiry

**Files:**
- Modify: `nmimes-api/services/redis_client.py`

**Interfaces:**
- Consumes: `get_client()` (existing, `nmimes-api/services/redis_client.py:30-33`).
- Produces: `async def increment_with_expiry(key: str, ex_seconds: int) -> int` — increments the
  counter at `key` and sets its expiry to `ex_seconds` **only if this increment created the key**
  (i.e. the key's value is now `1`), so the expiry window starts from the first attempt and isn't
  reset by subsequent attempts. Returns the new counter value. Used by Task 6
  (`routers/students.py`) for rate limiting.

The existing `cache_incr` (`nmimes-api/services/redis_client.py:65-69`) has no expiry support —
without one, a rate-limit key would never expire and would permanently lock out a parent after 10
lifetime attempts instead of 10 per 15 minutes.

- [ ] **Step 1: Add `increment_with_expiry` to `services/redis_client.py`**

Add this function after `cache_incr` (after line 69):

```python
async def increment_with_expiry(key: str, ex_seconds: int) -> int:
    """Increment key; set its expiry only on the increment that creates it (value becomes 1)."""
    new_value = await cache_incr(key)
    if new_value == 1:
        client = get_client()
        response = await client.post(f"/expire/{key}/{ex_seconds}")
        response.raise_for_status()
    return new_value
```

- [ ] **Step 2: Manually verify against Upstash**

This can't run without live Upstash credentials, so verification happens as part of Task 6's
end-to-end check (calling `verify-access-code` 11 times and confirming the 11th returns 429). No
standalone test here — proceed to commit.

- [ ] **Step 3: Commit**

```bash
cd "d:/nmimes mobile app/nmimes-backend"
git add nmimes-api/services/redis_client.py
git commit -m "Add increment_with_expiry helper for rate limiting"
```

---

### Task 2: Supabase upsert helper

**Files:**
- Modify: `nmimes-api/services/supabase_client.py`

**Interfaces:**
- Consumes: `get_client()` (existing, `nmimes-api/services/supabase_client.py:38-41`).
- Produces: `async def upsert_row(table: str, data: dict[str, Any], on_conflict: str = "id") ->
  dict[str, Any]` — inserts a row or updates it if a row with the same `on_conflict` column value
  already exists. Used by Task 7 (`POST /parents/me`, which must be safely callable on every
  sign-in, not just the first).

- [ ] **Step 1: Add `upsert_row` to `services/supabase_client.py`**

Add this function after `insert_row` (after line 54):

```python
async def upsert_row(table: str, data: dict[str, Any], on_conflict: str = "id") -> dict[str, Any]:
    """Insert a row, or update it in place if on_conflict's column value already exists."""
    client = get_client()
    response = await client.post(
        f"/{table}",
        json=data,
        params={"on_conflict": on_conflict},
        headers={"Prefer": "return=representation,resolution=merge-duplicates"},
    )
    response.raise_for_status()
    rows = response.json()
    return rows[0] if rows else {}
```

- [ ] **Step 2: Commit**

```bash
cd "d:/nmimes mobile app/nmimes-backend"
git add nmimes-api/services/supabase_client.py
git commit -m "Add upsert_row helper for idempotent parent record creation"
```

---

### Task 3: JWT verification service (JWKS fetch/cache, get_current_parent)

**Files:**
- Create: `nmimes-api/services/auth.py`
- Modify: `nmimes-api/requirements.txt`

**Interfaces:**
- Consumes: `config.get_settings()` (existing, `nmimes-api/config.py:33-35`) for `supabase_url`.
- Produces:
  - `async def get_current_parent(authorization: str = Header(...)) -> UUID` — FastAPI dependency.
    Raises `HTTPException(401, detail=...)` on any verification failure.
  - `async def verify_student_ownership(parent_id: UUID, student_id: UUID) -> None` — raises
    `HTTPException(403, detail="Student does not belong to this parent")` if no matching row
    exists. Used by Tasks 4, 5, 6, 7.

- [ ] **Step 1: Add JWT/JWKS dependencies to requirements.txt**

Add these two lines to `nmimes-api/requirements.txt` (after `python-dotenv==1.0.1`):

```
pyjwt[crypto]==2.10.1
bcrypt==4.2.1
```

- [ ] **Step 2: Install the new dependencies**

```bash
cd "d:/nmimes mobile app/nmimes-backend/nmimes-api"
source .venv/Scripts/activate
pip install -q pyjwt[crypto]==2.10.1 bcrypt==4.2.1
```

Expected: no errors. Confirm with `python -c "import jwt, bcrypt; print('OK')"` — expected output
`OK`.

- [ ] **Step 3: Write `services/auth.py`**

```python
"""Supabase JWT verification and student-ownership checks."""

import time
from uuid import UUID

import httpx
import jwt
from fastapi import Header, HTTPException

from config import get_settings
from services import supabase_client

_jwks_cache: dict | None = None
_jwks_cache_fetched_at: float = 0.0
_JWKS_TTL_SECONDS = 3600


async def _fetch_jwks() -> dict:
    settings = get_settings()
    async with httpx.AsyncClient(timeout=httpx.Timeout(10.0)) as client:
        response = await client.get(f"{settings.supabase_url}/auth/v1/.well-known/jwks.json")
        response.raise_for_status()
        return response.json()


async def _get_jwks(force_refresh: bool = False) -> dict:
    global _jwks_cache, _jwks_cache_fetched_at
    now = time.monotonic()
    is_stale = _jwks_cache is None or (now - _jwks_cache_fetched_at) > _JWKS_TTL_SECONDS
    if force_refresh or is_stale:
        _jwks_cache = await _fetch_jwks()
        _jwks_cache_fetched_at = now
    return _jwks_cache


def _find_signing_key(jwks: dict, kid: str) -> dict | None:
    for key in jwks.get("keys", []):
        if key.get("kid") == kid:
            return key
    return None


async def _verify_token(token: str) -> dict:
    try:
        unverified_header = jwt.get_unverified_header(token)
    except jwt.InvalidTokenError as exc:
        raise HTTPException(status_code=401, detail="Malformed token") from exc

    kid = unverified_header.get("kid")
    jwks = await _get_jwks()
    signing_key_data = _find_signing_key(jwks, kid) if kid else None

    if signing_key_data is None:
        jwks = await _get_jwks(force_refresh=True)
        signing_key_data = _find_signing_key(jwks, kid) if kid else None
        if signing_key_data is None:
            raise HTTPException(status_code=401, detail="Unknown signing key")

    try:
        public_key = jwt.PyJWK.from_dict(signing_key_data).key
        payload = jwt.decode(
            token,
            key=public_key,
            algorithms=["ES256"],
            options={"verify_aud": False},
        )
    except jwt.ExpiredSignatureError as exc:
        raise HTTPException(status_code=401, detail="Token expired") from exc
    except jwt.InvalidTokenError as exc:
        raise HTTPException(status_code=401, detail="Invalid token") from exc

    return payload


async def get_current_parent(authorization: str = Header(...)) -> UUID:
    """FastAPI dependency: verifies the Supabase JWT and returns the parent's UUID (auth.uid())."""
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or malformed Authorization header")
    token = authorization.removeprefix("Bearer ").strip()

    payload = await _verify_token(token)

    sub = payload.get("sub")
    if not sub:
        raise HTTPException(status_code=401, detail="Token missing subject claim")

    return UUID(sub)


async def verify_student_ownership(parent_id: UUID, student_id: UUID) -> None:
    """Raises 403 if student_id does not belong to parent_id."""
    student = await supabase_client.select_one(
        "students",
        filters={"id": f"eq.{student_id}", "parent_id": f"eq.{parent_id}"},
    )
    if student is None:
        raise HTTPException(status_code=403, detail="Student does not belong to this parent")
```

- [ ] **Step 4: Verify the module imports cleanly**

```bash
cd "d:/nmimes mobile app/nmimes-backend/nmimes-api"
source .venv/Scripts/activate
python -c "import services.auth; print('OK')"
```

Expected output: `OK`

- [ ] **Step 5: Commit**

```bash
cd "d:/nmimes mobile app/nmimes-backend"
git add nmimes-api/services/auth.py nmimes-api/requirements.txt
git commit -m "Add Supabase JWT verification (JWKS/ES256) and student ownership check"
```

---

### Task 4: Access-code (PIN) hashing service

**Files:**
- Create: `nmimes-api/services/access_code.py`

**Interfaces:**
- Produces: `def hash_access_code(code: str) -> str`, `def verify_access_code(code: str,
  hashed: str) -> bool`. Used by Task 6 (`routers/students.py`).

- [ ] **Step 1: Write `services/access_code.py`**

```python
"""Bcrypt hashing/verification for student access-code PINs."""

import bcrypt


def hash_access_code(code: str) -> str:
    """Hash a raw 4-digit PIN for storage in students.access_code_hash."""
    return bcrypt.hashpw(code.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_access_code(code: str, hashed: str) -> bool:
    """Compare a raw PIN against a stored bcrypt hash."""
    return bcrypt.checkpw(code.encode("utf-8"), hashed.encode("utf-8"))
```

- [ ] **Step 2: Verify hash/verify round-trip**

```bash
cd "d:/nmimes mobile app/nmimes-backend/nmimes-api"
source .venv/Scripts/activate
python -c "
from services.access_code import hash_access_code, verify_access_code
h = hash_access_code('1234')
assert verify_access_code('1234', h) is True
assert verify_access_code('9999', h) is False
print('OK')
"
```

Expected output: `OK`

- [ ] **Step 3: Commit**

```bash
cd "d:/nmimes mobile app/nmimes-backend"
git add nmimes-api/services/access_code.py
git commit -m "Add bcrypt hashing/verification for student access-code PINs"
```

---

### Task 5: Parent and student request/response models

**Files:**
- Create: `nmimes-api/models/parent.py`
- Create: `nmimes-api/models/student.py`

**Interfaces:**
- Produces: `CreateParentRequest`, `ParentResponse` (from `models/parent.py`);
  `CreateStudentRequest`, `StudentResponse`, `VerifyAccessCodeRequest` (from `models/student.py`).
  Used by Task 7 (`routers/parents.py`) and Task 6 (`routers/students.py`).

- [ ] **Step 1: Write `models/parent.py`**

```python
from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, Field


class CreateParentRequest(BaseModel):
    first_name: str = Field(..., min_length=1)
    last_name: str = Field(..., min_length=1)


class ParentResponse(BaseModel):
    id: UUID
    first_name: str
    last_name: str
    email: str
    subscription_status: Literal["free", "active", "canceled", "past_due"]
    created_at: datetime
    updated_at: datetime
```

Note: `email` is `str`, not Pydantic's `EmailStr` — Supabase JWT emails are already validated
upstream by Supabase Auth, and re-validating on read would risk rejecting legitimately stored
addresses that don't match `EmailStr`'s stricter parsing in edge cases (e.g. plus-addressing).

- [ ] **Step 2: Write `models/student.py`**

```python
from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


class CreateStudentRequest(BaseModel):
    name: str = Field(..., min_length=1)
    username: str | None = None
    grade: str | None = None
    interest: str | None = None
    access_code: str = Field(..., min_length=4, max_length=4, pattern=r"^\d{4}$")


class StudentResponse(BaseModel):
    id: UUID
    parent_id: UUID
    name: str
    username: str | None = None
    grade: str | None = None
    interest: str | None = None
    points_balance: int
    avatar_url: str | None = None
    created_at: datetime
    updated_at: datetime


class VerifyAccessCodeRequest(BaseModel):
    access_code: str = Field(..., min_length=4, max_length=4, pattern=r"^\d{4}$")
```

- [ ] **Step 3: Verify both modules import cleanly**

```bash
cd "d:/nmimes mobile app/nmimes-backend/nmimes-api"
source .venv/Scripts/activate
python -c "from models.parent import CreateParentRequest, ParentResponse; from models.student import CreateStudentRequest, StudentResponse, VerifyAccessCodeRequest; print('OK')"
```

Expected output: `OK`

- [ ] **Step 4: Commit**

```bash
cd "d:/nmimes mobile app/nmimes-backend"
git add nmimes-api/models/parent.py nmimes-api/models/student.py
git commit -m "Add parent and student request/response models"
```

---

### Task 6: Students router (create + verify access code)

**Files:**
- Create: `nmimes-api/routers/students.py`

**Interfaces:**
- Consumes: `get_current_parent`, `verify_student_ownership` (Task 3,
  `nmimes-api/services/auth.py`); `hash_access_code`, `verify_access_code` (Task 4,
  `nmimes-api/services/access_code.py`); `CreateStudentRequest`, `StudentResponse`,
  `VerifyAccessCodeRequest` (Task 5, `nmimes-api/models/student.py`);
  `supabase_client.insert_row`, `supabase_client.select_rows` (existing,
  `nmimes-api/services/supabase_client.py:44-54,70-85`); `redis_client.increment_with_expiry`
  (Task 1, `nmimes-api/services/redis_client.py`).
- Produces: `router` (FastAPI `APIRouter`, prefix `/students`) with `POST /students` and
  `POST /students/verify-access-code`. Registered in `main.py` by Task 7 (which registers both
  the `students` and `parents` routers together, since both edit the same import line).

- [ ] **Step 1: Write `routers/students.py`**

```python
import logging
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException

from models.student import CreateStudentRequest, StudentResponse, VerifyAccessCodeRequest
from services import supabase_client
from services.access_code import hash_access_code, verify_access_code
from services.auth import get_current_parent
from services.redis_client import increment_with_expiry

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/students", tags=["students"])

STUDENTS_TABLE = "students"
RATE_LIMIT_MAX_ATTEMPTS = 10
RATE_LIMIT_WINDOW_SECONDS = 900


@router.post("", response_model=StudentResponse)
async def create_student(
    payload: CreateStudentRequest, parent_id: UUID = Depends(get_current_parent)
) -> StudentResponse:
    student_row = await supabase_client.insert_row(
        STUDENTS_TABLE,
        {
            "parent_id": str(parent_id),
            "name": payload.name,
            "username": payload.username,
            "grade": payload.grade,
            "interest": payload.interest,
            "access_code_hash": hash_access_code(payload.access_code),
        },
    )
    return StudentResponse(**student_row)


@router.post("/verify-access-code", response_model=StudentResponse)
async def verify_student_access_code(
    payload: VerifyAccessCodeRequest, parent_id: UUID = Depends(get_current_parent)
) -> StudentResponse:
    attempts = await increment_with_expiry(
        f"access_code_attempts:{parent_id}", RATE_LIMIT_WINDOW_SECONDS
    )
    if attempts > RATE_LIMIT_MAX_ATTEMPTS:
        raise HTTPException(status_code=429, detail="Too many access code attempts, try again later")

    students = await supabase_client.select_rows(
        STUDENTS_TABLE, filters={"parent_id": f"eq.{parent_id}"}
    )
    for student in students:
        if verify_access_code(payload.access_code, student["access_code_hash"]):
            return StudentResponse(**student)

    raise HTTPException(status_code=404, detail="No matching student for this access code")
```

- [ ] **Step 2: Verify the module imports cleanly on its own**

`main.py` registration happens in Task 7 (which also creates `routers/parents.py` and edits
`main.py` once for both new routers, avoiding two tasks touching the same lines). For now, just
confirm this file has no syntax/import errors in isolation:

```bash
cd "d:/nmimes mobile app/nmimes-backend/nmimes-api"
source .venv/Scripts/activate
python -c "import routers.students; print('OK')"
```

Expected output: `OK`

- [ ] **Step 3: Commit**

```bash
cd "d:/nmimes mobile app/nmimes-backend"
git add nmimes-api/routers/students.py
git commit -m "Add students router: create student, verify access code (rate limited)"
```

---

### Task 7: Parents router (upsert on sign-in)

**Files:**
- Create: `nmimes-api/routers/parents.py`
- Modify: `nmimes-api/main.py`

**Interfaces:**
- Consumes: `get_current_parent` (Task 3, `nmimes-api/services/auth.py`); `CreateParentRequest`,
  `ParentResponse` (Task 5, `nmimes-api/models/parent.py`); `supabase_client.upsert_row` (Task 2,
  `nmimes-api/services/supabase_client.py`).
- Produces: `router` (FastAPI `APIRouter`, prefix `/parents`) with `POST /parents/me`. Registered
  in `main.py` by this task (completing the import started in Task 6).

The parent's `email` comes from the verified JWT's `email` claim, not the request body — this
means `get_current_parent` (Task 3) needs to also expose the full decoded payload, not just
`parent_id`, for this one route. Add a second dependency for that rather than re-verifying the
token twice.

- [ ] **Step 1: Add `get_current_parent_claims` to `services/auth.py`**

In `nmimes-api/services/auth.py`, add this function after `get_current_parent` (which Task 3
created):

```python
async def get_current_parent_claims(authorization: str = Header(...)) -> dict:
    """Like get_current_parent, but returns the full verified JWT payload (needed for email)."""
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or malformed Authorization header")
    token = authorization.removeprefix("Bearer ").strip()
    return await _verify_token(token)
```

- [ ] **Step 2: Write `routers/parents.py`**

```python
import logging
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException

from models.parent import CreateParentRequest, ParentResponse
from services import supabase_client
from services.auth import get_current_parent_claims

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/parents", tags=["parents"])

PARENTS_TABLE = "parents"


@router.post("/me", response_model=ParentResponse)
async def upsert_current_parent(
    payload: CreateParentRequest, claims: dict = Depends(get_current_parent_claims)
) -> ParentResponse:
    parent_id = claims.get("sub")
    email = claims.get("email")
    if not parent_id or not email:
        raise HTTPException(status_code=401, detail="Token missing subject or email claim")

    parent_row = await supabase_client.upsert_row(
        PARENTS_TABLE,
        {
            "id": parent_id,
            "first_name": payload.first_name,
            "last_name": payload.last_name,
            "email": email,
        },
        on_conflict="id",
    )
    return ParentResponse(**parent_row)
```

- [ ] **Step 3: Register both new routers in `main.py`**

In `nmimes-api/main.py`, change line 8 from:

```python
from routers import leaderboard, sessions, teach_it_back, webhooks
```

to:

```python
from routers import leaderboard, parents, sessions, students, teach_it_back, webhooks
```

Change lines 44-47 from:

```python
app.include_router(sessions.router)
app.include_router(teach_it_back.router)
app.include_router(leaderboard.router)
app.include_router(webhooks.router)
```

to:

```python
app.include_router(sessions.router)
app.include_router(teach_it_back.router)
app.include_router(leaderboard.router)
app.include_router(webhooks.router)
app.include_router(students.router)
app.include_router(parents.router)
```

- [ ] **Step 4: Verify the app imports cleanly**

```bash
cd "d:/nmimes mobile app/nmimes-backend/nmimes-api"
source .venv/Scripts/activate
python -c "import main; print([r.path for r in main.app.routes if hasattr(r, 'methods')])"
```

Expected output includes `/parents/me`, `/students`, `/students/verify-access-code`, plus all
routes from before (`/sessions/start`, `/sessions/{session_id}/step`, `/sessions/{session_id}`,
`/teach-it-back/{session_id}`, `/leaderboard/weekly`, `/webhooks/stripe`, `/health`).

- [ ] **Step 5: Commit**

```bash
cd "d:/nmimes mobile app/nmimes-backend"
git add nmimes-api/services/auth.py nmimes-api/routers/parents.py nmimes-api/main.py
git commit -m "Add parents router: upsert parent record on sign-in"
```

---

### Task 8: Add auth + ownership checks to sessions router

**Files:**
- Modify: `nmimes-api/routers/sessions.py`

**Interfaces:**
- Consumes: `get_current_parent`, `verify_student_ownership` (Task 3,
  `nmimes-api/services/auth.py`).
- Produces: all three routes in this file now require a valid parent JWT and verify student
  ownership before touching data. No changes to request/response models or SSE event shapes.

- [ ] **Step 1: Add the auth import**

In `nmimes-api/routers/sessions.py`, change line 4 from:

```python
from fastapi import APIRouter, HTTPException
```

to:

```python
from fastapi import APIRouter, Depends, HTTPException
```

Add this import after line 9 (`from services.claude import ...`):

```python
from services.auth import get_current_parent, verify_student_ownership
```

- [ ] **Step 2: Add auth + ownership check to `POST /sessions/start`**

Change the function signature at line 20 from:

```python
async def start_session(payload: StartSessionRequest) -> StreamingResponse:
```

to:

```python
async def start_session(
    payload: StartSessionRequest, parent_id: UUID = Depends(get_current_parent)
) -> StreamingResponse:
```

Ownership must be checked before the generator starts (so a 403 short-circuits immediately,
outside the SSE stream, rather than being wrapped in an `error` SSE event). Add this line
immediately after the function signature, before `async def event_stream():` (i.e. right after
the new line 23):

```python
    await verify_student_ownership(parent_id, payload.student_id)
```

- [ ] **Step 3: Add auth + ownership check to `POST /sessions/{session_id}/step`**

Change the function signature (originally line 73) from:

```python
async def submit_step(session_id: UUID, payload: StepAnswerRequest) -> StreamingResponse:
```

to:

```python
async def submit_step(
    session_id: UUID, payload: StepAnswerRequest, parent_id: UUID = Depends(get_current_parent)
) -> StreamingResponse:
```

This route doesn't receive `student_id` directly — it must look up the session's `student_id`
first, then verify ownership, before entering the generator. Add these lines immediately after the
new function signature, before `async def event_stream():`:

```python
    session_for_auth = await supabase_client.select_one(
        SESSIONS_TABLE, filters={"id": f"eq.{session_id}"}
    )
    if session_for_auth is None:
        raise HTTPException(status_code=404, detail="Session not found")
    await verify_student_ownership(parent_id, UUID(session_for_auth["student_id"]))
```

Note this makes the `session is None` check inside `event_stream()` (originally lines 76-81)
unreachable for the 404 case specifically, but it's harmless dead code for defense-in-depth (the
session could theoretically be deleted between this check and the generator running) — leave it
as-is, do not remove it.

- [ ] **Step 4: Add auth + ownership check to `GET /sessions/{session_id}`**

Change the function signature (originally line 165) from:

```python
async def get_session(session_id: UUID) -> SessionResponse:
```

to:

```python
async def get_session(
    session_id: UUID, parent_id: UUID = Depends(get_current_parent)
) -> SessionResponse:
```

Immediately after fetching `session` and confirming it's not `None` (originally lines 166-170),
add the ownership check before the `return` statement:

```python
    if session is None:
        raise HTTPException(status_code=404, detail="Session not found")
    await verify_student_ownership(parent_id, UUID(session["student_id"]))
    return SessionResponse(**session)
```

(This replaces the original two-line block of `if session is None: raise ...` /
`return SessionResponse(**session)` with the three-line block above.)

- [ ] **Step 5: Verify the app imports cleanly**

```bash
cd "d:/nmimes mobile app/nmimes-backend/nmimes-api"
source .venv/Scripts/activate
python -c "import main; print('OK')"
```

Expected output: `OK`

- [ ] **Step 6: Commit**

```bash
cd "d:/nmimes mobile app/nmimes-backend"
git add nmimes-api/routers/sessions.py
git commit -m "Require parent JWT and student ownership on all session routes"
```

---

### Task 9: Add auth + ownership checks to teach-it-back router

**Files:**
- Modify: `nmimes-api/routers/teach_it_back.py`

**Interfaces:**
- Consumes: `get_current_parent`, `verify_student_ownership` (Task 3,
  `nmimes-api/services/auth.py`).
- Produces: the teach-it-back route now requires a valid parent JWT and verifies student ownership
  (via the session's `student_id`) before touching data.

- [ ] **Step 1: Add the auth import and Depends import**

In `nmimes-api/routers/teach_it_back.py`, change line 4 from:

```python
from fastapi import APIRouter, HTTPException
```

to:

```python
from fastapi import APIRouter, Depends, HTTPException
```

Add this import after line 9 (`from services.whisper import transcribe_audio`):

```python
from services.auth import get_current_parent, verify_student_ownership
```

- [ ] **Step 2: Add auth + ownership check to `POST /teach-it-back/{session_id}`**

Change the function signature (originally line 20) from:

```python
async def teach_it_back(session_id: UUID, payload: TeachItBackRequest) -> TeachItBackResponse:
```

to:

```python
async def teach_it_back(
    session_id: UUID, payload: TeachItBackRequest, parent_id: UUID = Depends(get_current_parent)
) -> TeachItBackResponse:
```

Immediately after the existing session-lookup block (originally lines 24-28: fetch `session`,
raise 404 if `None`), add the ownership check:

```python
    session = await supabase_client.select_one(
        SESSIONS_TABLE, filters={"id": f"eq.{session_id}"}
    )
    if session is None:
        raise HTTPException(status_code=404, detail="Session not found")
    await verify_student_ownership(parent_id, UUID(session["student_id"]))
```

(This replaces the original four-line block with the five-line block above — same logic, plus the
ownership check appended.)

- [ ] **Step 3: Verify the app imports cleanly**

```bash
cd "d:/nmimes mobile app/nmimes-backend/nmimes-api"
source .venv/Scripts/activate
python -c "import main; print('OK')"
```

Expected output: `OK`

- [ ] **Step 4: Commit**

```bash
cd "d:/nmimes mobile app/nmimes-backend"
git add nmimes-api/routers/teach_it_back.py
git commit -m "Require parent JWT and student ownership on teach-it-back route"
```

---

### Task 10: End-to-end manual verification against live Supabase

**Files:**
- None created or modified — this task exercises the running app against the live
  `vebmbkbmmglgpwwmwevk` Supabase project.

**Interfaces:**
- Consumes: all routes and services from Tasks 1-9.
- Produces: confirmation that auth, ownership checks, and rate limiting work end-to-end, or a list
  of concrete failures to fix before this sub-project is considered done.

- [ ] **Step 1: Create two test parent users via the Supabase Admin API**

```bash
curl -s -X POST "https://vebmbkbmmglgpwwmwevk.supabase.co/auth/v1/admin/users" \
  -H "apikey: sb_secret_REDACTED_ROTATE_ME" \
  -H "Authorization: Bearer sb_secret_REDACTED_ROTATE_ME" \
  -H "Content-Type: application/json" \
  -d '{"email":"auth-verify-parent-a@nmimes.internal","password":"TempPassw0rd!2026abc","email_confirm":true}'
```

Note the returned `id` as `PARENT_A_ID`. Repeat with a different email
(`auth-verify-parent-b@nmimes.internal`) and note that `id` as `PARENT_B_ID`.

- [ ] **Step 2: Sign in as each test user to get real JWTs**

```bash
curl -s -X POST "https://vebmbkbmmglgpwwmwevk.supabase.co/auth/v1/token?grant_type=password" \
  -H "apikey: sb_publishable_JNNHRxxhIi5wYM0ljrMBjQ_i5dZQCmV" \
  -H "Content-Type: application/json" \
  -d '{"email":"auth-verify-parent-a@nmimes.internal","password":"TempPassw0rd!2026abc"}'
```

Note the `access_token` field as `JWT_A`. Repeat for parent B (using its password) to get `JWT_B`.

- [ ] **Step 3: Start the FastAPI app locally**

```bash
cd "d:/nmimes mobile app/nmimes-backend/nmimes-api"
source .venv/Scripts/activate
uvicorn main:app --reload --port 8000
```

Run this with `run_in_background: true` if using the Bash tool, since it's a long-running server.

- [ ] **Step 4: Confirm a protected route rejects requests with no auth header**

```bash
curl -s -o /dev/null -w "%{http_code}\n" -X POST "http://localhost:8000/students" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Child","access_code":"1234"}'
```

Expected output: `401` (FastAPI returns 422 if the header is entirely absent since it's a required
`Header(...)` — if you see `422` instead of `401`, that's the correct behavior for a missing
required header per FastAPI's validation layer, not a bug; note it and move on).

- [ ] **Step 5: Create the parent record for parent A**

```bash
curl -s -X POST "http://localhost:8000/parents/me" \
  -H "Authorization: Bearer $JWT_A" \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Parent","last_name":"A"}'
```

Expected: `200` with a JSON body containing `"id": "<PARENT_A_ID>"`,
`"subscription_status": "free"`. Repeat for parent B with `$JWT_B`.

- [ ] **Step 6: Create a student under parent A**

```bash
curl -s -X POST "http://localhost:8000/students" \
  -H "Authorization: Bearer $JWT_A" \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Child A","access_code":"1234"}'
```

Expected: `200` with a JSON body containing `parent_id` equal to `PARENT_A_ID` and
`points_balance: 0`. Note the returned `id` as `STUDENT_A_ID`.

- [ ] **Step 7: Verify the access code succeeds with the right PIN**

```bash
curl -s -X POST "http://localhost:8000/students/verify-access-code" \
  -H "Authorization: Bearer $JWT_A" \
  -H "Content-Type: application/json" \
  -d '{"access_code":"1234"}'
```

Expected: `200` with `"id": "<STUDENT_A_ID>"`.

- [ ] **Step 8: Verify the access code fails with the wrong PIN**

```bash
curl -s -o /dev/null -w "%{http_code}\n" -X POST "http://localhost:8000/students/verify-access-code" \
  -H "Authorization: Bearer $JWT_A" \
  -H "Content-Type: application/json" \
  -d '{"access_code":"9999"}'
```

Expected output: `404`

- [ ] **Step 9: Verify rate limiting kicks in after 10 attempts**

Run the Step 8 command 9 more times in a row (10 total failed attempts), then run it an 11th time:

```bash
for i in $(seq 1 11); do
  curl -s -o /dev/null -w "%{http_code}\n" -X POST "http://localhost:8000/students/verify-access-code" \
    -H "Authorization: Bearer $JWT_A" \
    -H "Content-Type: application/json" \
    -d '{"access_code":"9999"}'
done
```

Expected output: ten `404` lines followed by one `429` line (the 11th attempt, since Step 8 already
used up one of the ten; adjust the loop count if Step 8's attempt should be included in the total
— either way, confirm the 11th cumulative attempt since Step 7's rate-limit key was created
returns `429`).

- [ ] **Step 10: Confirm cross-parent ownership is enforced (the core IDOR fix)**

Using `STUDENT_A_ID` from Step 6, attempt to start a session as parent B:

```bash
curl -s -o /dev/null -w "%{http_code}\n" -X POST "http://localhost:8000/sessions/start" \
  -H "Authorization: Bearer $JWT_B" \
  -H "Content-Type: application/json" \
  -d "{\"student_id\":\"$STUDENT_A_ID\",\"ocr_text\":\"2x + 5 = 15\"}"
```

Expected output: `403`. This is the critical check confirming the IDOR vulnerability flagged
during sub-project A is closed.

- [ ] **Step 11: Confirm a legitimate session start succeeds**

```bash
curl -s -X POST "http://localhost:8000/sessions/start" \
  -H "Authorization: Bearer $JWT_A" \
  -H "Content-Type: application/json" \
  -d "{\"student_id\":\"$STUDENT_A_ID\",\"ocr_text\":\"2x + 5 = 15\"}"
```

Expected: an SSE stream (`event: session_created`, `event: question`) with no `error` event, since
parent A owns `STUDENT_A_ID`. Note this call to Claude and Supabase requires valid
`ANTHROPIC_API_KEY`/other `.env` values beyond the Supabase ones already configured — if those
aren't set, expect an `error` SSE event unrelated to auth (e.g. an Anthropic API failure) rather
than a 401/403; that's an out-of-scope failure for this task, not an auth bug.

- [ ] **Step 12: Stop the server and clean up test users**

```bash
curl -s -X DELETE "https://vebmbkbmmglgpwwmwevk.supabase.co/auth/v1/admin/users/$PARENT_A_ID" \
  -H "apikey: sb_secret_REDACTED_ROTATE_ME" \
  -H "Authorization: Bearer sb_secret_REDACTED_ROTATE_ME"
curl -s -X DELETE "https://vebmbkbmmglgpwwmwevk.supabase.co/auth/v1/admin/users/$PARENT_B_ID" \
  -H "apikey: sb_secret_REDACTED_ROTATE_ME" \
  -H "Authorization: Bearer sb_secret_REDACTED_ROTATE_ME"
```

(Deleting the `auth.users` rows cascades to delete the `parents` rows, which cascades to delete
`students`, `homework_sessions`, etc. — no separate cleanup needed.)

- [ ] **Step 13: Report results**

No commit for this task (no files changed) — summarize which steps passed/failed to the user
directly.

---

## Self-Review Notes

- **Spec coverage:** JWKS/ES256 verification (Task 3), `get_current_parent` (Task 3),
  `verify_student_ownership` (Task 3), `POST /parents/me` upsert-on-sign-in (Task 7),
  `POST /students` (Task 6), `POST /students/verify-access-code` with rate limiting (Tasks 1, 6),
  auth applied to all `sessions.py` and `teach_it_back.py` routes (Tasks 8, 9), leaderboard/webhook
  routes left untouched (implicitly satisfied — no task modifies them), manual live verification
  including the explicit cross-parent 403 check (Task 10) — all spec sections have a task.
- **Placeholder scan:** none found — all code blocks are complete; Task 6/7's `main.py` edit note
  explains a real sequencing ambiguity (which task's edit "wins" the import line) rather than
  leaving a TBD, and gives the exact resulting line either way.
- **Type consistency:** `parent_id: UUID` and `student_id: UUID` used consistently across
  `services/auth.py`, `routers/students.py`, `routers/sessions.py`, `routers/teach_it_back.py`.
  `verify_student_ownership(parent_id: UUID, student_id: UUID) -> None` signature matches every
  call site. `StudentResponse`/`ParentResponse` field names match the Supabase schema columns from
  sub-project A exactly (`parent_id`, `points_balance`, `subscription_status`, etc.).
