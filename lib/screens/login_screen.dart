import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/auth_service.dart';
import '../utils/token_store.dart';
import '../main.dart';
import '../graphql/graphql_config.dart';
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
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  InputDecoration _fieldDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFC3F44D)),
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white12,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC3F44D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC3F44D), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;
    final auth = AuthService(client);

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Prijava', style: TextStyle(color: Color(0xFFC3F44D))),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _email,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: _fieldDeco('Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                style: const TextStyle(color: Colors.white),
                decoration: _fieldDeco('Lozinka'),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading
                      ? null
                      : () async {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });

                    try {
                      final AuthResult result = await auth.login(
                        email: _email.text.trim(),
                        password: _password.text,
                      );

                      // Osvježi token – očisti stari ako postoji
                      await TokenStore.clear();
                      await TokenStore.set(result.token);

                      graphQLClient = await buildGraphQLNotifier();

                      // TEST: Ispiši spremljeni token
                      final savedToken = await TokenStore.get();
                      print("Spremljeni token: $savedToken");
                      print("Token koji je u TokenStore.get(): $savedToken");

                      final Map<String, dynamic>? user = result.user;
                      final String role = (user?['role'] as String? ?? 'user').toLowerCase();

                      final route = (role == 'admin')
                          ? MaterialPageRoute(builder: (_) => const AdminDashboardScreen())
                          : MaterialPageRoute(builder: (_) => const UserDashboardScreen());

                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(route);
                    } catch (e) {
                      String errorMessage = 'Došlo je do greške.';

                      if (e.toString().contains('Pogrešan email ili lozinka')) {
                        errorMessage = 'Email adresa ili lozinka nisu ispravni.';
                      } else if (e.toString().contains('Korisnik s danim emailom već postoji')) {
                        errorMessage = 'Email adresa već postoji u bazi podataka.';
                      }

                      setState(() => _error = errorMessage);
                    } finally {
                      setState(() => _loading = false);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC3F44D),
                    foregroundColor: const Color(0xFF1A434E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(_loading ? 'Prijavljujem...' : 'Prijavi se'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}