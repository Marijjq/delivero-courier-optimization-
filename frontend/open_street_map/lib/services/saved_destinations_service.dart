import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/saved_destination_model.dart';

class SavedDestinationService {
  final String baseUrl;
  final String token;

  SavedDestinationService({
    required this.baseUrl,
    required this.token,
  });

  Future<List<SavedDestination>> fetchSavedDestinations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/saved-destinations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json', // only for POST/PUT
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => SavedDestination.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch saved destinations');
    }
  }

  Future<SavedDestination> saveDestination(SavedDestination destination) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/saved-destinations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(destination.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return SavedDestination.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to save destination');
    }
  }

  Future<void> deleteDestination(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/saved-destinations/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete destination');
    }
  }
}
