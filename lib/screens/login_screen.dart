// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/auth_service.dart';
import 'user_dashboard_screen.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  static const route = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;
    final auth = AuthService(client);

    return Scaffold(
      appBar: AppBar(title: const Text('Prijava')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: _password, decoration: const InputDecoration(labelText: 'Lozinka'), obscureText: true),
            const SizedBox(height: 12),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : () async {
                setState(() { _loading = true; _error = null; });
                try {
                  final AuthResult result = await auth.login(
                    email: _email.text.trim(),
                    password: _password.text,
                  );

                  // result.user je Map<String, dynamic>?
                  final Map<String, dynamic>? user = result.user;
                  final String role = (user?['role'] as String? ?? 'user').toLowerCase();

                  final route = (role == 'admin')
                      ? MaterialPageRoute(builder: (_) => const AdminDashboardScreen())
                      : MaterialPageRoute(builder: (_) => const UserDashboardScreen());

                  if (!mounted) return;
                  Navigator.of(context).pushReplacement(route);
                } catch (e) {
                  setState(() => _error = e.toString());
                } finally {
                  setState(() => _loading = false);
                }
              },
              child: Text(_loading ? 'Prijavljujem...' : 'Prijavi se'),
            ),
          ],
        ),
      ),
    );
  }
}