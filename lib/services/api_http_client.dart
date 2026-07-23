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
    defaultValue: 'http://0.0.0.0:8000',
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
