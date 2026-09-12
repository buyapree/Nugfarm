import 'package:flutter/material.dart';
import '../models/wilayah.dart';
import '../services/wilayah_service.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/input_dialog.dart';
import 'area_lahan_list_final_screen.dart';

class KelurahanListScreen extends StatefulWidget {
  final Wilayah propinsi;
  final Wilayah kabupaten;
  final Wilayah kecamatan;
  const KelurahanListScreen({
    super.key, required this.propinsi, required this.kabupaten, required this.kecamatan,
  });
  @override
  State<KelurahanListScreen> createState() => _S();
}

class _S extends State<KelurahanListScreen> {
  final _service = WilayahService();
  late Future<List<Wilayah>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() => setState(() => _future = _service.getChildren('kelurahan', widget.kecamatan.id));

  Future<void> _tambah() async {
    final nama = await showTextInputDialog(context, 'Tambah Kelurahan/Desa');
    if (nama != null && nama.trim().isNotEmpty) {
      await _service.create(nama.trim(), 'kelurahan', widget.kecamatan.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithHome(context, widget.kecamatan.nama),
      body: Column(
        children: [
          BreadcrumbBar(items: [
            BreadcrumbItem(widget.propinsi.nama, 'kabupaten'),
            BreadcrumbItem(widget.kabupaten.nama, 'kecamatan'),
            BreadcrumbItem(widget.kecamatan.nama, 'kelurahan'),
          ]),
          Expanded(
            child: FutureBuilder<List<Wilayah>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(child: Text('Belum ada kelurahan.\nTap tombol + untuk menambah.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final w = items[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.home_work_outlined),
                        title: Text(w.nama),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: 'arealist'),
                            builder: (_) => AreaLahanListFinalScreen(
                              propinsi: widget.propinsi, kabupaten: widget.kabupaten,
                              kecamatan: widget.kecamatan, kelurahan: w,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _tambah, child: const Icon(Icons.add)),
    );
  }
}
