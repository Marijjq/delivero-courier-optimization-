import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/assigned_route_model.dart';

class AssignedRouteService {
  final String baseUrl;
  final String token;

  AssignedRouteService({required this.baseUrl, required this.token});

  Future<List<AssignedRoute>> fetchAssignedRoutes() async {
    final url = Uri.parse('$baseUrl/api/assigned-routes');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => AssignedRoute.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch assigned routes. Status: ${response.statusCode}');
    }
  }

  Future<void> markAsFinished(int routeId) async {
  final url = Uri.parse('$baseUrl/api/assigned-routes/$routeId/finish');
  final response = await http.put(
    url,
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to mark route as finished');
  }
}

}
