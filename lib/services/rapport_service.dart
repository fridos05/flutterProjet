import 'dart:convert';
import '../models/rapport_model.dart';
import 'api_service.dart';

/// Service pour gérer les rapports
/// Correspond aux contrôleurs RapportController et ParentController du backend
class RapportService {
  final ApiService _apiService = ApiService();

  /// Récupérer tous les rapports de l'enseignant connecté
  /// Endpoint: GET /api/rapports
  /// Réponse: Liste de rapports
  Future<List<Rapport>> getRapports() async {
    final response = await _apiService.get('/api/rapports');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => Rapport.fromJson(json)).toList();
    } else {
      throw Exception("Erreur rapports: ${response.body}");
    }
  }

  /// Créer un nouveau rapport (pour enseignant)
  /// Endpoint: POST /api/rapports
  /// 
  /// Payload requis:
  /// - parent_id: ID du parent (required)
  /// - date: Date du rapport (required, format: YYYY-MM-DD)
  /// - heure_debut: Heure de début (required, format: HH:mm)
  /// - heure_fin: Heure de fin (required, format: HH:mm)
  /// - contenu: Contenu du rapport (required)
  /// 
  /// Réponse:
  /// {
  ///   "message": "Rapport enregistré avec succès",
  ///   "rapport": { ... }
  /// }
  Future<Map<String, dynamic>> createRapport(Map<String, dynamic> body) async {
    final response = await _apiService.post('/api/rapports', body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur création rapport: ${response.body}");
    }
  }

  /// Récupérer un rapport spécifique par ID
  /// Endpoint: GET /api/rapports/{id}
  Future<Rapport> getRapport(int id) async {
    final response = await _apiService.get('/api/rapports/$id');

    if (response.statusCode == 200) {
      return Rapport.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Erreur lecture rapport: ${response.body}");
    }
  }

  /// Supprimer un rapport
  /// Endpoint: DELETE /api/rapports/{id}
  Future<void> deleteRapport(int id) async {
    final response = await _apiService.delete('/api/rapports/$id');

    if (response.statusCode != 200) {
      throw Exception("Erreur suppression rapport: ${response.body}");
    }
  }

  /// Récupérer les rapports du parent connecté
  /// Endpoint: GET /api/mes-rapports
  /// 
  /// Réponse: Liste de rapports avec infos enseignant et élèves
  /// [
  ///   {
  ///     "id": 1,
  ///     "date_rapport": "2024-01-15",
  ///     "heure_debut": "14:00",
  ///     "heure_fin": "15:00",
  ///     "contenu": "...",
  ///     "enseignant_nom": "Dupont",
  ///     "enseignant_prenom": "Jean",
  ///     "eleves": "Marie Martin, Paul Durand"
  ///   }
  /// ]
  Future<List<Map<String, dynamic>>> getMesRapports() async {
    final response = await _apiService.get('/api/mes-rapports');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception("Erreur mes rapports: ${response.body}");
    }
  }

  /// Créer un rapport pour une séance (enseignant)
  Future<Map<String, dynamic>> creerRapportSeance(int seanceId, String contenu) async {
    print('🔄 [RapportService] creerRapportSeance - Début');
    print('📤 [RapportService] Séance ID: $seanceId');
    print('📤 [RapportService] Contenu: ${contenu.substring(0, contenu.length > 50 ? 50 : contenu.length)}...');
    
    try {
      final response = await _apiService.post('/api/seances/$seanceId/rapport', {
        'contenu': contenu,
      });

      print('📥 [RapportService] Réponse - Status: ${response.statusCode}');
      print('📥 [RapportService] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [RapportService] Rapport créé avec succès');
        return jsonDecode(response.body);
      } else {
        print('❌ [RapportService] Erreur HTTP ${response.statusCode}');
        print('❌ [RapportService] Body: ${response.body}');
        throw Exception("Erreur création rapport: ${response.body}");
      }
    } catch (e, stackTrace) {
      print('❌ [RapportService] EXCEPTION capturée');
      print('❌ Type: ${e.runtimeType}');
      print('❌ Message: $e');
      print('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Récupérer les rapports validés (parent)
  Future<List<Map<String, dynamic>>> getRapportsValides() async {
    print('🔄 [RapportService] getRapportsValides - Début');
    
    try {
      final response = await _apiService.get('/api/rapports/valides');
      
      print('📥 [RapportService] Réponse - Status: ${response.statusCode}');
      print('📥 [RapportService] Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        print('✅ [RapportService] ${data.length} rapports reçus');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ [RapportService] Erreur HTTP ${response.statusCode}');
        throw Exception("Erreur rapports validés: ${response.body}");
      }
    } catch (e, stackTrace) {
      print('❌ [RapportService] EXCEPTION');
      print('❌ Message: $e');
      print('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }
}
