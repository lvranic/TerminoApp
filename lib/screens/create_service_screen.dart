import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class CreateServiceScreen extends StatefulWidget {
  static const route = '/create-service';

  final String providerId;

  const CreateServiceScreen({super.key, required this.providerId});

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();

  final String _mutation = r'''
    mutation CreateService(
      $providerId: String!,
      $name: String!,
      $durationMinutes: Int!
    ) {
      createService(
        providerId: $providerId,
        name: $name,
        durationMinutes: $durationMinutes
      ) {
        id
      }
    }
  ''';

  Future<void> _submit(GraphQLClient client) async {
    if (!_formKey.currentState!.validate()) return;

    final result = await client.mutate(
      MutationOptions(
        document: gql(_mutation),
        variables: {
          'providerId': widget.providerId,
          'name': _nameController.text.trim(),
          'durationMinutes': int.parse(_durationController.text.trim()),
        },
      ),
    );

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: ${result.exception.toString()}')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Usluga uspješno dodana ✅')),
    );

    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final client = GraphQLProvider.of(context).value;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text(
          'Dodaj uslugu',
          style: TextStyle(color: Color(0xFFC3F44D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      backgroundColor: const Color(0xFF1A434E),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Naziv usluge'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Unesite naziv' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration:
                const InputDecoration(labelText: 'Trajanje (u minutama)'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Unesite trajanje';
                  final val = int.tryParse(v);
                  if (val == null || val <= 0) return 'Neispravno trajanje';
                  return null;
                },
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => _submit(client),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC3F44D),
                  foregroundColor: const Color(0xFF1A434E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  'Spremi uslugu',
                  style: TextStyle(fontFamily: 'Sofadi One'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}