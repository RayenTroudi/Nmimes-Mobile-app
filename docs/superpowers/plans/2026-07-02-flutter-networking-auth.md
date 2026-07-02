# Flutter Networking Layer + Auth Screens Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the Nmimes Flutter app's existing auth screens (currently pure client-side
navigation with no real checks) to real Supabase Auth and the FastAPI backend from sub-project B,
so a parent can sign up, verify their email via OTP, sign in, add a child, and a child can sign in
with their access code and land on the app's home shell.

**Architecture:** Add `supabase_flutter` (Auth SDK), `dio` (HTTP client for the FastAPI backend),
`flutter_secure_storage` (persists the selected student), and `provider` (state management) as new
dependencies. A new `AuthState` `ChangeNotifier` tracks the Supabase session and the selected
student. A new `ApiClient` wraps `dio` with a JWT-attaching interceptor. Each of the 7 existing auth
screens gets its fake client-side-only submit handler replaced with a real call, using a
newly-introduced (this codebase has none today) loading/error UI pattern.

**Tech Stack:** Flutter/Dart, `supabase_flutter`, `dio`, `provider`, `flutter_secure_storage`.

## Global Constraints

- Parent auth = Supabase email+password, using the existing 4-digit PIN UI field as the password
  (per spec's "Auth model mapping" section) — do not redesign the PIN screens into longer password
  fields.
- Children are never separate Supabase Auth identities — child sign-in always calls
  `POST /students/verify-access-code` using the parent's already-active JWT.
- `lib/providers/locale_provider.dart`'s hand-rolled `InheritedWidget`/`ValueNotifier` pattern is
  NOT migrated to `provider` — the two coexist; only new state (`AuthState`) uses `provider`.
  - **Reviewer note (added after Task 2's initial review):** "coexist" means the packages coexist,
    not that both patterns must be exercised equally forever. `LocaleProvider` stays exactly as it
    is; nothing in this plan touches it. Provider is used for all state this plan introduces.
- No automated widget/integration tests are added in this pass — verification is manual, running
  `flutter run` against the real, already-verified Supabase project and FastAPI backend.
- Every new network-calling submit handler must show a loading state and a user-visible error
  message on failure — none of the 7 screens have this today; introduce one consistent pattern
  (see Task 1) and reuse it everywhere rather than inventing a new one per screen.
- FastAPI backend base URL is provided via `--dart-define=API_BASE_URL=<url>` at build/run time, not
  hardcoded.

---

### Task 1: Add dependencies and create the shared loading/error UI pattern

**Files:**
- Modify: `nmimes/pubspec.yaml`
- Create: `nmimes/lib/widgets/inline_error_text.dart`

**Interfaces:**
- Produces: `InlineErrorText` widget — `InlineErrorText({required String? message})` — renders
  nothing if `message` is null, otherwise a small red `Text` below the trigger point. Used by every
  screen task (3-9) as the shared error-display pattern, since no screen has one today.
- Produces: a documented convention (not a widget, just a pattern every later task follows): each
  screen's State class gains `bool _isLoading = false;` and `String? _errorMessage;` fields; the
  submit button's `child` becomes a ternary showing a small `CircularProgressIndicator` when
  `_isLoading` is true, and the button's `onPressed` becomes `null` while loading (in addition to
  its existing enablement check).

- [ ] **Step 1: Add new dependencies to pubspec.yaml**

Read `nmimes/pubspec.yaml` first to confirm current content, then add these lines inside the
existing `dependencies:` block (after `image_picker: ^1.1.2`):

```yaml
  supabase_flutter: ^2.8.0
  dio: ^5.7.0
  flutter_secure_storage: ^9.2.2
  provider: ^6.1.2
```

- [ ] **Step 2: Install dependencies**

```bash
cd "d:/nmimes mobile app/nmimes"
flutter pub get
```

Expected: completes with no errors, `pubspec.lock` updated with entries for `supabase_flutter`,
`dio`, `flutter_secure_storage`, `provider`.

- [ ] **Step 3: Create the shared InlineErrorText widget**

```dart
// nmimes/lib/widgets/inline_error_text.dart
import 'package:flutter/material.dart';

class InlineErrorText extends StatelessWidget {
  final String? message;

  const InlineErrorText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message!,
        style: const TextStyle(color: Colors.red, fontSize: 13),
      ),
    );
  }
}
```

- [ ] **Step 4: Verify the widget compiles**

```bash
cd "d:/nmimes mobile app/nmimes"
flutter analyze lib/widgets/inline_error_text.dart
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
cd "d:/nmimes mobile app/nmimes"
git add pubspec.yaml pubspec.lock lib/widgets/inline_error_text.dart
git commit -m "Add supabase_flutter, dio, flutter_secure_storage, provider deps and shared error widget"
```

---

### Task 2: Supabase initialization and AuthState provider

**Files:**
- Create: `nmimes/lib/providers/auth_state.dart`
- Modify: `nmimes/lib/main.dart`

**Interfaces:**
- Consumes: `supabase_flutter`'s `Supabase.instance.client.auth` (package API); `provider`'s
  `ChangeNotifierProvider`/`ChangeNotifier` (package API); `flutter_secure_storage`'s
  `FlutterSecureStorage` (package API).
- Produces: `AuthState extends ChangeNotifier` with:
  - `bool get isAuthenticated` — true if `Supabase.instance.client.auth.currentSession != null`
  - `String? get selectedStudentId` — in-memory cached value, backed by secure storage
  - `Future<void> setSelectedStudentId(String? id)` — writes to secure storage, updates in-memory
    cache, calls `notifyListeners()`
  - `Future<void> loadSelectedStudentId()` — reads from secure storage into the in-memory cache on
    startup, called once during `AuthState`'s construction
  - Subscribes to `Supabase.instance.client.auth.onAuthStateChange` in its constructor and calls
    `notifyListeners()` on every event (covers sign-in, sign-out, token refresh).
  Used by: Task 3 (`ApiClient`'s interceptor reads the current session token directly from
  `Supabase.instance.client.auth`, not from `AuthState`, but `AuthState.isAuthenticated` and
  `.selectedStudentId` are read by the splash screen (Task 9) and every screen task (4-8) to decide
  navigation and to pass `selectedStudentId` into API calls.

- [ ] **Step 1: Write lib/providers/auth_state.dart**

```dart
// nmimes/lib/providers/auth_state.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _kSelectedStudentIdKey = 'selected_student_id';

class AuthState extends ChangeNotifier {
  final FlutterSecureStorage _storage;
  String? _selectedStudentId;

  AuthState({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage() {
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  bool get isAuthenticated =>
      Supabase.instance.client.auth.currentSession != null;

  String? get selectedStudentId => _selectedStudentId;

  Future<void> loadSelectedStudentId() async {
    _selectedStudentId = await _storage.read(key: _kSelectedStudentIdKey);
    notifyListeners();
  }

  Future<void> setSelectedStudentId(String? id) async {
    _selectedStudentId = id;
    if (id == null) {
      await _storage.delete(key: _kSelectedStudentIdKey);
    } else {
      await _storage.write(key: _kSelectedStudentIdKey, value: id);
    }
    notifyListeners();
  }
}
```

- [ ] **Step 2: Wire Supabase.initialize and ChangeNotifierProvider into main.dart**

Read `nmimes/lib/main.dart` first (it will have changed slightly from the version referenced here
if Task 1 or others already touched it — they haven't, so it should match). Change the imports
block (originally lines 1-5):

```dart
import 'package:flutter/material.dart';
import 'package:camera_android/camera_android.dart';
import 'theme/app_theme.dart';
import 'providers/locale_provider.dart';
import 'l10n/generated/app_localizations.dart';
```

to:

```dart
import 'package:flutter/material.dart';
import 'package:camera_android/camera_android.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'providers/auth_state.dart';
import 'providers/locale_provider.dart';
import 'l10n/generated/app_localizations.dart';
```

Change `main()` (originally lines 79-84) from:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AndroidCamera.registerWith();
  final initialLocale = await resolveInitialLocale();
  runApp(NmimesApp(initialLocale: initialLocale));
}
```

to:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AndroidCamera.registerWith();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  final initialLocale = await resolveInitialLocale();
  runApp(NmimesApp(initialLocale: initialLocale));
}
```

Change `_NmimesAppState.build()` (originally lines 110-121) from:

```dart
  @override
  Widget build(BuildContext context) {
    return LocaleProvider(
      notifier: _localeNotifier,
      child: MaterialApp(
        title: 'Nmimes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightForLocale(_localeNotifier.value),
        locale: _localeNotifier.value,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: '/',
```

to:

```dart
  @override
  Widget build(BuildContext context) {
    return LocaleProvider(
      notifier: _localeNotifier,
      child: ChangeNotifierProvider(
        create: (_) => AuthState()..loadSelectedStudentId(),
        child: MaterialApp(
          title: 'Nmimes',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightForLocale(_localeNotifier.value),
          locale: _localeNotifier.value,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          initialRoute: '/',
```

This adds one extra level of nesting (`ChangeNotifierProvider` wrapping `MaterialApp`), so the
matching closing braces at the end of `build()` (originally lines 197-199) change from:

```dart
      ),
    );
  }
}
```

to:

```dart
        ),
      ),
    );
  }
}
```

(The `routes: { ... }` map itself, originally lines 122-196, is untouched — only its indentation
context changes since it's now one level deeper inside `MaterialApp` inside `ChangeNotifierProvider`
inside `LocaleProvider`. Re-indent the routes block by 2 spaces to match, but do not change any
route entries.)

- [ ] **Step 3: Verify the app still compiles**

```bash
cd "d:/nmimes mobile app/nmimes"
flutter analyze lib/main.dart lib/providers/auth_state.dart
```

Expected: `No issues found!` (Supabase.initialize will fail at runtime without real
`--dart-define` values, but static analysis doesn't execute the app, so this step only checks
compilation.)

- [ ] **Step 4: Commit**

```bash
cd "d:/nmimes mobile app/nmimes"
git add lib/main.dart lib/providers/auth_state.dart
git commit -m "Initialize Supabase and add AuthState provider for session/selected-student tracking"
```

---

### Task 3: Supabase auth service wrapper and Dart models

**Files:**
- Create: `nmimes/lib/services/supabase_service.dart`
- Create: `nmimes/lib/models/parent.dart`
- Create: `nmimes/lib/models/student.dart`

**Interfaces:**
- Consumes: `supabase_flutter` package API.
- Produces:
  - `SupabaseService` class with static-feeling instance methods (constructed once, but no
    singleton enforcement needed — screens will each create `SupabaseService()` since it's
    stateless, wrapping the single global `Supabase.instance.client`):
    - `Future<void> signUp({required String email, required String password})`
    - `Future<void> verifyOtp({required String email, required String token, required OtpType type})`
    - `Future<void> signInWithPassword({required String email, required String password})`
    - `Future<void> resetPasswordForEmail(String email)`
    - `Future<void> updatePassword(String newPassword)`
    - `Future<void> signOut()`
    All methods let `AuthException` propagate to the caller (screens catch it in Tasks 4-8) rather
    than swallowing or wrapping it — this keeps the service a thin, faithful wrapper.
  - `Parent` class (`lib/models/parent.dart`): fields `id`, `firstName`, `lastName`, `email`,
    `subscriptionStatus`, `createdAt`, `updatedAt` (all `String` except `createdAt`/`updatedAt`
    which are `DateTime`), with `factory Parent.fromJson(Map<String, dynamic> json)` and
    `Map<String, dynamic> toJson()`.
  - `Student` class (`lib/models/student.dart`): fields `id`, `parentId`, `name`, `username`
    (`String?`), `grade` (`String?`), `interest` (`String?`), `pointsBalance` (`int`), `avatarUrl`
    (`String?`), `createdAt`, `updatedAt` (`DateTime`), with `factory Student.fromJson(...)` and
    `toJson()`.
  Used by: Task 4 (`ApiClient` deserializes responses into these), Tasks 5-8 (screens call
  `SupabaseService` methods).

- [ ] **Step 1: Write lib/services/supabase_service.dart**

```dart
// nmimes/lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<void> signUp({required String email, required String password}) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> verifyOtp({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    await _client.auth.verifyOTP(email: email, token: token, type: type);
  }

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
```

- [ ] **Step 2: Write lib/models/parent.dart**

```dart
// nmimes/lib/models/parent.dart
class Parent {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String subscriptionStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Parent({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.subscriptionStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      subscriptionStatus: json['subscription_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'subscription_status': subscriptionStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
```

- [ ] **Step 3: Write lib/models/student.dart**

```dart
// nmimes/lib/models/student.dart
class Student {
  final String id;
  final String parentId;
  final String name;
  final String? username;
  final String? grade;
  final String? interest;
  final int pointsBalance;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Student({
    required this.id,
    required this.parentId,
    required this.name,
    this.username,
    this.grade,
    this.interest,
    required this.pointsBalance,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      parentId: json['parent_id'] as String,
      name: json['name'] as String,
      username: json['username'] as String?,
      grade: json['grade'] as String?,
      interest: json['interest'] as String?,
      pointsBalance: json['points_balance'] as int,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'name': name,
      'username': username,
      'grade': grade,
      'interest': interest,
      'points_balance': pointsBalance,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
```

- [ ] **Step 4: Verify compilation**

```bash
cd "d:/nmimes mobile app/nmimes"
flutter analyze lib/services/supabase_service.dart lib/models/parent.dart lib/models/student.dart
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
cd "d:/nmimes mobile app/nmimes"
git add lib/services/supabase_service.dart lib/models/parent.dart lib/models/student.dart
git commit -m "Add SupabaseService auth wrapper and Parent/Student models"
```

---

### Task 4: ApiClient (dio-based FastAPI client)

**Files:**
- Create: `nmimes/lib/services/api_client.dart`

**Interfaces:**
- Consumes: `dio` package API; `Supabase.instance.client.auth.currentSession?.accessToken` (from
  `supabase_flutter`, already a dependency per Task 1); `Parent.fromJson`, `Student.fromJson` (Task
  3).
- Produces: `ApiClient` class:
  - `ApiClient({String? baseUrl})` — defaults `baseUrl` to
    `const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000')`
  - `Future<Parent> upsertParent({required String firstName, required String lastName})` — calls
    `POST /parents/me`
  - `Future<Student> createStudent({required String name, String? grade, String? interest, required String accessCode})`
    — calls `POST /students`
  - `Future<Student> verifyAccessCode(String accessCode)` — calls
    `POST /students/verify-access-code`
  All three let `DioException` propagate to the caller (screens catch it in Tasks 6-8).
  Used by: Task 6 (`parent_otp_screen.dart` calls `upsertParent`), Task 7
  (`child_access_code_screen.dart` calls `verifyAccessCode`), Task 8
  (`parent_profile_setup_screen.dart` calls `createStudent`).

- [ ] **Step 1: Write lib/services/api_client.dart**

```dart
// nmimes/lib/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/parent.dart';
import '../models/student.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ??
              const String.fromEnvironment(
                'API_BASE_URL',
                defaultValue: 'http://localhost:8000',
              ),
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = Supabase.instance.client.auth.currentSession?.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<Parent> upsertParent({
    required String firstName,
    required String lastName,
  }) async {
    final response = await _dio.post('/parents/me', data: {
      'first_name': firstName,
      'last_name': lastName,
    });
    return Parent.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Student> createStudent({
    required String name,
    String? grade,
    String? interest,
    required String accessCode,
  }) async {
    final response = await _dio.post('/students', data: {
      'name': name,
      'grade': grade,
      'interest': interest,
      'access_code': accessCode,
    });
    return Student.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Student> verifyAccessCode(String accessCode) async {
    final response = await _dio.post('/students/verify-access-code', data: {
      'access_code': accessCode,
    });
    return Student.fromJson(response.data as Map<String, dynamic>);
  }
}
```

- [ ] **Step 2: Verify compilation**

```bash
cd "d:/nmimes mobile app/nmimes"
flutter analyze lib/services/api_client.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
cd "d:/nmimes mobile app/nmimes"
git add lib/services/api_client.dart
git commit -m "Add ApiClient with JWT-attaching interceptor for FastAPI backend calls"
```

---

### Task 5: Wire parent_sign_up_screen.dart and parent_otp_screen.dart (signup + email verification)

**Files:**
- Modify: `nmimes/lib/screens/auth/parent_sign_up_screen.dart`
- Modify: `nmimes/lib/screens/auth/parent_otp_screen.dart`

**Interfaces:**
- Consumes: `SupabaseService.signUp`, `SupabaseService.verifyOtp` (Task 3);
  `ApiClient.upsertParent` (Task 4); `InlineErrorText` (Task 1).
- Produces: a working sign-up → OTP-verify → parent-record-created flow. `parent_otp_screen.dart`
  now distinguishes signup-OTP-verification (calls `upsertParent` after success) from
  password-reset-OTP-verification (does not call `upsertParent` — that path is wired in Task 8).

- [ ] **Step 1: Read the current file to confirm no drift**

```bash
cd "d:/nmimes mobile app/nmimes"
```

Read `lib/screens/auth/parent_sign_up_screen.dart` in full — it should match the extraction: class
`_ParentSignUpScreenState`, controllers `_firstNameCtrl`, `_lastNameCtrl`, `_emailCtrl`, `_pinCtrl`,
`_confirmPinCtrl`, and a submit button at (originally) lines 198-225 whose `onPressed` is:

```dart
onPressed: _canSubmit
    ? () => Navigator.pushNamed(
        context, '/parent-otp',
        arguments: '/account-created')
    : null,
```

- [ ] **Step 2: Add imports and state fields to parent_sign_up_screen.dart**

Add these imports near the top of the file (alongside existing imports):

```dart
import '../../services/supabase_service.dart';
import '../../widgets/inline_error_text.dart';
```

Inside `_ParentSignUpScreenState`, add these fields alongside the existing controllers:

```dart
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _errorMessage;
```

- [ ] **Step 3: Replace the submit button's onPressed with a real signUp call**

Replace:

```dart
onPressed: _canSubmit
    ? () => Navigator.pushNamed(
        context, '/parent-otp',
        arguments: '/account-created')
    : null,
```

with:

```dart
onPressed: _canSubmit && !_isLoading ? _onSubmit : null,
```

Add a new `_onSubmit` method to the State class (place it near `_canSubmit`):

```dart
  Future<void> _onSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _supabaseService.signUp(
        email: _emailCtrl.text.trim(),
        password: _pinCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/parent-otp',
        arguments: {
          'next': '/account-created',
          'email': _emailCtrl.text.trim(),
          'firstName': _firstNameCtrl.text.trim(),
          'lastName': _lastNameCtrl.text.trim(),
        },
      );
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
```

Add the `AuthException` import (from `supabase_flutter`) alongside the other new imports from Step
2:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
```

Note the route arguments changed shape from a bare `String` (`'/account-created'`) to a `Map`
carrying `next`, `email`, `firstName`, `lastName` — `parent_otp_screen.dart` (Step 5 below) is
updated to read this new shape, since it needs the email to call `verifyOtp` and the names to call
`upsertParent`.

- [ ] **Step 4: Add the button's loading spinner and InlineErrorText to parent_sign_up_screen.dart**

Change the submit button's `child` from:

```dart
child: Text(
  l10n.parentSignUp_button,
  style: AppTextStyles.font(context,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  ),
),
```

to:

```dart
child: _isLoading
    ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.white,
        ),
      )
    : Text(
        l10n.parentSignUp_button,
        style: AppTextStyles.font(context,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
```

Immediately after the `SizedBox` containing the submit `ElevatedButton` (i.e. as the next sibling
in the enclosing `Column`), add:

```dart
InlineErrorText(message: _errorMessage),
```

- [ ] **Step 5: Update parent_otp_screen.dart to read the new argument shape and call verifyOtp + upsertParent**

Read `lib/screens/auth/parent_otp_screen.dart` in full to confirm current state — class
`_ParentOtpScreenState`, single controller `_controller`, an `_isSignIn` getter reading
`ModalRoute.of(context)?.settings.arguments == '/parent-success'`, and a submit button at
(originally) lines 228-261 whose `onPressed` is:

```dart
onPressed: _pin.length == 4
    ? () {
        final next = ModalRoute.of(context)
                ?.settings.arguments as String? ??
            '/account-created';
        Navigator.pushNamed(context, next);
      }
    : null,
```

Add imports:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../services/api_client.dart';
import '../../widgets/inline_error_text.dart';
```

Add state fields:

```dart
  final _supabaseService = SupabaseService();
  final _apiClient = ApiClient();
  bool _isLoading = false;
  String? _errorMessage;
```

Grep confirms only one call site in the entire app navigates to `/parent-otp`
(`parent_sign_up_screen.dart`, wired in this task's Step 3) — the `_isSignIn` getter's
`/parent-success` branch has no caller anywhere in the codebase today, and this plan does not give
it one (Task 8's forgot-password flow verifies its recovery OTP directly on
`parent_forgot_access_code_screen.dart` instead, per Task 8 Step 4 — it never navigates to
`/parent-otp`). `_isSignIn` is kept as-is (it still drives the button's sign-in-vs-sign-up label
text, which this task does not otherwise touch, so removing the getter would break that reference)
— it will simply always evaluate `false` in practice, exactly matching the app's current behavior
before this task. Add a second helper alongside it, without removing `_isSignIn`, that reads the
new `Map`-shaped arguments from Step 3 above:

```dart
  Map<String, dynamic> get _args {
    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is Map<String, dynamic>) return raw;
    return {'next': '/account-created'};
  }
```

(This replaces the inline `ModalRoute.of(context)?.settings.arguments as String? ?? '/account-created'`
cast used below and in the original code, since arguments are now always a `Map` per Step 3 — no
caller passes a bare `String` after this task, so the fallback only needs to cover a missing/null
argument, not a `String`-shaped one.)

Replace the submit button's `onPressed`:

```dart
onPressed: _pin.length == 4
    ? () {
        final next = ModalRoute.of(context)
                ?.settings.arguments as String? ??
            '/account-created';
        Navigator.pushNamed(context, next);
      }
    : null,
```

with:

```dart
onPressed: _pin.length == 4 && !_isLoading ? _onSubmit : null,
```

Add the `_onSubmit` method. This screen currently has exactly one caller (`parent_sign_up_screen.dart`,
per Step 3), always passing signup-shaped arguments, so `_onSubmit` only implements the
signup-verification path — it does not attempt to guess at a recovery-OTP path with no real caller
to exercise it (see Task 8 Step 4, which implements recovery-OTP verification directly on
`parent_forgot_access_code_screen.dart` instead, independent of this screen):

```dart
  Future<void> _onSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final args = _args;
      await _supabaseService.verifyOtp(
        email: args['email'] as String,
        token: _pin,
        type: OtpType.signup,
      );
      await _apiClient.upsertParent(
        firstName: args['firstName'] as String,
        lastName: args['lastName'] as String,
      );
      if (!mounted) return;
      Navigator.pushNamed(context, args['next'] as String);
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
```

Add the loading spinner to the submit button's `child` (same pattern as Step 4) and add
`InlineErrorText(message: _errorMessage)` after the button, following the exact same two edits
described in Step 4 above, applied to this file's button/text instead.

- [ ] **Step 6: Verify compilation**

```bash
cd "d:/nmimes mobile app/nmimes"
flutter analyze lib/screens/auth/parent_sign_up_screen.dart lib/screens/auth/parent_otp_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
cd "d:/nmimes mobile app/nmimes"
git add lib/screens/auth/parent_sign_up_screen.dart lib/screens/auth/parent_otp_screen.dart
git commit -m "Wire parent sign-up and OTP verification to real Supabase Auth + parent upsert"
```

---

### Task 6: Wire parent_access_code_screen.dart (parent sign-in)

**Files:**
- Modify: `nmimes/lib/screens/auth/parent_access_code_screen.dart`
- Modify (conditionally, per Step 2): `nmimes/lib/screens/auth/parent_sign_in_screen.dart`

**Interfaces:**
- Consumes: `SupabaseService.signInWithPassword` (Task 3); `InlineErrorText` (Task 1). Note: this
  screen does not need the parent's email as a field it collects — read the file first to confirm
  whether it already carries an email (likely passed as a route argument from `parent_sign_in_screen.dart`,
  since email needs to travel from an earlier screen — inspect and adapt; if no email is available
  via route arguments today, this task must also thread it through from `parent_sign_in_screen.dart`
  per Step 2, otherwise this file is untouched by this plan since its current submit just navigates
  here).
- Produces: a working parent sign-in flow using real Supabase password auth.

- [ ] **Step 1: Read parent_sign_in_screen.dart and parent_access_code_screen.dart to determine how email travels between them**

Read `lib/screens/auth/parent_sign_in_screen.dart` in full. Determine: does its submit action pass
the entered email as a route argument to `/parent-access-code`, or does it navigate with no
arguments? Read `lib/screens/auth/parent_access_code_screen.dart` in full to confirm: class
`_ParentAccessCodeScreenState`, controller `_pinCtrl`, submit button at (originally) lines 180-209
with `onPressed`:

```dart
onPressed: pin.length == 4
    ? () => Navigator.pushReplacementNamed(
        context, '/parents-view')
    : null,
```

- [ ] **Step 2: Thread the email through from parent_sign_in_screen.dart if not already present**

If `parent_sign_in_screen.dart`'s submit does not already pass the email as an argument, modify its
submit handler to add `arguments: _emailCtrl.text.trim()` (or equivalent — match whatever the
existing email controller variable is named in that file) to its `Navigator.pushNamed(context,
'/parent-access-code', ...)` call. If it already passes the email, skip this step — just note in
your report which case applied.

- [ ] **Step 3: Add imports and state fields to parent_access_code_screen.dart**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../widgets/inline_error_text.dart';
```

```dart
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _errorMessage;
```

- [ ] **Step 4: Replace the submit button's onPressed with a real signInWithPassword call**

Replace:

```dart
onPressed: pin.length == 4
    ? () => Navigator.pushReplacementNamed(
        context, '/parents-view')
    : null,
```

with:

```dart
onPressed: pin.length == 4 && !_isLoading ? _onSubmit : null,
```

Add the `_onSubmit` method (reading the email from `ModalRoute.of(context)?.settings.arguments as
String?`, per Step 2's threading):

```dart
  Future<void> _onSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
      await _supabaseService.signInWithPassword(email: email, password: pin);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/parents-view');
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
```

(`pin` here refers to whatever the existing getter/variable in this file is called for
`_pinCtrl.text` — read the file to confirm the exact name used in the existing `onPressed:
pin.length == 4` condition and use that same identifier.)

- [ ] **Step 5: Add the loading spinner and InlineErrorText**

Same pattern as Task 5 Step 4: ternary the button's `child` between a `CircularProgressIndicator`
and the existing `Text(l10n.parentAccessCode_button, ...)`, and add `InlineErrorText(message:
_errorMessage)` as the next sibling after the button's `SizedBox`.

- [ ] **Step 6: Verify compilation**

```bash
cd "d:/nmimes mobile app/nmimes"
flutter analyze lib/screens/auth/parent_access_code_screen.dart lib/screens/auth/parent_sign_in_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
cd "d:/nmimes mobile app/nmimes"
git add lib/screens/auth/parent_access_code_screen.dart lib/screens/auth/parent_sign_in_screen.dart
git commit -m "Wire parent sign-in screen to real Supabase password auth"
```

---

### Task 7: Wire child_access_code_screen.dart (child sign-in)

**Files:**
- Modify: `nmimes/lib/screens/auth/child_access_code_screen.dart`

**Interfaces:**
- Consumes: `ApiClient.verifyAccessCode` (Task 4); `AuthState.setSelectedStudentId` (Task 2, via
  `context.read<AuthState>()` from the `provider` package); `InlineErrorText` (Task 1).
- Produces: a working child sign-in flow — on success, the returned `Student.id` is stored in
  `AuthState` and the app navigates to the existing `/child-success` route.

- [ ] **Step 1: Read the current file to confirm no drift**

Read `lib/screens/auth/child_access_code_screen.dart` in full. Confirm: class
`_ChildAccessCodeScreenState`, controller `_ctrl`, a `_submit()` method (originally lines 34-38):

```dart
  void _submit() {
    if (_pin.length == 4) {
      Navigator.pushNamed(context, '/child-success');
    }
  }
```

auto-triggered from the hidden TextField's `onChanged` when 4 digits are entered (originally lines
117-120). Note this screen has **no visible submit button** — submission is automatic.

- [ ] **Step 2: Add imports**

```dart
import 'package:provider/provider.dart';
import '../../providers/auth_state.dart';
import '../../services/api_client.dart';
import '../../widgets/inline_error_text.dart';
```

- [ ] **Step 3: Add state fields**

```dart
  final _apiClient = ApiClient();
  bool _isLoading = false;
  String? _errorMessage;
```

- [ ] **Step 4: Replace _submit() with a real verifyAccessCode call**

Replace:

```dart
  void _submit() {
    if (_pin.length == 4) {
      Navigator.pushNamed(context, '/child-success');
    }
  }
```

with:

```dart
  Future<void> _submit() async {
    if (_pin.length != 4 || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final student = await _apiClient.verifyAccessCode(_pin);
      await context.read<AuthState>().setSelectedStudentId(student.id);
      if (!mounted) return;
      Navigator.pushNamed(context, '/child-success');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      setState(() {
        _errorMessage = status == 404
            ? 'That code doesn\'t match any child on this account.'
            : status == 429
                ? 'Too many attempts. Please try again later.'
                : 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
```

Add the `dio` import for `DioException`:

```dart
import 'package:dio/dio.dart';
```

- [ ] **Step 5: Display loading/error state**

This screen has no visible submit button to attach a spinner to (submission is automatic on the
4th digit). Instead, add a loading indicator and `InlineErrorText` near the hidden PIN input's
visual dot indicators. Read the file to find where the PIN dots are rendered (likely a `Row` of 4
small circle widgets reflecting `_pin.length`), and add directly after that `Row`:

```dart
if (_isLoading)
  const Padding(
    padding: EdgeInsets.only(top: 16),
    child: SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(strokeWidth: 2),
    ),
  ),
InlineErrorText(message: _errorMessage),
```

- [ ] **Step 6: Verify compilation**

```bash
cd "d:/nmimes mobile app/nmimes"
flutter analyze lib/screens/auth/child_access_code_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
cd "d:/nmimes mobile app/nmimes"
git add lib/screens/auth/child_access_code_screen.dart
git commit -m "Wire child access-code screen to real backend PIN verification"
```

---

### Task 8: Wire parent_profile_setup_screen.dart (add child), forgot/reset access code screens

**Files:**
- Modify: `nmimes/lib/screens/auth/parent_profile_setup_screen.dart`
- Modify: `nmimes/lib/screens/auth/parent_forgot_access_code_screen.dart`
- Modify: `nmimes/lib/screens/auth/parent_reset_access_code_screen.dart`

**Interfaces:**
- Consumes: `ApiClient.createStudent` (Task 4); `SupabaseService.resetPasswordForEmail`,
  `SupabaseService.updatePassword` (Task 3); `InlineErrorText` (Task 1).
- Produces: a working "add child" flow (create-student calls the backend for each child added, PIN
  hashed server-side) and a working forgot/reset-PIN flow using Supabase's password recovery.

- [ ] **Step 1: Read parent_profile_setup_screen.dart to confirm no drift**

Read the file in full. Confirm: class `_ParentProfileSetupScreenState`, controllers `_nameCtrl`,
`_usernameCtrl`, `_pinCtrl`, plus `_selectedGrade`/`_selectedInterest` (String?), a `_canSubmit`
getter, and `_onSubmit` (originally lines 39-126) which opens an `AlertDialog` with "No" (navigates
to `/profile-setup-done`) and "Yes" (clears the form to add another child) — currently no network
call anywhere in it.

- [ ] **Step 2: Add imports and state fields to parent_profile_setup_screen.dart**

```dart
import '../../services/api_client.dart';
import '../../widgets/inline_error_text.dart';
```

```dart
  final _apiClient = ApiClient();
  bool _isLoading = false;
  String? _errorMessage;
```

- [ ] **Step 3: Insert a real createStudent call before the existing dialog logic**

The existing `_onSubmit` (bound to the submit button's `onPressed: _canSubmit ? _onSubmit : null`)
currently opens the dialog immediately. Change its signature to `Future<void> _onSubmit() async`
and wrap its existing body so the dialog only opens after a successful `createStudent` call. Locate
the start of the existing `_onSubmit` method body and wrap it:

```dart
  Future<void> _onSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _apiClient.createStudent(
        name: _nameCtrl.text.trim(),
        grade: _selectedGrade,
        interest: _selectedInterest,
        accessCode: _pinCtrl.text,
      );
      if (!mounted) return;
      // ...existing dialog-showing code continues unchanged below this line...
```

and close the added `try` block with:

```dart
    } on DioException catch (e) {
      setState(() {
        _errorMessage = e.response?.statusCode == 422
            ? 'Please check the child\'s details and try again.'
            : 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
```

Add the `dio` import:

```dart
import 'package:dio/dio.dart';
```

Update the submit button's `onPressed` from `_canSubmit ? _onSubmit : null` to
`_canSubmit && !_isLoading ? _onSubmit : null`, add the loading-spinner ternary to its `child` (same
pattern as prior tasks), and add `InlineErrorText(message: _errorMessage)` after the button.

- [ ] **Step 4: Wire parent_forgot_access_code_screen.dart to resetPasswordForEmail and the recovery OTP**

Read `lib/screens/auth/parent_forgot_access_code_screen.dart` in full. This screen's job is: (a)
trigger Supabase's password-recovery email/OTP, (b) let the user enter the OTP, (c) navigate to
`/parent-reset-access-code`. Confirm: controller `_otpCtrl`, a submit ("Verify") button at
(originally) lines 214-243 with `onPressed`:

```dart
onPressed: otp.length == 4
    ? () => Navigator.pushReplacementNamed(
        context, '/parent-reset-access-code')
    : null,
```

This screen needs the parent's email as an input to call `resetPasswordForEmail` — check whether it
already collects an email field or receives one as a route argument from
`parent_access_code_screen.dart`'s "forgot code" link (Step lines 159-175 per the earlier
extraction). If no email is available, this screen needs its own email field added — since this is
a UI change beyond wiring, and the plan's scope is networking (not redesign), if no email is
available report this via DONE_WITH_CONCERNS rather than adding a new UI field unilaterally; the
most likely case is the email already travels as a route argument from the prior screen, in which
case: read it via `ModalRoute.of(context)?.settings.arguments as String?`.

Add imports:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../widgets/inline_error_text.dart';
```

Add state fields:

```dart
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _errorMessage;
```

In `initState()` (or wherever the screen first has access to the email argument — if `initState()`
can't read `ModalRoute` yet in this widget tree position, use `didChangeDependencies()` instead and
guard with a `bool _hasSentOtp = false` flag so it only fires once), trigger the OTP send:

```dart
  bool _hasSentOtp = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasSentOtp) {
      _hasSentOtp = true;
      _sendOtp();
    }
  }

  Future<void> _sendOtp() async {
    final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    try {
      await _supabaseService.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    }
  }
```

Replace the submit button's `onPressed`:

```dart
onPressed: otp.length == 4
    ? () => Navigator.pushReplacementNamed(
        context, '/parent-reset-access-code')
    : null,
```

with:

```dart
onPressed: otp.length == 4 && !_isLoading ? _onVerify : null,
```

Add `_onVerify` (this screen only verifies the OTP is correct-length locally today, per the
extraction). `parent_forgot_access_code_screen.dart` navigates directly to
`/parent-reset-access-code`, never through `/parent-otp` — this screen collects the OTP itself via
its own `_otpCtrl`, so the recovery-OTP `verifyOtp(type: OtpType.recovery)` call belongs here, not
on `parent_otp_screen.dart` (Task 5's `parent_otp_screen.dart` wiring only implements the
signup-verification path it actually serves, per that task's note):

```dart
  Future<void> _onVerify() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final email = ModalRoute.of(context)?.settings.arguments as String? ?? '';
      await _supabaseService.verifyOtp(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/parent-reset-access-code',
        arguments: email,
      );
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
```

(`otp` refers to whatever the existing getter/variable name is for `_otpCtrl.text` in this file —
use the same identifier already present in the `onPressed: otp.length == 4` condition.)

Add the loading spinner to the button and `InlineErrorText(message: _errorMessage)` after it, same
pattern as prior tasks.

- [ ] **Step 5: Wire parent_reset_access_code_screen.dart to updatePassword**

Read `lib/screens/auth/parent_reset_access_code_screen.dart` in full. Confirm: controllers
`_newPinCtrl`, `_confirmPinCtrl`, a `_canSubmit` getter, and a submit ("Confirm") button at
(originally) lines 156-191 with `onPressed`:

```dart
onPressed: _canSubmit
    ? () {
        // Pop back to sign-in after reset
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/parent-sign-in',
          (route) => false,
        );
      }
    : null,
```

Add imports:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../widgets/inline_error_text.dart';
```

Add state fields:

```dart
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _errorMessage;
```

Replace the submit button's `onPressed`:

```dart
onPressed: _canSubmit
    ? () {
        // Pop back to sign-in after reset
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/parent-sign-in',
          (route) => false,
        );
      }
    : null,
```

with:

```dart
onPressed: _canSubmit && !_isLoading ? _onSubmit : null,
```

Add `_onSubmit`:

```dart
  Future<void> _onSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _supabaseService.updatePassword(_newPinCtrl.text);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/parent-sign-in',
        (route) => false,
      );
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
```

Note: `updatePassword` relies on `Supabase.instance.client.auth` having an active recovery session
established by the prior screen's `verifyOtp(type: OtpType.recovery)` call (Step 4 above) — this is
standard Supabase recovery-flow behavior (verifying a recovery OTP creates a temporary session
scoped to allow a password update), no extra wiring needed here beyond the `updatePassword` call
itself.

Add the loading spinner and `InlineErrorText(message: _errorMessage)`, same pattern as prior tasks.

- [ ] **Step 6: Verify compilation**

```bash
cd "d:/nmimes mobile app/nmimes"
flutter analyze lib/screens/auth/parent_profile_setup_screen.dart lib/screens/auth/parent_forgot_access_code_screen.dart lib/screens/auth/parent_reset_access_code_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 7: Commit**

```bash
cd "d:/nmimes mobile app/nmimes"
git add lib/screens/auth/parent_profile_setup_screen.dart lib/screens/auth/parent_forgot_access_code_screen.dart lib/screens/auth/parent_reset_access_code_screen.dart
git commit -m "Wire add-child, forgot-PIN, and reset-PIN screens to real Supabase/backend calls"
```

---

### Task 9: Auth-gate the splash screen

**Files:**
- Modify: `nmimes/lib/screens/splash/splash_screen.dart`

**Interfaces:**
- Consumes: `AuthState.isAuthenticated`, `AuthState.selectedStudentId` (Task 2, via
  `context.read<AuthState>()`).
- Produces: splash screen now branches its final navigation based on real auth state instead of
  always going to `/onboarding`.

- [ ] **Step 1: Read the current file to confirm no drift**

Read `lib/screens/splash/splash_screen.dart` in full. Confirm the end of `_runSequence()`
(originally lines 144-148):

```dart
    // Phase 5: hold logo, then navigate
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/onboarding');
  }
```

- [ ] **Step 2: Add the provider import**

```dart
import 'package:provider/provider.dart';
import '../../providers/auth_state.dart';
```

- [ ] **Step 3: Replace the final navigation with an auth-state branch**

Replace:

```dart
    // Phase 5: hold logo, then navigate
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/onboarding');
  }
```

with:

```dart
    // Phase 5: hold logo, then navigate
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final authState = context.read<AuthState>();
    if (authState.isAuthenticated && authState.selectedStudentId != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (authState.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/child-access-code');
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }
```

This matches the spec's three-way branch: signed in + student selected → `/home`; signed in + no
student selected → the child access-code picker step; signed out → `/onboarding` (unchanged
first-run behavior).

- [ ] **Step 4: Verify compilation**

```bash
cd "d:/nmimes mobile app/nmimes"
flutter analyze lib/screens/splash/splash_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
cd "d:/nmimes mobile app/nmimes"
git add lib/screens/splash/splash_screen.dart
git commit -m "Auth-gate splash screen navigation using AuthState"
```

---

### Task 10: Manual end-to-end verification

**Files:**
- None created or modified — this task exercises the running app against the live, already-verified
  Supabase project and FastAPI backend from sub-projects A and B.

**Interfaces:**
- Consumes: everything from Tasks 1-9.
- Produces: confirmation the full sign-up → verify → sign-in → add-child → child-sign-in path works,
  or a list of concrete failures to fix.

- [ ] **Step 1: Start the FastAPI backend**

```bash
cd "d:/nmimes mobile app/nmimes-backend/nmimes-api"
source .venv/Scripts/activate
uvicorn main:app --port 8000
```

Run with `run_in_background: true` if using the Bash tool.

- [ ] **Step 2: Determine the correct API_BASE_URL for the target device/emulator**

If running on an Android emulator, `localhost` from the emulator's perspective is `10.0.2.2` — use
`API_BASE_URL=http://10.0.2.2:8000`. If running on a physical device or iOS simulator, use your
machine's LAN IP or `http://localhost:8000` respectively. Confirm which target is being used before
proceeding.

- [ ] **Step 3: Run the Flutter app with real Supabase and API values**

```bash
cd "d:/nmimes mobile app/nmimes"
flutter run \
  --dart-define=SUPABASE_URL=https://vebmbkbmmglgpwwmwevk.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_JNNHRxxhIi5wYM0ljrMBjQ_i5dZQCmV \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

(Substitute the correct `API_BASE_URL` per Step 2. The `SUPABASE_ANON_KEY` here is the publishable
key already used elsewhere in this project's verification steps — safe for client-side use.)

- [ ] **Step 4: Exercise the sign-up flow**

In the running app: navigate to parent sign-up, enter a real-format test email (e.g.
`flutter-e2e-test@nmimes.internal`), a 4-digit PIN, first/last name, submit. Confirm no error is
shown and the app navigates to the OTP screen.

- [ ] **Step 5: Retrieve the OTP and complete verification**

Since this is a real Supabase project, the OTP is emailed — for a `.internal` test address with no
real mailbox, instead fetch the OTP via the Supabase Admin API's magic-link/OTP inspection, or
temporarily use a real, reachable test email address you control for this manual run. Enter the
retrieved 4-digit OTP in the app, submit. Confirm the app navigates to `/account-created` (via
`/parent-setup` next) with no error, and confirm via Supabase that a `parents` row was created:

```bash
curl -s "https://vebmbkbmmglgpwwmwevk.supabase.co/rest/v1/parents?email=eq.flutter-e2e-test@nmimes.internal&select=*" \
  -H "apikey: sb_secret_REDACTED_ROTATE_ME" \
  -H "Authorization: Bearer sb_secret_REDACTED_ROTATE_ME"
```

Expected: one row with the test email and the entered first/last name.

- [ ] **Step 6: Exercise the add-child flow**

On the profile-setup screen, enter a child's name, grade, interest, and a 4-digit PIN (e.g. `1234`);
submit. Confirm the "add another child?" dialog appears with no error shown first. Choose "No",
confirm navigation to the account-created screen. Verify via Supabase:

```bash
curl -s "https://vebmbkbmmglgpwwmwevk.supabase.co/rest/v1/students?select=id,name,parent_id" \
  -H "apikey: sb_secret_REDACTED_ROTATE_ME" \
  -H "Authorization: Bearer sb_secret_REDACTED_ROTATE_ME"
```

Expected: a row for the created child, `parent_id` matching the test parent's id from Step 5.

- [ ] **Step 7: Exercise the child sign-in flow**

Sign out (or restart the app fresh with the same session), reach the child access-code screen,
enter the PIN from Step 6 (`1234`). Confirm no error, and confirm the app navigates to
`/child-success` then eventually `/home`.

- [ ] **Step 8: Exercise the parent sign-in flow (existing account)**

From a signed-out state, sign in with the test parent's email + PIN via
`parent_sign_in_screen.dart` → `parent_access_code_screen.dart`. Confirm no error and successful
navigation to `/parents-view`.

- [ ] **Step 9: Exercise the forgot/reset-PIN flow**

From the parent access-code screen, tap "forgot code". Confirm an OTP is sent (check Supabase Auth
logs or the test mailbox), enter it, then set a new 4-digit PIN. Confirm navigation back to
`/parent-sign-in`, and confirm the NEW pin (not the old one) successfully signs in afterward.

- [ ] **Step 10: Clean up test data**

```bash
curl -s -X DELETE "https://vebmbkbmmglgpwwmwevk.supabase.co/auth/v1/admin/users?email=eq.flutter-e2e-test@nmimes.internal" \
  -H "apikey: sb_secret_REDACTED_ROTATE_ME" \
  -H "Authorization: Bearer sb_secret_REDACTED_ROTATE_ME"
```

(If the above admin-API filter form doesn't support query-by-email for DELETE, first `GET
/auth/v1/admin/users` filtered client-side or via the dashboard to find the user id, then `DELETE
/auth/v1/admin/users/{id}` as done in sub-projects A/B's verification — cascades to the `parents`
and `students` rows.)

- [ ] **Step 11: Report results**

No commit for this task (no files changed) — summarize which steps passed/failed directly to the
user.

---

## Self-Review Notes

- **Spec coverage:** auth model mapping (Supabase email+password using the PIN, Task 5/6/8), child
  access-code flow via `POST /students/verify-access-code` (Task 7), new dependencies (Task 1),
  `AuthState`/`ApiClient`/`SupabaseService`/models (Tasks 2-4), all 7 listed screens wired (Tasks
  5-8: sign-up, OTP, sign-in, forgot/reset, child access-code, add-child), splash-screen auth
  gating (Task 9), manual end-to-end verification matching how sub-projects A/B were verified (Task
  10) — all spec sections have a task.
- **Placeholder scan:** none found — every code block is complete. Task 6 and Task 8 both flag real
  ambiguities discovered only by reading the actual screen files (does email already travel as a
  route argument, or not) rather than guessing — each gives the implementer a concrete instruction
  for both cases, including an explicit "report via DONE_WITH_CONCERNS rather than guess" escape
  hatch in Task 8 Step 4 if the assumption turns out wrong, which is the correct way to handle a
  genuine unknown rather than a placeholder.
- **Type consistency:** `AuthState.setSelectedStudentId(String? id)`,
  `ApiClient.verifyAccessCode(String accessCode) -> Future<Student>`,
  `SupabaseService.verifyOtp({required String email, required String token, required OtpType
  type})` are used identically everywhere they're called across Tasks 5-9. `Student`/`Parent`
  field names (`snake_case` JSON keys, `camelCase` Dart fields) match the FastAPI response models
  from sub-project B exactly (`ParentResponse`, `StudentResponse` in
  `nmimes-api/models/parent.py`/`student.py`).
- **Cross-task consistency fix applied during self-review:** an earlier draft of Task 5 had
  `parent_otp_screen.dart`'s `_onSubmit` branch on a signup-vs-recovery distinction with no real
  caller for the recovery branch (grep confirmed `/parent-otp` has exactly one call site in the
  whole app, always signup-shaped), while also claiming this getter was "deleted" despite the
  screen's unmodified button-label code still referencing it. Fixed: `_isSignIn` is kept (its
  existing, untouched button-label usage still needs it, and it harmlessly always evaluates
  `false`, matching current behavior), `_onSubmit` only implements the one reachable path
  (signup verification + `upsertParent`), and Task 8's cross-reference to a now-removed branch was
  corrected to match.
