import 'package:flutter/material.dart';
import '../models/wilayah.dart';
import '../models/area_lahan.dart';
import '../services/area_lahan_service.dart';
import '../services/aset_service.dart';
import '../widgets/breadcrumb_bar.dart';
import 'aset_by_area_screen.dart';
import 'area_lahan_form_screen.dart';

class AreaLahanListFinalScreen extends StatefulWidget {
  final Wilayah propinsi;
  final Wilayah kabupaten;
  final Wilayah kecamatan;
  final Wilayah kelurahan;
  const AreaLahanListFinalScreen({
    super.key, required this.propinsi, required this.kabupaten,
    required this.kecamatan, required this.kelurahan,
  });
  @override
  State<AreaLahanListFinalScreen> createState() => _S();
}

class _S extends State<AreaLahanListFinalScreen> {
  final _areaService = AreaLahanService();
  final _asetService = AsetService();
  late Future<List<AreaLahan>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() => setState(() => _future = _areaService.getByWilayah(widget.kelurahan.id));

  Future<void> _bukaAset(AreaLahan area) async {
    final semua = await _asetService.getAll();
    final terkait = semua.where((a) => a.areaLahanId == area.id).toList();
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AsetByAreaScreen(areaNama: area.nama, areaLahanId: area.id!, asetList: terkait),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithHome(context, widget.kelurahan.nama),
      body: Column(
        children: [
          BreadcrumbBar(items: [
            BreadcrumbItem(widget.propinsi.nama, 'kabupaten'),
            BreadcrumbItem(widget.kabupaten.nama, 'kecamatan'),
            BreadcrumbItem(widget.kecamatan.nama, 'kelurahan'),
            BreadcrumbItem(widget.kelurahan.nama, 'arealist'),
          ]),
          Expanded(
            child: FutureBuilder<List<AreaLahan>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(child: Text('Belum ada area di sini.\nTap tombol + untuk menambah.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final area = items[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.forest),
                        title: Text(area.nama),
                        subtitle: Text(area.lokasi ?? '-'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AreaLahanFormScreen(area: area)),
                            );
                            _refresh();
                          },
                        ),
                        onTap: () => _bukaAset(area),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AreaLahanFormScreen(initialWilayahId: widget.kelurahan.id)),
          );
          _refresh();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
