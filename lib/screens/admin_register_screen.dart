import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/auth_service.dart';
import 'admin_dashboard_screen.dart';

class AdminRegisterScreen extends StatefulWidget {
  static const route = '/admin-register';
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  // Podaci o obrtu – spremit ćemo u 2. paketu na backend
  final _businessName = TextEditingController();
  final _address = TextEditingController();
  final _workHours = TextEditingController(); // npr. "Pon-Pet 9-17"
  final _serviceDuration = TextEditingController(); // u minutama

  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;
    final auth = AuthService(client);

    return Scaffold(
      appBar: AppBar(title: const Text('Registracija pružatelja usluga')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Ime i prezime')),
              const SizedBox(height: 8),
              TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 8),
              TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Telefon')),
              const SizedBox(height: 8),
              TextField(controller: _password, decoration: const InputDecoration(labelText: 'Lozinka'), obscureText: true),
              const Divider(height: 32),
              TextField(controller: _businessName, decoration: const InputDecoration(labelText: 'Naziv obrta')),
              const SizedBox(height: 8),
              TextField(controller: _address, decoration: const InputDecoration(labelText: 'Adresa')),
              const SizedBox(height: 8),
              TextField(controller: _workHours, decoration: const InputDecoration(labelText: 'Radno vrijeme')),

              const SizedBox(height: 8),
              TextField(
                controller: _serviceDuration,
                decoration: const InputDecoration(labelText: 'Trajanje jedne usluge (min)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loading ? null : () async {
                  setState(() { _loading = true; _error = null; });
                  try {
                    // 1) Kreiraj “admin” korisnika
                    await auth.register(
                      name: _name.text.trim(),
                      email: _email.text.trim(),
                      phone: _phone.text.trim(),
                      role: 'Admin',
                      password: _password.text,
                    );
                    // 2) U 2. paketu: poslat ćemo i profil obrta (mutacija npr. saveBusinessProfile)

                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, AdminDashboardScreen.route);
                  } catch (e) {
                    setState(() => _error = e.toString());
                  } finally {
                    setState(() => _loading = false);
                  }
                },
                child: Text(_loading ? 'Spremam...' : 'Registriraj obrt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}