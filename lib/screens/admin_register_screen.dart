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

  final _businessName = TextEditingController();
  final _address = TextEditingController();
  final _workHours = TextEditingController();
  final _serviceDuration = TextEditingController();

  bool _loading = false;
  String? _error;

  static const _createServiceMutation = r'''
    mutation CreateService($providerId: String!, $name: String!, $durationMinutes: Int!) {
      createService(providerId: $providerId, name: $name, durationMinutes: $durationMinutes) {
        id
      }
    }
  ''';

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;
    final auth = AuthService(client);

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text(
          'Registracija pružatelja usluga',
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
              const Divider(height: 32, color: Color(0xFFC3F44D)),
              _buildTextField('Naziv obrta', _businessName),
              const SizedBox(height: 8),
              _buildTextField('Adresa', _address),
              const SizedBox(height: 8),
              _buildTextField('Radno vrijeme (npr. Pon–Pet 9–17)', _workHours),
              const SizedBox(height: 8),
              _buildTextField(
                'Trajanje jedne usluge (min)',
                _serviceDuration,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed: _loading ? null : () => _registerAdmin(auth, client),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC3F44D),
                      foregroundColor: const Color(0xFF1A434E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      _loading ? 'Spremam...' : 'Registriraj obrt',
                      style: const TextStyle(fontFamily: 'Sofadi One'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerAdmin(AuthService auth, GraphQLClient client) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await auth.register(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        role: 'Admin',
        password: _password.text.trim(),
      );

      final userId = result.user['id'] as String;

      final duration = int.tryParse(_serviceDuration.text.trim()) ?? 30;

      await client.mutate(
        MutationOptions(
          document: gql(_createServiceMutation),
          variables: {
            'providerId': userId,
            'name': _businessName.text.trim(),
            'durationMinutes': duration,
          },
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AdminDashboardScreen.route);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
        bool obscureText = false,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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
