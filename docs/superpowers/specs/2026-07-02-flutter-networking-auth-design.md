# Flutter Networking Layer + Auth Screens Design (Sub-project C)

Date: 2026-07-02

## Context

Sub-projects A (Supabase schema) and B (FastAPI auth verification) are complete and live-verified.
The Flutter app (`nmimes/`) is still a pure UI prototype: no networking, no auth, no Dart models,
no Supabase integration at all — confirmed by earlier exploration and by the original design spec's
explicit note ("no real camera, no real backend, no real auth — all interactions navigate between
screens only").

This is sub-project C of the four-part effort to connect everything:

- **A (done)** — Supabase schema + relations
- **B (done)** — FastAPI auth verification
- **C (this spec)** — Flutter networking layer + Dart models + Supabase Auth screen wiring
- **D** — Flutter feature wiring (snap → session SSE, teach-it-back, leaderboard)

## Scope

Wire the Flutter app's existing auth-related screens to real Supabase Auth and the FastAPI backend
built in sub-project B, so a parent can sign up, verify their email, sign in, add a child, and a
child can sign in with their access code and land on the app's home shell. Feature screens (snap
homework, teach-it-back, leaderboard, AI chat, challenges, study rooms, rewards) are explicitly out
of scope — that's sub-project D.

## Auth model mapping

The existing Figma-designed screens collect an email + self-chosen 4-digit PIN for parents
(`parent_sign_up_screen.dart`, `parent_access_code_screen.dart`), with a separate OTP screen used
for signup email verification and for a forgot/reset-PIN flow. This maps directly onto Supabase's
standard **email + password** auth, using the PIN as the password:

- **Sign up**: `supabase.auth.signUp(email, password: pin)` — triggers Supabase's built-in signup
  email OTP, verified by the existing `parent_otp_screen.dart` via
  `supabase.auth.verifyOTP(email, token, type: OtpType.signup)`.
- **Sign in**: `supabase.auth.signInWithPassword(email, password: pin)`.
- **Forgot/reset PIN**: `supabase.auth.resetPasswordForEmail(email)` → OTP verify (reusing the
  existing forgot/reset screens) → `supabase.auth.updateUser(UserAttributes(password: newPin))`.

The 4-digit PIN is kept as-is (matches the existing UI/UX exactly; Supabase's server-side
rate-limiting on auth attempts is the primary defense). Strengthening PIN length/complexity later
is a validation-rule change, not an architecture change, and is explicitly deferred.

Children are **not** separate Supabase Auth identities (per sub-project A/B's account model): a
child signs in on a device by submitting their 4-digit access code against `POST
/students/verify-access-code` (using the *parent's* JWT, which must already be active on the
device), and the returned `student_id` is persisted locally as the "active student" for that
device.

## New dependencies

- `dio` — HTTP client for calling the FastAPI backend, chosen over `http` for its interceptor
  support (auto-attaching the Supabase JWT to every request in one place).
- `supabase_flutter` — official Supabase Auth SDK (OTP flow, password auth, session persistence,
  automatic token refresh) rather than hand-rolling these against the raw Auth REST API.
- `flutter_secure_storage` — persists the selected `student_id` across app restarts (session tokens
  themselves are persisted by `supabase_flutter` internally).
- `provider` — state management for `AuthState`. The codebase's only existing state-management
  precedent (`lib/providers/locale_provider.dart`) is a hand-rolled `InheritedWidget` +
  `ValueNotifier`, not the `provider` package — `provider` is added as a new, small, officially
  Flutter-team-maintained dependency because `AuthState` has real async complexity (Supabase's
  `onAuthStateChange` stream, secure-storage reads) that `ChangeNotifierProvider` handles cleanly.
  `locale_provider.dart` is explicitly **not** migrated to `provider` — that's out of scope; the two
  patterns coexist.

## New files

- `lib/services/api_client.dart` — a `dio` instance configured with the FastAPI base URL (via
  `--dart-define=API_BASE_URL`, so dev/staging/prod can point at different backends without a code
  change), an interceptor that reads the current Supabase session's access token and attaches
  `Authorization: Bearer <token>` to every outgoing request, and typed methods wrapping the
  sub-project-B endpoints: `upsertParent`, `createStudent`, `verifyAccessCode`, plus placeholders
  for the sub-project-D endpoints (`startSession`, `submitStep`, `getSession`, `teachItBack`,
  `weeklyLeaderboard`) that D will implement — C only needs to establish the client shape.
- `lib/services/supabase_service.dart` — a thin wrapper around
  `Supabase.instance.client.auth` (`signUp`, `signInWithPassword`, `verifyOTP`,
  `resetPasswordForEmail`, `updateUser`, `signOut`). Isolates the SDK so screens never call
  `Supabase.instance` directly — keeps the SDK swappable and screens testable.
- `lib/providers/auth_state.dart` — `ChangeNotifier` exposing `parent` (the cached
  `POST /parents/me` response), `selectedStudentId` (backed by `flutter_secure_storage`), and
  `isAuthenticated` (derived from the current Supabase session). Subscribes to
  `Supabase.instance.client.auth.onAuthStateChange` to stay in sync with sign-in/sign-out/refresh
  events.
- `lib/models/parent.dart` — `Parent` class mirroring `ParentResponse` from the FastAPI backend
  (`id`, `firstName`, `lastName`, `email`, `subscriptionStatus`, `createdAt`, `updatedAt`), with
  `fromJson`/`toJson`.
- `lib/models/student.dart` — `Student` class mirroring `StudentResponse` (`id`, `parentId`,
  `name`, `username`, `grade`, `interest`, `pointsBalance`, `avatarUrl`, `createdAt`, `updatedAt`),
  with `fromJson`/`toJson`.

## Modified files

- `lib/main.dart` — call `Supabase.initialize(url: ..., anonKey: ...)` before `runApp`; wrap
  `MaterialApp` with `ChangeNotifierProvider<AuthState>` (added alongside the existing
  `LocaleProvider` wiring, not replacing it).
- `lib/screens/splash/splash_screen.dart` — after the existing ~4s animation sequence (unchanged),
  replace the unconditional `Navigator.pushReplacementNamed(context, '/onboarding')` with a check
  against `AuthState`: signed in + a student already selected → `/home`; signed in + no student
  selected → the child/student picker step of the existing flow; signed out → `/onboarding`
  (current behavior, unchanged for first-time users).
- `lib/screens/auth/parent_sign_up_screen.dart` — submit handler calls
  `supabaseService.signUp(email, password: pin)`; on success, navigate to `/parent-otp` passing the
  email; on failure, surface the error using whatever inline error-display pattern the screen's
  Figma design already includes (no new error UI pattern introduced).
- `lib/screens/auth/parent_otp_screen.dart` — verify handler calls
  `supabaseService.verifyOTP(email, token, type: OtpType.signup)`; **only after** OTP verification
  succeeds (not immediately after `signUp()`, since there's no active session and the email isn't
  confirmed until OTP verification completes) does it call `apiClient.upsertParent(firstName,
  lastName)` to create the `parents` row; navigates to `/parent-setup` (the existing add-child flow)
  on success.
- `lib/screens/auth/parent_access_code_screen.dart` — submit handler calls
  `supabaseService.signInWithPassword(email, password: pin)`; navigates to `/parents-view` (existing
  route) on success.
- `lib/screens/auth/parent_forgot_access_code_screen.dart` and
  `parent_reset_access_code_screen.dart` — wired to `resetPasswordForEmail` → OTP verify (type
  `recovery`) → `updateUser(password: newPin)`, reusing the existing screen flow/UI as-is.
- `lib/screens/auth/child_access_code_screen.dart` — submit handler calls
  `apiClient.verifyAccessCode(pin)`; on success, stores the returned `student_id` via
  `AuthState.selectedStudentId =`, navigates to `/home`; on 404 (no match) or 429 (rate limited),
  surfaces the corresponding inline error.
- `lib/screens/auth/parent_profile_setup_screen.dart` (existing "add child" flow) — submit handler
  calls `apiClient.createStudent(name, grade, interest, accessCode)` using the fields the screen
  already collects; the existing "add another child?" dialog loop is unchanged, just backed by real
  calls now.

## Error handling

Each screen's existing submit handler gains a try/catch around its new network call. `DioException`
(FastAPI errors: 401/403/404/429/422/500) and Supabase's `AuthException` (invalid credentials, rate
limited, etc.) are both caught and mapped to a short user-facing message, displayed using whatever
inline error-text pattern the screen's Figma design already provides. No new global error-display
widget or pattern is introduced in this sub-project.

## Testing

No Flutter test suite exists yet in this repo beyond the default `flutter_test` scaffold
(`test/widget_test.dart`, unmodified default counter test). This sub-project does not add automated
widget/integration tests — verification is manual: running the app (`flutter run`), exercising the
sign-up → OTP → sign-in → add-child → child-access-code path against the real, already-verified
Supabase project and FastAPI backend, confirming each screen transition and that the created
`parents`/`students` rows appear correctly in Supabase. This matches how sub-projects A and B were
verified (live, against real infrastructure, not mocked).

## Out of scope (sub-project D)

- Snap-homework capture → `POST /sessions/start` SSE wiring
- Teach-it-back screen wiring to `POST /teach-it-back/{session_id}`
- Leaderboard screen wiring to `GET /leaderboard/weekly`
- Any other feature screen (AI chat, challenges, study rooms, rewards, saved formulas) — these
  remain mocked UI, unchanged by this sub-project, consistent with sub-project A's schema scope
  decision to leave those subsystems for later, separately-scoped work.
