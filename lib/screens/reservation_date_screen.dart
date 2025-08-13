import 'package:flutter/material.dart';
import 'reservation_time_screen.dart';

class ReservationDateScreen extends StatefulWidget {
  static const route = '/reservation-date';

  final String providerId;
  final String providerName;
  final String serviceId;

  const ReservationDateScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.serviceId,
  });

  @override
  State<ReservationDateScreen> createState() => _ReservationDateScreenState();
}

class _ReservationDateScreenState extends State<ReservationDateScreen> {
  DateTime? _selectedDate;

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Usluga: ${widget.serviceId}',
              style: const TextStyle(color: Color(0xFFC3F44D)),
            ),
            const SizedBox(height: 8),
            Text(
              'Pružatelj: ${widget.providerId} – ${widget.providerName}',
              style: const TextStyle(color: Color(0xFFC3F44D)),
            ),
            const SizedBox(height: 24),

            // Odabir datuma
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

            // Dalje na izbor vremena
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
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
    final onlyDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    Navigator.pushNamed(
      context,
      ReservationTimeScreen.route,
      arguments: {
        'providerId': widget.providerId,
        'providerName': widget.providerName,
        'serviceId': widget.serviceId,
        // ➜ Šaljemo stvarni DateTime, ne ISO string
        'date': onlyDate,
      },
    );
  }
}