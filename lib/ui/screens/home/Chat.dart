import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../utils/chatFonctions.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];

  // Define two users: a server and a chef
  final types.User _server = types.User(id: 'server', firstName: 'Serveur');
  final types.User _chef = types.User(id: 'chef', firstName: 'Cuisinier');

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() async {
    List<dynamic> messages = await recupererMessagesDepuisApi(1, 1); // Replace with actual idChat and offset
    setState(() {
      _messages = messages.map((json) => _convertToTextMessage(json)).toList();
    });
  }

  void _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = _messages.map((message) => message.toJson()).toList();
    await prefs.setString('messages', jsonEncode(messagesJson));
  }

  void _fetchMessagesFromApi() async {
    List<dynamic> messages = await recupererMessagesDepuisApi(1, 0); // Replace with actual idChat and offset
    print(messages); // Print messages to the console
    setState(() {
      _messages = messages.map((json) => _convertToTextMessage(json)).toList();
    });
  }

  types.TextMessage _convertToTextMessage(dynamic json) {
    int boolCuisinier = json['boolCuisinier'] is String
        ? int.parse(json['boolCuisinier'])
        : json['boolCuisinier'];

    return types.TextMessage(
      author: boolCuisinier == 0 ? _chef : _server,
      createdAt: DateTime.parse(json['date']).millisecondsSinceEpoch,
      id: json['idMessage'].toString(),
      text: json['contenu'],
    );
  }

  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _server, // Server sends the message
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().toString(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
    });

    try {
      await sendMessage(1, 1, message.text);
      _saveMessages();
    } catch (e) {
      print('Failed to send message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat avec les serveurs'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchMessagesFromApi,
          ),
        ],
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _server,
        theme: DefaultChatTheme(
          primaryColor: Color(0xFFA2C4DD),
          secondaryColor: Color(0xFF97EFCE),
          sentMessageBodyTextStyle: TextStyle(
            color: Colors.black,
          ),
          receivedMessageBodyTextStyle: TextStyle(
            color: Colors.black,
          ),
          inputBackgroundColor: Colors.grey[100]!,
          inputTextColor: Colors.grey[800]!,
          inputBorderRadius: BorderRadius.circular(20),
        ),
      ),

    );
  }
}