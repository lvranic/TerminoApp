// lib/main.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql/graphql_config.dart';

// Core ekrani
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_register_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/select_service_screen.dart';

// Rezervacije (dinamični argumenti idu kroz onGenerateRoute)
import 'screens/reservation_date_screen.dart';
import 'screens/reservation_time_screen.dart';
import 'screens/reservation_confirmation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final clientNotifier = await buildGraphQLNotifier();

  runApp(
    GraphQLProvider(
      client: clientNotifier,
      child: const TerminoApp(),
    ),
  );
}

class TerminoApp extends StatelessWidget {
  const TerminoApp({super.key});

  // Helper: parse DateTime iz dynamic (String ISO8601 ili DateTime)
  DateTime _parseDate(dynamic v) {
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) return DateTime.parse(v);
    return DateTime.now();
  }

  // Helper: parse TimeOfDay iz dynamic (TimeOfDay ili "HH:mm" ili "HH:mm:ss")
  TimeOfDay _parseTime(dynamic v) {
    if (v is TimeOfDay) return v;
    if (v is String && v.isNotEmpty) {
      final parts = v.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      return TimeOfDay(hour: h, minute: m);
    }
    final now = TimeOfDay.now();
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Termino',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFC3F44D),
        scaffoldBackgroundColor: const Color(0xFF1A434E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A434E),
          foregroundColor: Color(0xFFC3F44D),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFC3F44D)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingPage(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/admin-register': (_) => const AdminRegisterScreen(),
        '/user-dashboard': (_) => const UserDashboardScreen(),
        '/admin-dashboard': (_) => const AdminDashboardScreen(),
        '/select-service': (_) => const SelectServiceScreen(),
      },
      onGenerateRoute: (settings) {
        final args = (settings.arguments as Map?) ?? {};

        // 1) Odabir datuma
        if (settings.name == ReservationDateScreen.route) {
          return MaterialPageRoute(
            builder: (_) => ReservationDateScreen(
              providerId: args['providerId']?.toString() ?? '',
              providerName: args['providerName']?.toString() ?? '',
              serviceId: args['serviceId']?.toString() ?? '',
            ),
          );
        }

        // 2) Odabir vremena
        if (settings.name == ReservationTimeScreen.route) {
          return MaterialPageRoute(
            builder: (_) => ReservationTimeScreen(
              providerId: args['providerId']?.toString() ?? '',
              providerName: args['providerName']?.toString() ?? '',
              serviceId: args['serviceId']?.toString() ?? '',
              date: _parseDate(args['date']),
            ),
          );
        }

        // 3) Potvrda rezervacije
        if (settings.name == ReservationConfirmationScreen.route) {
          return MaterialPageRoute(
            builder: (_) => ReservationConfirmationScreen(
              providerId: args['providerId']?.toString() ?? '',
              providerName: args['providerName']?.toString() ?? '',
              serviceId: args['serviceId']?.toString() ?? '',
              date: _parseDate(args['date']),
              time: _parseTime(args['time']),
            ),
          );
        }

        return null;
      },
    );
  }
}