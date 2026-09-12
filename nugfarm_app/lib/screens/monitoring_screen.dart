import 'package:flutter/material.dart';
import '../models/aset.dart';
import '../services/aset_service.dart';
import 'monitoring_aset_list_screen.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final _service = AsetService();
  late Future<List<Aset>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring Registrasi')),
      body: FutureBuilder<List<Aset>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada aset.'));
          }

          final Map<String, List<Aset>> byArea = {};
          for (final a in items) {
            final key = a.areaLahanNama ?? 'Tanpa Area';
            byArea.putIfAbsent(key, () => []).add(a);
          }
          final areaNames = byArea.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: areaNames.length,
            itemBuilder: (context, index) {
              final areaNama = areaNames[index];
              final list = byArea[areaNama]!;
              final terpasang = list.where((a) => a.status == 'terpasang').length;
              final total = list.length;
              return Card(
                child: ListTile(
                  title: Text(areaNama),
                  subtitle: Text('$terpasang / $total sudah diregistrasi'),
                  trailing: SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: total == 0 ? 0 : terpasang / total,
                        ),
                        Text(
                          total == 0 ? '0%' : '${((terpasang / total) * 100).round()}%',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MonitoringAsetListScreen(areaNama: areaNama, asetList: list),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
