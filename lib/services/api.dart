// Configuration de base de l'API
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000'; // Adaptez selon votre environnement
  static const int timeoutSeconds = 30;
}

// Constantes pour les endpoints API
class ApiEndpoints {
  // Authentification
  static const String login = '/api/login';
  static const String register = '/api/register';
  static const String logout = '/api/logout';
  static const String csrfCookie = '/sanctum/csrf-cookie';
  
  // Élèves
  static const String eleveIndex = '/api/eleve/index';
  static const String eleveStore = '/api/eleve/store';
  static const String parentEleve = '/api/eleve';
  
  // Enseignants
  static const String enseignantIndex = '/api/enseignant/index';
  static const String enseignantStore = '/api/enseignant/store';
  static const String mesEleves = '/api/mes-eleves';
  static const String parentStats = '/api/parent/stats';
  
  // Témoins
  static const String temoinIndex = '/api/temoin/index';
  static const String temoinStore = '/api/temoin/store';
  static const String parentTemoin = '/api/temoin';
  
  // Emplois du temps
  static const String emploiIndex = '/api/emploi';
  static const String emploiStore = '/api/emploi';
  static const String emplois = '/api/emplois';
  static const String emploisEleve = '/api/emplois-eleve';
  static const String emploisParent = '/api/emplois-parent';
  static const String emploisTemoin = '/api/emplois-temoin';
  
  // Rapports
  static const String rapportsIndex = '/api/rapports';
  static const String rapportsStore = '/api/rapports';
  static const String mesRapports = '/api/mes-rapports';
  static String rapportShow(int id) => '/api/rapports/$id';
  static String rapportDelete(int id) => '/api/rapports/$id';
  
  // Divers
  static const String niveauIndex = '/api/niveau/index';
  static const String associations = '/api/associations';
}

// Modèles de données basés sur votre backend
class LoginRequest {
  final String courriel;
  final String motDePasse;
  final String role; // 'parent', 'eleve', 'temoin', 'enseignant'

  LoginRequest({
    required this.courriel,
    required this.motDePasse,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'courriel': courriel,
    'mot_de_passe': motDePasse,
    'role': role,
  };
}

class RegisterRequest {
  final String prenomNom;
  final String nomFamille;
  final String courriel;
  final String motDePasse;
  final String motDePasseConfirmation;

  RegisterRequest({
    required this.prenomNom,
    required this.nomFamille,
    required this.courriel,
    required this.motDePasse,
    required this.motDePasseConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'prenom_nom': prenomNom,
    'nom_famille': nomFamille,
    'courriel': courriel,
    'mot_de_passe': motDePasse,
    'mot_de_passe_confirmation': motDePasseConfirmation,
  };
}

class EleveRequest {
  final String nomFamille;
  final String prenom;
  final String courriel;

  EleveRequest({
    required this.nomFamille,
    required this.prenom,
    required this.courriel,
  });

  Map<String, dynamic> toJson() => {
    'nom_famille': nomFamille,
    'prenom': prenom,
    'courriel': courriel,
  };
}

class EnseignantRequest {
  final String nomFamille;
  final String prenom;
  final String courriel;

  EnseignantRequest({
    required this.nomFamille,
    required this.prenom,
    required this.courriel,
  });

  Map<String, dynamic> toJson() => {
    'nom_famille': nomFamille,
    'prenom': prenom,
    'courriel': courriel,
  };
}

class TemoinRequest {
  final String nom;
  final String prenom;
  final String courriel;

  TemoinRequest({
    required this.nom,
    required this.prenom,
    required this.courriel,
  });

  Map<String, dynamic> toJson() => {
    'nom': nom,
    'prenom': prenom,
    'courriel': courriel,
  };
}

class RapportRequest {
  final int parentId;
  final String date;
  final String heureDebut;
  final String heureFin;
  final String contenu;

  RapportRequest({
    required this.parentId,
    required this.date,
    required this.heureDebut,
    required this.heureFin,
    required this.contenu,
  });

  Map<String, dynamic> toJson() => {
    'parent_id': parentId,
    'date': date,
    'heure_debut': heureDebut,
    'heure_fin': heureFin,
    'contenu': contenu,
  };
}

class AssociationRequest {
  final int enseignantId;
  final int eleveId;
  final int? temoinId;

  AssociationRequest({
    required this.enseignantId,
    required this.eleveId,
    this.temoinId,
  });

  Map<String, dynamic> toJson() => {
    'enseignant_id': enseignantId,
    'eleve_id': eleveId,
    'temoin_id': temoinId,
  };
}

// Modèles de réponse
class LoginResponse {
  final String message;
  final String token;
  final String role;
  final dynamic user;
  final dynamic parentInfo;

  LoginResponse({
    required this.message,
    required this.token,
    required this.role,
    required this.user,
    this.parentInfo,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      role: json['role'] ?? '',
      user: json['user'],
      parentInfo: json['parent_info'] ?? json['parent_eleve'] ?? json['parent_enseignant'] ?? json['parent_temoin'],
    );
  }
}

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<dynamic>? errors;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode = 200,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJson) {
    return ApiResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      data: fromJson != null && json['data'] != null ? fromJson(json['data']) : json['data'],
      errors: json['errors'] != null ? List<dynamic>.from(json['errors']) : null,
      statusCode: json['status_code'] ?? 200,
    );
  }
}

// Service principal pour les appels API
class ApiService {
  final String baseUrl;

  ApiService({this.baseUrl = ApiConfig.baseUrl});

  // Headers communs
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Méthode utilitaire pour construire les URLs
  String buildUrl(String endpoint) => baseUrl + endpoint;
}

// Exceptions personnalisées
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  ApiException(this.message, this.statusCode, [this.data]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

// Gestionnaire de tokens
class TokenManager {
  static const String tokenKey = 'auth_token';
  static const String roleKey = 'user_role';
  static const String userKey = 'user_data';

  static Future<void> saveAuthData(String token, String role, dynamic userData) async {
    // Implémentation avec shared_preferences
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString(tokenKey, token);
    // await prefs.setString(roleKey, role);
    // await prefs.setString(userKey, json.encode(userData));
  }

  static Future<String?> getToken() async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString(tokenKey);
    return null;
  }

  static Future<String?> getRole() async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString(roleKey);
    return null;
  }

  static Future<void> clearAuthData() async {
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.remove(tokenKey);
    // await prefs.remove(roleKey);
    // await prefs.remove(userKey);
  }
}

// Services spécialisés par domaine
class AuthService {
  final ApiService apiService = ApiService();

  Future<LoginResponse> login(LoginRequest request) async {
    // Implémentation avec http ou dio
    // Exemple avec http:
    // final response = await http.post(
    //   Uri.parse(apiService.buildUrl(ApiEndpoints.login)),
    //   headers: ApiService.headers,
    //   body: json.encode(request.toJson()),
    // );
    
    // Simuler une réponse pour l'exemple
    return LoginResponse.fromJson({
      'message': 'Connexion réussie',
      'token': 'example_token',
      'role': request.role,
      'user': {'id': 1, 'prenom_nom': 'Test User'},
    });
  }

  Future<ApiResponse<dynamic>> register(RegisterRequest request) async {
    // Implémentation similaire
    return ApiResponse(
      success: true,
      message: 'Utilisateur créé avec succès',
      data: {'user': {}},
    );
  }

  Future<void> logout(String token) async {
    // Implémentation de la déconnexion
    await TokenManager.clearAuthData();
  }
}

class EleveService {
  final ApiService apiService = ApiService();

  Future<ApiResponse<List<dynamic>>> getEleves(String token) async {
    try {
      // Implémentation pour récupérer les élèves
      return ApiResponse(
        success: true,
        message: 'Élèves récupérés avec succès',
        data: [],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  Future<ApiResponse<dynamic>> createEleve(EleveRequest request, String token) async {
    // Implémentation de la création d'élève
    return ApiResponse(
      success: true,
      message: 'Élève créé avec succès',
      data: {'eleve': {}},
    );
  }
}

class EnseignantService {
  final ApiService apiService = ApiService();

  Future<ApiResponse<List<dynamic>>> getEnseignants(String token) async {
    // Récupérer la liste des enseignants
    return ApiResponse(
      success: true,
      message: 'Enseignants récupérés avec succès',
      data: [],
    );
  }

  Future<ApiResponse<dynamic>> createEnseignant(EnseignantRequest request, String token) async {
    // Création d'enseignant
    return ApiResponse(
      success: true,
      message: 'Enseignant créé avec succès',
      data: {'enseignant': {}},
    );
  }
}

class RapportService {
  final ApiService apiService = ApiService();

  Future<ApiResponse<List<dynamic>>> getRapports(String token) async {
    // Récupérer les rapports
    return ApiResponse(
      success: true,
      message: 'Rapports récupérés avec succès',
      data: [],
    );
  }

  Future<ApiResponse<dynamic>> createRapport(RapportRequest request, String token) async {
    // Création de rapport
    return ApiResponse(
      success: true,
      message: 'Rapport créé avec succès',
      data: {'rapport': {}},
    );
  }

  Future<ApiResponse<dynamic>> deleteRapport(int id, String token) async {
    // Suppression de rapport
    return ApiResponse(
      success: true,
      message: 'Rapport supprimé avec succès',
    );
  }
}

// Exemple d'utilisation
class ApiExample {
  static void exampleUsage() async {
    final authService = AuthService();
    
    // Connexion
    final loginRequest = LoginRequest(
      courriel: 'test@example.com',
      motDePasse: 'password',
      role: 'parent',
    );
    
    try {
      final loginResponse = await authService.login(loginRequest);
      print('Connexion réussie: ${loginResponse.message}');
      
      // Sauvegarder le token
      await TokenManager.saveAuthData(
        loginResponse.token,
        loginResponse.role,
        loginResponse.user,
      );
      
    } catch (e) {
      print('Erreur de connexion: $e');
    }
  }
}