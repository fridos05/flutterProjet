import 'dart:convert';
import 'api_service.dart';

/// Service pour gérer les associations entre enseignants, élèves et témoins
/// Correspond au contrôleur AssociationController du backend
class AssociationService {
  final ApiService _apiService = ApiService();

  /// Créer une association enseignant-élève-témoin
  /// 
  /// Payload requis:
  /// - enseignant_id: ID de l'enseignant (required)
  /// - eleve_id: ID de l'élève (required)
  /// - temoin_id: ID du témoin (nullable)
  /// 
  /// Réponse backend:
  /// {
  ///   "message": "Association enregistrée avec succès",
  ///   "association": { ... }
  /// }
  Future<Map<String, dynamic>> createAssociation({
    required int enseignantId,
    required int eleveId,
    int? temoinId,
  }) async {
    final data = {
      'enseignant_id': enseignantId,
      'eleve_id': eleveId,
      'temoin_id': temoinId,
    };

    final response = await _apiService.post('/api/associations', data);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la création de l\'association: ${response.statusCode}');
    }
  }

  /// Récupérer toutes les associations (si endpoint disponible)
  Future<List<Map<String, dynamic>>> getAssociations() async {
    final response = await _apiService.get('/api/associations');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors du chargement des associations: ${response.statusCode}');
    }
  }
}
