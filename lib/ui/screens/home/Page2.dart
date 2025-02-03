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
                          trailing: Chip(
                            label: Text(plat.etatplat.libelleEtat),
                            backgroundColor: _getStatusColor(plat.etatplat.libelleEtat).withOpacity(0.2),
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
