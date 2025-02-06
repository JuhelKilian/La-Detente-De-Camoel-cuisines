import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
    initializeDateFormatting('fr_FR', null);
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

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Date inconnue";

    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat("EEEE d MMMM yyyy", "fr_FR").format(date);
    } catch (e) {
      return "Format de date invalide";
    }
  }

  Widget buildStatCard(String title, List<Widget> content) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Divider(),
            ...content,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques des déchets'),
        backgroundColor: Color(0xFFA4D6F4),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stats == null
          ? const Center(child: Text('Erreur lors du chargement des statistiques'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildStatCard("Statistiques du mois en cours", [
              Text("Total du mois : ${stats!['current_month_stats']['total_mois']} kg"),
              Text("Total de la semaine : ${stats!['current_month_stats']['total_semaine']} kg"),
              Text(
                "Jour max : ${formatDate(stats!['current_month_stats']['max_waste']['dateRecensement'])} "
                    "(${stats!['current_month_stats']['max_waste']['quantite']} kg)",
              ),
              Text(
                "Jour min : ${formatDate(stats!['current_month_stats']['min_waste']['dateRecensement'])} "
                    "(${stats!['current_month_stats']['min_waste']['quantite']} kg)",
              ),
              Text("Nombre d'enregistrements : ${stats!['current_month_stats']['nombre_enregistrements']}"),
            ]),

            buildStatCard("Statistiques de la semaine dernière", [
              Text("Total de la semaine dernière : ${stats!['last_week_stats']['total_semaine']} kg"),
              Text("Du ${formatDate(stats!['last_week_stats']['start_date'])} au ${formatDate(stats!['last_week_stats']['end_date'])}"),
            ]),

            buildStatCard("Statistiques du mois précédent", [
              Text("Total du mois précédent : ${stats!['previous_month_stats']['total_mois']} kg"),
              Text(
                "Jour max : ${formatDate(stats!['previous_month_stats']['max_waste']['dateRecensement'])} "
                    "(${stats!['previous_month_stats']['max_waste']['quantite']} kg)",
              ),
              Text(
                "Jour min : ${formatDate(stats!['previous_month_stats']['min_waste']['dateRecensement'])} "
                    "(${stats!['previous_month_stats']['min_waste']['quantite']} kg)",
              ),
              Text("Nombre d'enregistrements : ${stats!['previous_month_stats']['nombre_enregistrements']}"),
            ]),
          ],
        ),
      ),
    );
  }
}
