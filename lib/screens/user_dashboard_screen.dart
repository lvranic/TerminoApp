// lib/screens/user_dashboard_screen.dart
import 'package:flutter/material.dart';

class UserDashboardScreen extends StatelessWidget {
  static const route = '/user-dashboard';
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo podaci – u sljedećem koraku ovo ćemo čitati iz backenda
    final providers = const [
      {'id': 'admin-1', 'name': 'Demo salon 1'},
      {'id': 'admin-2', 'name': 'Demo salon 2'},
      {'id': 'admin-3', 'name': 'Demo salon 3'},
      {'id': 'admin-4', 'name': 'Demo salon 4'},
      {'id': 'admin-5', 'name': 'Demo salon 5'},
      {'id': 'admin-6', 'name': 'Demo salon 6'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text(
          'Termino – Korisnik',
          style: TextStyle(color: Color(0xFFC3F44D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: Padding(
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
                  return ListTile(
                    title: Text(
                      p['name']!,
                      style: const TextStyle(color: Color(0xFFC3F44D)),
                    ),
                    subtitle: Text(
                      'Pružatelj: ${p['name']}',
                      style: const TextStyle(color: Color(0xFFC3F44D)),
                    ),
                    trailing:
                    const Icon(Icons.chevron_right, color: Color(0xFFC3F44D)),
                    onTap: () {
                      // → IDEMO NA PRAVI EKRAN za odabir usluge
                      Navigator.pushNamed(
                        context,
                        '/select-service',
                        arguments: {
                          'providerId': p['id'],
                          'providerName': p['name'],
                        },
                      );
                    },
                  );
                },
                separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFC3F44D)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}