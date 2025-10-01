import 'dart:convert';
import 'api_service.dart';

/// Service pour gérer les données du parent
/// Correspond au contrôleur ParentController du backend
class ParentService {
  final ApiService _apiService = ApiService();

  /// Récupérer les statistiques du parent
  /// Endpoint: GET /api/parent/stats
  /// 
  /// Réponse:
  /// {
  ///   "enseignants": 5,
  ///   "eleves": 10,
  ///   "temoins": 3,
  ///   "seances": 0
  /// }
  Future<Map<String, dynamic>> getStats() async {
    final response = await _apiService.get('/api/parent/stats');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des statistiques: ${response.statusCode}');
    }
  }

  /// Récupérer les rapports du parent
  /// Endpoint: GET /api/mes-rapports
  Future<List<Map<String, dynamic>>> getRapports() async {
    final response = await _apiService.get('/api/mes-rapports');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors du chargement des rapports: ${response.statusCode}');
    }
  }

  /// Supprimer un rapport
  /// Endpoint: DELETE /api/rapports/{id}
  Future<void> deleteRapport(int id) async {
    final response = await _apiService.delete('/api/rapports/$id');
    
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression du rapport: ${response.statusCode}');
    }
  }

  /// Récupérer les séances du parent
  /// Endpoint: GET /api/emplois-parent
  Future<List<Map<String, dynamic>>> getSeances() async {
    final response = await _apiService.get('/api/emplois-parent');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors du chargement des séances: ${response.statusCode}');
    }
  }
}