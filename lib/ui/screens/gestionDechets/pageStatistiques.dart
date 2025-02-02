import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import du package pour la gestion des dates
import '../../../utils/config.dart';

class StatistiquesPage extends StatefulWidget {
  const StatistiquesPage({Key? key}) : super(key: key);

  @override
  _StatistiquesPageState createState() => _StatistiquesPageState();
}

class _StatistiquesPageState extends State<StatistiquesPage> {
  bool isLoading = true;
  Map<String, dynamic>? stats;

  @override
  void initState() {
    super.initState();
    fetchStats();
  }

  Future<void> fetchStats() async {
    final url = Uri.parse('${AppConfig.baseUrl}/dechets/statistiques');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          stats = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print("Erreur HTTP ${response.statusCode} : ${response.reasonPhrase}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Erreur lors de la récupération des statistiques: $e");
    }
  }

  /// Fonction pour formater une date en français
  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Date inconnue";

    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat("EEEE d MMMM yyyy", "fr_FR").format(date);
    } catch (e) {
      throw Exception(e);
      return "Format de date invalide"; // Retourne un message d'erreur plus clair
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques des déchets'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stats == null
          ? const Center(child: Text('Erreur lors du chargement des statistiques'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques du mois en cours
            const Text(
              "Statistiques du mois en cours",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Total du mois: ${stats?['current_month_stats']?['total_mois'] ?? 'Non disponible'} kg"),
            Text("Total de la semaine: ${stats?['current_month_stats']?['total_semaine'] ?? 'Non disponible'} kg"),
            Text(
                "Jour avec le plus de déchets: ${formatDate(stats?['current_month_stats']?['max_waste']?['dateRecensement'])} "
                    "(${stats?['current_month_stats']?['max_waste']?['quantite'] ?? 0} kg)"),
            Text(
                "Jour avec le moins de déchets: ${formatDate(stats?['current_month_stats']?['min_waste']?['dateRecensement'])} "
                    "(${stats?['current_month_stats']?['min_waste']?['quantite'] ?? 0} kg)"),
            Text("Nombre d'enregistrements: ${stats?['current_month_stats']?['nombre_enregistrements'] ?? 0}"),
            const Divider(height: 32),

            // Statistiques de la semaine dernière
            const Text(
              "Statistiques de la semaine dernière",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Total de la semaine dernière: ${stats?['last_week_stats']?['total_semaine'] ?? 'Non disponible'} kg"),
            Text("Du ${formatDate(stats?['last_week_stats']?['start_date'])} au ${formatDate(stats?['last_week_stats']?['end_date'])}"),
            const Divider(height: 32),

            // Statistiques du mois précédent
            const Text(
              "Statistiques du mois précédent",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Total du mois précédent: ${stats?['previous_month_stats']?['total_mois'] ?? 'Non disponible'} kg"),
            Text(
                "Jour avec le plus de déchets: ${formatDate(stats?['previous_month_stats']?['max_waste']?['dateRecensement'])} "
                    "(${stats?['previous_month_stats']?['max_waste']?['quantite'] ?? 0} kg)"),
            Text(
                "Jour avec le moins de déchets: ${formatDate(stats?['previous_month_stats']?['min_waste']?['dateRecensement'])} "
                    "(${stats?['previous_month_stats']?['min_waste']?['quantite'] ?? 0} kg)"),
            Text("Nombre d'enregistrements: ${stats?['previous_month_stats']?['nombre_enregistrements'] ?? 0}"),
          ],
        ),
      ),
    );
  }
}
