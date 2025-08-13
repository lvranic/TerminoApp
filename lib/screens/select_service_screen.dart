// lib/screens/select_service_screen.dart
import 'package:flutter/material.dart';
import 'reservation_date_screen.dart';

class SelectServiceScreen extends StatelessWidget {
  static const route = '/select-service';
  const SelectServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final providerId = args['providerId']?.toString() ?? '';
    final providerName = args['providerName']?.toString() ?? 'Pružatelj';

    // Demo popis usluga – kasnije ćeš ih puniti iz backenda
    final services = const [
      {'id': 'svc-1', 'name': 'Šišanje'},
      {'id': 'svc-2', 'name': 'Brijanje'},
      {'id': 'svc-3', 'name': 'Manikura'},
      {'id': 'svc-4', 'name': 'Masaža leđa'},
      {'id': 'svc-5', 'name': 'Instrukcija'},
    ];


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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final s = services[i];
          return ListTile(
            tileColor: Colors.white24,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              s['name']!,
              style: const TextStyle(color: Color(0xFFC3F44D), fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFFC3F44D)),
            onTap: () {
              Navigator.pushNamed(
                context,
                ReservationDateScreen.route,
                arguments: {
                  'providerId': providerId,
                  'providerName': providerName,
                  'serviceId': s['id'],
                },
              );
            },
          );
        },
      ),
    );
  }
}