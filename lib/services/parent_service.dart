import 'dart:convert';
import 'package:edumanager/services/api.dart';
import 'package:http/http.dart' as http;

class ParentService {
  Future<Map<String, dynamic>> fetchStatistics(int parentId) async {
    final token = await TokenManager.getToken();
    final url = ApiService().buildUrl('${ApiEndpoints.parentStats}/$parentId');

    final response = await http.get(
      Uri.parse(url),
      headers: ApiService.authHeaders(token ?? ''),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(
        "Erreur récupération stats parent",
        response.statusCode,
        response.body,
      );
    }
  }
}
