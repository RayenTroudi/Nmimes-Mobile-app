# Profile Wiring Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the profile screen layout (fixed name, centered button labels) and wire it to real data via a new Redis-cached FastAPI endpoint backed by Supabase, with a full sign-out on Log Out.

**Architecture:** A new `GET /students/{id}/profile` FastAPI route reads the `students` row from Supabase and read-through-caches it in Upstash Redis (60s TTL), scoped by parent→student ownership. A new Flutter Dio client calls it with the parent's Supabase access token; the profile screen (now stateful) renders name/points/avatar from the response, falling back to the existing mock values on any failure. Log Out ends the Supabase session and clears the locally-selected student.

**Tech Stack:** FastAPI + httpx (Supabase REST, Upstash Redis REST), Flutter + Dio + Provider + supabase_flutter.

## Global Constraints

- Backend has **no pytest**; verification uses `starlette.testclient.TestClient` run via the repo venv `python`, plus code review (matches the backend's manual/live verification pattern). Venv python: `nmimes-backend/nmimes-api/.venv/Scripts/python.exe`.
- Redis TTL for the profile cache is **60 seconds** (`PROFILE_CACHE_TTL_SECONDS = 60`); no invalidation on points change.
- Cache key format: `student_profile:{student_id}`.
- Ownership MUST be verified (`verify_student_ownership`) **before** any cache read.
- `verify_student_ownership` returns 403 for both non-owned AND unknown student ids (it filters on `id`+`parent_id` together). The endpoint's 404 branch is a TOCTOU race guard only (row deleted mid-request), not the general "unknown id" path.
- Current Plan stays hardcoded `'Free'` — do not read `parents.subscription_status`.
- Flutter API base URL: `const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000')`.
- Auth header: `Authorization: Bearer <Supabase currentSession.accessToken>`.
- Flutter: `flutter analyze` must be clean; follow the existing widget-test idiom (`ChangeNotifierProvider` + `MaterialApp` + `Supabase.initialize('http://localhost:54321', anonKey:'test-anon-key')`).
- All commits happen on branch `profile-wiring` (already created). Do not touch `main`.
- Commit message trailer for every commit: `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`.

## File Structure

- `nmimes-backend/nmimes-api/routers/students.py` — MODIFY: add `GET /{student_id}/profile`.
- `nmimes-backend/nmimes-api/verify_profile_endpoint.py` — CREATE (temporary, committed): TestClient verification script.
- `nmimes/lib/models/student_profile.dart` — CREATE: lean profile model.
- `nmimes/lib/services/api_http_client.dart` — CREATE: Dio client for the FastAPI backend.
- `nmimes/lib/screens/profile/points_card.dart` — MODIFY: optional `points` param.
- `nmimes/lib/screens/profile/profile_screen.dart` — MODIFY: stateful, load data, fixed name, centered labels, full sign-out.
- `nmimes/test/profile_screen_test.dart` — CREATE: widget tests for render + fallback + logout wiring.

---

## Task 1: Backend profile endpoint (Supabase + Redis read-through)

**Files:**
- Modify: `nmimes-backend/nmimes-api/routers/students.py`
- Test: `nmimes-backend/nmimes-api/verify_profile_endpoint.py` (create)

**Interfaces:**
- Consumes (existing): `services.supabase_client.select_one(table, filters) -> dict|None`; `services.redis_client.cache_get(key) -> Any|None`; `services.redis_client.cache_set(key, value, ex_seconds=None)`; `services.auth.get_current_parent -> UUID` (FastAPI dependency); `services.auth.verify_student_ownership(parent_id: UUID, student_id: UUID)` (raises 403).
- Produces: `GET /students/{student_id}/profile` returning JSON `{"cached": bool, "profile": {"id": str, "name": str, "points_balance": int, "avatar_url": str|None}}`. 403 if not owner, 404 if student missing.

- [ ] **Step 1: Write the failing verification script**

Create `nmimes-backend/nmimes-api/verify_profile_endpoint.py`:

```python
"""Standalone verification for GET /students/{id}/profile using Starlette's
TestClient with all external services monkeypatched. Run with the repo venv:
    .venv/Scripts/python.exe verify_profile_endpoint.py
Exits non-zero on any failed assertion.
"""
import sys
from uuid import UUID

from fastapi.testclient import TestClient

import routers.students as students_router
import services.auth as auth
from main import app

STUDENT_ID = "11111111-1111-1111-1111-111111111111"
OWNER_ID = "22222222-2222-2222-2222-222222222222"
OTHER_ID = "33333333-3333-3333-3333-333333333333"

STUDENT_ROW = {
    "id": STUDENT_ID,
    "parent_id": OWNER_ID,
    "name": "Amina",
    "points_balance": 240,
    "avatar_url": None,
    "created_at": "2026-07-23T00:00:00+00:00",
    "updated_at": "2026-07-23T00:00:00+00:00",
}


def run():
    # Fake auth: pretend the caller is OWNER_ID.
    app.dependency_overrides[auth.get_current_parent] = lambda: UUID(OWNER_ID)

    # Fake ownership: owner passes, anyone else 403.
    async def fake_ownership(parent_id, student_id):
        from fastapi import HTTPException
        if str(parent_id) != OWNER_ID or str(student_id) != STUDENT_ID:
            raise HTTPException(status_code=403, detail="not owner")
    students_router.verify_student_ownership = fake_ownership

    # In-memory fake Redis.
    store = {}

    async def fake_cache_get(key):
        return store.get(key)

    async def fake_cache_set(key, value, ex_seconds=None):
        store[key] = value

    students_router.cache_get = fake_cache_get
    students_router.cache_set = fake_cache_set

    # Fake Supabase select_one.
    calls = {"select_one": 0}

    async def fake_select_one(table, filters, select="*"):
        calls["select_one"] += 1
        if table == "students" and filters.get("id") == f"eq.{STUDENT_ID}":
            return STUDENT_ROW
        return None

    students_router.select_one = fake_select_one

    client = TestClient(app)

    # 1. First call -> cache miss, hits Supabase.
    r1 = client.get(f"/students/{STUDENT_ID}/profile")
    assert r1.status_code == 200, r1.text
    body1 = r1.json()
    assert body1["cached"] is False, body1
    assert body1["profile"]["name"] == "Amina", body1
    assert body1["profile"]["points_balance"] == 240, body1
    assert body1["profile"]["avatar_url"] is None, body1
    assert body1["profile"]["id"] == STUDENT_ID, body1
    assert calls["select_one"] == 1, calls

    # 2. Second call -> cache hit, does NOT hit Supabase again.
    r2 = client.get(f"/students/{STUDENT_ID}/profile")
    assert r2.status_code == 200, r2.text
    body2 = r2.json()
    assert body2["cached"] is True, body2
    assert body2["profile"]["name"] == "Amina", body2
    assert calls["select_one"] == 1, calls  # unchanged

    # 3. Non-owner -> 403.
    app.dependency_overrides[auth.get_current_parent] = lambda: UUID(OTHER_ID)
    r3 = client.get(f"/students/{STUDENT_ID}/profile")
    assert r3.status_code == 403, r3.text

    # 4. Unknown student -> 404 (owner of a non-existent id).
    app.dependency_overrides[auth.get_current_parent] = lambda: UUID(OWNER_ID)
    unknown = "44444444-4444-4444-4444-444444444444"

    async def owns_anything(parent_id, student_id):
        return None
    students_router.verify_student_ownership = owns_anything
    r4 = client.get(f"/students/{unknown}/profile")
    assert r4.status_code == 404, r4.text

    print("OK: profile endpoint verification passed")


if __name__ == "__main__":
    try:
        run()
    except AssertionError as exc:
        print(f"FAILED: {exc}")
        sys.exit(1)
```

- [ ] **Step 2: Run the script to verify it fails**

Run (from `nmimes-backend/nmimes-api`):
`.venv/Scripts/python.exe verify_profile_endpoint.py`
Expected: FAIL — the route does not exist yet, first assertion gets `404` on `/students/{id}/profile` (FastAPI returns 404 for an undefined path), so `assert r1.status_code == 200` fails with "FAILED: 404 ...". (If instead it errors on import of a name, that's still a failing run — proceed to implement.)

- [ ] **Step 3: Add the endpoint**

In `nmimes-backend/nmimes-api/routers/students.py`, add the imports for the cache helpers at the top (next to the existing `from services.redis_client import increment_with_expiry`):

```python
from services.redis_client import cache_get, cache_set, increment_with_expiry
```

Add these constants near the existing `RATE_LIMIT_*` constants:

```python
PROFILE_CACHE_TTL_SECONDS = 60
PROFILE_CACHE_KEY_PREFIX = "student_profile:"
```

Add the route at the end of the file:

```python
@router.get("/{student_id}/profile")
async def get_student_profile(
    student_id: UUID, parent_id: UUID = Depends(get_current_parent)
) -> dict:
    # Ownership is checked before any cache read so a non-owner can never
    # read another student's cached profile.
    await verify_student_ownership(parent_id, student_id)

    cache_key = f"{PROFILE_CACHE_KEY_PREFIX}{student_id}"
    cached = await cache_get(cache_key)
    if cached is not None:
        return {"cached": True, "profile": cached}

    row = await select_one(STUDENTS_TABLE, filters={"id": f"eq.{student_id}"})
    if row is None:
        raise HTTPException(status_code=404, detail="Student not found")

    profile = {
        "id": row["id"],
        "name": row["name"],
        "points_balance": row["points_balance"],
        "avatar_url": row.get("avatar_url"),
    }
    await cache_set(cache_key, profile, ex_seconds=PROFILE_CACHE_TTL_SECONDS)
    return {"cached": False, "profile": profile}
```

Add the required imports if not already present in the file's import block:
- `verify_student_ownership` — add to the existing `from services.auth import get_current_parent` line so it reads `from services.auth import get_current_parent, verify_student_ownership`.
- `select_one` — add to the existing `from services import supabase_client` usage. The file currently uses `supabase_client.insert_row` / `supabase_client.select_rows`. For the verification script's monkeypatch of `students_router.select_one` to take effect, import the name directly: add `from services.supabase_client import select_one` to the imports. (Leave the existing `from services import supabase_client` line intact — `create_student` and `verify_student_access_code` still use it.)

- [ ] **Step 4: Run the script to verify it passes**

Run (from `nmimes-backend/nmimes-api`):
`.venv/Scripts/python.exe verify_profile_endpoint.py`
Expected: prints `OK: profile endpoint verification passed`, exit code 0.

- [ ] **Step 5: Commit**

```bash
git add nmimes-backend/nmimes-api/routers/students.py nmimes-backend/nmimes-api/verify_profile_endpoint.py
git commit -m "$(cat <<'EOF'
Add GET /students/{id}/profile with Redis read-through cache

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: Flutter StudentProfile model

**Files:**
- Create: `nmimes/lib/models/student_profile.dart`
- Test: covered by Task 5's widget test (model is trivial; a dedicated unit test is optional and folded in here as a self-check).

**Interfaces:**
- Produces: `class StudentProfile { final String id; final String name; final int pointsBalance; final String? avatarUrl; StudentProfile({...}); factory StudentProfile.fromJson(Map<String, dynamic> json); }`.

- [ ] **Step 1: Create the model**

Create `nmimes/lib/models/student_profile.dart`:

```dart
// nmimes/lib/models/student_profile.dart
/// Lean read-model for the profile screen, matching the `profile` object
/// returned by the FastAPI `GET /students/{id}/profile` endpoint.
class StudentProfile {
  final String id;
  final String name;
  final int pointsBalance;
  final String? avatarUrl;

  const StudentProfile({
    required this.id,
    required this.name,
    required this.pointsBalance,
    this.avatarUrl,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      pointsBalance: json['points_balance'] as int,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
```

- [ ] **Step 2: Verify it analyzes clean**

Run (from `nmimes`): `flutter analyze lib/models/student_profile.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add nmimes/lib/models/student_profile.dart
git commit -m "$(cat <<'EOF'
Add StudentProfile read-model for profile screen

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Flutter Dio API HTTP client

**Files:**
- Create: `nmimes/lib/services/api_http_client.dart`
- Test: exercised via a fake in Task 5 (this client is thin over Dio; no live-network unit test).

**Interfaces:**
- Consumes: `StudentProfile.fromJson` (Task 2); `Supabase.instance.client.auth.currentSession?.accessToken`.
- Produces: `abstract class ProfileApi { Future<StudentProfile> fetchStudentProfile(String studentId); }`; `class ApiHttpClient implements ProfileApi`; `class ApiHttpException implements Exception { final int? statusCode; final String message; }`.

The `ProfileApi` interface exists so the profile screen can depend on an abstraction and Task 5 can inject a fake without any network.

- [ ] **Step 1: Create the client**

Create `nmimes/lib/services/api_http_client.dart`:

```dart
// nmimes/lib/services/api_http_client.dart
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/student_profile.dart';

/// Thrown by [ApiHttpClient] on a non-2xx response or transport failure.
class ApiHttpException implements Exception {
  final int? statusCode;
  final String message;
  const ApiHttpException(this.statusCode, [this.message = '']);

  @override
  String toString() =>
      'ApiHttpException($statusCode${message.isEmpty ? '' : ': $message'})';
}

/// Abstraction the UI depends on, so tests can inject a fake.
abstract class ProfileApi {
  Future<StudentProfile> fetchStudentProfile(String studentId);
}

/// Dio-backed client for the FastAPI backend. Authenticates every request
/// with the current Supabase parent session's access token.
class ApiHttpClient implements ProfileApi {
  final Dio _dio;

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  ApiHttpClient({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl)) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token =
              Supabase.instance.client.auth.currentSession?.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  @override
  Future<StudentProfile> fetchStudentProfile(String studentId) async {
    try {
      final res = await _dio.get('/students/$studentId/profile');
      final data = res.data as Map;
      final profile = Map<String, dynamic>.from(data['profile'] as Map);
      return StudentProfile.fromJson(profile);
    } on DioException catch (e) {
      throw ApiHttpException(
        e.response?.statusCode,
        e.message ?? 'request failed',
      );
    } catch (e) {
      throw ApiHttpException(null, e.toString());
    }
  }
}
```

- [ ] **Step 2: Verify it analyzes clean**

Run (from `nmimes`): `flutter analyze lib/services/api_http_client.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add nmimes/lib/services/api_http_client.dart
git commit -m "$(cat <<'EOF'
Add Dio ApiHttpClient for the FastAPI profile endpoint

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: PointsCard accepts an optional points value

**Files:**
- Modify: `nmimes/lib/screens/profile/points_card.dart`
- Test: rendered assertion is covered in Task 5.

**Interfaces:**
- Produces: `ProfilePointsCard({super.key, int? points})` — shows `points?.toString() ?? '150'`.

- [ ] **Step 1: Add the optional param**

In `nmimes/lib/screens/profile/points_card.dart`, change the class to accept `points`:

Replace:
```dart
class ProfilePointsCard extends StatelessWidget {
  const ProfilePointsCard({super.key});
```
with:
```dart
class ProfilePointsCard extends StatelessWidget {
  final int? points;
  const ProfilePointsCard({super.key, this.points});
```

Replace the hardcoded points `Text('150', ...)` with:
```dart
              Text(
                points?.toString() ?? '150',
                style: AppTextStyles.font(context,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
```

- [ ] **Step 2: Verify it analyzes clean**

Run (from `nmimes`): `flutter analyze lib/screens/profile/points_card.dart`
Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add nmimes/lib/screens/profile/points_card.dart
git commit -m "$(cat <<'EOF'
Let ProfilePointsCard show a live points value

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: Profile screen — layout fixes, data loading, full sign-out

**Files:**
- Modify: `nmimes/lib/screens/profile/profile_screen.dart`
- Test: `nmimes/test/profile_screen_test.dart` (create)

**Interfaces:**
- Consumes: `ProfileApi` + `ApiHttpClient` + `ApiHttpException` (Task 3); `StudentProfile` (Task 2); `ProfilePointsCard(points:)` (Task 4); `AuthState.selectedStudentId` + `AuthState.setSelectedStudentId` (existing); `SupabaseService().signOut()` (existing).
- Produces: `ProfileScreen({super.key, ProfileApi? api})` — the optional `api` is for test injection; production uses `ApiHttpClient()`.

The Log Out sign-out uses `SupabaseService`. To keep the widget testable without a real Supabase call, wrap the sign-out in a guard: if there is no current session, skip `signOut()` (the test has no session). This keeps the test focused on the `setSelectedStudentId(null)` + navigation wiring, which are the observable behaviors.

- [ ] **Step 1: Write the failing widget test**

Create `nmimes/test/profile_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:nmimes/l10n/generated/app_localizations.dart';
import 'package:nmimes/models/student_profile.dart';
import 'package:nmimes/providers/auth_state.dart';
import 'package:nmimes/services/api_http_client.dart';
import 'package:nmimes/screens/profile/profile_screen.dart';
import 'package:nmimes/theme/app_theme.dart';

class _FakeApi implements ProfileApi {
  final StudentProfile? profile;
  final Object? error;
  _FakeApi({this.profile, this.error});

  @override
  Future<StudentProfile> fetchStudentProfile(String studentId) async {
    if (error != null) throw error!;
    return profile!;
  }
}

/// AuthState with a preset selected student and no secure-storage dependency
/// in the test (setSelectedStudentId(null) still records the call).
class _TestAuthState extends AuthState {
  bool clearedSelection = false;
  _TestAuthState() : super();

  @override
  Future<void> setSelectedStudentId(String? id) async {
    if (id == null) clearedSelection = true;
    // Skip secure storage in tests.
  }
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'http://localhost:54321',
      anonKey: 'test-anon-key',
    );
  });

  Widget wrap(ProfileApi api, {AuthState? auth, String? selectedId}) {
    final authState = auth ?? AuthState();
    return ChangeNotifierProvider<AuthState>.value(
      value: authState,
      child: MaterialApp(
        theme: AppTheme.lightForLocale(const Locale('en')),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: ProfileScreen(api: api, selectedStudentIdOverride: selectedId),
        routes: {
          '/': (_) => const Scaffold(body: Text('ROOT')),
        },
      ),
    );
  }

  testWidgets('renders name and points from the profile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final api = _FakeApi(
      profile: const StudentProfile(
        id: 'abc',
        name: 'Amina',
        pointsBalance: 240,
        avatarUrl: null,
      ),
    );
    await tester.pumpWidget(wrap(api, selectedId: 'abc'));
    await tester.pumpAndSettle();

    expect(find.text('Amina'), findsOneWidget);
    expect(find.text('240'), findsOneWidget);
  });

  testWidgets('falls back to mock values when the fetch fails',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final api = _FakeApi(error: const ApiHttpException(500, 'boom'));
    await tester.pumpWidget(wrap(api, selectedId: 'abc'));
    await tester.pumpAndSettle();

    expect(find.text('John'), findsOneWidget);
    expect(find.text('150'), findsOneWidget);
  });

  testWidgets('log out clears the selected student and navigates to root',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final auth = _TestAuthState();
    final api = _FakeApi(
      profile: const StudentProfile(
        id: 'abc', name: 'Amina', pointsBalance: 240, avatarUrl: null),
    );
    await tester.pumpWidget(wrap(api, auth: auth, selectedId: 'abc'));
    await tester.pumpAndSettle();

    // Open the Log Out confirmation, then confirm "Yes".
    await tester.tap(find.text('Log Out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(auth.clearedSelection, isTrue);
    expect(find.text('ROOT'), findsOneWidget);
  });
}
```

Note on the l10n strings: the test taps `find.text('Log Out')` and `find.text('Yes')`. If the English ARB values differ (e.g. "Log out" / "Log Out"), adjust the finder to the actual `context.l10n.profile_button_logOut` and `context.l10n.logOut_button_yes` values — verify by grepping the generated `app_localizations_en.dart` for `profile_button_logOut` and `logOut_button_yes` before running, and use those exact strings.

- [ ] **Step 2: Run the test to verify it fails**

Run (from `nmimes`): `flutter test test/profile_screen_test.dart`
Expected: FAIL to compile — `ProfileScreen` has no `api` or `selectedStudentIdOverride` parameter yet.

- [ ] **Step 3: Rewrite profile_screen.dart**

Replace the entire contents of `nmimes/lib/screens/profile/profile_screen.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n_extension.dart';
import '../../models/student_profile.dart';
import '../../providers/auth_state.dart';
import '../../services/api_http_client.dart';
import '../../services/supabase_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'points_card.dart';

Future<void> _confirmLogout(BuildContext context) async {
  // End the Supabase session if one exists (guarded so tests without a live
  // session don't attempt a real network sign-out), clear the locally
  // selected student, then return to the root route.
  final auth = context.read<AuthState>();
  final messenger = Navigator.of(context);
  try {
    if (Supabase.instance.client.auth.currentSession != null) {
      await SupabaseService().signOut();
    }
  } catch (_) {
    // Ignore sign-out transport errors; still clear local state below.
  }
  await auth.setSelectedStudentId(null);
  messenger.pushNamedAndRemoveUntil('/', (r) => false);
}

void _showLogoutDialog(BuildContext context) {
  final l10n = context.l10n;
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.logOut_title,
              style: AppTextStyles.font(context,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.logOut_body,
              style: AppTextStyles.font(context,
                fontSize: 16,
                color: const Color(0xFF2E2E2E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(dialogContext),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: AppColors.primary, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          l10n.logOut_button_no,
                          style: AppTextStyles.font(context,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Navigator.pop(dialogContext);
                      await _confirmLogout(context);
                    },
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Text(
                          l10n.logOut_button_yes,
                          style: AppTextStyles.font(context,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class ProfileScreen extends StatefulWidget {
  /// Injectable for tests; production uses [ApiHttpClient].
  final ProfileApi? api;

  /// Test-only override for the selected student id. When null, the id is
  /// read from [AuthState].
  final String? selectedStudentIdOverride;

  const ProfileScreen({super.key, this.api, this.selectedStudentIdOverride});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileApi _api;
  StudentProfile? _profile;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? ApiHttpClient();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final id = widget.selectedStudentIdOverride ??
        context.read<AuthState>().selectedStudentId;
    if (id == null) return;
    try {
      final profile = await _api.fetchStudentProfile(id);
      if (mounted) setState(() => _profile = profile);
    } catch (_) {
      // Keep fallback mock values on any failure.
    }
  }

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 100;
    const double avatarOverlap = 50;
    // Reserve space for the fixed name that now sits below the avatar.
    const double nameBlockHeight = 44;

    final name = _profile?.name ?? 'John';
    final avatarUrl = _profile?.avatarUrl;

    return ColoredBox(
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Text(
                context.l10n.profile_title,
                style: AppTextStyles.font(context,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Cream body — only the cards inside this scroll.
                Positioned.fill(
                  top: avatarOverlap,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: SingleChildScrollView(
                      // Top padding clears the pinned avatar + fixed name.
                      padding: EdgeInsets.fromLTRB(
                          20, avatarOverlap + 8 + nameBlockHeight, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfilePointsCard(points: _profile?.pointsBalance),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFE0E0E0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                      Icons.workspace_premium_rounded,
                                      color: AppColors.primary,
                                      size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.l10n.profile_label_currentPlan,
                                        style: AppTextStyles.font(context,
                                          fontSize: 13,
                                          color: const Color(0xFF888888),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        context.l10n.profile_plan_free,
                                        style: AppTextStyles.font(context,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2E2E2E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/subscription',
                                      arguments: 1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      context.l10n.profile_button_upgrade,
                                      style: AppTextStyles.font(context,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Help row — label centered.
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/help'),
                            child: Container(
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFFE0E0E0)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                context.l10n.profile_button_help,
                                style: AppTextStyles.font(context,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF2E2E2E),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Log Out row — label centered.
                          GestureDetector(
                            onTap: () => _showLogoutDialog(context),
                            child: Container(
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBD7C8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: const Color(0xFFE62929)),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                context.l10n.profile_button_logOut,
                                style: AppTextStyles.font(context,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFE62929),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Pinned avatar + fixed name (do not scroll).
                Positioned(
                  top: 0,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: avatarSize,
                            height: avatarSize,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: (avatarUrl != null && avatarUrl.isNotEmpty)
                                  ? Image.network(
                                      avatarUrl,
                                      width: avatarSize,
                                      height: avatarSize,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _avatarFallback(),
                                    )
                                  : Image.asset(
                                      'assets/images/nmimes_front.png',
                                      width: avatarSize,
                                      height: avatarSize,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _avatarFallback(),
                                    ),
                            ),
                          ),
                          Positioned(
                            right: -4,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/avatar'),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit_rounded,
                                    color: AppColors.primary, size: 15),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Fixed name — pinned with the avatar, never scrolls.
                      Text(
                        name,
                        style: AppTextStyles.font(context,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E2E2E),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() => Container(
        color: const Color(0xFFE8E8E8),
        child: const Icon(Icons.person_rounded, color: Colors.grey, size: 60),
      );
}
```

Add the Supabase import used by `_confirmLogout`. At the top of the file, add:
```dart
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
```
(placed with the other imports; `hide AuthState` avoids clashing with the app's own `AuthState`).

- [ ] **Step 4: Confirm the l10n strings the test taps**

Run (from `nmimes`): `grep -E "profile_button_logOut|logOut_button_yes|profile_button_help" lib/l10n/generated/app_localizations_en.dart`
Read the exact English values and, if they differ from `'Log Out'` / `'Yes'`, update the finders in `test/profile_screen_test.dart` to match.

- [ ] **Step 5: Run the widget tests to verify they pass**

Run (from `nmimes`): `flutter test test/profile_screen_test.dart`
Expected: all 3 tests PASS.

- [ ] **Step 6: Run analyze on the whole project**

Run (from `nmimes`): `flutter analyze`
Expected: `No issues found!` (fix any new warnings introduced by this task).

- [ ] **Step 7: Commit**

```bash
git add nmimes/lib/screens/profile/profile_screen.dart nmimes/test/profile_screen_test.dart
git commit -m "$(cat <<'EOF'
Wire profile screen to backend; fix fixed name and centered labels; full sign-out

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
EOF
)"
```

---

## Task 6: Full-suite regression check

**Files:** none (verification only).

- [ ] **Step 1: Run the entire Flutter test suite**

Run (from `nmimes`): `flutter test`
Expected: all tests pass, including the pre-existing overflow/navigation tests (the profile layout change must not introduce overflow — the `overflow_audit_test.dart` / `overflow_test.dart` cover this). If the fixed-name layout causes a `RenderFlex`/overflow failure, adjust `nameBlockHeight` / paddings until clean.

- [ ] **Step 2: Re-run the backend verification script**

Run (from `nmimes-backend/nmimes-api`): `.venv/Scripts/python.exe verify_profile_endpoint.py`
Expected: `OK: profile endpoint verification passed`.

- [ ] **Step 3: Final analyze**

Run (from `nmimes`): `flutter analyze`
Expected: `No issues found!`

---

## Self-Review

**Spec coverage:**
- Part 1 layout fixes → Task 5 (fixed name moved into pinned block; Help/Log Out `Alignment.center`). ✓
- Part 2 FastAPI endpoint + Redis read-through + ownership + 404 → Task 1. ✓
- Part 3 Dio client + StudentProfile model + base URL dart-define + JWT interceptor → Tasks 2, 3. ✓
- Part 4 stateful load + fallback + avatar_url + points wiring + full sign-out → Tasks 4, 5. ✓
- Testing section (owner/cache-hit/non-owner/404; render + fallback + logout widget tests; analyze) → Tasks 1, 5, 6. ✓
- Plan stays hardcoded Free → Task 5 keeps `profile_plan_free`. ✓

**Placeholder scan:** No TBD/TODO; every code step shows full code. The only conditional is the l10n-string check (Task 5 Step 4) which gives an exact grep command and instruction, not a placeholder. ✓

**Type consistency:** `ProfileApi.fetchStudentProfile(String) -> Future<StudentProfile>` used identically in Tasks 3 and 5; `StudentProfile` fields (`id/name/pointsBalance/avatarUrl`) consistent Tasks 2/5; `ApiHttpException(int?, String)` consistent Tasks 3/5; endpoint response `{cached, profile}` consistent Task 1 (backend) and Task 3 (client reads `data['profile']`). ✓
