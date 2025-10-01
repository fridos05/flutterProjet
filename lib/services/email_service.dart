import 'dart:convert';
import 'api_service.dart';

/// Service pour envoyer des emails via le backend
/// Le backend doit avoir un endpoint pour envoyer des emails
class EmailService {
  final ApiService _apiService = ApiService();

  /// Envoyer un email avec le mot de passe à un nouvel utilisateur
  /// 
  /// Paramètres:
  /// - destinataire: Email du destinataire
  /// - nomComplet: Nom complet de l'utilisateur
  /// - motDePasse: Mot de passe généré
  /// - role: Rôle de l'utilisateur (eleve, enseignant, temoin)
  Future<void> envoyerMotDePasse({
    required String destinataire,
    required String nomComplet,
    required String motDePasse,
    required String role,
  }) async {
    try {
      final data = {
        'destinataire': destinataire,
        'nom_complet': nomComplet,
        'mot_de_passe': motDePasse,
        'role': role,
      };

      final response = await _apiService.post('/api/send-password', data);
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur lors de l\'envoi de l\'email: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur d\'envoi d\'email: $e');
    }
  }

  /// Envoyer un email de bienvenue personnalisé
  Future<void> envoyerEmailBienvenue({
    required String destinataire,
    required String nomComplet,
    required String motDePasse,
    required String role,
    String? messagePersonnalise,
  }) async {
    try {
      final data = {
        'destinataire': destinataire,
        'nom_complet': nomComplet,
        'mot_de_passe': motDePasse,
        'role': role,
        'message_personnalise': messagePersonnalise,
      };

      final response = await _apiService.post('/api/send-welcome-email', data);
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur lors de l\'envoi de l\'email de bienvenue: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur d\'envoi d\'email de bienvenue: $e');
    }
  }

  /// Envoyer un SMS avec le mot de passe (si le backend supporte les SMS)
  Future<void> envoyerSMSMotDePasse({
    required String telephone,
    required String nomComplet,
    required String motDePasse,
  }) async {
    try {
      final data = {
        'telephone': telephone,
        'nom_complet': nomComplet,
        'mot_de_passe': motDePasse,
      };

      final response = await _apiService.post('/api/send-sms-password', data);
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur lors de l\'envoi du SMS: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur d\'envoi de SMS: $e');
    }
  }
}

/// Service local pour afficher le mot de passe (fallback si email ne fonctionne pas)
class PasswordDisplayService {
  /// Générer un message formaté avec le mot de passe
  static String genererMessageMotDePasse({
    required String nomComplet,
    required String email,
    required String motDePasse,
    required String role,
  }) {
    String roleLabel;
    switch (role.toLowerCase()) {
      case 'eleve':
        roleLabel = 'Élève';
        break;
      case 'enseignant':
        roleLabel = 'Enseignant';
        break;
      case 'temoin':
        roleLabel = 'Témoin';
        break;
      default:
        roleLabel = role;
    }

    return '''
Compte créé avec succès !

Nom: $nomComplet
Rôle: $roleLabel
Email: $email

Mot de passe temporaire: $motDePasse

⚠️ IMPORTANT:
- Notez ce mot de passe et envoyez-le à l'utilisateur
- L'utilisateur devra changer ce mot de passe lors de sa première connexion
- Ne partagez jamais ce mot de passe par des moyens non sécurisés
''';
  }

  /// Générer un message court pour copier-coller
  static String genererMessageCourt({
    required String email,
    required String motDePasse,
  }) {
    return 'Email: $email\nMot de passe: $motDePasse';
  }
}
