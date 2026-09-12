import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_menu_screen.dart';
import 'field_home_screen.dart';

/// Cek session yang sudah tersimpan; kalau ada, langsung arahkan
/// ke halaman sesuai role tanpa perlu login ulang.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return const LoginScreen();
    }

    return FutureBuilder<String?>(
      future: _authService.getRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == 'admin') {
          return const HomeMenuScreen();
        }
        return const FieldHomeScreen();
      },
    );
  }
}
