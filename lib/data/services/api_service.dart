import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/config.dart';
import '../models/commande.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

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

  static Future<List<Commande>> getCommandes() async {
    var url = Uri.parse("${AppConfig.baseUrl}/commandes");
    var response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Commande.fromJson(json)).toList();
    } else {
      throw Exception('Échec du chargement des commandes');
    }
  }

  static Future<bool> updatePlatState(int idInstance, int newStateId) async {
    var url = Uri.parse("${AppConfig.baseUrl}/commandes/$idInstance");
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    var response = await http.put(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'idEtat': newStateId,
      }),
    );

    return response.statusCode == 200;
  }
}
