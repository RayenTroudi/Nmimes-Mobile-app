# Supabase Schema Design (Sub-project A)

Date: 2026-07-02

## Context

The Nmimes FastAPI backend (`nmimes-backend/nmimes-api/`) already implements routes for homework
sessions, teach-it-back, leaderboard, and Stripe webhooks, but no Supabase tables exist yet. The
Flutter app (`nmimes/`) is a UI-only prototype with no backend wiring at all.

This is sub-project A of a four-part effort to connect everything:

- **A (this spec)** — Supabase schema + relations
- **B** — FastAPI auth verification (Supabase JWT check on protected routes)
- **C** — Flutter networking layer + Dart models + Supabase Auth screen wiring
- **D** — Flutter feature wiring (snap → session SSE, teach-it-back, leaderboard)

## Scope

The Flutter UI implies a much larger domain (rewards/badges, solo + PVP challenges, study rooms,
saved formulas, ai_chat) than the existing FastAPI routes cover. This spec is scoped to **only**
what's needed to make the four existing routes (`/sessions/*`, `/teach-it-back/*`,
`/leaderboard/weekly`, `/webhooks/stripe`) work end-to-end with real auth and real data. Rewards,
challenges, study rooms, and saved formulas are explicitly out of scope and will get their own
specs later.

One exception: `students.points_balance` is included now because it's tightly coupled to session
completion (the snap-homework success screen shows "+50 points earned" as part of the core loop,
not the separate rewards subsystem).

## Account model

- One Supabase Auth user (`auth.users`) = one parent. Parents authenticate via Supabase Auth
  (email + OTP).
- Children are **not** separate Supabase Auth identities. A child is a `students` row owned by a
  parent, with its own 4-digit access code (bcrypt-hashed, never stored plaintext).
- Child sign-in on a device works by verifying the entered PIN against the hash of one of the
  signed-in parent's students, then storing the selected `student_id` locally. All API calls from
  that device still use the parent's Supabase JWT; the backend scopes every query by
  `student_id` ownership (a student row must belong to the requesting parent). There is no
  separate child token type.
- Access codes are 4-digit PINs. Two different parents may reuse the same PIN for their children —
  uniqueness is not enforced globally or even at the database level (hashes are salted, so a
  uniqueness constraint on the hash column would be meaningless). Verification works by fetching
  the requesting parent's students and checking the submitted PIN against each one's hash.

## Tables

```sql
-- parents: one row per Supabase Auth user
create table parents (
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

-- students: child profiles owned by a parent
create table students (
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

-- homework_sessions: one Socratic tutoring session per snapped/entered problem
create table homework_sessions (
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

-- session_steps: each Socratic question/answer/evaluation exchange within a session
create table session_steps (
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

-- teach_it_back_attempts: Feynman-technique explanation attempts tied to a session
create table teach_it_back_attempts (
  id             uuid primary key default gen_random_uuid(),
  session_id     uuid not null references homework_sessions(id) on delete cascade,
  transcript     text not null,
  clarity_score  integer not null check (clarity_score between 0 and 100),
  feedback       text,
  strengths      jsonb not null default '[]',
  gaps           jsonb not null default '[]',
  created_at     timestamptz not null default now()
);
```

## Relations

`auth.users` (Supabase Auth) 1—1 `parents` 1—N `students` 1—N `homework_sessions` 1—N
`session_steps`, and `homework_sessions` 1—N `teach_it_back_attempts`.

## Indexes

- `students(parent_id)`
- `homework_sessions(student_id)`
- `homework_sessions(status, created_at)` — supports the weekly leaderboard query
- `session_steps(session_id)`
- `teach_it_back_attempts(session_id)`

## Points

`students.points_balance` increments by a fixed amount in two places, both handled explicitly in
FastAPI (not a DB trigger, for auditability and to keep the increment amount in application code
next to the business logic that decides it):

- When a `homework_sessions.status` transition to `completed` happens in
  `POST /sessions/{id}/step` (already the point where the 4-tier evaluation signals completion).
- When a `teach_it_back_attempts` row is inserted in `POST /teach-it-back/{session_id}`.

Point amounts are a plain constant in the FastAPI service layer for now (matching the UI's
hardcoded "+50 points" mock), not configurable per-problem-difficulty — that's rewards-subsystem
scope.

## Row Level Security

RLS is enabled on all five tables as defense-in-depth, even though FastAPI always uses the
service-role key (which bypasses RLS) for all current access. This protects against any future
path where the Flutter app queries Supabase directly.

- `parents`: a row is readable/writable only where `auth.uid() = parents.id`.
- `students`, `homework_sessions`, `session_steps`, `teach_it_back_attempts`: readable/writable
  only where the row's `student_id` (or `session_id` chain) resolves to a `students.parent_id`
  matching `auth.uid()`.

## Out of scope (future specs)

- Rewards, badges, coupons, saved formulas
- Solo and PVP challenges, streaks, invite codes
- Study rooms (peer chat, room membership)
- ai_chat as a distinct freeform-chat feature (current UI reuses the same Socratic-session pattern
  already covered by `homework_sessions`/`session_steps`)

## Open questions resolved during brainstorming

- Points included in this pass (see above) — confirmed by user.
- Access code PINs may collide across different parents' children — confirmed by user, no
  uniqueness constraint needed.
