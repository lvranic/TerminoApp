import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class ReservationConfirmationScreen extends StatelessWidget {
  static const route = '/reservation-confirmation';

  final String providerId;
  final String providerName;
  final String serviceId;
  final DateTime date;
  final TimeOfDay time;

  const ReservationConfirmationScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.date,
    required this.time,
  });

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  final String _createReservationMutation = r'''
    mutation CreateReservation(
      $providerId: String!,
      $serviceId: String!,
      $startsAtUtc: DateTime!,
      $duration: Int
    ) {
      createReservation(
        providerId: $providerId,
        serviceId: $serviceId,
        startsAtUtc: $startsAtUtc,
        durationMinutes: $duration
      ) {
        id
      }
    }
  ''';

  Future<void> _saveReservation(BuildContext context) async {
    final client = GraphQLProvider.of(context).value;

    final localStart = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final startsAtUtc = localStart.toUtc().toIso8601String();

    final result = await client.mutate(
      MutationOptions(
        document: gql(_createReservationMutation),
        variables: <String, dynamic>{
          'providerId': providerId,
          'serviceId': serviceId,
          'startsAtUtc': startsAtUtc,
          'duration': 30,
        },
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      final msg = result.exception.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri spremanju: $msg')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rezervacija spremljena ✅')),
    );
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text(
          'Potvrda rezervacije',
          style: TextStyle(color: Color(0xFFC3F44D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Row(label: 'Pružatelj', value: '$providerName (ID: $providerId)'),
            const SizedBox(height: 12),
            _Row(label: 'Usluga', value: serviceId),
            const SizedBox(height: 12),
            _Row(label: 'Datum', value: _formatDate(date)),
            const SizedBox(height: 12),
            _Row(label: 'Vrijeme', value: _formatTime(time)),
            const Spacer(),
            FilledButton(
              onPressed: () => _saveReservation(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC3F44D),
                foregroundColor: const Color(0xFF1A434E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: const Text(
                'Potvrdi',
                style: TextStyle(fontFamily: 'Sofadi One'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFC3F44D);
    return Row(
      children: [
        const SizedBox(width: 2),
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: color),
          ),
        ),
      ],
    );
  }
}