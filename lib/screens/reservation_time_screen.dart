import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'reservation_confirmation_screen.dart';

class ReservationTimeScreen extends StatefulWidget {
  static const route = '/reservation-time';

  final String providerId;
  final String providerName;
  final String serviceId;
  final DateTime date;

  const ReservationTimeScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.date,
  });

  @override
  State<ReservationTimeScreen> createState() => _ReservationTimeScreenState();
}

class _ReservationTimeScreenState extends State<ReservationTimeScreen> {
  late final List<TimeOfDay> _slots;

  @override
  void initState() {
    super.initState();
    _slots = _generateSlots(
      startHour: 9,
      endHour: 17,
      stepMinutes: 30,
      date: widget.date,
    );
  }

  List<TimeOfDay> _generateSlots({
    required int startHour,
    required int endHour,
    required int stepMinutes,
    required DateTime date,
  }) {
    final List<TimeOfDay> out = [];
    final now = DateTime.now();

    for (int h = startHour; h <= endHour; h++) {
      for (int m = 0; m < 60; m += stepMinutes) {
        final t = TimeOfDay(hour: h, minute: m);
        final asDateTime = DateTime(date.year, date.month, date.day, t.hour, t.minute);

        if (date.year == now.year &&
            date.month == now.month &&
            date.day == now.day &&
            asDateTime.isBefore(now)) continue;

        if (h == endHour && m > 0) continue;

        out.add(t);
      }
    }
    return out;
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: Text(
          'Odabir vremena – ${widget.providerName}',
          style: const TextStyle(color: Color(0xFFC3F44D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Datum: ${_formatDate(widget.date)}',
              style: const TextStyle(color: Color(0xFFC3F44D)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _slots.isEmpty
                  ? const Center(
                child: Text(
                  'Nema dostupnih termina za odabrani datum.',
                  style: TextStyle(color: Color(0xFFC3F44D)),
                ),
              )
                  : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.6,
                ),
                itemCount: _slots.length,
                itemBuilder: (_, i) {
                  final t = _slots[i];
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFC3F44D)),
                      foregroundColor: const Color(0xFFC3F44D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final client = GraphQLProvider.of(context).value;

                      const query = r'''
                              query GetService($id: String!) {
                                serviceById(id: $id) {
                                  durationMinutes
                                }
                              }
                            ''';

                      final result = await client.query(QueryOptions(
                        document: gql(query),
                        variables: {'id': widget.serviceId},
                      ));

                      if (result.hasException) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Greška: Ne mogu dohvatiti trajanje usluge')),
                        );
                        return;
                      }

                      final duration = result.data?['serviceById']?['durationMinutes'] ?? 30;

                      Navigator.pushNamed(
                        context,
                        ReservationConfirmationScreen.route,
                        arguments: {
                          'providerId': widget.providerId,
                          'providerName': widget.providerName,
                          'serviceId': widget.serviceId,
                          'date': widget.date,
                          'timeHour': t.hour,
                          'timeMinute': t.minute,
                          'durationMinutes': duration,
                        },
                      );
                    },
                    child: Text(
                      _formatTime(t),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}