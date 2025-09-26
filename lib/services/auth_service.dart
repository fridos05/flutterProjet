import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  static const String baseUrl = "http://192.168.10.101:8000"; // Porable l'URL de ton API
  static const String loginUrl = "/api/login";
  static const String registerUrl = "/api/register";
  static const String logoutUrl = "/api/logout";
  static const String userUrl = "/api/user";

  // Sauvegarde le token dans SharedPreferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // Connexion
  Future<Map<String, dynamic>> login(String courriel, String motDePasse, String role) async {
    final response = await http.post(
      Uri.parse("$baseUrl$loginUrl"),
      headers: {"Accept": "application/json"},
      body: {
        "courriel": courriel,
        "mot_de_passe": motDePasse,
        "role": role,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveToken(data["token"]);
      return data;
    } else {
      throw Exception("Échec de la connexion: ${response.body}");
    }
  }

  // Inscription
  Future<Map<String, dynamic>> register(Map<String, String> body) async {
    final response = await http.post(
      Uri.parse("$baseUrl$registerUrl"),
      headers: {"Accept": "application/json"},
      body: body,
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Échec de l'inscription: ${response.body}");
    }
  }

  // Déconnexion
  Future<void> logout() async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$baseUrl$logoutUrl"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      await _clearToken();
    } else {
      throw Exception("Échec de la déconnexion: ${response.body}");
    }
  }

  // Récupérer l’utilisateur connecté
  Future<Map<String, dynamic>> getUser() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl$userUrl"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Impossible de récupérer l'utilisateur: ${response.body}");
    }
  }
}
