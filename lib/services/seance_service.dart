import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SeanceService {
  static const String baseUrl = "http://192.168.10.101:8000";
  static const String seancesIndex = "/api/seances";
  static const String seancesStore = "/api/seances";
  static const String seancesEleve = "/api/seances/eleve";
  static const String seancesParent = "/api/seances/parent";
  static const String seancesTemoin = "/api/seances/temoin";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<List<dynamic>> getSeances() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl$seancesIndex"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur séances: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> createSeance(Map<String, dynamic> body) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse("$baseUrl$seancesStore"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
      body: body,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur création séance: ${response.body}");
    }
  }

  Future<List<dynamic>> getSeancesEleve() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl$seancesEleve"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur séances élève: ${response.body}");
    }
  }

  Future<List<dynamic>> getSeancesParent() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl$seancesParent"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur séances parent: ${response.body}");
    }
  }

  Future<List<dynamic>> getSeancesTemoin() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl$seancesTemoin"),
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur séances témoin: ${response.body}");
    }
  }
}
