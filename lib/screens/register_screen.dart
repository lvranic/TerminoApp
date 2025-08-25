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

  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;
    final auth = AuthService(client);

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text(
          'Registracija korisnika',
          style: TextStyle(color: Color(0xFFC3F44D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Ime i prezime', _name),
              const SizedBox(height: 8),
              _buildTextField('Email', _email, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 8),
              _buildTextField('Telefon', _phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 8),
              _buildTextField('Lozinka', _password, obscureText: true),
              const SizedBox(height: 12),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });

                    try {
                      await auth.register(
                        name: _name.text.trim(),
                        email: _email.text.trim(),
                        phone: _phone.text.trim(),
                        role: 'User',
                        password: _password.text,
                      );

                      if (!mounted) return;
                      Navigator.pushReplacementNamed(context, UserDashboardScreen.route);
                    } catch (e) {
                      String errorMessage = 'Došlo je do greške.';

                      if (e.toString().contains('Korisnik s danim emailom već postoji')) {
                        errorMessage = 'Email adresa već postoji u bazi podataka.';
                      }

                      setState(() => _error = errorMessage);
                    } finally {
                      setState(() => _loading = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC3F44D),
                    foregroundColor: const Color(0xFF1A434E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text(
                    _loading ? 'Kreiram...' : 'Kreiraj račun',
                    style: const TextStyle(fontFamily: 'Sofadi One'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
        bool obscureText = false,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFFC3F44D)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFC3F44D)),
        fillColor: Colors.white24,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}