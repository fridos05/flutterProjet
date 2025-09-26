import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edumanager/models/course.dart';
import 'package:edumanager/services/api.dart';

class CourseService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TokenManager.tokenKey);
  }

  Future<List<Course>> fetchCoursesByParent(int parentId) async {
    final token = await _getToken();
    final url = ApiService().buildUrl(ApiEndpoints.emploisParent);
    final response = await http.get(
      Uri.parse('$url/$parentId'),
      headers: ApiService.authHeaders(token ?? ''),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => Course.fromJson(e)).toList();
    } else {
      throw ApiException(
        "Erreur récupération des cours",
        response.statusCode,
        response.body,
      );
    }
  }
}
