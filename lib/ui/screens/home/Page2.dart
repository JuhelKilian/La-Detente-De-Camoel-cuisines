import 'package:flutter/material.dart';
import '../../../data/models/commande.dart';
import '../../../data/services/api_service.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  late Future<List<Commande>> _commandesFuture;

  @override
  void initState() {
    super.initState();
    _commandesFuture = ApiService.getCommandes();
  }

  Future<void> _updatePlatState(int idInstance, String currentState) async {
    final Map<String, int> states = {
      'A FAIRE': 1,
      'EN PRÉPARATION': 2,
      'TERMINÉ': 3,
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer l\'état'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('A faire'),
              onTap: () async {
                await _processStateChange(idInstance, 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('En préparation'),
              onTap: () async {
                await _processStateChange(idInstance, 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Terminé'),
              onTap: () async {
                await _processStateChange(idInstance, 3);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processStateChange(int idInstance, int newStateId) async {
    try {
      final success = await ApiService.updatePlatState(idInstance, newStateId);
      if (success) {
        setState(() {
          _commandesFuture = ApiService.getCommandes();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Échec de la mise à jour')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes en cours'),
      ),
      body: FutureBuilder<List<Commande>>(
        future: _commandesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune commande disponible'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final commande = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text('Commande #${commande.idCommande}'),
                  subtitle: Text('Table ${commande.idTable}'),
                  children: [
                    ...commande.instancePlats.map((plat) => ListTile(
                          leading: Container(
                            width: 8,
                            height: double.infinity,
                            color: _getStatusColor(plat.etatplat.libelleEtat),
                          ),
                          title: Text(plat.plat.libellePlat),
                          subtitle: Text(plat.plat.typeplat.typePlat),
                          trailing: GestureDetector(
                            onTap: () => _updatePlatState(
                              plat.idInstance,
                              plat.etatplat.libelleEtat,
                            ),
                            child: Chip(
                              label: Text(plat.etatplat.libelleEtat),
                              backgroundColor: _getStatusColor(plat.etatplat.libelleEtat).withOpacity(0.2),
                            ),
                          ),
                        ))
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _commandesFuture = ApiService.getCommandes();
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'A FAIRE':
        return Colors.orange;
      case 'EN COURS':
        return Colors.blue;
      case 'TERMINÉ':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
