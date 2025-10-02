import 'dart:convert';
import 'package:flutter/foundation.dart'; // pour debugPrint
import 'api_service.dart';
import 'email_service.dart';

class EnseignantService {
  final ApiService _apiService = ApiService();
  final EmailService _emailService = EmailService();

  Future<List<Map<String, dynamic>>> getEnseignants() async {
    debugPrint('📡 [EnseignantService] GET /api/enseignant/index');
    final response = await _apiService.get('/api/enseignant/index');

    debugPrint('📥 Status: ${response.statusCode}');
    debugPrint('📥 Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      debugPrint('✅ Données décodées: $data');
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur chargement enseignants: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createEnseignant(
    Map<String, dynamic> data, {
    bool envoyerEmail = true,
  }) async {
    debugPrint('📡 [EnseignantService] POST /api/enseignant/store');
    debugPrint('➡️ Payload: $data');

    final response = await _apiService.post('/api/enseignant/store', data);

    debugPrint('📥 Status: ${response.statusCode}');
    debugPrint('📥 Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = json.decode(response.body);
      debugPrint('✅ JSON décodé: $responseBody');

      Map<String, dynamic> result;
      if (responseBody is String) {
        result = {'message': responseBody, 'enseignant': data};
      } else {
        result = responseBody;
      }

      if (envoyerEmail && data['courriel'] != null) {
        try {
          final nomComplet = '${data['prenom']} ${data['nom_famille']}';
          await _emailService.envoyerMotDePasse(
            destinataire: data['courriel'],
            nomComplet: nomComplet,
            motDePasse: 'password',
            role: 'enseignant',
          );
          debugPrint('📧 Email envoyé à ${data['courriel']}');
          result['email_envoye'] = true;
        } catch (emailError) {
          debugPrint('❌ Erreur envoi email: $emailError');
          result['email_envoye'] = false;
        }
      }
      return result;
    } else {
      throw Exception('Erreur création enseignant: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getMesEleves() async {
    debugPrint('📡 [EnseignantService] GET /api/mes-eleves');
    try {
      final response = await _apiService.get('/api/mes-eleves');
      debugPrint('📥 Status: ${response.statusCode}');
      debugPrint('📥 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('✅ JSON décodé: $data');
        return data;
      } else {
        throw Exception('Erreur chargement élèves: ${response.statusCode}');
      }
    } catch (e, stack) {
      debugPrint('❌ Exception: $e');
      debugPrint('❌ Stack: $stack');
      rethrow;
    }
  }
}
