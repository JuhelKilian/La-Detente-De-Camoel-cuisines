import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'config.dart';

Future<Map<String, int>> chargerDonneesDechets(int annee, int mois) async {
  final prefs = await SharedPreferences.getInstance();
  final String cacheKey = 'dechets_$annee' + '_$mois'; // Clé unique pour le cache par mois

  // Vérifier si les données sont déjà dans le cache
  if (prefs.containsKey(cacheKey)) {
    try {
      // Récupérer et parser les données depuis SharedPreferences
      List<String>? donneesCache = prefs.getStringList(cacheKey);
      if (donneesCache != null) {
        return Map.fromEntries(
          donneesCache.map((e) {
            var parts = e.split(':');
            return MapEntry(parts[0], int.parse(parts[1]));
          }),
        );
      }
    } catch (e) {
      print("Erreur de parsing des données en cache : $e");
    }
  }

  // Si les données ne sont pas en cache, récupérer depuis l'API
  final url = '${AppConfig.baseUrl}/dechets/$annee/$mois';

  try {
    var request = http.Request('GET', Uri.parse(url));
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      List<dynamic> dechets = json.decode(responseBody);

      // Convertir les données en Map<String, int>
      Map<String, int> enregistrementsDechets = {
        for (var dechet in dechets) dechet['dateRecensement']: dechet['quantite']
      };

      // Sauvegarde des données dans SharedPreferences
      List<String> donnees = enregistrementsDechets.entries.map((e) => "${e.key}:${e.value}").toList();
      await prefs.setStringList(cacheKey, donnees);

      return enregistrementsDechets;
    } else {
      print("Erreur HTTP ${response.statusCode} : ${response.reasonPhrase}");
      throw Exception('Échec de la récupération des données des déchets');
    }
  } catch (e) {
    print("Erreur de connexion : $e");
    throw Exception('Impossible de contacter le serveur');
  }
}





Future<void> sauvegarderDonneesDechets(Map<String, int> enregistrementsDechets) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> donnees = enregistrementsDechets.entries.map((e) => "${e.key}:${e.value}").toList();
  await prefs.setStringList('dechets', donnees);
}

List<DateTime> genererCalendrier(DateTime mois) {
  int nombreJours = DateTime(mois.year, mois.month + 1, 0).day;
  int premierJourSemaine = DateTime(mois.year, mois.month, 1).weekday % 7;
  List<DateTime> dates = [];

  for (int i = 0; i < premierJourSemaine; i++) {
    dates.add(DateTime(mois.year, mois.month - 1, 28 - premierJourSemaine + i + 1));
  }
  for (int jour = 1; jour <= nombreJours; jour++) {
    dates.add(DateTime(mois.year, mois.month, jour));
  }
  while (dates.length % 7 != 0) {
    dates.add(DateTime(mois.year, mois.month + 1, dates.length - nombreJours + 1));
  }

  return dates;
}

DateTime DebutSemaine() {
  DateTime now = DateTime.now();
  return now.subtract(Duration(days: now.weekday - 1));
}

int calculerDechetsSemaine(Map<String, int> enregistrementsDechets) {
  DateTime debutSemaine = DebutSemaine();
  return enregistrementsDechets.entries
      .where((entry) {
    DateTime date = DateTime.parse(entry.key);
    return date.isAfter(debutSemaine.subtract(const Duration(days: 1))) && date.isBefore(DateTime.now().add(const Duration(days: 1)));
  })
      .fold(0, (total, entry) => total + entry.value);
}

// Section API

Future<void> envoyerQuantiteDechets(String date, int quantite) async {
  var url = Uri.parse('${AppConfig.baseUrl}/dechets/$date'); // Utilisation de baseUrl
  var headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json'
  };

  var body = json.encode({"quantite": quantite});

  var response = await http.put(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    print("Données mises à jour avec succès : ${response.body}");
  } else {
    print("Erreur lors de l'envoi : ${response.statusCode} - ${response.body}");
  }
}