import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../services/auth_service.dart';

class AddServiceScreen extends StatefulWidget {
  static const route = '/add-service';
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _serviceName = TextEditingController();
  final _durationMinutes = TextEditingController();

  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _saveService() async {
    final client = GraphQLProvider.of(context).value;
    final auth = AuthService(client);
    final user = auth.getCurrentUser();
    final providerId = user?['id'] as String?;

    if (providerId == null) {
      setState(() => _error = 'Greška: Nedostaje provider ID.');
      return;
    }

    final name = _serviceName.text.trim();
    final durationMinutes = int.tryParse(_durationMinutes.text.trim()) ?? 30;

    const mutation = r'''
      mutation CreateService($providerId: String!, $name: String!, $durationMinutes: Int!) {
        createService(providerId: $providerId, name: $name, durationMinutes: $durationMinutes) {
          id
        }
      }
    ''';

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final result = await client.mutate(MutationOptions(
        document: gql(mutation),
        variables: {
          'providerId': providerId,
          'name': name,
          'durationMinutes': durationMinutes,
        },
      ));

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      setState(() => _success = 'Usluga uspješno dodana!');
      _serviceName.clear();
      _durationMinutes.clear();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        title: const Text(
          'Dodaj uslugu',
          style: TextStyle(color: Color(0xFFC3F44D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTextField('Naziv usluge', _serviceName),
            const SizedBox(height: 16),
            _buildTextField('Trajanje u minutama', _durationMinutes, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_success != null)
              Text(_success!, style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16), // ~2 cm sa svake strane
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _saveService,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFC3F44D),
                    foregroundColor: const Color(0xFF1A434E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(_loading ? 'Spremam...' : 'Spremi uslugu'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
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