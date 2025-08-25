import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../widgets/notification_badge.dart';

class UserDashboardScreen extends StatelessWidget {
  static const route = '/user-dashboard';
  const UserDashboardScreen({super.key});

  final String _getProvidersQuery = '''
    query GetProviders {
      providers {
        id
        businessName
        workHours
      }
    }
  ''';

  final String _unreadNotificationsCountQuery = r'''
    query UnreadNotificationsCount {
      unreadNotificationsCount
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
          'Termino – Korisnik',
          style: TextStyle(color: Color(0xFFC3F44D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
        actions: [
          NotificationBadge(query: _unreadNotificationsCountQuery),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-user');
            },
          ),
        ],
      ),
      body: FutureBuilder<QueryResult>(
        future: client.query(QueryOptions(
          document: gql(_getProvidersQuery),
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

          final providers = result.data?['providers'] ?? [];

          if (providers.isEmpty) {
            return const Center(
              child: Text(
                'Nema dostupnih pružatelja usluga.',
                style: TextStyle(color: Color(0xFFC3F44D)),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Odaberi uslugu i pružatelja',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC3F44D),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: providers.length,
                    itemBuilder: (_, i) {
                      final p = providers[i];
                      final businessName = p['businessName'] ?? 'Naziv obrta';
                      final workHours = p['workHours'] ?? 'Radno vrijeme nije uneseno';

                      return ListTile(
                        title: Text(
                          businessName,
                          style: const TextStyle(color: Color(0xFFC3F44D)),
                        ),
                        subtitle: Text(
                          workHours,
                          style: const TextStyle(color: Color(0xFFC3F44D)),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Color(0xFFC3F44D)),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/select-service',
                            arguments: {
                              'providerId': p['id'],
                              'providerName': businessName,
                            },
                          );
                        },
                      );
                    },
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFC3F44D)),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/user-appointments');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC3F44D),
                      foregroundColor: const Color(0xFF1A434E),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text('Rezervirani termini'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}