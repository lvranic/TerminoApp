import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class EditUserScreen extends StatefulWidget {
  static const route = '/edit-user';

  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  final String _meQuery = '''
    query {
      me {
        id
        name
        email
        phone
        address
      }
    }
  ''';

  final String _updateUserMutation = '''
    mutation UpdateUser(\$userId: String!, \$address: String!, \$phone: String!) {
      updateUser(userId: \$userId, address: \$address, phone: \$phone) {
        id
        address
        phone
      }
    }
  ''';

  String? _userId;
  String? _name;
  String? _email;

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final client = GraphQLProvider.of(context).value;
    final result = await client.query(QueryOptions(document: gql(_meQuery)));

    if (result.hasException || result.data?['me'] == null) return;

    final user = result.data!['me'];
    _userId = user['id'];
    _name = user['name'];
    _email = user['email'];
    _addressController.text = user['address'] ?? '';
    _phoneController.text = user['phone'] ?? '';
    setState(() {});
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate() || _userId == null) return;

    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(MutationOptions(
      document: gql(_updateUserMutation),
      variables: {
        'userId': _userId!,
        'address': _addressController.text,
        'phone': _phoneController.text,
      },
    ));

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: ${result.exception.toString()}')),
      );
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaci su uspješno spremljeni!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData(); // ✅ PRAVILNO MJESTO ZA POZIV KOJI KORISTI context
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        title: const Text('Uredi profil'),
      ),
      body: _userId == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC3F44D)))
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Ime: $_name', style: const TextStyle(color: Color(0xFFC3F44D))),
              Text('Email: $_email', style: const TextStyle(color: Color(0xFFC3F44D))),
              const SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Color(0xFFC3F44D)),
                decoration: const InputDecoration(
                  labelText: 'Broj mobitela',
                  labelStyle: TextStyle(color: Color(0xFFC3F44D)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC3F44D)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC3F44D),
                  foregroundColor: const Color(0xFF1A434E),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text('Spremi promjene'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}