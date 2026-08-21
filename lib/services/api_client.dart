import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class ApiClient {
  static String get baseUrl => AppConstants.baseUrl;

  static final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    // Filter out null and empty values from query parameters
    final filteredParams = <String, String>{};
    if (queryParams != null) {
      queryParams.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          filteredParams[key] = value.toString();
        }
      });
    }

    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: filteredParams.isNotEmpty ? filteredParams : null,
    );

    try {
      final response = await http
          .get(uri, headers: {..._defaultHeaders, ...?headers})
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => http.Response('Request timeout', 408),
          );
      return response;
    } catch (e) {
      return http.Response('Network error: $e', 500);
    }
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .post(
            uri,
            headers: {..._defaultHeaders, ...?headers},
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => http.Response('Request timeout', 408),
          );
      return response;
    } catch (e) {
      return http.Response('Network error: $e', 500);
    }
  }

  static Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .put(
            uri,
            headers: {..._defaultHeaders, ...?headers},
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => http.Response('Request timeout', 408),
          );
      return response;
    } catch (e) {
      return http.Response('Network error: $e', 500);
    }
  }

  static Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http
          .delete(uri, headers: {..._defaultHeaders, ...?headers})
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => http.Response('Request timeout', 408),
          );
      return response;
    } catch (e) {
      return http.Response('Network error: $e', 500);
    }
  }

  static Future<http.Response> multipartPost(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    Map<String, http.MultipartFile>? files,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    try {
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({..._defaultHeaders, ...?headers});

      if (fields != null) {
        request.fields.addAll(fields);
      }

      if (files != null) {
        request.files.addAll(files.values);
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw Exception('Request timeout'),
      );

      final response = await http.Response.fromStream(streamedResponse);
      return response;
    } catch (e) {
      return http.Response('Network error: $e', 500);
    }
  }

  static bool isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static String handleError(http.Response response) {
    if (response.statusCode == 408) {
      return 'Request timeout. Please check your connection and try again.';
    } else if (response.statusCode == 500) {
      return 'Server error. Please try again later.';
    } else if (response.statusCode == 404) {
      return 'Resource not found.';
    } else if (response.statusCode == 400) {
      try {
        final body = jsonDecode(response.body);
        return body['detail'] ?? 'Bad request';
      } catch (e) {
        return 'Bad request';
      }
    } else {
      return 'An error occurred: ${response.statusCode}';
    }
  }
}
