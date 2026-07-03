// nmimes/lib/services/supabase_service.dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient get _client => Supabase.instance.client;

  /// Supabase Auth enforces a hard minimum password length of 6 characters,
  /// which a 4-digit PIN cannot satisfy directly. This deterministically
  /// derives a Supabase-compliant password from the user-facing PIN and their
  /// email (so the same PIN produces different derived passwords for
  /// different parents), while every caller still only ever handles the
  /// raw 4-digit PIN.
  String _derivePassword({required String email, required String pin}) {
    final digest = sha256.convert(utf8.encode('${email.trim().toLowerCase()}:$pin'));
    return digest.toString().substring(0, 32);
  }

  Future<void> signUp({required String email, required String pin}) async {
    await _client.auth.signUp(
      email: email,
      password: _derivePassword(email: email, pin: pin),
    );
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
    required String pin,
  }) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: _derivePassword(email: email, pin: pin),
    );
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword({required String email, required String newPin}) async {
    await _client.auth.updateUser(
      UserAttributes(password: _derivePassword(email: email, pin: newPin)),
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
