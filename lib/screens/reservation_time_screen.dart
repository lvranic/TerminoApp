import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

class ReservationTimeScreen extends StatefulWidget {
  static const route = '/reservation-time';

  final String providerId;
  final String providerName;
  final String serviceId;
  final String serviceName; // ✅ Dodano
  final DateTime selectedDate;

  const ReservationTimeScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName, // ✅ Dodano
    required this.selectedDate,
  });

  @override
  State<ReservationTimeScreen> createState() => _ReservationTimeScreenState();
}

class _ReservationTimeScreenState extends State<ReservationTimeScreen> {
  final int startHour = 9;
  final int endHour = 17;
  int serviceDuration = 0;
  List<Map<String, dynamic>> reservations = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final client = GraphQLProvider.of(context).value;

    await _fetchServiceDuration(client);
    await _fetchReservations(client);

    setState(() => isLoading = false);
  }

  Future<void> _fetchServiceDuration(GraphQLClient client) async {
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

    if (!result.hasException && result.data?['serviceById'] != null) {
      serviceDuration = result.data!['serviceById']['durationMinutes'];
    } else {
      print("❌ Error fetching service duration: ${result.exception}");
    }
  }

  Future<void> _fetchReservations(GraphQLClient client) async {
    const query = r'''
      query ReservationsByProvider($providerId: String!, $startDate: DateTime!, $endDate: DateTime!) {
        reservationsByProvider(providerId: $providerId, startDate: $startDate, endDate: $endDate) {
          startsAt
          durationMinutes
        }
      }
    ''';

    final start = DateTime.utc(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    final end = start.add(const Duration(days: 1));

    final result = await client.query(QueryOptions(
      document: gql(query),
      variables: {
        'providerId': widget.providerId,
        'startDate': start.toIso8601String(),
        'endDate': end.toIso8601String(),
      },
    ));

    if (result.hasException) {
      print("❌ Error fetching reservations: ${result.exception}");
      return;
    }

    final resData = result.data?['reservationsByProvider'] as List?;
    if (resData != null) {
      reservations = resData.map((res) {
        return {
          'start': DateTime.parse(res['startsAt']),
          'duration': res['durationMinutes'],
        };
      }).toList();
    }
  }

  bool _isSlotAvailable(DateTime slotStart) {
    final slotEnd = slotStart.add(Duration(minutes: serviceDuration));
    for (final res in reservations) {
      final resStart = res['start'] as DateTime;
      final resEnd = resStart.add(Duration(minutes: res['duration'] as int));
      if (slotStart.isBefore(resEnd) && slotEnd.isAfter(resStart)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
        title: Text('Odabir vremena – ${widget.serviceName}',
          style: const TextStyle(color: Color(0xFFC3F44D)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC3F44D)))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datum: ${DateFormat('dd.MM.yyyy').format(widget.selectedDate)}',
              style: const TextStyle(color: Color(0xFFC3F44D)),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: (endHour - startHour) * 2,
                itemBuilder: (context, index) {
                  final hour = startHour + (index ~/ 2);
                  final minute = (index % 2) * 30;
                  final slotStart = DateTime(
                    widget.selectedDate.year,
                    widget.selectedDate.month,
                    widget.selectedDate.day,
                    hour,
                    minute,
                  );

                  final available = _isSlotAvailable(slotStart);
                  final displayTime = DateFormat('HH:mm').format(slotStart);

                  return OutlinedButton(
                    onPressed: available
                        ? () {
                      Navigator.pushNamed(
                        context,
                        '/reservation-confirmation',
                        arguments: {
                          'providerId': widget.providerId,
                          'providerName': widget.providerName,
                          'serviceId': widget.serviceId,
                          'serviceName': widget.serviceName, // ✅ proslijedi dalje
                          'date': widget.selectedDate,
                          'timeHour': hour,
                          'timeMinute': minute,
                          'durationMinutes': serviceDuration,
                        },
                      );
                    }
                        : null,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: available ? const Color(0xFFC3F44D) : Colors.grey,
                      ),
                      backgroundColor: available ? null : Colors.grey.shade800,
                    ),
                    child: Text(
                      displayTime,
                      style: TextStyle(
                        color: available ? const Color(0xFFC3F44D) : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
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