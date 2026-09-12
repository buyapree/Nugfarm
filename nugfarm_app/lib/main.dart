import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'screens/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NugfarmApp());
}

class NugfarmApp extends StatelessWidget {
  const NugfarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    const hijauTua = Color(0xFF3A5A40);
    const coklatKopi = Color(0xFF6F4E37);
    const krem = Color(0xFFF3EFE6);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: hijauTua,
      primary: hijauTua,
      secondary: coklatKopi,
      surface: Colors.white,
      brightness: Brightness.light,
    );

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: krem,
      appBarTheme: const AppBarTheme(
        backgroundColor: hijauTua,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: hijauTua,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: coklatKopi,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: hijauTua, width: 2),
        ),
      ),
    );

    return MaterialApp(
      title: 'Nugfarm',
      theme: theme,
      home: FutureBuilder(
        future: Supabase.initialize(
          url: SupabaseConfig.url,
          anonKey: SupabaseConfig.anonKey,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return const AuthGate();
          }
          return Scaffold(
            backgroundColor: krem,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.eco, size: 56, color: hijauTua),
                  const SizedBox(height: 16),
                  const Text('Nugfarm',
                      style: TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold, color: hijauTua)),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(color: hijauTua),
                  const SizedBox(height: 12),
                  const Text('Menghubungkan ke server...',
                      style: TextStyle(color: coklatKopi, fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
