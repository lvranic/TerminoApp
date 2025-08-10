import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/auth_service.dart';
import 'user_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const route = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  String _role = 'User';

  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;
    final auth = AuthService(client);

    return Scaffold(
      appBar: AppBar(title: const Text('Registracija korisnika')),
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
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Uloga'),
                items: const [
                  DropdownMenuItem(value: 'User', child: Text('User')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'User'),
              ),
              const SizedBox(height: 8),
              TextField(controller: _password, decoration: const InputDecoration(labelText: 'Lozinka'), obscureText: true),
              const SizedBox(height: 12),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loading ? null : () async {
                  setState(() { _loading = true; _error = null; });
                  try {
                    await auth.register(
                      name: _name.text.trim(),
                      email: _email.text.trim(),
                      phone: _phone.text.trim(),
                      role: _role,
                      password: _password.text,
                    );
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(context, UserDashboardScreen.route);
                  } catch (e) {
                    setState(() => _error = e.toString());
                  } finally {
                    setState(() => _loading = false);
                  }
                },
                child: Text(_loading ? 'Kreiram...' : 'Kreiraj račun'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}