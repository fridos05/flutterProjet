import 'dart:convert';
import 'api_service.dart';
import 'email_service.dart';

class TemoinService {
  final ApiService _apiService = ApiService();
  final EmailService _emailService = EmailService();

  // Récupérer tous les témoins du parent connecté
  // Backend retourne: [{ "id": 1, "id_parent": 1, "id_temoin": 2, "temoin": {...}, "parent": {...} }]
  Future<List<Map<String, dynamic>>> getTemoins() async {
    final response = await _apiService.get('/api/temoin/index');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors du chargement des témoins: ${response.statusCode}');
    }
  }

  // Alias pour getTemoins (même endpoint)
  Future<List<Map<String, dynamic>>> getParentTemoins() async {
    return getTemoins();
  }

  /// Créer un témoin (le backend génère automatiquement le mot de passe = "password")
  /// 
  /// Payload: { "nom": "...", "prenom": "...", "courriel": "..." }
  /// Réponse: "Enregistrement reussi"
  /// 
  /// Paramètres:
  /// - data: Données du témoin
  /// - envoyerEmail: Si true, envoie automatiquement le mot de passe par email (défaut: true)
  Future<Map<String, dynamic>> createTemoin(
    Map<String, dynamic> data, {
    bool envoyerEmail = true,
  }) async {
    final response = await _apiService.post('/api/temoin/store', data);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = json.decode(response.body);
      Map<String, dynamic> result;
      
      // Le backend retourne juste un message string, on le wrap dans un objet
      if (responseBody is String) {
        result = {
          'message': responseBody,
          'temoin': data, // On retourne les données envoyées
        };
      } else {
        result = responseBody;
      }
      
      // Envoyer le mot de passe par email si demandé
      // Note: Le backend utilise 'password' comme mot de passe par défaut
      if (envoyerEmail && data['courriel'] != null) {
        try {
          final nomComplet = '${data['prenom']} ${data['nom']}';
          
          await _emailService.envoyerMotDePasse(
            destinataire: data['courriel'],
            nomComplet: nomComplet,
            motDePasse: 'password', // Mot de passe par défaut du backend
            role: 'temoin',
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

  // Note: Le backend ne semble pas avoir de routes update/delete pour témoin
  Future<Map<String, dynamic>> updateTemoin(int id, Map<String, dynamic> data) async {
    final response = await _apiService.put('/api/temoin/$id', data);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la mise à jour: ${response.statusCode}');
    }
  }

  Future<void> deleteTemoin(int id) async {
    final response = await _apiService.delete('/api/temoin/$id');
    
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression: ${response.statusCode}');
    }
  }
}