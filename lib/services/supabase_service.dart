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
