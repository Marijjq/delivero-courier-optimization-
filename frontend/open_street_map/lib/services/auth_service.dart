import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/token_storage.dart';
import '../data/theme_notifier.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.5:8888';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email.trim(),
        'password': password.trim(),
      }),
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await TokenStorage.saveToken(data['token']);
      return {
        'success': true,
        'user': data['user'],
        'token': data['token'],
      };
    } else {
      try {
        final error = json.decode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed',
        };
      } catch (e) {
        return {
          'success': false,
          'message': 'Unexpected response: ${response.body}',
        };
      }
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password.trim(),
        'password_confirmation': confirmPassword.trim(),
      }),
    );

    if (response.statusCode == 201) {
      return {'success': true};
    } else {
      final error = json.decode(response.body);
      return {
        'success': false,
        'message': error['message'] ?? 'Registration failed',
      };
    }
  }

  static Future<void> logout(BuildContext context) async {
    final token = await TokenStorage.getToken();
    print('Logging out with token: $token');

    if (token != null) {
      await http.post(
        Uri.parse('$baseUrl/api/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    }

    await TokenStorage.deleteToken();

    // ✅ Reset theme to light
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    themeNotifier.toggleTheme(false);

    // ✅ Reset language to English
    context.setLocale(const Locale('en'));

    print('Token deleted. Theme reset. Language set to English.');
  }
}
