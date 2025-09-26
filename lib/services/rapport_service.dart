import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/rapport_model.dart';
import 'api.dart';

class RapportService {
  Future<List<Rapport>> getRapports() async {
    final token = await TokenManager.getToken();
    final response = await http.get(
      Uri.parse(ApiService().buildUrl(ApiEndpoints.rapportsIndex)),
      headers: ApiService.authHeaders(token ?? ''),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => Rapport.fromJson(json)).toList();
    } else {
      throw Exception("Erreur rapports: ${response.body}");
    }
  }

  Future<Rapport> createRapport(Map<String, dynamic> body) async {
    final token = await TokenManager.getToken();
    final response = await http.post(
      Uri.parse(ApiService().buildUrl(ApiEndpoints.rapportsStore)),
      headers: ApiService.authHeaders(token ?? ''),
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Rapport.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erreur création rapport: ${response.body}");
    }
  }

  Future<Rapport> getRapport(int id) async {
    final token = await TokenManager.getToken();
    final response = await http.get(
      Uri.parse(ApiService().buildUrl('${ApiEndpoints.rapportsIndex}/$id')),
      headers: ApiService.authHeaders(token ?? ''),
    );

    if (response.statusCode == 200) {
      return Rapport.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erreur lecture rapport: ${response.body}");
    }
  }

  Future<void> deleteRapport(int id) async {
    final token = await TokenManager.getToken();
    final response = await http.delete(
      Uri.parse(ApiService().buildUrl('${ApiEndpoints.rapportsIndex}/$id')),
      headers: ApiService.authHeaders(token ?? ''),
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur suppression rapport: ${response.body}");
    }
  }

  Future<List<Rapport>> getMesRapports() async {
    final token = await TokenManager.getToken();
    final response = await http.get(
      Uri.parse(ApiService().buildUrl(ApiEndpoints.mesRapports)),
      headers: ApiService.authHeaders(token ?? ''),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => Rapport.fromJson(json)).toList();
    } else {
      throw Exception("Erreur mes rapports: ${response.body}");
    }
  }
}
