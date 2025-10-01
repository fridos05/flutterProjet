import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.137.80:8000';
  static const bool enableDebugLogs = true; // Activer/désactiver les logs

  void _log(String message, {String? tag, dynamic data}) {
    if (enableDebugLogs) {
      final logTag = tag ?? 'ApiService';
      developer.log(
        message,
        name: logTag,
        time: DateTime.now(),
      );
      if (data != null) {
        developer.log(
          'Data: ${json.encode(data)}',
          name: logTag,
        );
      }
    }
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      _log('Token récupéré: ${token != null ? "✓ Présent" : "✗ Absent"}', tag: 'Auth');
      return token;
    } catch (e) {
      _log('❌ Erreur récupération token: $e', tag: 'Auth');
      return null;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    _log('Headers préparés', tag: 'Request', data: headers);
    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final url = '$baseUrl$endpoint';
    _log('🔵 GET Request', tag: 'HTTP', data: {'url': url});
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('⏱️ Timeout: Le serveur ne répond pas après 30 secondes');
        },
      );
      
      _log(
        '✅ GET Response ${response.statusCode}',
        tag: 'HTTP',
        data: {
          'url': url,
          'status': response.statusCode,
          'body': response.body.length > 500 
              ? '${response.body.substring(0, 500)}...' 
              : response.body,
        },
      );
      
      return _handleResponse(response, 'GET', url);
    } catch (e) {
      _log('❌ GET Error: $e', tag: 'HTTP', data: {'url': url});
      throw Exception('Erreur GET $endpoint: $e');
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    final url = '$baseUrl$endpoint';
    _log('🟢 POST Request', tag: 'HTTP', data: {'url': url, 'payload': data});
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: json.encode(data),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('⏱️ Timeout: Le serveur ne répond pas après 30 secondes');
        },
      );
      
      _log(
        '✅ POST Response ${response.statusCode}',
        tag: 'HTTP',
        data: {
          'url': url,
          'status': response.statusCode,
          'body': response.body.length > 500 
              ? '${response.body.substring(0, 500)}...' 
              : response.body,
        },
      );
      
      return _handleResponse(response, 'POST', url);
    } catch (e) {
      _log('❌ POST Error: $e', tag: 'HTTP', data: {'url': url, 'payload': data});
      throw Exception('Erreur POST $endpoint: $e');
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    final url = '$baseUrl$endpoint';
    _log('🟡 PUT Request', tag: 'HTTP', data: {'url': url, 'payload': data});
    
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: await _getHeaders(),
        body: json.encode(data),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('⏱️ Timeout: Le serveur ne répond pas après 30 secondes');
        },
      );
      
      _log(
        '✅ PUT Response ${response.statusCode}',
        tag: 'HTTP',
        data: {
          'url': url,
          'status': response.statusCode,
          'body': response.body.length > 500 
              ? '${response.body.substring(0, 500)}...' 
              : response.body,
        },
      );
      
      return _handleResponse(response, 'PUT', url);
    } catch (e) {
      _log('❌ PUT Error: $e', tag: 'HTTP', data: {'url': url, 'payload': data});
      throw Exception('Erreur PUT $endpoint: $e');
    }
  }

  Future<http.Response> delete(String endpoint) async {
    final url = '$baseUrl$endpoint';
    _log('🔴 DELETE Request', tag: 'HTTP', data: {'url': url});
    
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: await _getHeaders(),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('⏱️ Timeout: Le serveur ne répond pas après 30 secondes');
        },
      );
      
      _log(
        '✅ DELETE Response ${response.statusCode}',
        tag: 'HTTP',
        data: {
          'url': url,
          'status': response.statusCode,
          'body': response.body,
        },
      );
      
      return _handleResponse(response, 'DELETE', url);
    } catch (e) {
      _log('❌ DELETE Error: $e', tag: 'HTTP', data: {'url': url});
      throw Exception('Erreur DELETE $endpoint: $e');
    }
  }

  http.Response _handleResponse(http.Response response, String method, String url) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      // Log détaillé de l'erreur
      String errorMessage = 'Erreur HTTP ${response.statusCode}';
      
      try {
        final errorBody = json.decode(response.body);
        if (errorBody is Map) {
          if (errorBody.containsKey('message')) {
            errorMessage = errorBody['message'];
          } else if (errorBody.containsKey('error')) {
            errorMessage = errorBody['error'];
          } else if (errorBody.containsKey('errors')) {
            errorMessage = errorBody['errors'].toString();
          }
        }
      } catch (e) {
        errorMessage = response.body;
      }
      
      _log(
        '❌ HTTP Error ${response.statusCode}',
        tag: 'HTTP',
        data: {
          'method': method,
          'url': url,
          'status': response.statusCode,
          'error': errorMessage,
          'body': response.body,
        },
      );
      
      throw HttpException(
        errorMessage,
        response.statusCode,
        response.body,
      );
    }
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  final String? body;

  HttpException(this.message, this.statusCode, [this.body]);

  @override
  String toString() => 'HttpException: $message (Status: $statusCode)';
}