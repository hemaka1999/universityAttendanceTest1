import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
class TokenJWT{
  Future<void> storeCurrentUser(Map<String, dynamic> jsonObject) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(jsonObject);
    await prefs.setString('currentUser', jsonString);

  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('currentUser');
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null; // Return null if the JSON object is not found
  }

  Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
  }
}

