import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class EditServicesListScreen extends StatefulWidget {
  static const route = '/edit-services-list';

  const EditServicesListScreen({super.key});

  @override
  State<EditServicesListScreen> createState() => _EditServicesListScreenState();
}

class _EditServicesListScreenState extends State<EditServicesListScreen> {
  final String _myServicesQuery = r'''
    query {
      myServices {
        id
        name
        durationMinutes
      }
    }
  ''';

  Future<void> _showEditDialog(
      BuildContext context,
      String id,
      String name,
      int currentDuration,
      VoidCallback onUpdated,
      ) async {
    final controller = TextEditingController(text: currentDuration.toString());
    final String mutation = r'''
      mutation UpdateService($id: String!, $newDuration: Int!) {
        updateService(serviceId: $id, newDurationMinutes: $newDuration) {
          id
        }
      }
    ''';

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A434E),
          title: Text('Uredi: $name', style: const TextStyle(color: Color(0xFFC3F44D))),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Trajanje (min)',
              labelStyle: TextStyle(color: Color(0xFFC3F44D)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFC3F44D)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Odustani', style: TextStyle(color: Colors.red)),
            ),
            Mutation(
              options: MutationOptions(
                document: gql(mutation),
                onCompleted: (_) {
                  Navigator.pop(context); // zatvori dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Usluga je ažurirana!',
                        style: TextStyle(color: Color(0xFF1A434E)), // 👈 TAMNO ZELENA
                      ),
                      backgroundColor: const Color(0xFFC3F44D), // LIMETA
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  onUpdated(); // ponovno pokreni dohvat podataka
                },
              ),
              builder: (runMutation, result) {
                return TextButton(
                  onPressed: () {
                    final newDuration = int.tryParse(controller.text);
                    if (newDuration != null && newDuration > 0) {
                      runMutation({'id': id, 'newDuration': newDuration});
                    }
                  },
                  child: result?.isLoading ?? false
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC3F44D)),
                  )
                      : const Text('Spremi', style: TextStyle(color: Color(0xFFC3F44D))),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        title: const Text('Uredi usluge', style: TextStyle(color: Color(0xFFC3F44D))),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: FutureBuilder<QueryResult>(
        future: client.query(QueryOptions(document: gql(_myServicesQuery))),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data!;
          if (result.hasException) {
            return Center(
              child: Text('Greška: ${result.exception.toString()}', style: const TextStyle(color: Colors.red)),
            );
          }

          final services = result.data?['myServices'] ?? [];

          if (services.isEmpty) {
            return const Center(
              child: Text('Nema dostupnih usluga.', style: TextStyle(color: Color(0xFFC3F44D))),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFFC3F44D),
            onRefresh: () async {
              setState(() {}); // pokreni rebuild koji ponovo dohvati podatke
            },
            child: ListView.builder(
              itemCount: services.length,
              itemBuilder: (_, i) {
                final s = services[i];

                return ListTile(
                  title: Text(s['name'], style: const TextStyle(color: Color(0xFFC3F44D))),
                  subtitle: Text('Trajanje: ${s['durationMinutes']} min', style: const TextStyle(color: Color(0xFFC3F44D))),
                  trailing: const Icon(Icons.edit, color: Color(0xFFC3F44D)),
                  onTap: () => _showEditDialog(
                    context,
                    s['id'],
                    s['name'],
                    s['durationMinutes'],
                        () => setState(() {}), // osiguraj refresh nakon izmjene
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}