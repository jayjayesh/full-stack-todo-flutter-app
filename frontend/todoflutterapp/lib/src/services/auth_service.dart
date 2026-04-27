import 'dart:async';
import '../utils/utils.dart';
import '../config/app_config.dart';
import 'secure_storage_service.dart';
import 'package:dio/dio.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();
  static const _tokenKey = 'auth_token';

  Dio get _dio => AppConfig.dio;
  SecureStorageService get _secureStorage => SecureStorageService.instance;

  // Custom Backend doesn't have a built-in auth state stream, so we manage our own
  final StreamController<Map<String, dynamic>?> _authStateController =
      StreamController<Map<String, dynamic>?>.broadcast();

  /// Stream of auth state changes. Emits the current user map or null.
  Stream<Map<String, dynamic>?> get authStateChanges =>
      _authStateController.stream;

  FutureEither<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      final response =
          await _dio.post<Map<String, dynamic>>('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data!;
      await _saveToken(data);
      _authStateController.add(data['user'] ?? data);
      return data;
    }, requiresNetwork: true);
  }

  FutureEither<Map<String, dynamic>?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return runTask(() async {
      final response =
          await _dio.post<Map<String, dynamic>>('/auth/signup', data: {
        'name': name,
        'email': email,
        'password': password,
      });
      final data = response.data!;
      await _saveToken(data);
      _authStateController.add(data['user'] ?? data);
      return data;
    }, requiresNetwork: true);
  }

  FutureEither<void> forgotPassword({required String email}) async {
    return runTask(() async {
      await _dio.post<void>('/auth/forgot-password', data: {'email': email});
    }, requiresNetwork: true);
  }

  FutureEither<void> logout() async {
    return runTask(() async {
      await _secureStorage.delete(_tokenKey);

      try {
        await _dio.post<void>('/auth/logout');
      } catch (_) {
        // Logout is local for this lesson, so clearing the token is enough.
      }

      _authStateController.add(null);
    });
  }

  FutureEither<Map<String, dynamic>?> getCurrentUser() async {
    return runTask(() async {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      return response.data;
    });
  }

  void dispose() {
    _authStateController.close();
  }

  Future<void> _saveToken(Map<String, dynamic> data) async {
    final token = data['token'];

    if (token is String && token.isNotEmpty) {
      await _secureStorage.write(_tokenKey, token);
    }
  }
}
