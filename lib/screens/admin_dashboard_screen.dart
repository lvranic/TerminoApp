import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const route = '/admin-dashboard';
  const AdminDashboardScreen({super.key});

  final String _myReservationsQuery = r'''
    query {
      myReservations {
        id
        startsAt
        durationMinutes
        service { name }
        user { name email }
      }
    }
  ''';

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text(
          'Termino – Admin',
          style: TextStyle(color: Color(0xFFC3F44D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: FutureBuilder<QueryResult>(
        future: client.query(QueryOptions(
          document: gql(_myReservationsQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        )),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data!;
          if (result.hasException) {
            return Center(
              child: Text(
                'Greška: ${result.exception.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final reservations = result.data?['myReservations'] ?? [];

          if (reservations.isEmpty) {
            return const Center(
              child: Text(
                'Trenutno nema rezervacija.',
                style: TextStyle(color: Color(0xFFC3F44D)),
              ),
            );
          }

          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (_, i) {
              final r = reservations[i];
              final startsAt = DateTime.parse(r['startsAt']);
              final dateStr = '${startsAt.day.toString().padLeft(2, '0')}.${startsAt.month.toString().padLeft(2, '0')}.${startsAt.year}';
              final timeStr = '${startsAt.hour.toString().padLeft(2, '0')}:${startsAt.minute.toString().padLeft(2, '0')}';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF12333D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Usluga: ${r['service']['name']}', style: const TextStyle(color: Color(0xFFC3F44D), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Korisnik: ${r['user']['name']} (${r['user']['email']})', style: const TextStyle(color: Color(0xFFC3F44D))),
                      const SizedBox(height: 4),
                      Text('Datum: $dateStr', style: const TextStyle(color: Color(0xFFC3F44D))),
                      Text('Vrijeme: $timeStr', style: const TextStyle(color: Color(0xFFC3F44D))),
                      Text('Trajanje: ${r['durationMinutes']} min', style: const TextStyle(color: Color(0xFFC3F44D))),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFC3F44D),
        foregroundColor: const Color(0xFF1A434E),
        icon: const Icon(Icons.add),
        label: const Text(
          'Dodaj uslugu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/add-service');
        },
      ),
    );
  }
}