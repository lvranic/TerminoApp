import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

class UserAppointmentsScreen extends StatelessWidget {
  static const route = '/user-appointments';

  const UserAppointmentsScreen({super.key});

  final String _appointmentsQuery = '''
    query {
      myReservations {
        id
        startsAt
        durationMinutes
        service {
          name
        }
        provider {
          businessName
        }
      }
    }
  ''';

  final String _cancelMutation = '''
    mutation CancelReservation(\$id: String!, \$reason: String) {
      deleteReservation(id: \$id, reason: \$reason) {
        success
        message
      }
    }
  ''';

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFFC3F44D);
    const bg = Color(0xFF1A434E);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: const Text('Moji termini', style: TextStyle(color: green)),
        iconTheme: const IconThemeData(color: green),
      ),
      body: Query(
        options: QueryOptions(document: gql(_appointmentsQuery)),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator(color: green));
          }

          if (result.hasException) {
            return Center(
              child: Text(
                'Greška: ${result.exception.toString()}',
                style: const TextStyle(color: green),
              ),
            );
          }

          final items = result.data?['myReservations'] ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Trenutno nema rezerviranih termina.',
                style: TextStyle(color: green),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final item = items[i];
              final startsAt = DateTime.parse(item['startsAt']);
              final dateStr = DateFormat('dd.MM.yyyy.').format(startsAt);
              final timeStr = DateFormat('HH:mm').format(startsAt);
              final serviceName = item['service']?['name'] ?? 'Nepoznata usluga';
              final providerName = item['provider']?['businessName'] ?? 'Nepoznat obrt';

              return Mutation(
                options: MutationOptions(
                  document: gql(_cancelMutation),
                  onCompleted: (data) {
                    final success = data?['deleteReservation']?['success'] ?? false;
                    final message = data?['deleteReservation']?['message'] ?? 'Nepoznata greška.';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Termin je otkazan.'
                            : 'Neuspješno otkazivanje: $message'),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                    if (success && refetch != null) {
                      refetch();
                    }
                  },
                ),
                builder: (runMutation, mutationResult) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        serviceName,
                        style: const TextStyle(
                          color: green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '$providerName • $dateStr u $timeStr',
                        style: const TextStyle(color: green),
                      ),
                      trailing: TextButton.icon(
                        onPressed: () async {
                          String? reason;
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: bg,
                              title: const Text('Otkazivanje', style: TextStyle(color: green)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Unesite razlog otkazivanja (opcionalno):', style: TextStyle(color: green)),
                                  const SizedBox(height: 10),
                                  TextField(
                                    onChanged: (val) => reason = val,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      filled: true,
                                      fillColor: Color(0xFF12333D),
                                      hintText: 'Npr. spriječen sam...',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ne', style: TextStyle(color: green))),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Da', style: TextStyle(color: green))),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            runMutation({'id': item['id'], 'reason': reason});
                          }
                        },
                        icon: const Icon(Icons.cancel, color: green),
                        label: const Text('Otkaži', style: TextStyle(color: green)),
                      ),
                    ),
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
