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
        initialRoute: '/profile',
        routes: {
          '/': (_) => const Scaffold(body: Text('ROOT')),
          '/profile': (_) =>
              ProfileScreen(api: api, selectedStudentIdOverride: selectedId),
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
