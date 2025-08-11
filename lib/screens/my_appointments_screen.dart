import 'package:flutter/material.dart';

class MyAppointmentsScreen extends StatefulWidget {
  static const route = '/my-appointments';
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  // TODO: zamijeniti pravim dohvatom preko GraphQL-a
  final List<Map<String, dynamic>> _items = [
    {
      'id': 'a1',
      'service': 'Šišanje',
      'provider': 'Barber Luka',
      'date': DateTime.now().add(const Duration(days: 1)),
      'time': '10:30',
    },
    {
      'id': 'a2',
      'service': 'Masaža leđa',
      'provider': 'Wellness Vita',
      'date': DateTime.now().add(const Duration(days: 3)),
      'time': '17:00',
    },
  ];

  Future<void> _cancel(String id) async {
    // TODO: GraphQL mutacija za otkazivanje termina
    setState(() {
      _items.removeWhere((e) => e['id'] == id);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Termin je otkazan')),
    );
  }

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
      body: _items.isEmpty
          ? const Center(
        child: Text(
          'Trenutno nema rezerviranih termina.',
          style: TextStyle(color: green),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final item = _items[i];
          final date = item['date'] as DateTime;
          return Container(
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                item['service'],
                style: const TextStyle(
                  color: green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${item['provider']} • ${date.day}.${date.month}.${date.year}. u ${item['time']}',
                style: const TextStyle(color: green),
              ),
              trailing: TextButton.icon(
                onPressed: () => _cancel(item['id']),
                icon: const Icon(Icons.cancel, color: green),
                label: const Text('Otkaži', style: TextStyle(color: green)),
                style: TextButton.styleFrom(
                  foregroundColor: green,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}