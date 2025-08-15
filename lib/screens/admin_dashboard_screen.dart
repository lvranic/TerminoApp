import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const route = '/admin-dashboard';
  const AdminDashboardScreen({super.key});

  static const Color _green = Color(0xFFC3F44D);
  static const Color _background = Color(0xFF1A434E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        title: const Text(
          'Termino – Admin',
          style: TextStyle(color: _green),
        ),
        iconTheme: const IconThemeData(color: _green),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Rezervacije vašeg obrta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _green,
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: _ReservationList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationList extends StatelessWidget {
  const _ReservationList();

  static const Color _green = Color(0xFFC3F44D);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 5, // Ovo ćeš zamijeniti s pravim podacima
      itemBuilder: (_, i) => ListTile(
        leading: const CircleAvatar(
          backgroundColor: _green,
          child: Icon(Icons.person, color: Color(0xFF1A434E)),
        ),
        title: Text(
          'Korisnik #${i + 1}',
          style: const TextStyle(color: _green),
        ),
        subtitle: const Text(
          'Datum: 12.09. u 14:30  •  Usluga: Frizura',
          style: TextStyle(color: _green),
        ),
      ),
      separatorBuilder: (_, __) => const Divider(height: 1, color: _green),
    );
  }
}