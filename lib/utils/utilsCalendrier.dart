import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, int>> chargerDonneesDechets() async {
  final prefs = await SharedPreferences.getInstance();
  return Map<String, int>.from(
    (prefs.getStringList('dechets') ?? []).asMap().map(
          (key, value) => MapEntry(
          value.split(':')[0],
          int.parse(value.split(':')[1])
      ),
    ),
  );
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