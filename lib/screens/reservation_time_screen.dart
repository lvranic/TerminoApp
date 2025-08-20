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
  List<TimeOfDay> _slots = [];
  bool _loading = true;
  int _serviceDuration = 30;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _fetchProviderData();
      _initialized = true;
    }
  }

  Future<void> _fetchProviderData() async {
    final client = GraphQLProvider.of(context).value;

    // Dohvati radno vrijeme i dane
    const providerQuery = r'''
      query GetProvider($id: String!) {
        userById(id: $id) {
          workingHoursRange
          workDays
        }
      }
    ''';

    final providerResult = await client.query(QueryOptions(
      document: gql(providerQuery),
      variables: {'id': widget.providerId},
    ));

    if (providerResult.hasException) {
      setState(() => _loading = false);
      return;
    }

    final providerData = providerResult.data?['userById'];
    final workDays = List<String>.from(providerData?['workDays'] ?? []);
    final workingHoursRange = providerData?['workingHoursRange'] ?? '9-17';

    // Dohvati trajanje usluge
    const serviceQuery = r'''
      query GetService($id: String!) {
        serviceById(id: $id) {
          durationMinutes
        }
      }
    ''';

    final serviceResult = await client.query(QueryOptions(
      document: gql(serviceQuery),
      variables: {'id': widget.serviceId},
    ));

    final duration = serviceResult.data?['serviceById']?['durationMinutes'];
    _serviceDuration = duration ?? 30;

    // Provjera dana
    final weekday = widget.date.weekday; // 1 = pon, 7 = ned
    final dayNames = ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub', 'Ned'];
    final currentDay = dayNames[weekday - 1];

    if (!workDays.contains(currentDay)) {
      _slots = [];
    } else {
      final parts = workingHoursRange.split('-');
      final start = int.tryParse(parts[0]) ?? 9;
      final end = int.tryParse(parts[1]) ?? 17;
      _slots = _generateSlots(
        startHour: start,
        endHour: end,
        stepMinutes: 30,
        date: widget.date,
        duration: _serviceDuration,
      );
    }

    setState(() => _loading = false);
  }

  List<TimeOfDay> _generateSlots({
    required int startHour,
    required int endHour,
    required int stepMinutes,
    required DateTime date,
    required int duration,
  }) {
    final List<TimeOfDay> out = [];
    final now = DateTime.now();

    for (int h = startHour; h <= endHour; h++) {
      for (int m = 0; m < 60; m += stepMinutes) {
        final t = TimeOfDay(hour: h, minute: m);
        final startTime = DateTime(date.year, date.month, date.day, t.hour, t.minute);
        final endTime = startTime.add(Duration(minutes: duration));

        // Preskoči prošle termine
        if (date.year == now.year &&
            date.month == now.month &&
            date.day == now.day &&
            startTime.isBefore(now)) continue;

        // Preskoči ako bi završetak bio izvan radnog vremena
        if (endTime.hour > endHour || (endTime.hour == endHour && endTime.minute > 0)) continue;

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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                    onPressed: () {
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
                          'durationMinutes': _serviceDuration,
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