import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://192.168.100.7:3001'; // Update with your NestJS backend URL
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();
  Dio get dio => _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          print('Adding Bearer token to request: Bearer $token');
        } else {
          print('No token found in storage');
        }
        print('Request Headers: ${options.headers}');
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        print('API Error Details:');
        print('Error Type: ${e.type}');
        print('Error Message: ${e.message}');
        print('Response Status: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
        print('Request URL: ${e.requestOptions.uri}');
        print('Request Method: ${e.requestOptions.method}');
        print('Request Headers: ${e.requestOptions.headers}');
        print('Request Data: ${e.requestOptions.data}');
        
        if (e.response?.statusCode == 401) {
          _storage.delete(key: 'auth_token');
        }
        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String path) async {
    try {
      print('Making GET request to: $path');
      final response = await _dio.get(path);
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      print('Making POST request to: $path');
      print('Request data: $data');
      final response = await _dio.post(path, data: data);
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    print('API Error Details:');
    print('Error Type: ${e.type}');
    print('Error Message: ${e.message}');
    print('Response Status: ${e.response?.statusCode}');
    print('Response Data: ${e.response?.data}');
    print('Request URL: ${e.requestOptions.uri}');
    print('Request Method: ${e.requestOptions.method}');
    print('Request Headers: ${e.requestOptions.headers}');
    print('Request Data: ${e.requestOptions.data}');
    
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Connection timed out. Please check your internet connection and try again.');
    }
    
    if (e.response?.data != null) {
      if (e.response?.data['message'] != null) {
        return Exception(e.response?.data['message']);
      }
      if (e.response?.data['error'] != null) {
        return Exception(e.response?.data['error']);
      }
      // If we have response data but no specific error message, return the whole response
      return Exception('Server error: ${e.response?.data}');
    }
    
    return Exception('An error occurred: ${e.message}');
  }
}