import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class NotificationBadge extends StatelessWidget {
  final String query;

  const NotificationBadge({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(query),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      builder: (result, {refetch, fetchMore}) {
        if (result.isLoading || result.hasException) {
          return IconButton(
            icon: const Icon(Icons.notifications, color: Color(0xFFC3F44D)),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications').then((_) {
                refetch?.call(); // ✅ Osvježi broj nakon povratka
              });
            },
          );
        }

        final count = result.data?['unreadNotificationsCount'] ?? 0;

        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Color(0xFFC3F44D)),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications').then((_) {
                  refetch?.call(); // ✅ Osvježi broj nakon povratka
                });
              },
            ),
            if (count > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}