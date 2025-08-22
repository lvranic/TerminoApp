import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class EditServiceScreen extends StatefulWidget {
  final String serviceId;
  final String currentName;
  final int currentDuration;

  const EditServiceScreen({
    super.key,
    required this.serviceId,
    required this.currentName,
    required this.currentDuration,
  });

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _duration;

  final String updateServiceMutation = r'''
    mutation UpdateService($id: String!, $newDuration: Int!) {
      updateService(serviceId: $id, newDurationMinutes: $newDuration) {
        id
        name
        durationMinutes
      }
    }
  ''';

  @override
  void initState() {
    super.initState();
    _duration = widget.currentDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: Text(
          'Uredi uslugu: ${widget.currentName}',
          style: const TextStyle(color: Color(0xFFC3F44D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Builder(
              builder: (ctx) => Column(
                children: [
                  TextFormField(
                    initialValue: _duration.toString(),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Trajanje usluge (min)',
                      labelStyle: TextStyle(color: Color(0xFFC3F44D)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFC3F44D)),
                      ),
                    ),
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null || parsed <= 0) {
                        return 'Unesite ispravno trajanje u minutama';
                      }
                      return null;
                    },
                    onChanged: (val) => _duration = int.tryParse(val) ?? _duration,
                  ),
                  const SizedBox(height: 24),
                  Mutation(
                    options: MutationOptions(
                      document: gql(updateServiceMutation),
                      onCompleted: (_) {
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).clearSnackBars();
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Usluga je ažurirana!'),
                            backgroundColor: Color(0xFFC3F44D),
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(ctx, true);
                      },
                    ),
                    builder: (runMutation, result) {
                      return Column(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                runMutation({
                                  'id': widget.serviceId,
                                  'newDuration': _duration,
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC3F44D),
                              foregroundColor: const Color(0xFF1A434E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: result?.isLoading ?? false
                                ? const CircularProgressIndicator()
                                : const Text('Spremi promjene'),
                          ),
                          if (result?.hasException ?? false)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'Greška: ${result!.exception.toString()}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}