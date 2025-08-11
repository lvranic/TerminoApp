import 'package:flutter/material.dart';
import 'select_service_screen.dart'; // dolazi u 2. paketu

class UserDashboardScreen extends StatelessWidget {
  static const route = '/user-dashboard';
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                itemCount: 6,
                itemBuilder: (_, i) => ListTile(
                  title: Text(
                    'Usluga #${i + 1}',
                    style: const TextStyle(color: Color(0xFFC3F44D)),
                  ),
                  subtitle: const Text(
                    'Pružatelj: Demo salon',
                    style: TextStyle(color: Color(0xFFC3F44D)),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFFC3F44D)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SelectServiceScreenPlaceholder(),
                      ),
                    );
                  },
                ),
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFC3F44D)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// privremeni placeholder dok ne stigne 2. paket
class SelectServiceScreenPlaceholder extends StatelessWidget {
  const SelectServiceScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text(
          'Odabir usluge',
          style: TextStyle(color: Color(0xFFC3F44D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: const Center(
        child: Text(
          'Dolazi u 2. paketu…',
          style: TextStyle(color: Color(0xFFC3F44D)),
        ),
      ),
    );
  }
}