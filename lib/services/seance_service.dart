import 'dart:convert';
import 'package:edumanager/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/seance_model.dart';

class SeanceService {
  static const String baseUrl = "http://192.168.137.80:8000";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token");
  }

  // Récupérer toutes les séances (pour l'enseignant)
  Future<List<Seance>> getSeances() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/emplois-enseignant"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Seance.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des séances: ${response.statusCode}");
    }
  }

  // Créer une ou plusieurs séances
  Future<List<Seance>> createSeances(List<Seance> seances) async {
    final token = await _getToken();
    
    final data = {
      'seances': seances.map((seance) => {
        'jour': seance.jour,
        'heure': seance.heure,
        'matiere': seance.matiere,
        'eleve_id': seance.idEleve,
        'temoin_id': seance.idTemoin,
        'parent_id': seance.idParent,
      }).toList(),
    };

    final response = await http.post(
      Uri.parse("$baseUrl/api/emploi"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final List<dynamic> seancesData = responseData['seances'];
      return seancesData.map((json) => Seance.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors de la création des séances: ${response.statusCode}");
    }
  }

  // Récupérer les séances de l'élève
  Future<List<Seance>> getSeancesEleve() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/emplois-eleve"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Seance.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des séances élève: ${response.statusCode}");
    }
  }

  // Récupérer les séances du parent
  Future<List<Seance>> getSeancesParent() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/emplois-parent"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Seance.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des séances parent: ${response.statusCode}");
    }
  }

  // Récupérer les séances du témoin
  Future<List<Seance>> getSeancesTemoin() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/api/emplois-temoin"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Seance.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des séances témoin: ${response.statusCode}");
    }
  }

  // Supprimer une séance
  Future<void> deleteSeance(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/api/emploi/$id"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Erreur lors de la suppression de la séance: ${response.statusCode}");
    }
  }

  // Récupérer les séances selon le rôle
  Future<List<Seance>> getSeancesByRole() async {
    final authService = AuthService();
    final role = await authService.getUserRole();
    
    switch (role) {
      case 'enseignant':
        return await getSeances();
        return await getSeancesEleve();
      case 'temoin':
        return await getSeancesTemoin();
      case 'parent':
        return await getSeancesParent();
      default:
        return await getSeances();
    }
  }

  // Créer une séance par l'enseignant (avec validation requise)
  Future<Map<String, dynamic>> createSeanceByEnseignant(Map<String, dynamic> data) async {
    print('🔄 [SeanceService] createSeanceByEnseignant - Début');
    print('📤 [SeanceService] Données à envoyer: $data');
    
    final token = await _getToken();
    print('🔑 [SeanceService] Token récupéré: ${token?.substring(0, 20)}...');
    
    final url = "$baseUrl/api/seances/enseignant";
    print('🌐 [SeanceService] URL: $url');
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(data),
      );

      print('📥 [SeanceService] Réponse reçue - Status: ${response.statusCode}');
      print('📥 [SeanceService] Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [SeanceService] Séance créée avec succès');
        return jsonDecode(response.body);
      } else {
        print('❌ [SeanceService] Erreur HTTP ${response.statusCode}');
        final error = jsonDecode(response.body);
        print('❌ [SeanceService] Erreur détaillée: $error');
        throw Exception(error['message'] ?? "Erreur lors de la création de la séance");
      }
    } catch (e, stackTrace) {
      print('❌ [SeanceService] EXCEPTION capturée');
      print('❌ Type: ${e.runtimeType}');
      print('❌ Message: $e');
      print('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }

  // Récupérer les séances en attente de validation (pour le parent)
  Future<List<Seance>> getSeancesEnAttente() async {
    final token = await _getToken();
    
    final response = await http.get(
      Uri.parse("$baseUrl/api/seances/en-attente"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Seance.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des séances en attente");
    }
  }

  // Valider une séance (parent)
  Future<void> validerSeance(int seanceId) async {
    final token = await _getToken();
    
    final response = await http.post(
      Uri.parse("$baseUrl/api/seances/$seanceId/valider"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? "Erreur lors de la validation");
    }
  }

  // Reprogrammer une séance (enseignant)
  Future<void> reprogrammerSeance(int seanceId, String jour, String heure) async {
    print('🔄 [SeanceService] reprogrammerSeance - Début');
    print('📤 [SeanceService] Séance ID: $seanceId, Jour: $jour, Heure: $heure');
    
    final token = await _getToken();
    final url = "$baseUrl/api/seances/$seanceId/reprogrammer";
    print('🌐 [SeanceService] URL: $url');
    
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'jour': jour,
          'heure': heure,
        }),
      );

      print('📥 [SeanceService] Réponse - Status: ${response.statusCode}');
      print('📥 [SeanceService] Body: ${response.body}');

      if (response.statusCode != 200) {
        print('❌ [SeanceService] Erreur HTTP ${response.statusCode}');
        final error = jsonDecode(response.body);
        print('❌ [SeanceService] Erreur: $error');
        throw Exception(error['message'] ?? "Erreur lors de la reprogrammation");
      }
      
      print('✅ [SeanceService] Reprogrammation réussie');
    } catch (e, stackTrace) {
      print('❌ [SeanceService] EXCEPTION');
      print('❌ Message: $e');
      print('❌ StackTrace: $stackTrace');
      rethrow;
    }
  }

  // Refuser une séance (parent)
  Future<void> refuserSeance(int seanceId) async {
    final token = await _getToken();
    
    final response = await http.post(
      Uri.parse("$baseUrl/api/seances/$seanceId/refuser"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? "Erreur lors du refus");
    }
  }

  // Récupérer les séances à valider pour le témoin
  Future<List<Seance>> getSeancesAValiderTemoin() async {
    final token = await _getToken();
    
    final response = await http.get(
      Uri.parse("$baseUrl/api/seances/temoin/a-valider"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Seance.fromJson(json)).toList();
    } else {
      throw Exception("Erreur lors du chargement des séances à valider");
    }
  }

  // Valider une séance (témoin)
  Future<void> validerSeanceTemoin(int seanceId) async {
    final token = await _getToken();
    
    final response = await http.post(
      Uri.parse("$baseUrl/api/seances/$seanceId/valider-temoin"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? "Erreur lors de la validation");
    }
  }
}