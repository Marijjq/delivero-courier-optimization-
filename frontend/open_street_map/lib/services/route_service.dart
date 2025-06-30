import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route_history_model.dart'; // adjust if needed

class RouteService {
  // Fetch all route history
  static Future<List<RouteHistory>> fetchRouteHistory(
    String token,
    String baseUrl,
  ) async {
    final url = Uri.parse('$baseUrl/api/route-history');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RouteHistory.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load route history');
    }
  }

  // Delete a route history item
  static Future<void> deleteRouteHistory(
    int id,
    String baseUrl,
    String? token,
  ) async {
    if (token == null) throw Exception("No auth token");

    final url = Uri.parse('$baseUrl/api/route-history/$id');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete route');
    }
  }

  // Add this method to save route history
  static Future<bool> saveRouteHistory({
    required String token,
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required double distance,
    required int duration,
    required String baseUrl,
  }) async {
    final url = Uri.parse('$baseUrl/api/route-history');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'start_latitude': startLat,
        'start_longitude': startLng,
        'end_latitude': endLat,
        'end_longitude': endLng,
        'distance': distance,
        'duration': duration,
      }),
    );

    return response.statusCode == 201;
  }
}
