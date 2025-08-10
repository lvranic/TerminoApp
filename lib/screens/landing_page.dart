// lib/screens/landing_page.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'admin_register_screen.dart';

class LandingPage extends StatelessWidget {
  static const route = '/';

  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E), // tamno-zelena/teal pozadina
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo / naslov
              const SizedBox(height: 24),
              const Text(
                'TERMINO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontFamily: 'Sofadi One',
                  color: Color(0xFFC3F44D), // primarna zelena
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'rješenje za sve vaše dogovore',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Sofadi One',
                  color: Color(0xFFC3F44D),
                ),
              ),

              const Spacer(),

              // Prijava
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, LoginScreen.route),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC3F44D),
                  foregroundColor: const Color(0xFF1A434E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  'Prijava',
                  style: TextStyle(fontSize: 16, fontFamily: 'Sofadi One'),
                ),
              ),
              const SizedBox(height: 12),

              // Registracija korisnika
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, RegisterScreen.route),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFC3F44D), width: 2),
                  foregroundColor: const Color(0xFFC3F44D),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  'Registracija korisnika',
                  style: TextStyle(fontSize: 16, fontFamily: 'Sofadi One'),
                ),
              ),
              const SizedBox(height: 8),

              // Registracija pružatelja usluge (admin)
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AdminRegisterScreen.route),
                child: const Text(
                  'Registracija pružatelja usluge',
                  style: TextStyle(
                    color: Color(0xFFC3F44D),
                    fontFamily: 'Sofadi One',
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}