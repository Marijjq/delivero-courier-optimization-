import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ProfileService {
  final String baseUrl;
  final String token;

  ProfileService({required this.baseUrl, required this.token});

  Future<UserModel> fetchUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  Future<bool> updateOnlineStatus(bool isOnline) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/user/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'is_online': isOnline}),
    );

    return response.statusCode == 200;
  }

Future<bool> updateLocation(double latitude, double longitude) async {
  final response = await http.put(
    Uri.parse('$baseUrl/api/user/location'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'latitude': latitude,
      'longitude': longitude,
    }),
  );

  return response.statusCode == 200;
}

}
