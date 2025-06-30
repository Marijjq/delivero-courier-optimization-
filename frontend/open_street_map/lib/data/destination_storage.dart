import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DestinationStorage {
  static const _key = 'saved_destinations';

  /// Save the list of destinations (each is a Map) to local storage
  static Future<void> saveDestinations(List<Map<String, dynamic>> destinations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = destinations.map(json.encode).toList();
    await prefs.setStringList(_key, jsonList);
  }

  /// Load the list of destinations from local storage
  static Future<List<Map<String, dynamic>>> loadDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    return jsonList.map((str) => json.decode(str) as Map<String, dynamic>).toList();
  }
}
