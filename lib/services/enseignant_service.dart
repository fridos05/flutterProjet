import 'dart:convert';
import 'api_service.dart';
import 'email_service.dart';

class EnseignantService {
  final ApiService _apiService = ApiService();
  final EmailService _emailService = EmailService();

  // Récupérer tous les enseignants du parent connecté
  // Backend retourne: [{ "id": 1, "id_parent": 1, "id_enseignant": 2, "enseignant": {...}, "parent": {...}, "associations": [...] }]
  Future<List<Map<String, dynamic>>> getEnseignants() async {
    final response = await _apiService.get('/api/enseignant/index');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors du chargement des enseignants: ${response.statusCode}');
    }
  }

  /// Créer un enseignant (le backend génère automatiquement le mot de passe = "password")
  /// 
  /// Payload: { "prenom": "...", "nom_famille": "...", "courriel": "...", "mode_paiement": "...", "salaire": 0 }
  /// Réponse: "Enrégistrement effectué avec succes"
  /// 
  /// Paramètres:
  /// - data: Données de l'enseignant
  /// - envoyerEmail: Si true, envoie automatiquement le mot de passe par email (défaut: true)
  Future<Map<String, dynamic>> createEnseignant(
    Map<String, dynamic> data, {
    bool envoyerEmail = true,
  }) async {
    final response = await _apiService.post('/api/enseignant/store', data);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = json.decode(response.body);
      Map<String, dynamic> result;
      
      // Le backend retourne juste un message string, on le wrap dans un objet
      if (responseBody is String) {
        result = {
          'message': responseBody,
          'enseignant': data, // On retourne les données envoyées
        };
      } else {
        result = responseBody;
      }
      
      // Envoyer le mot de passe par email si demandé
      // Note: Le backend utilise 'password' comme mot de passe par défaut
      if (envoyerEmail && data['courriel'] != null) {
        try {
          final nomComplet = '${data['prenom']} ${data['nom_famille']}';
          
          await _emailService.envoyerMotDePasse(
            destinataire: data['courriel'],
            nomComplet: nomComplet,
            motDePasse: 'password', // Mot de passe par défaut du backend
            role: 'enseignant',
          );
          
          result['email_envoye'] = true;
          result['mot_de_passe_defaut'] = 'password';
        } catch (emailError) {
          result['email_envoye'] = false;
          result['email_erreur'] = emailError.toString();
          result['mot_de_passe_defaut'] = 'password';
        }
      }
      
      return result;
    } else {
      throw Exception('Erreur lors de la création: ${response.statusCode}');
    }
  }

  // Note: Le backend ne semble pas avoir de route update pour enseignant
  Future<Map<String, dynamic>> updateEnseignant(int id, Map<String, dynamic> data) async {
    final response = await _apiService.put('/api/enseignant/$id', data);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la mise à jour: ${response.statusCode}');
    }
  }

  // Note: Le backend ne semble pas avoir de route delete pour enseignant
  Future<void> deleteEnseignant(int id) async {
    final response = await _apiService.delete('/api/enseignant/$id');
    
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression: ${response.statusCode}');
    }
  }

  // Récupérer les statistiques des enseignants (pour le parent)
  // Réponse: { "total": 5, "actifs": 3, "inactifs": 2 }
  Future<Map<String, dynamic>> getStats() async {
    final response = await _apiService.get('/api/enseignant/stats');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des statistiques: ${response.statusCode}');
    }
  }

  // Récupérer les élèves de l'enseignant connecté (pour vue enseignant)
  // Réponse: { "enseignant_id": 1, "parent": {...}, "eleves": [...], "temoins": [...] }
  Future<Map<String, dynamic>> getMesEleves() async {
    print('🔄 [EnseignantService] getMesEleves - Début');
    
    try {
      print('📡 [EnseignantService] Appel API /api/mes-eleves');
      final response = await _apiService.get('/api/mes-eleves');
      
      print('📥 [EnseignantService] Réponse reçue - Status: ${response.statusCode}');
      print('📥 [EnseignantService] Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ [EnseignantService] Données décodées: $data');
        return data;
      } else {
        print('❌ [EnseignantService] Erreur HTTP ${response.statusCode}');
        print('❌ [EnseignantService] Body: ${response.body}');
        throw Exception('Erreur lors du chargement des élèves: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ [EnseignantService] EXCEPTION capturée');
      print('❌ Type: ${e.runtimeType}');
      print('❌ Message: $e');
      print('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }
}