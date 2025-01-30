import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/models/Auth.dart';
import '../HomePageScreen.dart';

class Connexion extends StatefulWidget {
  const Connexion({Key? key}) : super(key: key);

  @override
  State<Connexion> createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final TextEditingController emailInput = TextEditingController();
  final TextEditingController passwordInput = TextEditingController();
  bool isLoading = false;

  void login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await AuthService.login(emailInput.text, passwordInput.text);

      switch (response.statusCode) {
        case 200:
          final responseData = jsonDecode(response.body);

          // Stocker le token dans SharedPreferences
          String token = responseData['access_token'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);

          // Vérifier le rôle de l'utilisateur
          String role = await AuthService.getUserRole();
          if (role == 'Cuisinier') {
            // Puis changer de page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePageScreen(initialIndex: 1),
              ),
            );
          } else {
            showErrorDialog('Vous n\'êtes pas autorisé à accéder à cette application.');
            await prefs.remove('auth_token'); // Supprimer le token si l'utilisateur n'est pas autorisé
          }
          break;

        case 400:
          showErrorDialog('Requête invalide. Veuillez vérifier les données saisies.');
          break;

        case 401:
          showErrorDialog('Email ou mot de passe incorrect.');
          break;

        case 403:
          showErrorDialog('Vous n\'êtes pas autorisé à accéder à cette application.');
          break;

        case 404:
          showErrorDialog('Ressource introuvable. Veuillez réessayer plus tard.');
          break;

        case 422:
          final errorData = jsonDecode(response.body);
          showErrorDialog(errorData['message'] ?? 'Données invalides.');
          break;

        case 429:
          showErrorDialog('Trop de requêtes. Veuillez réessayer plus tard.');
          break;

        case 500:
          showErrorDialog('Erreur interne du serveur. Veuillez réessayer plus tard.');
          break;

        case 503:
          showErrorDialog('Service temporairement indisponible. Veuillez réessayer plus tard.');
          break;

        case 504:
          showErrorDialog('Le serveur ne répond pas. Veuillez réessayer plus tard.');
          break;

        default:
          showErrorDialog('Erreur inattendue : ${response.statusCode}');
          break;
      }

    } catch (e) {
      showErrorDialog("Connexion à la base de données impossible, essayer d'activer le VPN ou de lancez le serveur correctement.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (screenWidth > 900)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Image.asset(
                      'images/logoConnexion.png',
                      height: 400, // Logo plus petit
                      fit: BoxFit.contain,
                    ),
                  ),
                SizedBox(
                  width: screenWidth > 600 ? 500 : double.infinity, // Formulaire plus large
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32), // Plus d'espace intérieur
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Bienvenue',
                            style: TextStyle(
                              fontSize: 28, // Texte plus grand
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: emailInput,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Adresse Email',
                              prefixIcon: Icon(Icons.email),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: passwordInput,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Mot de passe',
                              prefixIcon: Icon(Icons.lock),
                            ),
                          ),
                          const SizedBox(height: 30),
                          isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff006FFD),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                'Connexion',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailInput.dispose();
    passwordInput.dispose();
    super.dispose();
  }
}
