import 'dart:convert';
import 'package:edumanager/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/seance_model.dart';

class SeanceServiceDebug {
  static const String baseUrl = "http://192.168.137.80:8000";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token");
    print('🔑 Token récupéré: ${token?.substring(0, 20)}...');
    return token;
  }

  // Créer une ou plusieurs séances avec logs détaillés
  Future<List<Seance>> createSeances(List<Seance> seances) async {
    print('\n════════════════════════════════════════════════════════');
    print('📝 DÉBUT DE LA CRÉATION DE ${seances.length} SÉANCE(S)');
    print('════════════════════════════════════════════════════════\n');
    
    try {
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        print('❌ ERREUR: Token manquant ou vide');
        throw Exception('Token d\'authentification manquant');
      }
      
      final data = {
        'seances': seances.map((seance) {
          final seanceData = {
            'jour': seance.jour,
            'heure': seance.heure,
            'matiere': seance.matiere,
            'eleve_id': seance.idEleve,
            'temoin_id': seance.idTemoin,
            'parent_id': seance.idParent,
          };
          print('📄 Séance à créer:');
          print('   - Jour: ${seance.jour}');
          print('   - Heure: ${seance.heure}');
          print('   - Matière: ${seance.matiere}');
          print('   - Élève ID: ${seance.idEleve}');
          print('   - Témoin ID: ${seance.idTemoin}');
          print('   - Parent ID: ${seance.idParent}');
          return seanceData;
        }).toList(),
      };

      print('\n📤 ENVOI DE LA REQUÊTE:');
      print('   URL: $baseUrl/api/emploi');
      print('   Méthode: POST');
      print('   Headers:');
      print('     - Authorization: Bearer ${token.substring(0, 20)}...');
      print('     - Accept: application/json');
      print('     - Content-Type: application/json');
      print('   Body (JSON):');
      print('${json.encode(data)}\n');

      final response = await http.post(
        Uri.parse("$baseUrl/api/emploi"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: json.encode(data),
      );

      print('📥 RÉPONSE DU SERVEUR:');
      print('   Status Code: ${response.statusCode}');
      print('   Status Message: ${response.reasonPhrase}');
      print('   Headers: ${response.headers}');
      print('   Body:');
      print('${response.body}\n');

      if (response.statusCode == 201) {
        print('✅ SUCCÈS: Séances créées avec succès!');
        final responseData = jsonDecode(response.body);
        final List<dynamic> seancesData = responseData['seances'];
        print('   Nombre de séances créées: ${seancesData.length}');
        
        final createdSeances = seancesData.map((json) => Seance.fromJson(json)).toList();
        
        print('\n════════════════════════════════════════════════════════');
        print('✅ FIN DE LA CRÉATION - SUCCÈS');
        print('════════════════════════════════════════════════════════\n');
        
        return createdSeances;
      } else {
        print('❌ ERREUR: Le serveur a retourné un code ${response.statusCode}');
        
        // Essayer de parser l'erreur
        try {
          final errorData = jsonDecode(response.body);
          print('   Détails de l\'erreur:');
          print('${json.encode(errorData)}');
        } catch (e) {
          print('   Corps de l\'erreur (brut):');
          print('${response.body}');
        }
        
        print('\n════════════════════════════════════════════════════════');
        print('❌ FIN DE LA CRÉATION - ÉCHEC');
        print('════════════════════════════════════════════════════════\n');
        
        throw Exception("Erreur ${response.statusCode}: ${response.body}");
      }
    } catch (e, stackTrace) {
      print('\n💥 EXCEPTION CAPTURÉE:');
      print('   Type: ${e.runtimeType}');
      print('   Message: $e');
      print('   Stack trace:');
      print('$stackTrace');
      
      print('\n════════════════════════════════════════════════════════');
      print('💥 FIN DE LA CRÉATION - EXCEPTION');
      print('════════════════════════════════════════════════════════\n');
      
      rethrow;
    }
  }

  // Récupérer toutes les séances avec logs
  Future<List<Seance>> getSeances() async {
    print('\n📋 Récupération des séances...');
    
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse("$baseUrl/api/emploi"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print('📥 Réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ ${data.length} séance(s) récupérée(s)');
        return data.map((json) => Seance.fromJson(json)).toList();
      } else {
        print('❌ Erreur: ${response.statusCode} - ${response.body}');
        throw Exception("Erreur lors du chargement des séances: ${response.statusCode}");
      }
    } catch (e) {
      print('💥 Exception: $e');
      rethrow;
    }
  }

  // Supprimer une séance avec logs
  Future<void> deleteSeance(int id) async {
    print('\n🗑️ Suppression de la séance ID: $id');
    
    try {
      final token = await _getToken();
      
      final response = await http.delete(
        Uri.parse("$baseUrl/api/emploi/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print('📥 Réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Séance supprimée avec succès');
      } else {
        print('❌ Erreur: ${response.statusCode} - ${response.body}');
        throw Exception("Erreur lors de la suppression: ${response.statusCode}");
      }
    } catch (e) {
      print('💥 Exception: $e');
      rethrow;
    }
  }

  // Récupérer les séances selon le rôle
  Future<List<Seance>> getSeancesByRole() async {
    print('\n👤 Récupération des séances selon le rôle...');
    
    final authService = AuthService();
    final role = await authService.getUserRole();
    
    print('   Rôle détecté: $role');
    
    final token = await _getToken();
    String endpoint;
    
    switch (role) {
      case 'enseignant':
        endpoint = '/api/emploi';
        break;
      case 'eleve':
        endpoint = '/api/emplois-eleve';
        break;
      case 'temoin':
        endpoint = '/api/emplois-temoin';
        break;
      case 'parent':
        endpoint = '/api/emplois-parent';
        break;
      default:
        endpoint = '/api/emploi';
    }
    
    print('   Endpoint: $endpoint');
    
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$endpoint"),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      print('📥 Réponse: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('✅ ${data.length} séance(s) récupérée(s)');
        return data.map((json) => Seance.fromJson(json)).toList();
      } else {
        print('❌ Erreur: ${response.statusCode} - ${response.body}');
        throw Exception("Erreur: ${response.statusCode}");
      }
    } catch (e) {
      print('💥 Exception: $e');
      rethrow;
    }
  }
}
