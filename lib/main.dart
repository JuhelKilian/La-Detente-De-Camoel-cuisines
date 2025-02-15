import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:la_detente_de_camoel_cuisines/theme.dart';
import 'package:la_detente_de_camoel_cuisines/ui/screens/HomePageScreen.dart';

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Detente De Camoel',
      debugShowCheckedModeBanner: false, 
      theme: myTheme,
      home: HomePageScreen(),
    );
  }
}
