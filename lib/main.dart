import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql/graphql_config.dart'; // ⬅️ Import konfiguracije s tokenima
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_register_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/select_service_screen.dart';
import 'screens/reservation_date_screen.dart';
import 'screens/reservation_time_screen.dart';
import 'screens/reservation_confirmation_screen.dart';
import 'screens/add_service_screen.dart';
import 'screens/edit_service_screen.dart';
import 'screens/edit_business_screen.dart';
import 'screens/edit_services_list_screen.dart';
import 'screens/edit_user_screen.dart';
import 'screens/user_appointments_screen.dart';
import 'screens/notifications_screen.dart';

late ValueNotifier<GraphQLClient> graphQLClient; // ⬅️ Globalni client

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  graphQLClient = await buildGraphQLNotifier(); // ⬅️ Token-aware client

  runApp(
    GraphQLProvider(
      client: graphQLClient,
      child: const TerminoApp(),
    ),
  );
}

class TerminoApp extends StatelessWidget {
  const TerminoApp({super.key});

  DateTime _parseDate(dynamic v) {
    if (v is DateTime) return v;
    if (v is String && v.isNotEmpty) return DateTime.parse(v);
    return DateTime.now();
  }

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
        '/add-service': (_) => const AddServiceScreen(),
        '/edit-services-list': (_) => const EditServicesListScreen(),
        '/edit-user': (_) => const EditUserScreen(),
        '/user-appointments': (_) => const UserAppointmentsScreen(),
        '/notifications': (_) => const NotificationsScreen(),
      },
      onGenerateRoute: (settings) {
        final args = (settings.arguments as Map?) ?? {};

        if (settings.name == ReservationDateScreen.route) {
          return MaterialPageRoute(
            builder: (_) => ReservationDateScreen(
              providerId: args['providerId']?.toString() ?? '',
              providerName: args['providerName']?.toString() ?? '',
              serviceId: args['serviceId']?.toString() ?? '',
            ),
          );
        }

        if (settings.name == ReservationTimeScreen.route) {
          return MaterialPageRoute(
            builder: (_) => ReservationTimeScreen(
              providerId: args['providerId']?.toString() ?? '',
              providerName: args['providerName']?.toString() ?? '',
              serviceId: args['serviceId']?.toString() ?? '',
              selectedDate: _parseDate(args['date']),
            ),
          );
        }

        if (settings.name == ReservationConfirmationScreen.route) {
          TimeOfDay time;
          if (args.containsKey('timeHour') && args.containsKey('timeMinute')) {
            final h = (args['timeHour'] as num?)?.toInt() ?? 0;
            final m = (args['timeMinute'] as num?)?.toInt() ?? 0;
            time = TimeOfDay(hour: h, minute: m);
          } else {
            time = _parseTime(args['time']);
          }

          return MaterialPageRoute(
            builder: (_) => ReservationConfirmationScreen(
              providerId: args['providerId']?.toString() ?? '',
              providerName: args['providerName']?.toString() ?? '',
              serviceId: args['serviceId']?.toString() ?? '',
              date: _parseDate(args['date']),
              time: time,
              durationMinutes: (args['durationMinutes'] as num?)?.toInt() ?? 30,
            ),
          );
        }

        if (settings.name == '/edit-service') {
          return MaterialPageRoute(
            builder: (_) => EditServiceScreen(
              serviceId: args['serviceId']?.toString() ?? '',
              currentName: args['currentName']?.toString() ?? '',
              currentDuration: (args['currentDuration'] as num?)?.toInt() ?? 30,
            ),
          );
        }

        if (settings.name == '/edit-business') {
          return MaterialPageRoute(
            builder: (_) => EditBusinessScreen(
              userId: args['userId']?.toString() ?? '',
              currentAddress: args['currentAddress']?.toString() ?? '',
              currentWorkHours: args['currentWorkHours']?.toString() ?? '',
            ),
          );
        }

        return null;
      },
    );
  }
}