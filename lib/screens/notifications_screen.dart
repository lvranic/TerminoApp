import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final String _notificationsQuery = r'''
    query {
      notifications {
        id
        message
        isRead
        createdAt
      }
    }
  ''';

  final String _markNotificationAsReadMutation = r'''
    mutation MarkNotificationAsRead($id: String!) {
      markNotificationAsRead(id: $id) {
        success
        message
      }
    }
  ''';

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikacije', style: TextStyle(color: Color(0xFFC3F44D))),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
        backgroundColor: const Color(0xFF1A434E),
      ),
      backgroundColor: const Color(0xFF1A434E),
      body: Query(
        options: QueryOptions(
          document: gql(_notificationsQuery),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFC3F44D)));
          }

          if (result.hasException) {
            return Center(
              child: Text(
                'Greška: ${result.exception.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final notifications = result.data?['notifications'] ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Text('Nemate novih notifikacija.', style: TextStyle(color: Color(0xFFC3F44D))),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (_, i) {
              final n = notifications[i];
              final isRead = n['isRead'] ?? false;
              final date = DateTime.parse(n['createdAt']).toLocal();
              final formattedDate =
                  '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

              return ListTile(
                tileColor: isRead ? const Color(0xFF12333D) : const Color(0xFF254A52),
                title: Text(n['message'], style: const TextStyle(color: Color(0xFFC3F44D))),
                subtitle: Text(formattedDate, style: const TextStyle(color: Color(0xFF8BC34A))),
                onTap: () async {
                  if (!isRead) {
                    await client.mutate(MutationOptions(
                      document: gql(_markNotificationAsReadMutation),
                      variables: {'id': n['id']},
                    ));
                    refetch?.call();
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}