import 'package:la_detente_de_camoel_cuisines/ui/screens/connexion/connexion.dart';
import 'package:flutter/material.dart';

import 'gestionDechets/Page1.dart';
import './home/Page2.dart';
import 'messages/Chat.dart';

// Connexion
import 'connexion/connexion.dart';

class HomePageScreen extends StatefulWidget {
  final int initialIndex;
  const HomePageScreen({Key? key, this.initialIndex = 1}) : super(key: key);

  @override
  createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  // Page login ajoutée au début de la liste (index 0)
  final List<Widget> _children = <Widget>[
    Connexion(),
    GestionDechets(),
    Page2(),
    ChatPage(),
  ];

  final List<String> _titles = <String>[
    'Connexion', // Titre pour la page de login
    'Scan QR',
    'Nouvelle commande',
    'Chat',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      // Affiche la navbar seulement si on n'est pas sur la page login et que l'index <= 2
      bottomNavigationBar: _currentIndex != 0 && _currentIndex <= 4
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: onTabTapped,
              // Décale l'index de -1 car la page login n'est pas dans la navbar
              currentIndex: _currentIndex - 1,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  label: 'Gestion déchets',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_alt),
                  label: 'Commandes',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: 'Chat',
                ),
              ],
            )
          : null,
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index + 1;
    });
  }
}
