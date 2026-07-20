# Supabase Schema Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the Supabase database schema (5 tables + RLS + indexes) that the existing FastAPI
backend needs to persist parents, students, homework sessions, session steps, and teach-it-back
attempts.

**Architecture:** A single idempotent SQL migration file, applied via the Supabase CLI (or the
Supabase SQL editor if the CLI isn't linked yet), plus a verification script that exercises
inserts/constraints/RLS against a live Supabase project using `psql` or the REST API.

**Tech Stack:** PostgreSQL (Supabase-hosted), Supabase CLI, `pgcrypto`/`gen_random_uuid()`.

## Global Constraints

- Schema exactly as specified in `docs/superpowers/specs/2026-07-02-supabase-schema-design.md` —
  do not add rewards/challenges/study-room tables (out of scope).
- Access codes (`students.access_code_hash`) must never store plaintext PINs.
- RLS enabled on all 5 tables per the spec's policies, even though FastAPI uses the service-role
  key and bypasses RLS — this is defense-in-depth.
- All timestamps `timestamptz`, all primary keys `uuid default gen_random_uuid()` (except
  `parents.id` which is the Supabase Auth user id, no default).

---

### Task 1: Migration file — tables, indexes, constraints

**Files:**
- Create: `nmimes-backend/supabase/migrations/0001_core_schema.sql`

**Interfaces:**
- Produces: tables `parents`, `students`, `homework_sessions`, `session_steps`,
  `teach_it_back_attempts` with columns exactly as listed below. Later tasks (RLS, verification)
  depend on these exact table/column names.

- [ ] **Step 1: Write the migration SQL**

```sql
-- nmimes-backend/supabase/migrations/0001_core_schema.sql

create extension if not exists pgcrypto;

create table if not exists parents (
  id                    uuid primary key references auth.users(id) on delete cascade,
  first_name            text not null,
  last_name             text not null,
  email                 text not null,
  stripe_customer_id    text unique,
  subscription_status   text not null default 'free'
    check (subscription_status in ('free', 'active', 'canceled', 'past_due')),
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

create table if not exists students (
  id                 uuid primary key default gen_random_uuid(),
  parent_id          uuid not null references parents(id) on delete cascade,
  name               text not null,
  username           text,
  grade              text,
  interest           text,
  access_code_hash   text not null,
  points_balance     integer not null default 0,
  avatar_url         text,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);

create table if not exists homework_sessions (
  id            uuid primary key default gen_random_uuid(),
  student_id    uuid not null references students(id) on delete cascade,
  ocr_text      text not null,
  image_url     text,
  subject       text,
  topic         text,
  status        text not null default 'active'
    check (status in ('active', 'completed', 'abandoned')),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create table if not exists session_steps (
  id               uuid primary key default gen_random_uuid(),
  session_id       uuid not null references homework_sessions(id) on delete cascade,
  step_number      integer not null,
  question         text not null,
  student_answer   text,
  tier             text
    check (tier in ('correct', 'partially_correct', 'incorrect', 'off_topic')),
  feedback         text,
  created_at       timestamptz not null default now()
);

create table if not exists teach_it_back_attempts (
  id             uuid primary key default gen_random_uuid(),
  session_id     uuid not null references homework_sessions(id) on delete cascade,
  transcript     text not null,
  clarity_score  integer not null check (clarity_score between 0 and 100),
  feedback       text,
  strengths      jsonb not null default '[]',
  gaps           jsonb not null default '[]',
  created_at     timestamptz not null default now()
);

create index if not exists idx_students_parent_id on students(parent_id);
create index if not exists idx_homework_sessions_student_id on homework_sessions(student_id);
create index if not exists idx_homework_sessions_status_created_at on homework_sessions(status, created_at);
create index if not exists idx_session_steps_session_id on session_steps(session_id);
create index if not exists idx_teach_it_back_attempts_session_id on teach_it_back_attempts(session_id);
```

- [ ] **Step 2: Commit**

```bash
cd "d:/nmimes mobile app/nmimes-backend"
git init 2>/dev/null; git add supabase/migrations/0001_core_schema.sql
git commit -m "Add core Supabase schema migration (parents, students, sessions, steps, teach-it-back)"
```

(If this directory isn't a git repo yet, `git init` creates one — confirm with the user before
running `git init` if unexpected. If it's already a repo, skip straight to `add`/`commit`.)

---

### Task 2: Migration file — updated_at triggers

**Files:**
- Create: `nmimes-backend/supabase/migrations/0002_updated_at_triggers.sql`

**Interfaces:**
- Consumes: tables `parents`, `students`, `homework_sessions` from Task 1.
- Produces: trigger function `set_updated_at()` reused by three triggers so `updated_at` always
  reflects the last write, matching what the FastAPI `update_rows` helper expects to be able to
  rely on for freshness (it does not set `updated_at` itself).

- [ ] **Step 1: Write the trigger migration**

```sql
-- nmimes-backend/supabase/migrations/0002_updated_at_triggers.sql

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_parents_updated_at on parents;
create trigger trg_parents_updated_at
  before update on parents
  for each row execute function set_updated_at();

drop trigger if exists trg_students_updated_at on students;
create trigger trg_students_updated_at
  before update on students
  for each row execute function set_updated_at();

drop trigger if exists trg_homework_sessions_updated_at on homework_sessions;
create trigger trg_homework_sessions_updated_at
  before update on homework_sessions
  for each row execute function set_updated_at();
```

- [ ] **Step 2: Commit**

```bash
cd "d:/nmimes mobile app/nmimes-backend"
git add supabase/migrations/0002_updated_at_triggers.sql
git commit -m "Add updated_at triggers for parents, students, homework_sessions"
```

---

### Task 3: Migration file — Row Level Security policies

**Files:**
- Create: `nmimes-backend/supabase/migrations/0003_rls_policies.sql`

**Interfaces:**
- Consumes: tables from Task 1.
- Produces: RLS enabled + policies on all 5 tables, scoped via `auth.uid()` matching
  `parents.id`, matching the spec's "Row Level Security" section exactly.

- [ ] **Step 1: Write the RLS migration**

```sql
-- nmimes-backend/supabase/migrations/0003_rls_policies.sql

alter table parents enable row level security;
alter table students enable row level security;
alter table homework_sessions enable row level security;
alter table session_steps enable row level security;
alter table teach_it_back_attempts enable row level security;

-- parents: a parent can only see/modify their own row
create policy parents_self_select on parents
  for select using (auth.uid() = id);
create policy parents_self_update on parents
  for update using (auth.uid() = id);
create policy parents_self_insert on parents
  for insert with check (auth.uid() = id);

-- students: owned via parent_id
create policy students_owner_select on students
  for select using (
    exists (select 1 from parents p where p.id = students.parent_id and p.id = auth.uid())
  );
create policy students_owner_all on students
  for all using (
    exists (select 1 from parents p where p.id = students.parent_id and p.id = auth.uid())
  ) with check (
    exists (select 1 from parents p where p.id = students.parent_id and p.id = auth.uid())
  );

-- homework_sessions: owned via students.parent_id
create policy homework_sessions_owner_all on homework_sessions
  for all using (
    exists (
      select 1 from students s
      join parents p on p.id = s.parent_id
      where s.id = homework_sessions.student_id and p.id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from students s
      join parents p on p.id = s.parent_id
      where s.id = homework_sessions.student_id and p.id = auth.uid()
    )
  );

-- session_steps: owned via homework_sessions -> students.parent_id
create policy session_steps_owner_all on session_steps
  for all using (
    exists (
      select 1 from homework_sessions hs
      join students s on s.id = hs.student_id
      join parents p on p.id = s.parent_id
      where hs.id = session_steps.session_id and p.id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from homework_sessions hs
      join students s on s.id = hs.student_id
      join parents p on p.id = s.parent_id
      where hs.id = session_steps.session_id and p.id = auth.uid()
    )
  );

-- teach_it_back_attempts: owned via homework_sessions -> students.parent_id
create policy teach_it_back_attempts_owner_all on teach_it_back_attempts
  for all using (
    exists (
      select 1 from homework_sessions hs
      join students s on s.id = hs.student_id
      join parents p on p.id = s.parent_id
      where hs.id = teach_it_back_attempts.session_id and p.id = auth.uid()
    )
  ) with check (
    exists (
      select 1 from homework_sessions hs
      join students s on s.id = hs.student_id
      join parents p on p.id = s.parent_id
      where hs.id = teach_it_back_attempts.session_id and p.id = auth.uid()
    )
  );
```

- [ ] **Step 2: Commit**

```bash
cd "d:/nmimes mobile app/nmimes-backend"
git add supabase/migrations/0003_rls_policies.sql
git commit -m "Add RLS policies scoping all tables to the owning parent"
```

---

### Task 4: Apply migrations to the Supabase project

**Files:**
- None created — this task runs the migrations against the real Supabase project referenced by
  `SUPABASE_URL/SUPABASE_SERVICE_ROLE_KEY` in `nmimes-backend/nmimes-api/.env`.

**Interfaces:**
- Consumes: migration files from Tasks 1–3.
- Produces: live tables in the Supabase project, verified in Task 5.

- [ ] **Step 1: Confirm Supabase project link**

Check whether the Supabase CLI is already linked to a project:

```bash
cd "d:/nmimes mobile app/nmimes-backend"
supabase status
```

If this errors with "not linked" or the CLI isn't installed, **stop and ask the user** for their
Supabase project ref (or ask them to run `supabase link --project-ref <ref>` themselves) rather
than guessing or creating a new project — creating/linking a Supabase project is a
user-authorization decision, not something to do silently.

- [ ] **Step 2: Apply migrations**

```bash
supabase db push
```

Expected output: lists `0001_core_schema.sql`, `0002_updated_at_triggers.sql`,
`0003_rls_policies.sql` as applied, no errors.

If `supabase db push` isn't available (CLI not linked / user prefers manual), fall back to: open
the Supabase SQL editor for the project and run the three files' contents in order, reporting
each result to the user before proceeding to the next.

---

### Task 5: Verification script — constraints and RLS behave correctly

**Files:**
- Create: `nmimes-backend/scripts/verify_schema.py`

**Interfaces:**
- Consumes: `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY` from `nmimes-backend/nmimes-api/.env`
  (loaded via `python-dotenv`, already a transitive dependency of `pydantic-settings`).
- Produces: a standalone script (not part of the FastAPI app) that inserts a throwaway parent →
  student → homework_session → session_step → teach_it_back_attempt chain via the service-role
  REST API, asserts each insert succeeds and foreign keys resolve, then deletes the parent row
  (cascades clean up the rest) and asserts the cascade worked.

- [ ] **Step 1: Write the verification script**

```python
# nmimes-backend/scripts/verify_schema.py
"""One-off script to verify the Supabase schema migration applied correctly.

Run manually after `supabase db push`: python scripts/verify_schema.py
Requires SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in nmimes-api/.env.
Uses a fake auth.users id, so this only validates schema shape/constraints/cascades,
not RLS policies (RLS requires a real authenticated session to exercise).
"""

import asyncio
import sys
import uuid
from pathlib import Path

import httpx
from dotenv import load_dotenv

load_dotenv(Path(__file__).parent.parent / "nmimes-api" / ".env")

import os

SUPABASE_URL = os.environ["SUPABASE_URL"]
SERVICE_ROLE_KEY = os.environ["SUPABASE_SERVICE_ROLE_KEY"]

HEADERS = {
    "apikey": SERVICE_ROLE_KEY,
    "Authorization": f"Bearer {SERVICE_ROLE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=representation",
}


async def main() -> None:
    async with httpx.AsyncClient(base_url=f"{SUPABASE_URL}/rest/v1", headers=HEADERS) as client:
        # NOTE: parents.id must reference an existing auth.users row via FK.
        # This script expects a real Supabase Auth test user's UUID to be passed as argv[1].
        if len(sys.argv) < 2:
            print("Usage: python verify_schema.py <existing-auth-users-uuid>")
            sys.exit(1)
        auth_user_id = sys.argv[1]

        print("1. Inserting parent...")
        resp = await client.post(
            "/parents",
            json={
                "id": auth_user_id,
                "first_name": "Test",
                "last_name": "Parent",
                "email": "test-parent@example.com",
            },
        )
        resp.raise_for_status()
        parent = resp.json()[0]
        assert parent["subscription_status"] == "free", "default subscription_status should be 'free'"
        print(f"   OK parent id={parent['id']}")

        print("2. Inserting student...")
        resp = await client.post(
            "/students",
            json={
                "parent_id": parent["id"],
                "name": "Test Student",
                "access_code_hash": "dummy-bcrypt-hash",
            },
        )
        resp.raise_for_status()
        student = resp.json()[0]
        assert student["points_balance"] == 0, "default points_balance should be 0"
        print(f"   OK student id={student['id']}")

        print("3. Inserting homework_session...")
        resp = await client.post(
            "/homework_sessions",
            json={"student_id": student["id"], "ocr_text": "2x + 5 = 15"},
        )
        resp.raise_for_status()
        session = resp.json()[0]
        assert session["status"] == "active", "default status should be 'active'"
        print(f"   OK session id={session['id']}")

        print("4. Inserting session_step...")
        resp = await client.post(
            "/session_steps",
            json={"session_id": session["id"], "step_number": 1, "question": "What operation isolates x?"},
        )
        resp.raise_for_status()
        step = resp.json()[0]
        print(f"   OK step id={step['id']}")

        print("5. Rejecting invalid tier value...")
        resp = await client.post(
            "/session_steps",
            json={
                "session_id": session["id"],
                "step_number": 2,
                "question": "test",
                "tier": "not-a-real-tier",
            },
        )
        assert resp.status_code >= 400, "invalid tier should be rejected by CHECK constraint"
        print(f"   OK rejected with status {resp.status_code}")

        print("6. Inserting teach_it_back_attempt...")
        resp = await client.post(
            "/teach_it_back_attempts",
            json={"session_id": session["id"], "transcript": "x equals five", "clarity_score": 80},
        )
        resp.raise_for_status()
        attempt = resp.json()[0]
        print(f"   OK attempt id={attempt['id']}")

        print("7. Deleting parent (should cascade)...")
        resp = await client.delete(f"/parents?id=eq.{parent['id']}")
        resp.raise_for_status()

        resp = await client.get(f"/students?id=eq.{student['id']}")
        resp.raise_for_status()
        assert resp.json() == [], "student should have been cascade-deleted with parent"
        print("   OK cascade delete verified")

        print("\nAll schema checks passed.")


if __name__ == "__main__":
    asyncio.run(main())
```

- [ ] **Step 2: Create a throwaway Supabase Auth test user to get a valid `auth.users` id**

Ask the user for a real (test) email, or use the Supabase dashboard's Auth panel to create one
manually, since `auth.users` rows can't be created by this script directly (they're managed by
Supabase Auth, not plain REST inserts). Note the resulting UUID for Step 3.

- [ ] **Step 3: Run the verification script**

```bash
cd "d:/nmimes mobile app/nmimes-backend"
source nmimes-api/.venv/Scripts/activate
python scripts/verify_schema.py <the-auth-users-uuid-from-step-2>
```

Expected output: all 7 numbered checks print `OK ...`, ending with `All schema checks passed.`

- [ ] **Step 4: Commit**

```bash
git add scripts/verify_schema.py
git commit -m "Add schema verification script for Supabase migration"
```

---

## Self-Review Notes

- **Spec coverage:** all 5 tables, all columns, all indexes, RLS policies, and the "no plaintext
  PIN" constraint (enforced by never inserting one — `access_code_hash` is documented as
  bcrypt-hashed, hashing itself happens in sub-project B/C where the access-code endpoint lives)
  are covered by Tasks 1–3. Points-balance defaulting to 0 and incrementing later (in FastAPI, per
  spec) is covered by the column default in Task 1; the increment logic itself is explicitly
  out of scope for this plan (it's FastAPI service-layer work, part of sub-project B).
- **Placeholder scan:** none found — all SQL is complete and runnable, the verification script is
  fully implemented.
- **Type consistency:** table/column names match the spec exactly; verification script's JSON
  payloads use the same field names as the migration.
