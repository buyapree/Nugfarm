import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'registrasi_scan_screen.dart';
import 'perawatan_scan_screen.dart';
import '../app_version.dart';

class FieldHomeScreen extends StatelessWidget {
  const FieldHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nugfarm — Lapangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('Registrasi Pohon'),
                    subtitle: const Text('Scan QR, isi data pohon baru'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegistrasiScanScreen()),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.eco),
                    title: const Text('Perawatan Pohon'),
                    subtitle: const Text('Scan QR, catat kunjungan & kondisi'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PerawatanScanScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(appVersion, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
