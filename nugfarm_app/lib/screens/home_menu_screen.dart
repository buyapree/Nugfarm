import 'package:flutter/material.dart';
import 'propinsi_list_screen.dart';
import 'aset_list_screen.dart';
import 'cetak_qr_screen.dart';
import 'monitoring_screen.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../app_version.dart';

class HomeMenuScreen extends StatelessWidget {
  const HomeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nugfarm — Admin'),
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
                    leading: const Icon(Icons.map),
                    title: const Text('Area Lahan'),
                    subtitle: const Text('Propinsi → Kabupaten → Kecamatan → Kelurahan → Area'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PropinsiListScreen()),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.inventory_2),
                    title: const Text('Aset'),
                    subtitle: const Text('Lihat, edit & generate aset per area'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AsetListScreen()),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.qr_code),
                    title: const Text('Cetak QR'),
                    subtitle: const Text('Aset yang belum dicetak QR-nya'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CetakQrScreen()),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.monitor_heart),
                    title: const Text('Monitoring Registrasi'),
                    subtitle: const Text('Progres kerja lapangan per area'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MonitoringScreen()),
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
