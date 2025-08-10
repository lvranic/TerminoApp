import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const route = '/admin-dashboard';
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Termino – Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rezervacije vašeg obrta', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: 5,
                itemBuilder: (_, i) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('Korisnik #${i + 1}'),
                  subtitle: const Text('Datum: 12.09. u 14:30  •  Usluga: Frizura'),
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