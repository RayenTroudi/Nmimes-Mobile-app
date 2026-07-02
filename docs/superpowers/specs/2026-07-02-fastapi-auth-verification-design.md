# FastAPI Auth Verification Design (Sub-project B)

Date: 2026-07-02

## Context

Sub-project A delivered the Supabase schema (`parents`, `students`, `homework_sessions`,
`session_steps`, `teach_it_back_attempts`) with RLS policies, but the FastAPI backend
(`nmimes-backend/nmimes-api/`) has zero auth — every route currently trusts whatever
`student_id`/`session_id` the caller sends, with no verification that the caller is even a
signed-in parent, let alone that they own the student/session in question (flagged by an
automated security review during sub-project A as an IDOR vulnerability).

This is sub-project B of the four-part effort to connect the backend, database, and Flutter app:

- **A (done)** — Supabase schema + relations
- **B (this spec)** — FastAPI auth verification
- **C** — Flutter networking layer + Dart models + Supabase Auth screen wiring
- **D** — Flutter feature wiring

## Scope

Add Supabase JWT verification to every route that touches parent/student data, plus the minimum
new endpoints needed to create a parent record after signup and to create/authenticate a child
via access code. `GET /leaderboard/weekly` stays public (aggregate, no PII beyond `student_id`).
`POST /webhooks/stripe` stays authenticated via Stripe's own signature scheme, unchanged.

No automated test suite is added in this pass — verification is manual, against the live
Supabase project, using a real test parent + JWT (matching how sub-project A was verified).

## JWT verification

Supabase Auth on this project signs tokens with ES256 (asymmetric, `ECC (P-256)` per the project's
JWT key settings) — this requires verifying against Supabase's public JWKS endpoint
(`{SUPABASE_URL}/auth/v1/.well-known/jwks.json`), not a shared HS256 secret.

- `services/auth.py` fetches and caches the JWKS in memory with a 1-hour TTL. If verification
  fails because the token's `kid` isn't in the cached key set (e.g. Supabase rotated keys), the
  cache is refreshed once and verification retried before rejecting — this makes the cache
  self-healing without requiring an API restart.
- `get_current_parent(authorization: str = Header(...))` is a FastAPI dependency: extracts the
  bearer token, verifies its signature and expiry, and returns `parent_id: UUID` (the token's
  `sub` claim, which is `auth.uid()`). Raises `HTTPException(401)` on any verification failure
  (missing header, malformed token, bad signature, expired).

## Ownership verification

`services/auth.py` also exposes `verify_student_ownership(parent_id: UUID, student_id: UUID) ->
None`, which queries `students` via the existing `supabase_client.select_one` helper
(`filters={"id": f"eq.{student_id}", "parent_id": f"eq.{parent_id}"}`) and raises
`HTTPException(403)` if no matching row is found. Every route that receives a `student_id` calls
this immediately after the `get_current_parent` dependency resolves, before touching any other
data. Routes that operate on a `session_id` instead (e.g. `POST /sessions/{id}/step`) first look
up the session's `student_id`, then verify ownership the same way.

## New endpoints

**`POST /parents/me`** — called once by Flutter right after a parent's first successful Supabase
Auth sign-in. Body: `{first_name: str, last_name: str}`. Uses `get_current_parent` for the JWT,
takes `email` from the verified token's `email` claim (not the request body, to avoid trusting
client-supplied email). Upserts (insert-or-update) the `parents` row keyed on
`id = parent_id` — idempotent-safe if called again on a later sign-in.

**`POST /students`** — creates a child profile under the authenticated parent. Body:
`{name, username?, grade?, interest?, access_code: str}` where `access_code` is the raw 4-digit
PIN the parent chose in the UI. `services/access_code.py` bcrypt-hashes it before storing in
`students.access_code_hash`; the raw PIN is never persisted or logged. Returns the created
`StudentResponse` (no hash included).

**`POST /students/verify-access-code`** — body: `{access_code: str}`. Uses `get_current_parent`
for the JWT (so this only ever checks PINs within the signed-in parent's own children — matches
the earlier decision that PINs may collide across different parents' children). Rate limited via
`services/redis_client.cache_incr` on a key scoped to `parent_id` (e.g. `access_code_attempts:
{parent_id}`, 15-minute expiry, capped at 10 attempts) — returns `HTTPException(429)` once
exceeded, since a 4-digit PIN is only 10,000 combinations and is otherwise brute-forceable within
a single parent's own JWT session. Fetches all of that parent's students, bcrypt-compares the
submitted code against each `access_code_hash` in turn, and returns the matching `StudentResponse`
(200) or `HTTPException(404)` if none match (a failed attempt still counts toward the rate limit).
Flutter stores the returned `student_id` locally and includes it in subsequent session/
teach-it-back requests — no new token type, matching the "stateless" decision below.

## Student scoping in existing routes

`student_id` continues to travel exactly as it does today — as a field in `StartSessionRequest`
(already exists) or resolved from the `session_id` path parameter for step/teach-it-back routes.
No request/response model shapes change. What changes is that every handler now:

1. Depends on `get_current_parent` to resolve `parent_id` from the `Authorization` header.
2. Calls `verify_student_ownership(parent_id, student_id)` (or the session-id variant) before any
   Supabase read/write.

This was chosen over minting a second custom JWT (encoding `parent_id` + `student_id`) because it
requires no new token infrastructure and fits the request shapes already built in the FastAPI
scaffold that preceded sub-project A.

## Files

**New:**
- `nmimes-api/services/auth.py` — JWKS fetch/cache, `get_current_parent`, `verify_student_ownership`
- `nmimes-api/services/access_code.py` — bcrypt hash/verify helpers
- `nmimes-api/models/parent.py` — `CreateParentRequest`, `ParentResponse`
- `nmimes-api/models/student.py` — `CreateStudentRequest`, `StudentResponse`,
  `VerifyAccessCodeRequest`
- `nmimes-api/routers/parents.py` — `POST /parents/me`
- `nmimes-api/routers/students.py` — `POST /students`, `POST /students/verify-access-code`
  (consumes `services/redis_client.py`, already built in the original scaffold, for rate limiting)

**Modified:**
- `nmimes-api/routers/sessions.py` — add auth dependency + ownership check to all 3 routes
- `nmimes-api/routers/teach_it_back.py` — add auth dependency + ownership check
- `nmimes-api/main.py` — register the two new routers
- `nmimes-api/requirements.txt` — add `pyjwt[crypto]` (ES256 verification needs the `cryptography`
  extra) and `bcrypt`

**Unchanged:**
- `nmimes-api/routers/leaderboard.py` — stays public
- `nmimes-api/routers/webhooks.py` — stays Stripe-signature-authenticated

## Error handling

- No/malformed/expired/invalid-signature JWT → `401 Unauthorized`
- Valid JWT, but the referenced `student_id`/`session_id` doesn't belong to that parent →
  `403 Forbidden`
- Valid JWT, parent has no `parents` row yet (client skipped `POST /parents/me`) → not
  special-cased; the downstream Supabase foreign-key constraint on `students.parent_id` naturally
  fails as a `400`, since this is a client integration bug, not a runtime case to handle gracefully
- `access_code` verification with no match among the parent's students → `404 Not Found`

## Verification plan

Manual, against the live Supabase project (`vebmbkbmmglgpwwmwevk`), matching how sub-project A was
verified:

1. Create a real test `auth.users` row via the Supabase Admin API (as done in sub-project A) and
   obtain a real signed JWT for it (via the Supabase Auth `token` endpoint, e.g. a password-based
   sign-in for the test user).
2. Run the FastAPI app locally (`uvicorn main:app`).
3. `curl` each new/modified endpoint: `POST /parents/me` with a valid JWT (expect 201/200),
   `POST /students`, `POST /students/verify-access-code` with correct and incorrect PINs (expect
   200 and 404), then `POST /sessions/start` with that `student_id` (expect success) and with a
   `student_id` belonging to a different, second test parent (expect 403). Also confirm no
   `Authorization` header on a protected route returns 401.
4. Clean up test users/rows via the Supabase Admin API afterward.

## Out of scope

- Automated pytest suite (deferred; noted as a gap, not a rejection — may be added once the
  Flutter integration in sub-projects C/D stabilizes the request shapes further)
- Student profile editing (`PATCH /students/{id}`) and access-code reset — UI for these
  (`edit_child_profile_screen.dart`) isn't wired until sub-project D; endpoint added then if still
  needed
