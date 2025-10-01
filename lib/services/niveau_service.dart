import 'dart:convert';
import 'api_service.dart';

/// Service pour gérer les niveaux scolaires
/// Correspond au contrôleur NiveauController du backend
class NiveauService {
  final ApiService _apiService = ApiService();

  /// Récupérer tous les niveaux disponibles
  /// Endpoint: GET /api/niveau/index
  /// 
  /// Réponse: Liste de niveaux
  /// [
  ///   { "id": 1, "nom": "Primaire" },
  ///   { "id": 2, "nom": "Collège" },
  ///   { "id": 3, "nom": "Lycée" }
  /// ]
  Future<List<Map<String, dynamic>>> getNiveaux() async {
    final response = await _apiService.get('/api/niveau/index');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors du chargement des niveaux: ${response.statusCode}');
    }
  }
}
