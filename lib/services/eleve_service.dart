import 'dart:convert';
import 'package:flutter/foundation.dart'; // pour debugPrint
import 'api_service.dart';
import 'email_service.dart';

class EleveService {
  final ApiService _apiService = ApiService();
  final EmailService _emailService = EmailService();

  Future<List<Map<String, dynamic>>> getParentEleves() async {
    debugPrint('📡 [EleveService] GET /api/eleve/index');
    final response = await _apiService.get('/api/eleve/index');

    debugPrint('📥 Status: ${response.statusCode}');
    debugPrint('📥 Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      debugPrint('✅ Données décodées: $data');
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur chargement élèves: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createEleve(
    Map<String, dynamic> data, {
    bool envoyerEmail = true,
  }) async {
    debugPrint('📡 [EleveService] POST /api/eleve/store');
    debugPrint('➡️ Payload: $data');

    final response = await _apiService.post('/api/eleve/store', data);

    debugPrint('📥 Status: ${response.statusCode}');
    debugPrint('📥 Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = json.decode(response.body);
      debugPrint('✅ JSON décodé: $result');

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
          debugPrint('📧 Email envoyé à ${eleve['courriel']}');
          result['email_envoye'] = true;
        } catch (emailError) {
          debugPrint('❌ Erreur envoi email: $emailError');
          result['email_envoye'] = false;
        }
      }

      return result;
    } else {
      throw Exception('Erreur création élève: ${response.statusCode}');
    }
  }
}
