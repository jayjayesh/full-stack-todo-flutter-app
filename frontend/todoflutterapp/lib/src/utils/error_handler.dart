import 'package:dio/dio.dart';

class AppErrorHandler {
  static String format(dynamic error) {
    if (error is String) return error;

    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map && data['message'] is String) {
        final errors = data['errors'];

        if (errors is List && errors.isNotEmpty) {
          final messages = errors
              .whereType<Map<dynamic, dynamic>>()
              .map((error) => error['message'])
              .whereType<String>()
              .where((message) => message.trim().isNotEmpty)
              .toList();

          if (messages.isNotEmpty) {
            return messages.join('\n');
          }
        }

        return data['message'];
      }

      if (error.message != null) {
        return error.message!;
      }
    }

    try {
      if (error?.message != null) return error.message;
      if (error?.toString() != null) return error.toString();
    } catch (_) {}

    return 'An unexpected error occurred';
  }
}
