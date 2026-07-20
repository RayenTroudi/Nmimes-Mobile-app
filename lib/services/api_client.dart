// nmimes/lib/services/api_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/parent.dart';
import '../models/student.dart';

/// Raised by [ApiClient] with a stable [code] describing what went wrong.
/// Known codes: 'not_authenticated', 'invalid_name',
/// 'invalid_access_code_format', 'duplicate_access_code',
/// 'access_code_not_found', 'unknown'.
class ApiException implements Exception {
  final String code;
  final String message;
  const ApiException(this.code, [this.message = '']);

  @override
  String toString() => 'ApiException($code${message.isEmpty ? '' : ': $message'})';
}

/// Data client backed entirely by Supabase RPCs (security-definer Postgres
/// functions), so no separate backend server is needed.
class ApiClient {
  final SupabaseClient _client;

  ApiClient({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  static const _knownCodes = {
    'not_authenticated',
    'invalid_name',
    'invalid_username_format',
    'invalid_access_code_format',
    'username_taken',
    'duplicate_access_code',
    'access_code_not_found',
  };

  Never _rethrow(Object error) {
    if (error is PostgrestException) {
      final msg = error.message;
      // No/expired parent session: Postgres denies EXECUTE to the anon role
      // (42501), or PostgREST rejects an expired JWT. Surface both as an
      // auth problem rather than a generic failure.
      if (error.code == '42501' ||
          msg.contains('permission denied') ||
          msg.toUpperCase().contains('JWT')) {
        throw const ApiException('not_authenticated');
      }
      final code = _knownCodes.firstWhere(
        (c) => msg.contains(c),
        orElse: () => 'unknown',
      );
      throw ApiException(code, msg);
    }
    throw ApiException('unknown', error.toString());
  }

  Future<Parent> upsertParent({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final data = await _client.rpc('upsert_parent', params: {
        'p_first_name': firstName,
        'p_last_name': lastName,
      });
      return Parent.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      _rethrow(e);
    }
  }

  /// Creating a child mints a real auth user, which requires the service-role
  /// key — so it runs in the `create-student` edge function, never in-app.
  Future<Student> createStudent({
    required String name,
    required String username,
    String? grade,
    String? interest,
    required String accessCode,
  }) async {
    try {
      final res = await _client.functions.invoke('create-student', body: {
        'name': name,
        'username': username,
        'access_code': accessCode,
        'grade': grade,
        'interest': interest,
      });
      final data = Map<String, dynamic>.from(res.data as Map);
      if (res.status >= 400) {
        throw ApiException(
          _knownCodes.contains(data['code']) ? data['code'] as String : 'unknown',
          data['detail']?.toString() ?? '',
        );
      }
      return Student.fromJson(data);
    } on ApiException {
      rethrow;
    } on FunctionException catch (e) {
      final details = e.details;
      final code = details is Map && _knownCodes.contains(details['code'])
          ? details['code'] as String
          : 'unknown';
      throw ApiException(code, e.reasonPhrase ?? '');
    } catch (e) {
      _rethrow(e);
    }
  }

  Future<Student> verifyAccessCode(String accessCode) async {
    try {
      final data = await _client.rpc('verify_access_code', params: {
        'p_access_code': accessCode,
      });
      return Student.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      _rethrow(e);
    }
  }
}
