# Profile Screen: Layout Fixes + Redis/Supabase Wiring

Date: 2026-07-23

## Context

The student profile screen (`nmimes/lib/screens/profile/profile_screen.dart`) is currently a
static mock: the name (`'John'`), earned points (`'150'`), and plan (`'Free'`) are all hardcoded,
and "Log Out" only navigates away without ending the session. Two layout defects also exist:

1. The name `Text` lives *inside* the `SingleChildScrollView`, so it scrolls away from the avatar
   (which is pinned in a `Stack` overlay). The name should stay fixed alongside the avatar.
2. The Help and Log Out row labels use `AlignmentDirectional.centerStart` (left-aligned). They
   should be horizontally centered.

The backend (`nmimes-backend/nmimes-api/`) is live and fully verified against real Supabase
(`vebmbkbmmglgpwwmwevk`) and real Upstash Redis (`working-magpie-111631.upstash.io`). It exposes
sessions, teach-it-back, leaderboard, students (create / verify-access-code), parents, and Stripe
webhook routes — but **no read-only "get this student's profile" endpoint**. Redis is used there
only for the leaderboard read-through cache and access-code rate limiting.

The Flutter app currently talks to Supabase **directly** (via `ApiClient` RPCs and
`SupabaseService` auth) and has never called the FastAPI backend, though `dio` is already a
dependency in `pubspec.yaml`.

## Account model recap (relevant to this screen)

A signed-in device holds **one parent Supabase JWT** plus a locally-stored selected `student_id`
(`AuthState.selectedStudentId`, in `flutter_secure_storage`). The profile screen shows that
selected student. All backend calls authenticate with the parent's JWT; the backend scopes every
query by student→parent ownership. There is no separate child token.

## Scope

In scope:

- Profile screen layout fixes (fixed name, centered Help/Log Out labels).
- New FastAPI `GET /students/{id}/profile` endpoint: Supabase read + Redis read-through cache.
- New Flutter Dio HTTP client that calls the endpoint with the parent's Supabase access token.
- Profile screen loads name / points / avatar from the endpoint, with loading + error fallback.
- Log Out performs a full sign-out (Supabase signOut + clear selected student + navigate to root).

Explicitly out of scope (confirmed with user):

- **Current Plan** stays hardcoded `'Free'` — no `parents.subscription_status` read.
- No cache invalidation on points change — **60-second TTL only** (points may lag up to 60s).
- No changes to how points are earned/written (session completion, teach-it-back) — read only.

## Part 1 — Profile layout fixes

File: `lib/screens/profile/profile_screen.dart`.

- **Fixed name:** Move the name `Text` out of the `SingleChildScrollView` and into the pinned
  `Positioned` avatar block in the `Stack`, so it renders in the same non-scrolling layer as the
  avatar (placed directly below the avatar, left-aligned to the screen's 20px gutter). Adjust the
  scroll view's top padding so the first card (Earned Points) begins below the fixed name rather
  than overlapping it.
- **Centered labels:** In the Help row and the Log Out row, change
  `alignment: AlignmentDirectional.centerStart` → `alignment: Alignment.center`.

No color, size, or spacing changes beyond what's needed to keep the fixed name from overlapping the
scrolling cards.

## Part 2 — FastAPI `GET /students/{id}/profile`

File: `nmimes-backend/nmimes-api/routers/students.py` (new route on the existing router).

Mirrors the leaderboard read-through cache pattern (`routers/leaderboard.py`) and the existing
ownership-check pattern (`services/auth.verify_student_ownership`).

```
GET /students/{student_id}/profile
  Depends: parent_id = get_current_parent   # verifies Supabase JWT -> parent UUID
  1. verify_student_ownership(parent_id, student_id)   # 403 if not this parent's student
  2. cache_get(f"student_profile:{student_id}")
       -> if hit: return {"cached": True, "profile": <cached dict>}
  3. miss:
       row = supabase_client.select_one("students", {"id": f"eq.{student_id}"})
       if row is None: raise 404 "Student not found"
       profile = {"id", "name", "points_balance", "avatar_url"}   # subset of the row
       cache_set(f"student_profile:{student_id}", profile, ex_seconds=60)
       return {"cached": False, "profile": profile}
```

- TTL constant: `PROFILE_CACHE_TTL_SECONDS = 60`.
- Cache key prefix: `student_profile:`.
- Response shape is stable in both cache-hit and cache-miss cases: a top-level `cached` boolean
  plus a `profile` object. The Flutter client only reads `profile`.
- `avatar_url` may be `null`.
- Reuses `select_one`, `cache_get`, `cache_set` — no new service helpers required.

Ownership check ordering: ownership is verified **before** touching the cache, so a non-owning
parent can never read another student's cached profile.

**403 vs 404 note:** the existing `verify_student_ownership` selects on `id` AND `parent_id`
together, so it returns `None` — and the endpoint raises **403** — for *both* a non-owned student
and a wholly unknown id (you cannot prove ownership of something that does not exist). The endpoint's
own 404 branch is therefore reachable only in the narrow TOCTOU case where the row is deleted between
the ownership check and the profile fetch; it is kept as a race guard. The Flutter client treats any
error status as "keep fallback values," so this distinction does not affect the UI.

## Part 3 — Flutter Dio HTTP client

New file: `lib/services/api_http_client.dart`.

- Base URL: `const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000')`
  (`10.0.2.2` is the Android emulator's alias for the host's `localhost`; overridable at build time
  via `--dart-define`, mirroring how `SUPABASE_URL` is handled in `main.dart`).
- A single `Dio` instance with a request interceptor that reads
  `Supabase.instance.client.auth.currentSession?.accessToken` and, when present, sets
  `Authorization: Bearer <token>`.
- One method:
  `Future<StudentProfile> fetchStudentProfile(String studentId)` →
  `GET /students/$studentId/profile`, parses `response.data['profile']` into `StudentProfile`.
- Errors: on `DioException` / non-2xx, throw a small typed `ApiHttpException(statusCode, message)`
  so the UI can distinguish "not signed in / 401" from other failures and fall back gracefully.

New model: `lib/models/student_profile.dart`.

```
class StudentProfile {
  final String id;
  final String name;
  final int pointsBalance;
  final String? avatarUrl;
  factory StudentProfile.fromJson(Map<String, dynamic> json);
}
```

(Kept separate from the fuller `Student` model because the endpoint returns only this subset.)

## Part 4 — Profile screen data loading + Log Out

File: `lib/screens/profile/profile_screen.dart` (convert `ProfileScreen` to `StatefulWidget`).

- On `initState`: read `context.read<AuthState>().selectedStudentId`. If non-null, call
  `ApiHttpClient().fetchStudentProfile(id)`.
- State: `StudentProfile? _profile; bool _loading; Object? _error;`.
- Rendering:
  - Name: `_profile?.name ?? 'John'` (mock name is the fallback while loading / on error).
  - Points card: pass `_profile?.pointsBalance`; `ProfilePointsCard` gains an optional
    `int? points` param and shows `points?.toString() ?? '150'`.
  - Avatar: if `_profile?.avatarUrl` is a non-empty URL, load it with
    `Image.network(..., errorBuilder: <existing asset fallback>)`; otherwise keep the current
    local asset (`assets/images/nmimes_front.png`).
  - Plan row: unchanged, still `'Free'`.
- Loading state: keep the layout stable; show the fallback text (no jarring spinner over the whole
  screen). A subtle inline treatment is acceptable but not required.
- Error handling: on any failure, keep the fallback values and do not crash. (No error toast
  required for this pass; the screen degrades to the mock values.)

**Log Out** (`_showLogoutDialog`, the "Yes" branch): make the handler async and, in order:

```
await SupabaseService().signOut();
if (context.mounted) context.read<AuthState>().setSelectedStudentId(null);
if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
```

`SupabaseService` and `AuthState` are already available in the app; `AuthState` is provided at the
`MaterialApp` root via `ChangeNotifierProvider`, so `context.read<AuthState>()` resolves.

## Data flow

```
Profile screen (Flutter)
  -> AuthState.selectedStudentId (secure storage)
  -> ApiHttpClient.fetchStudentProfile(id)   [Dio, Authorization: Bearer <parent JWT>]
       -> FastAPI GET /students/{id}/profile
            -> verify_student_ownership (Supabase students table)
            -> Redis cache_get student_profile:{id}   (hit -> return)
            -> Supabase select_one students            (miss)
            -> Redis cache_set (TTL 60s)
       <- { cached, profile: { id, name, points_balance, avatar_url } }
  <- StudentProfile -> render name / points / avatar
```

## Error handling summary

| Failure | Backend | Flutter UI |
|---|---|---|
| No / expired JWT | 401 | Keep fallback mock values; no crash |
| Student not owned by parent OR unknown id | 403 | Keep fallback values |
| Student row deleted mid-request (TOCTOU) | 404 | Keep fallback values |
| Network / server down | 5xx / DioException | Keep fallback values |
| `selectedStudentId == null` | (no call) | Render fallback values |

## Testing

- **Backend:** follow the repo's existing verification style (the SDD progress shows manual live
  verification against real Supabase + Upstash). Verify: owner gets 200 with `profile`; second
  request returns `cached: true`; non-owner gets 403; unknown id gets 404; missing auth gets
  401/422. If a test harness exists it will be used; otherwise manual/live verification is the
  documented pattern for this backend.
- **Flutter:** `flutter analyze` must be clean. A widget test that pumps `ProfileScreen` with a
  faked client and asserts (a) the name/points render from the profile, (b) fallback values render
  when the fetch throws. Log Out wiring verified by asserting `signOut` + `setSelectedStudentId(null)`
  are invoked (via injected fakes).

## Verification limits (stated up front)

The live FastAPI server and a real device/emulator cannot be run in this environment, so true
end-to-end (device → deployed endpoint → Redis/Supabase) verification is the user's to run.
Automated coverage here is `flutter analyze`, Flutter widget tests with faked dependencies, and —
for the backend — code review plus any runnable unit tests.

## Open questions

None outstanding. Plan source (hardcoded Free), cache strategy (60s TTL, no invalidation), API base
URL (dart-define, localhost default), and Log Out behavior (full sign-out) were all confirmed
during brainstorming.
