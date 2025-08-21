import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class EditBusinessScreen extends StatefulWidget {
  static const route = '/edit-business';

  final String userId;
  final String currentAddress;
  final String currentWorkHours;

  const EditBusinessScreen({
    super.key,
    required this.userId,
    required this.currentAddress,
    required this.currentWorkHours,
  });

  @override
  State<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends State<EditBusinessScreen> {
  late TextEditingController _addressController;
  late TextEditingController _workHoursController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.currentAddress);
    _workHoursController = TextEditingController(text: widget.currentWorkHours);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _workHoursController.dispose();
    super.dispose();
  }

  void _submit() async {
    final client = GraphQLProvider.of(context).value;
    const mutation = r'''
      mutation UpdateUser(
        \$userId: String!
        \$address: String!
        \$workHours: String!
      ) {
        updateUser(userId: \$userId, address: \$address, workHours: \$workHours) {
          id
          address
          workHours
        }
      }
    ''';

    final result = await client.mutate(MutationOptions(
      document: gql(mutation),
      variables: {
        'userId': widget.userId,
        'address': _addressController.text,
        'workHours': _workHoursController.text,
      },
    ));

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: ${result.exception.toString()}')),
      );
      return;
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        title: const Text('Uredi obrt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _addressController,
              style: const TextStyle(color: Color(0xFFC3F44D)),
              decoration: const InputDecoration(
                labelText: 'Adresa',
                labelStyle: TextStyle(color: Color(0xFFC3F44D)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFC3F44D)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _workHoursController,
              style: const TextStyle(color: Color(0xFFC3F44D)),
              decoration: const InputDecoration(
                labelText: 'Radno vrijeme (npr. Pon–Pet 9–17)',
                labelStyle: TextStyle(color: Color(0xFFC3F44D)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFC3F44D)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Spremi promjene'),
            ),
          ],
        ),
      ),
    );
  }
}
