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
