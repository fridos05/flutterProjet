import 'dart:convert';
import 'api_service.dart';

class EnseignantService {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> getEnseignants() async {
    final response = await _apiService.get('/api/enseignant/index');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors du chargement des enseignants: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getEnseignantById(int id) async {
    final enseignants = await getEnseignants();
    final enseignantData = enseignants.firstWhere(
      (e) => e['enseignant']['id'] == id,
      orElse: () => {},
    );
    if (enseignantData.isNotEmpty) {
      return enseignantData['enseignant'];
    } else {
      throw Exception('Enseignant non trouvé');
    }
  }

  Future<Map<String, dynamic>> createEnseignant(Map<String, dynamic> data) async {
    final response = await _apiService.post('/api/enseignant/store', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la création: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateEnseignant(int id, Map<String, dynamic> data) async {
    final response = await _apiService.put('/api/enseignant/$id', data);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la mise à jour: ${response.statusCode}');
    }
  }

  Future<void> deleteEnseignant(int id) async {
    final response = await _apiService.delete('/api/enseignant/$id');
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _apiService.get('/api/parent/stats');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des statistiques: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getMesEleves() async {
    final response = await _apiService.get('/api/mes-eleves');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des élèves: ${response.statusCode}');
    }
  }
}
