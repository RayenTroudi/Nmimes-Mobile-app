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
