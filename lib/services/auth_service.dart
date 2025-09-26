// TODO Implement this library.// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://192.168.10.101:8000/api';

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role, // 'parent', 'eleve', 'temoin', 'enseignant'
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'courriel': email,
        'mot_de_passe': password,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body)['message'] ?? 'Erreur inconnue';
      throw Exception(error);
    }
  }
}