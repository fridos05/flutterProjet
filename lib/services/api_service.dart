import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Configuration de base de l'API
class ApiConfig {
  static const String baseUrl = 'http://192.168.10.101:8000';
  static const int timeoutSeconds = 30;
}

// Service principal pour les appels API
class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = ApiConfig.baseUrl});

  // Récupérer le token depuis SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Headers communs
  Future<Map<String, String>> get headers async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Méthode utilitaire pour construire les URLs
  String buildUrl(String endpoint) => baseUrl + endpoint;

  // Méthodes HTTP avec gestion d'erreurs
  Future<http.Response> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse(buildUrl(endpoint)),
        headers: await headers,
      ).timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(buildUrl(endpoint)),
        headers: await headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse(buildUrl(endpoint)),
        headers: await headers,
        body: json.encode(data),
      ).timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse(buildUrl(endpoint)),
        headers: await headers,
      ).timeout(const Duration(seconds: ApiConfig.timeoutSeconds));
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  http.Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw HttpException(
        'Erreur HTTP ${response.statusCode}: ${response.body}',
        response.statusCode,
      );
    }
  }

  // Méthode pour sauvegarder le token après login
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Méthode pour supprimer le token après logout
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;

  HttpException(this.message, this.statusCode);

  @override
  String toString() => 'HttpException: $message (Status: $statusCode)';
}