import 'dart:convert';
import 'api_service.dart';

class TemoinService {
  final ApiService _apiService = ApiService();

  Future<List<Map<String, dynamic>>> getTemoins() async {
    final response = await _apiService.get('/api/temoin/index');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors du chargement des témoins: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createTemoin(Map<String, dynamic> data) async {
    final response = await _apiService.post('/api/temoin/store', data);
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la création: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateTemoin(int id, Map<String, dynamic> data) async {
    final response = await _apiService.put('/api/temoin/$id', data);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors de la mise à jour: ${response.statusCode}');
    }
  }

  Future<void> deleteTemoin(int id) async {
    final response = await _apiService.delete('/api/temoin/$id');
    
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression: ${response.statusCode}');
    }
  }

  // Méthode pour récupérer les témoins d'un parent
  Future<List<Map<String, dynamic>>> getParentTemoins() async {
    final response = await _apiService.get('/api/temoin');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur lors du chargement des témoins du parent: ${response.statusCode}');
    }
  }
}