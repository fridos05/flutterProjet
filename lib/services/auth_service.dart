import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const String baseUrl = "http://192.168.137.80:8000";
  
  void _log(String message, {dynamic data}) {
    developer.log(
      message,
      name: 'AuthService',
      time: DateTime.now(),
    );
    if (data != null) {
      developer.log(
        'Data: ${json.encode(data)}',
        name: 'AuthService',
      );
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  Future<void> _saveToken(String token) async {
    await ApiService.saveToken(token);
  }

  Future<void> _clearToken() async {
    await ApiService.removeToken();
  }

  // Connexion
  Future<Map<String, dynamic>> login(String courriel, String motDePasse, String role) async {
    print('\n════════════════════════════════════════════════════════');
    print('🔐 DÉBUT DE LA CONNEXION');
    print('════════════════════════════════════════════════════════\n');
    
    print('📋 Informations de connexion:');
    print('   - Email: $courriel');
    print('   - Rôle: $role');
    print('   - Mot de passe: ${motDePasse.replaceAll(RegExp(r'.'), '*')}');
    
    try {
      final url = "$baseUrl/api/login";
      final requestBody = {
        "courriel": courriel,
        "mot_de_passe": motDePasse,
        "role": role,
      };
      
      print('\n📤 ENVOI DE LA REQUÊTE:');
      print('   URL: $url');
      print('   Méthode: POST');
      print('   Headers:');
      print('     - Accept: application/json');
      print('     - Content-Type: application/json');
      print('   Body (JSON):');
      print('${json.encode(requestBody)}\n');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ TIMEOUT: Le serveur ne répond pas après 30 secondes');
          throw Exception('⏱️ Timeout: Le serveur ne répond pas');
        },
      );

      print('📥 RÉPONSE DU SERVEUR:');
      print('   Status Code: ${response.statusCode}');
      print('   Status Message: ${response.reasonPhrase}');
      print('   Headers: ${response.headers}');
      print('   Body:');
      print('${response.body}\n');

      if (response.statusCode == 200) {
        print('✅ SUCCÈS: Connexion réussie!');
        
        final data = jsonDecode(response.body);
        print('   Token reçu: ${data["token"]?.substring(0, 20)}...');
        print('   User: ${data['user']}');
        print('   Rôle: ${data['role']}');
        
        await _saveToken(data["token"]);
        print('   💾 Token sauvegardé');
        
        // Sauvegarder le rôle de l'utilisateur
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', role);
        await prefs.setString('user_data', json.encode(data['user']));
        print('   💾 Données utilisateur sauvegardées');
        
        print('\n════════════════════════════════════════════════════════');
        print('✅ FIN DE LA CONNEXION - SUCCÈS');
        print('════════════════════════════════════════════════════════\n');
        
        return data;
      } else {
        print('❌ ERREUR: Le serveur a retourné un code ${response.statusCode}');
        
        try {
          final errorData = jsonDecode(response.body);
          print('   Détails de l\'erreur:');
          print('${json.encode(errorData)}');
          final errorMsg = errorData['message'] ?? "Échec de la connexion: ${response.statusCode}";
          
          print('\n════════════════════════════════════════════════════════');
          print('❌ FIN DE LA CONNEXION - ÉCHEC');
          print('════════════════════════════════════════════════════════\n');
          
          throw Exception(errorMsg);
        } catch (e) {
          print('   Corps de l\'erreur (brut):');
          print('${response.body}');
          
          print('\n════════════════════════════════════════════════════════');
          print('❌ FIN DE LA CONNEXION - ÉCHEC');
          print('════════════════════════════════════════════════════════\n');
          
          throw Exception("Échec de la connexion: ${response.statusCode}");
        }
      }
    } catch (e, stackTrace) {
      print('\n💥 EXCEPTION CAPTURÉE:');
      print('   Type: ${e.runtimeType}');
      print('   Message: $e');
      print('   Stack trace:');
      print('$stackTrace');
      
      print('\n════════════════════════════════════════════════════════');
      print('💥 FIN DE LA CONNEXION - EXCEPTION');
      print('════════════════════════════════════════════════════════\n');
      
      rethrow;
    }
  }

  // Inscription (uniquement pour les parents)
  Future<Map<String, dynamic>> register({
    required String prenomNom,
    required String nomFamille,
    required String courriel,
    required String motDePasse,
    required String motDePasseConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/register"),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode({
          "prenom_nom": prenomNom,
          "nom_famille": nomFamille,
          "courriel": courriel,
          "mot_de_passe": motDePasse,
          "mot_de_passe_confirmation": motDePasseConfirmation,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await _saveToken(data['token']);
          // Sauvegarder le rôle parent par défaut
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_role', 'parent');
          await prefs.setString('user_data', json.encode(data['user']));
        }
        return data;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Échec de l'inscription: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur d'inscription: $e");
    }
  }

  // Déconnexion
  Future<void> logout() async {
    try {
      final token = await _getToken();
      if (token == null) {
        await _clearToken();
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/api/logout"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      await _clearToken();
      
      // Supprimer les données utilisateur
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_role');
      await prefs.remove('user_data');

      if (response.statusCode != 200) {
        throw Exception("Erreur lors de la déconnexion: ${response.statusCode}");
      }
    } catch (e) {
      await _clearToken();
      throw Exception("Erreur de déconnexion: $e");
    }
  }

  // Récupérer le rôle de l'utilisateur
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  // Récupérer les données utilisateur
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return json.decode(userDataString);
    }
    return null;
  }
}