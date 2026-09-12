import 'package:flutter/material.dart';
import '../models/aset.dart';
import '../services/aset_service.dart';
import 'aset_by_area_screen.dart';

class AsetListScreen extends StatefulWidget {
  const AsetListScreen({super.key});

  @override
  State<AsetListScreen> createState() => _AsetListScreenState();
}

class _AsetListScreenState extends State<AsetListScreen> {
  final _service = AsetService();
  late Future<List<Aset>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = _service.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aset — per Area')),
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
              final persen = total == 0 ? 0.0 : terpasang / total;

              return Card(
                child: ListTile(
                  leading: SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: persen,
                          strokeWidth: 5,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: const AlwaysStoppedAnimation(Colors.green),
                        ),
                        Text(
                          '${(persen * 100).round()}%',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  title: Text(areaNama),
                  subtitle: Text('$total aset • $terpasang sudah diregistrasi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AsetByAreaScreen(
                          areaNama: areaNama,
                          areaLahanId: list.first.areaLahanId,
                          asetList: list,
                        ),
                      ),
                    );
                    _refresh();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
