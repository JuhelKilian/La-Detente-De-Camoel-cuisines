import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GestionDechets extends StatefulWidget {
  const GestionDechets({super.key});

  @override
  State<GestionDechets> createState() => _GestionDechetsState();
}

class _GestionDechetsState extends State<GestionDechets> {
  late DateTime currentMonth;
  late List<DateTime> datesGrid;
  DateTime? selectedDate;
  final TextEditingController quantityController = TextEditingController();
  int totalWaste = 0;
  Map<String, int> wasteRecords = {};

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    datesGrid = _generateDatesGrid(currentMonth);
    _loadWasteData();
  }

  Future<void> _loadWasteData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      wasteRecords = Map<String, int>.from(
          (prefs.getStringList('wasteRecords') ?? []).asMap().map((key, value) => MapEntry(value.split(':')[0], int.parse(value.split(':')[1]))));
      totalWaste = wasteRecords.values.fold(0, (prev, element) => prev + element);
    });
  }

  Future<void> _saveWasteData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> data = wasteRecords.entries.map((e) => "${e.key}:${e.value}").toList();
    await prefs.setStringList('wasteRecords', data);
  }

  List<DateTime> _generateDatesGrid(DateTime month) {
    int numDays = DateTime(month.year, month.month + 1, 0).day;
    int firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    List<DateTime> dates = [];

    for (int i = 0; i < firstWeekday; i++) {
      dates.add(DateTime(month.year, month.month - 1, 28 - firstWeekday + i + 1));
    }
    for (int day = 1; day <= numDays; day++) {
      dates.add(DateTime(month.year, month.month, day));
    }
    while (dates.length % 7 != 0) {
      dates.add(DateTime(month.year, month.month + 1, dates.length - numDays + 1));
    }

    return dates;
  }

  void _changeMonth(int offset) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + offset);
      datesGrid = _generateDatesGrid(currentMonth);
      selectedDate = null;
    });
  }

  void _validateQuantity() {
    if (selectedDate == null) return;
    setState(() {
      String dateKey = "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}";
      int newQuantity = int.tryParse(quantityController.text) ?? 0;
      // Remplace la quantité existante par la nouvelle
      wasteRecords[dateKey] = newQuantity;
      totalWaste = wasteRecords.values.fold(0, (prev, element) => prev + element);
      quantityController.clear();
    });
    _saveWasteData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Repertorier les déchets"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            _buildWeekdayHeader(),
            Expanded(child: _buildCalendarGrid()),
            _buildQuantityInput(),
            Text("$totalWaste Kilos ont été jeté cette semaine",
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _changeMonth(-1),
        ),
        Text("${_monthName(currentMonth.month)} ${currentMonth.year}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    const weekdays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) => Text(day, style: const TextStyle(fontWeight: FontWeight.w600))).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: datesGrid.length,
      itemBuilder: (context, index) {
        DateTime date = datesGrid[index];
        bool isSelected = selectedDate != null && date.isAtSameMomentAs(selectedDate!);
        String dateKey = "${date.year}-${date.month}-${date.day}";
        int wasteKg = wasteRecords[dateKey] ?? 0;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade100 : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${date.day}",
                  style: TextStyle(
                    color: isSelected ? Colors.blue : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                if (wasteKg > 0)
                  Text("${wasteKg} kg", style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuantityInput() {
    // Vérifie si une date est sélectionnée et récupère la quantité correspondante
    int currentQuantity = 0;
    if (selectedDate != null) {
      String dateKey = "${selectedDate!.year}-${selectedDate!.month}-${selectedDate!.day}";
      currentQuantity = wasteRecords[dateKey] ?? 0;
    }

    // Met à jour le controller avec la quantité du jour sélectionné
    quantityController.text = currentQuantity.toString();

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Quantité (en kg)",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _validateQuantity,
          child: const Text("Valider"),
        ),
      ],
    );
  }

  String _monthName(int month) {
    return ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'][month - 1];
  }
}
