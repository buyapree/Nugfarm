import 'package:flutter/material.dart';
import '../models/area_lahan.dart';
import '../services/area_lahan_service.dart';
import 'area_lahan_form_screen.dart';
import 'gambar_polygon_screen.dart';

class AreaLahanListScreen extends StatefulWidget {
  const AreaLahanListScreen({super.key});

  @override
  State<AreaLahanListScreen> createState() => _AreaLahanListScreenState();
}

class _AreaLahanListScreenState extends State<AreaLahanListScreen> {
  final _service = AreaLahanService();
  late Future<List<AreaLahan>> _future;

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

  Future<void> _deleteItem(AreaLahan area) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Area?'),
        content: Text('Yakin mau hapus "${area.nama}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true && area.id != null) {
      await _service.delete(area.id!);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Area Lahan')),
      body: FutureBuilder<List<AreaLahan>>(
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
            return const Center(child: Text('Belum ada area lahan.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final area = items[index];
              return ListTile(
                title: Text(area.nama),
                subtitle: Text(area.lokasi ?? '-'),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AreaLahanFormScreen(area: area),
                    ),
                  );
                  _refresh();
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.map, color: Colors.green),
                      tooltip: 'Gambar Batas Lahan',
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GambarPolygonScreen(area: area),
                          ),
                        );
                        _refresh();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteItem(area),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
