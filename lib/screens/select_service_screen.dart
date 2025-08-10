import 'package:flutter/material.dart';

class SelectServiceScreen extends StatelessWidget {
  static const route = '/select-service';
  const SelectServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};
    final providerName = args['providerName'] ?? 'Pružatelj usluge';

    return Scaffold(
      appBar: AppBar(title: Text('Odaberi uslugu – $providerName')),
      body: const Center(
        child: Text('Ovdje će doći lista usluga / termini.'),
      ),
    );
  }
}