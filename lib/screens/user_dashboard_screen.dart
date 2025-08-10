import 'package:flutter/material.dart';
import 'select_service_screen.dart'; // dolazi u 2. paketu

class UserDashboardScreen extends StatelessWidget {
  static const route = '/user-dashboard';
  const UserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Termino – Korisnik')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Odaberi uslugu i pružatelja', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: 6,
                itemBuilder: (_, i) => ListTile(
                  title: Text('Usluga #${i + 1}'),
                  subtitle: const Text('Pružatelj: Demo salon'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SelectServiceScreenPlaceholder()));
                  },
                ),
                separatorBuilder: (_, __) => const Divider(height: 1),
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
      appBar: AppBar(title: const Text('Odabir usluge')),
      body: const Center(child: Text('Dolazi u 2. paketu…')),
    );
  }
}