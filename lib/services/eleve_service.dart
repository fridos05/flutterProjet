import 'dart:convert';
import 'api_service.dart';

class EleveService {
  final ApiService _apiService = ApiService();

  // Récupérer tous les élèves du parent connecté
  Future<List<Map<String, dynamic>>> getParentEleves() async {
    final response = await _apiService.get('/api/eleve/index');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors du chargement des élèves: ${response.statusCode}');
    }
  }

  // Récupérer un élève spécifique par ID
  Future<Map<String, dynamic>> getEleveById(int id) async {
    final eleves = await getParentEleves();
    // Chaque élément est { "eleve": {...}, "parent": {...} }
    final eleveData = eleves.firstWhere(
      (e) => e['eleve']['id'] == id,
      orElse: () => {},
    );
    if (eleveData.isNotEmpty) {
      return eleveData['eleve'];
    } else {
      throw Exception('Élève non trouvé');
    }
  }

  Future<Map<String, dynamic>> createEleve(Map<String, dynamic> data) async {
    final response = await _apiService.post('/api/eleve/store', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la création: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateEleve(int id, Map<String, dynamic> data) async {
  final response = await _apiService.put('/api/eleve/$id', data);

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Erreur lors de la mise à jour de l\'élève: ${response.statusCode}');
  }
}
  Future<void> deleteEleve(int id) async {
    final response = await _apiService.delete('/api/eleve/$id');
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression: ${response.statusCode}');
    }
  }
}
