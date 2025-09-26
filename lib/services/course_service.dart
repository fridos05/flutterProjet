import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edumanager/models/course.dart';
import 'package:edumanager/services/api.dart';

class CourseService {
  // Récupérer le token stocké
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TokenManager.tokenKey);
  }

  // Récupérer les cours d'un enseignant
  Future<List<Course>> fetchCoursesByTeacher(int teacherId) async {
    final token = await _getToken();
    final url = ApiService().buildUrl(ApiEndpoints.seancesTeacher); // endpoint Laravel pour l'enseignant
    final response = await http.get(
      Uri.parse('$url/$teacherId'),
      headers: ApiService.authHeaders(token ?? ''),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) {
        // Transformer la séance Laravel en Course Flutter
        return Course(
          id: e['id'],
          teacherId: e['id_enseignant'],
          studentId: e['id_eleve'],
          subject: e['matiere'],
          startTime: DateTime.parse('${e['jour']} ${e['heure']}'),
          endTime: DateTime.parse('${e['jour']} ${e['heure']}')
              .add(const Duration(hours: 1)), // Durée par défaut 1h
          pricePerSession: 5000, // tu peux mettre la valeur par défaut ou depuis l'API
          status: CourseStatus.pending, // par défaut, peut être étendu selon ton backend
        );
      }).toList();
    } else {
      throw ApiException(
        "Erreur récupération des cours",
        response.statusCode,
        response.body,
      );
    }
  }
}
