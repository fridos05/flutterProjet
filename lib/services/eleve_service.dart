import 'dart:convert';
import 'api_service.dart';
import 'email_service.dart';

class EleveService {
  final ApiService _apiService = ApiService();
  final EmailService _emailService = EmailService();

  // Récupérer tous les élèves du parent connecté
  // Backend retourne: [{ "id": 1, "id_parent": 1, "id_eleve": 2, "eleve": {...}, "parent": {...} }]
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
    // Chaque élément est { "id": ..., "eleve": {...}, "parent": {...} }
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

  /// Créer un élève (le backend génère automatiquement le mot de passe)
  /// 
  /// Payload: { "nom_famille": "...", "prenom": "...", "courriel": "...", "niveau_id": 1 }
  /// Réponse: { "message": "...", "eleve": {...}, "parent_relation": {...}, "password": "..." }
  /// 
  /// Paramètres:
  /// - data: Données de l'élève
  /// - envoyerEmail: Si true, envoie automatiquement le mot de passe par email (défaut: true)
  Future<Map<String, dynamic>> createEleve(
    Map<String, dynamic> data, {
    bool envoyerEmail = true,
  }) async {
    final response = await _apiService.post('/api/eleve/store', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = json.decode(response.body);
      
      // Envoyer le mot de passe par email si demandé
      if (envoyerEmail && result['password'] != null && result['eleve'] != null) {
        try {
          final eleve = result['eleve'];
          final nomComplet = '${eleve['prenom']} ${eleve['nom_famille']}';
          
          await _emailService.envoyerMotDePasse(
            destinataire: eleve['courriel'],
            nomComplet: nomComplet,
            motDePasse: result['password'],
            role: 'eleve',
          );
          
          // Ajouter un flag pour indiquer que l'email a été envoyé
          result['email_envoye'] = true;
        } catch (emailError) {
          // Si l'envoi d'email échoue, on continue mais on signale l'erreur
          result['email_envoye'] = false;
          result['email_erreur'] = emailError.toString();
        }
      }
      
      return result;
    } else {
      throw Exception('Erreur lors de la création: ${response.statusCode}');
    }
  }

  // Note: Le backend ne semble pas avoir de route update pour élève
  // Si nécessaire, il faudra l'ajouter côté backend
  Future<Map<String, dynamic>> updateEleve(int id, Map<String, dynamic> data) async {
    final response = await _apiService.put('/api/eleve/$id', data);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la mise à jour de l\'élève: ${response.statusCode}');
    }
  }

  // Note: Le backend ne semble pas avoir de route delete pour élève
  // Si nécessaire, il faudra l'ajouter côté backend
  Future<void> deleteEleve(int id) async {
    final response = await _apiService.delete('/api/eleve/$id');
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression: ${response.statusCode}');
    }
  }
}
