import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:la_detente_de_camoel_cuisines/utils/utilsCalendrier.dart';

class GestionDechets extends StatefulWidget {
  const GestionDechets({super.key});

  @override
  State<GestionDechets> createState() => _GestionDechetsState();
}

class _GestionDechetsState extends State<GestionDechets> {
  late DateTime moisActuel;
  late List<DateTime> calendrierJours;
  DateTime? dateSelectionnee;
  final TextEditingController controleQuantite = TextEditingController();
  int totalDechets = 0;
  Map<String, int> enregistrementsDechets = {};

  @override
  void initState() {
    super.initState();
    moisActuel = DateTime.now();
    calendrierJours = genererCalendrier(moisActuel);
    _chargerDonneesDechets();
  }

  Future<void> _chargerDonneesDechets() async {
    enregistrementsDechets = await chargerDonneesDechets(moisActuel.year, moisActuel.month);
    setState(() {
      totalDechets = enregistrementsDechets.values.fold(0, (prev, element) => prev + element);
    });
  }

  Future<void> _sauvegarderDonneesDechets() async {
    await sauvegarderDonneesDechets(enregistrementsDechets);
  }

  void _changerMois(int decalage) {
    setState(() {
      moisActuel = DateTime(moisActuel.year, moisActuel.month + decalage);
      calendrierJours = genererCalendrier(moisActuel);
      dateSelectionnee = null;
    });
    _chargerDonneesDechets();
  }


  void _validerQuantite() {
    if (dateSelectionnee == null) return;

    setState(() {
      String cleDate = "${dateSelectionnee!.year}-${dateSelectionnee!.month.toString().padLeft(2, '0')}-${dateSelectionnee!.day.toString().padLeft(2, '0')}";
      int nouvelleQuantite = int.tryParse(controleQuantite.text) ?? 0;

      enregistrementsDechets[cleDate] = nouvelleQuantite;
      totalDechets = enregistrementsDechets.values.fold(0, (prev, element) => prev + element);
      controleQuantite.clear();
    });

    _sauvegarderDonneesDechets();
    envoyerQuantiteDechets(dateSelectionnee!.toIso8601String().split("T")[0], enregistrementsDechets[dateSelectionnee!.toIso8601String().split("T")[0]] ?? 0);
  }


  @override
  Widget build(BuildContext context) {
    int dechetsSemaine = calculerDechetsSemaine(enregistrementsDechets);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Répertorier les déchets"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _construireEnTete(),
            _construireEnTeteJours(),
            Expanded(child: _construireCalendrier()),
            _construireSaisieQuantite(),
            Text("$dechetsSemaine Kilos ont été jetés cette semaine",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextButton(
                onPressed: () {},
                child: const Text("Voir les statistiques", style: TextStyle(color: Colors.blue))
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireEnTete() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _changerMois(-1),
        ),
        Text(
          "${moisActuel.month}/${moisActuel.year}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () => _changerMois(1),
        ),
      ],
    );
  }

  Widget _construireEnTeteJours() {
    List<String> joursSemaine = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: joursSemaine.map((jour) => Text(jour, style: const TextStyle(fontWeight: FontWeight.bold))).toList(),
    );
  }

  Widget _construireCalendrier() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: calendrierJours.length,
      itemBuilder: (context, index) {
        DateTime date = calendrierJours[index];
        bool estSelectionnee = dateSelectionnee != null && date.isAtSameMomentAs(dateSelectionnee!);
        bool estMoisActuel = date.month == moisActuel.month;
        String cleDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        int dechetsKg = enregistrementsDechets[cleDate] ?? 0;

        DateTime now = DateTime.now();
        DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
        bool estDateValide = date.isBefore(now) && date.isAfter(oneMonthAgo);

        return GestureDetector(
          onTap: () {
            if (estMoisActuel && estDateValide) {
              setState(() {
                dateSelectionnee = date;
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: estSelectionnee ? Colors.blue.shade100 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${date.day}",
                  style: TextStyle(
                    color: estMoisActuel ? (estSelectionnee ? Colors.blue : Colors.black) : Colors.grey,
                    fontWeight: estSelectionnee ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (dechetsKg > 0)
                  Text("${dechetsKg} kg", style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _construireSaisieQuantite() {
    int quantiteActuelle = 0;
    if (dateSelectionnee != null) {
      String cleDate = "${dateSelectionnee!.year}-${dateSelectionnee!.month.toString().padLeft(2, '0')}-${dateSelectionnee!.day.toString().padLeft(2, '0')}";
      quantiteActuelle = enregistrementsDechets[cleDate] ?? 0;
    }

    controleQuantite.text = quantiteActuelle.toString();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controleQuantite,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Quantité (en kg)",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _validerQuantite,
          child: const Text("Valider"),
        ),
      ],
    );
  }
}