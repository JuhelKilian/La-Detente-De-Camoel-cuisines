import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/config.dart';
class AuthService {

  static Future<http.Response> login(String email, String password) async {
    var url = Uri.parse("${AppConfig.baseUrl}/login");
    var response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}), // Encode la Map en JSON
    );
    return response;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      await http.post(
        Uri.parse('${AppConfig.baseUrl}/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      await prefs.remove('auth_token');
    }
  }

  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      return 'Non authentifié';
    }

    // Envoi de la requête pour récupérer le rôle
    var url = Uri.parse("${AppConfig.baseUrl}/roles");
    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(response.statusCode);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['role'] ?? 'Aucun rôle';
    } else {
      return 'Erreur de récupération du rôle';
    }
  }
}
