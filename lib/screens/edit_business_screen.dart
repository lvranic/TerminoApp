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

  final String _updateUserMutation = r'''
    mutation UpdateUser($userId: String!, $address: String!, $workHours: String!) {
      updateUser(userId: $userId, address: $address, workHours: $workHours) {
        id
        address
        workHours
      }
    }
  ''';

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

  void _submit(RunMutation runMutation) {
    final address = _addressController.text.trim();
    final workHours = _workHoursController.text.trim();

    if (address.isEmpty || workHours.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Molimo ispunite sva polja.')),
      );
      return;
    }

    runMutation({
      'userId': widget.userId,
      'address': address,
      'workHours': workHours,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Uredi obrt', style: TextStyle(color: Color(0xFFC3F44D))),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Mutation(
          options: MutationOptions(
            document: gql(_updateUserMutation),
            onCompleted: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Podaci su uspješno spremljeni!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Greška: ${error?.graphqlErrors.firstOrNull?.message ?? 'Nepoznata greška'}',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
          builder: (runMutation, result) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32), // šire margine
                  child: ElevatedButton(
                    onPressed: () => _submit(runMutation),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC3F44D),
                      foregroundColor: const Color(0xFF1A434E),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text('Spremi promjene'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}