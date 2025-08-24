import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'user_dashboard_screen.dart';

class ReservationConfirmationScreen extends StatefulWidget {
  static const route = '/reservation-confirmation';

  final String providerId;
  final String providerName;
  final String serviceId;
  final DateTime date;
  final TimeOfDay time;
  final int durationMinutes;

  const ReservationConfirmationScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.date,
    required this.time,
    required this.durationMinutes,
  });

  @override
  State<ReservationConfirmationScreen> createState() => _ReservationConfirmationScreenState();
}

class _ReservationConfirmationScreenState extends State<ReservationConfirmationScreen> {
  int? _durationMinutes;
  bool _loading = true;
  String? _error;

  final String _getServiceQuery = r'''
    query ServiceById($id: String!) {
      serviceById(id: $id) {
        id
        name
        durationMinutes
      }
    }
  ''';

  final String _createReservationMutation = r'''
    mutation CreateReservation(
      $providerId: String!,
      $serviceId: String!,
      $startsAtUtc: DateTime!,
      $durationMinutes: Int!
    ) {
      createReservation(
        providerId: $providerId,
        serviceId: $serviceId,
        startsAtUtc: $startsAtUtc,
        durationMinutes: $durationMinutes
      ) {
        id
      }
    }
  ''';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchServiceDuration();
  }

  Future<void> _fetchServiceDuration() async {
    final client = GraphQLProvider.of(context).value;

    try {
      final result = await client.query(QueryOptions(
        document: gql(_getServiceQuery),
        variables: {'id': widget.serviceId},
      ));

      if (result.hasException) throw Exception(result.exception.toString());

      final data = result.data?['serviceById'];
      setState(() {
        _durationMinutes = data['durationMinutes'];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Greška: $e';
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _saveReservation(BuildContext context) async {
    final client = GraphQLProvider.of(context).value;

    final localStart = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      widget.time.hour,
      widget.time.minute,
    );
    final startsAtUtc = localStart.toUtc().toIso8601String();

    final effectiveDuration = _durationMinutes ?? widget.durationMinutes;

    try {
      final result = await client.mutate(
        MutationOptions(
          document: gql(_createReservationMutation),
          variables: <String, dynamic>{
            'providerId': widget.providerId,
            'serviceId': widget.serviceId,
            'startsAtUtc': startsAtUtc,
            'durationMinutes': effectiveDuration,
          },
        ),
      );

      if (result.hasException) throw Exception(result.exception.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rezervacija spremljena ✅')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const UserDashboardScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška pri spremanju: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A434E),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFC3F44D)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        title: const Text('Potvrda rezervacije', style: TextStyle(color: Color(0xFFC3F44D))),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
        backgroundColor: const Color(0xFF1A434E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Row(label: 'Pružatelj', value: '${widget.providerName} (ID: ${widget.providerId})'),
            const SizedBox(height: 12),
            _Row(label: 'Usluga', value: widget.serviceId),
            const SizedBox(height: 12),
            _Row(label: 'Datum', value: _formatDate(widget.date)),
            const SizedBox(height: 12),
            _Row(label: 'Vrijeme', value: _formatTime(widget.time)),
            const SizedBox(height: 12),
            _Row(label: 'Trajanje', value: '${_durationMinutes ?? widget.durationMinutes} min'),
            const Spacer(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
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
              child: const Text('Potvrdi', style: TextStyle(fontFamily: 'Sofadi One')),
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