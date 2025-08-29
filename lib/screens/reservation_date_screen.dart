import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'reservation_time_screen.dart';

class ReservationDateScreen extends StatefulWidget {
  static const route = '/reservation-date';

  final String providerId;
  final String providerName;
  final String serviceId;
  final String serviceName;

  const ReservationDateScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
    required this.serviceName,
  });

  @override
  State<ReservationDateScreen> createState() => _ReservationDateScreenState();
}

class _ReservationDateScreenState extends State<ReservationDateScreen> {
  DateTime? _selectedDate;
  List<String> _workDays = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProviderWorkDays();
  }

  Future<void> _loadProviderWorkDays() async {
    final client = GraphQLProvider.of(context).value;

    const query = r'''
      query GetUserById($id: String!) {
        userById(id: $id) {
          workDays
        }
      }
    ''';

    final result = await client.query(QueryOptions(
      document: gql(query),
      variables: {'id': widget.providerId},
    ));

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: ${result.exception.toString()}')),
      );
      return;
    }

    final days = result.data?['userById']?['workDays'];
    if (days != null) {
      setState(() {
        _workDays = List<String>.from(days);
        _loading = false;
      });
    }
  }

  DateTime _findNextValidDate(DateTime start) {
    final dayMap = {
      1: 'Pon',
      2: 'Uto',
      3: 'Sri',
      4: 'Čet',
      5: 'Pet',
      6: 'Sub',
      7: 'Ned',
    };

    var current = start;
    for (int i = 0; i < 365; i++) {
      final label = dayMap[current.weekday];
      if (_workDays.contains(label)) {
        return current;
      }
      current = current.add(const Duration(days: 1));
    }
    return start;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _findNextValidDate(now);

    final Map<int, String> dayMap = {
      1: 'Pon',
      2: 'Uto',
      3: 'Sri',
      4: 'Čet',
      5: 'Pet',
      6: 'Sub',
      7: 'Ned',
    };

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime day) {
        final label = dayMap[day.weekday];
        return _workDays.contains(label);
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFC3F44D),
              surface: Color(0xFF1A434E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _goNext() {
    if (_selectedDate == null) return;

    Navigator.pushNamed(
      context,
      ReservationTimeScreen.route,
      arguments: {
        'providerId': widget.providerId,
        'providerName': widget.providerName,
        'serviceId': widget.serviceId,
        'serviceName': widget.serviceName,
        'date': _selectedDate!.toIso8601String(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: Text(
          'Rezervacija – ${widget.providerName}',
          style: const TextStyle(color: Color(0xFFC3F44D)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Usluga: ${widget.serviceName}',
              style: const TextStyle(color: Color(0xFFC3F44D)),
            ),
            const SizedBox(height: 8),
            Text(
              'Pružatelj: ${widget.providerName}',
              style: const TextStyle(color: Color(0xFFC3F44D)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? 'Odaberi datum'
                    : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3F44D),
                foregroundColor: const Color(0xFF1A434E),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: (_selectedDate != null) ? _goNext : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC3F44D),
                foregroundColor: const Color(0xFF1A434E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: const Text(
                'Dalje',
                style: TextStyle(fontFamily: 'Sofadi One'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}