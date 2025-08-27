// lib/screens/select_service_screen.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'reservation_date_screen.dart';

class SelectServiceScreen extends StatelessWidget {
  static const route = '/select-service';
  const SelectServiceScreen({super.key});

  static const String _getServicesQuery = r'''
    query GetProviderServices($providerId: String!) {
      services(providerId: $providerId) {
        id
        name
      }
    }
  ''';

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final providerId = args['providerId']?.toString() ?? '';
    final providerName = args['providerName']?.toString() ?? 'Pružatelj';

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: Text(
          'Odaberi uslugu – $providerName',
          style: const TextStyle(color: Color(0xFFC3F44D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(_getServicesQuery),
          variables: {'providerId': providerId},
          fetchPolicy: FetchPolicy.noCache,
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (result.hasException) {
            return Center(
              child: Text(
                'Greška: ${result.exception.toString()}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final services = result.data?['services'] ?? [];

          if (services.isEmpty) {
            return const Center(
              child: Text(
                'Nema dostupnih usluga za ovog pružatelja.',
                style: TextStyle(color: Color(0xFFC3F44D)),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final service = services[i];
              return ListTile(
                tileColor: Colors.white24,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  service['name'],
                  style: const TextStyle(
                    color: Color(0xFFC3F44D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, color: Color(0xFFC3F44D)),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    ReservationDateScreen.route,
                    arguments: {
                      'providerId': providerId,
                      'providerName': providerName,
                      'serviceId': service['id'],
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}