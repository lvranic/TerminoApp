import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'graphql/graphql_config.dart';

// Ekrani koje već imaš
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_register_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/admin_dashboard_screen.dart';

// Ova dva su “stub” (dodaj datoteke iz točke 2)
import 'screens/admin_setup_screen.dart';
import 'screens/select_service_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Termino',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // Zelena paleta iz tvojeg UI-a
        colorSchemeSeed: const Color(0xFFC3F44D),
        scaffoldBackgroundColor: const Color(0xFF1A434E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A434E),
          foregroundColor: Color(0xFFC3F44D),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingPage(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/admin-register': (_) => const AdminRegisterScreen(), // bez isAdmin
        '/user-dashboard': (_) => const UserDashboardScreen(),
        '/admin-dashboard': (_) => const AdminDashboardScreen(),
        '/select-service': (_) => const SelectServiceScreen(), // stub
        '/admin-setup': (_) => const AdminSetupScreen(),       // stub
      },
    );
  }
}