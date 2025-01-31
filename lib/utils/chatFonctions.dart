import 'dart:convert'; // Nécessaire pour la conversion JSON
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<dynamic>> recupererMessagesEnregistres() async {
  final prefs = await SharedPreferences.getInstance();
  String? messagesString = prefs.getString('messages');
  if (messagesString != null) {
    return jsonDecode(messagesString);
  } else {
    return [];
  }
}

Future<void> enregistrerMessages(List<dynamic> messages) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('messages', jsonEncode(messages));
}

Future<List<dynamic>> recupererMessagesDepuisApi(int idChat, int offset) async {
  var headers = {
    'Accept': 'application/json',
  };

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  if (token == null) {
    return ["unauthenticated"];
  }

  headers['Authorization'] = 'Bearer $token';

  String url = '${AppConfig.baseUrl}/Message/$idChat/$offset';

  var request = http.Request('GET', Uri.parse(url));
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    String responseData = await response.stream.bytesToString();
    return jsonDecode(responseData);
  } else {
    throw Exception('Erreur serveur: ${response.reasonPhrase}');
  }
}

Future<void> mettreAJourMessages(int idChat, int offset) async {
  List<dynamic> messagesLocaux = await recupererMessagesEnregistres();
  List<dynamic> messagesApi = await recupererMessagesDepuisApi(idChat, offset);

  // Filter out messages that are already in local storage
  List<dynamic> nouveauxMessages = messagesApi.where((messageApi) {
    return !messagesLocaux.any((messageLocal) => messageLocal['idMessage'] == messageApi['idMessage']);
  }).toList();

  // Add new messages to local storage
  messagesLocaux.addAll(nouveauxMessages);
  await enregistrerMessages(messagesLocaux);
}

Future<void> sendMessage(int idChat, int boolCuisinier, String message) async {
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  headers['Authorization'] = 'Bearer $token';

  var body = jsonEncode({
    'idChat': idChat,
    'boolCuisinier': boolCuisinier,
    'message': message,
  });

  String url = '${AppConfig.baseUrl}/SendMessage';

  var response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: body,
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to send message: ${response.reasonPhrase}');
  }
}