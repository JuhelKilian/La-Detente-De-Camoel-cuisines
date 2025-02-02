import 'package:flutter/material.dart';
import 'package:la_detente_de_camoel_cuisines/ui/screens/gestionDechets/pageStatistiques.dart';
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
    final prefs = await SharedPreferences.getInstance();
    String cacheKey = 'dechets_${moisActuel.year}_${moisActuel.month}'; // Clé unique pour chaque mois
    List<String> donnees = enregistrementsDechets.entries.map((e) => "${e.key}:${e.value}").toList();
    await prefs.setStringList(cacheKey, donnees);
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
        title: const Text(
          "Répertorier les déchets",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        elevation: 4,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _construireEnTete(),
            _construireEnTeteJours(),
            Expanded(child: _construireCalendrier()),
            SizedBox(height: 8),
            _construireSaisieQuantite(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Pour espacer le texte et le bouton
              children: [
                Text(
                  "$dechetsSemaine Kilos ont été jetés cette semaine",  // Le texte
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigation vers la page des statistiques
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StatistiquesPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),  // Plus de padding pour agrandir le bouton
                  ),
                  child: const Text(
                    "Voir les statistiques",  // Le texte du bouton
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  // Taille de police plus grande
                  ),
                ),
              ],
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
    DateTime aujourdHui = DateTime.now(); // Date actuelle
    DateTime debutMoisPrecedent = DateTime(aujourdHui.year, aujourdHui.month - 1, 1); // Premier jour du mois précédent

    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: calendrierJours.length,
      itemBuilder: (context, index) {
        DateTime date = calendrierJours[index];

        // Vérification si la date est dans la plage valide (du mois dernier jusqu'à aujourd'hui)
        bool estValide = date.isBefore(aujourdHui) || date.isAtSameMomentAs(aujourdHui);
        bool estDansLeMoisPrecedent = date.isAfter(debutMoisPrecedent);
        bool estSelectionnee = dateSelectionnee != null && date.isAtSameMomentAs(dateSelectionnee!);
        bool estMoisActuel = date.month == moisActuel.month;
        String cleDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        int dechetsKg = enregistrementsDechets[cleDate] ?? 0;

        // Désactiver la date si elle est hors de la plage valide (moins que le mois dernier ou plus tard qu'aujourd'hui)
        Color bgColor = estSelectionnee
            ? Colors.blueAccent
            : (estMoisActuel && estDansLeMoisPrecedent && estValide
            ? Colors.white
            : Colors.grey[200]!);
        Color textColor = estSelectionnee
            ? Colors.white
            : (estMoisActuel && estDansLeMoisPrecedent && estValide ? Colors.black : Colors.grey);

        return GestureDetector(
          onTap: () {
            if (estMoisActuel && estDansLeMoisPrecedent && estValide) {
              setState(() {
                dateSelectionnee = date;
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: estSelectionnee
                  ? [BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 8)]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${date.day}", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                if (dechetsKg > 0)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text("$dechetsKg kg", style: const TextStyle(fontSize: 12, color: Colors.black)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }



  Widget _construireSaisieQuantite() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controleQuantite,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantité (kg)",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _validerQuantite,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            child: const Text("Valider", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

}