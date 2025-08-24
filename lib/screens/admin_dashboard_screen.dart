import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../widgets/notification_badge.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const route = '/admin-dashboard';
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final String _meQuery = r'''
    query {
      me {
        id
        address
        workHours
      }
    }
  ''';

  final String _unreadNotificationsCountQuery = r'''
    query UnreadNotificationsCount {
      unreadNotificationsCount
    }
  ''';

  final String _reservationsByProviderQuery = r'''
  query ReservationsByProvider($providerId: String!, $startDate: DateTime!, $endDate: DateTime!) {
    reservationsByProvider(providerId: $providerId, startDate: $startDate, endDate: $endDate) {
      id
      startsAt
      durationMinutes
      service { name }
      user { name email }
    }
  }
''';

  final String _cancelReservationMutation = r'''
    mutation CancelReservation($id: String!) {
      deleteReservation(id: $id) {
        success
        message
      }
    }
  ''';

  Future<QueryResult>? _reservationsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshReservations();
  }

  void _refreshReservations() async {
    final client = GraphQLProvider.of(context).value;

    final meResult = await client.query(QueryOptions(document: gql(_meQuery)));
    final me = meResult.data?['me'];
    if (me == null) return;

    final providerId = me['id'];
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final endDate = startDate.add(const Duration(days: 7)); // prikaz za tjedan dana unaprijed

    setState(() {
      _reservationsFuture = client.query(QueryOptions(
        document: gql(_reservationsByProviderQuery),
        variables: {
          'providerId': providerId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ));
    });
  }

  void _cancelReservation(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Potvrda', style: TextStyle(color: Color(0xFFC3F44D))),
        content: const Text('Jeste li sigurni da želite otkazati ovu rezervaciju?', style: TextStyle(color: Color(0xFFC3F44D))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ne', style: TextStyle(color: Color(0xFFC3F44D)))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Da', style: TextStyle(color: Color(0xFFC3F44D)))),
        ],
      ),
    );

    if (confirm != true) return;

    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(MutationOptions(
      document: gql(_cancelReservationMutation),
      variables: {'id': id},
    ));

    final success = result.data?['deleteReservation']?['success'] ?? false;
    if (success) {
      _refreshReservations();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Neuspješno otkazivanje rezervacije.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Termino – Admin', style: TextStyle(color: Color(0xFFC3F44D))),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
        actions: [
          NotificationBadge(query: _unreadNotificationsCountQuery),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await client.query(QueryOptions(document: gql(_meQuery)));
              final user = result.data?['me'];
              if (user != null) {
                Navigator.pushNamed(
                  context,
                  '/edit-business',
                  arguments: {
                    'userId': user['id'],
                    'currentAddress': user['address'] ?? '',
                    'currentWorkHours': user['workHours'] ?? '',
                  },
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-services-list');
            },
          ),
        ],
      ),
      body: FutureBuilder<QueryResult>(
        future: _reservationsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFC3F44D)));
          }

          final result = snapshot.data!;
          if (result.hasException) {
            return Center(child: Text('Greška: ${result.exception.toString()}', style: const TextStyle(color: Colors.red)));
          }

          final reservations = result.data?['reservationsByProvider'] ?? [];

          if (reservations.isEmpty) {
            return const Center(child: Text('Trenutno nema rezervacija.', style: TextStyle(color: Color(0xFFC3F44D))));
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
                      Text('Korisnik: ${r['user']['name']} (${r['user']['email']})', style: const TextStyle(color: Color(0xFFC3F44D))),
                      Text('Datum: $dateStr', style: const TextStyle(color: Color(0xFFC3F44D))),
                      Text('Vrijeme: $timeStr', style: const TextStyle(color: Color(0xFFC3F44D))),
                      Text('Trajanje: ${r['durationMinutes']} min', style: const TextStyle(color: Color(0xFFC3F44D))),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text('Otkaži rezervaciju', style: TextStyle(color: Colors.red)),
                        onPressed: () => _cancelReservation(r['id']),
                      )
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
        label: const Text('Dodaj uslugu', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.pushNamed(context, '/add-service');
        },
      ),
    );
  }
}