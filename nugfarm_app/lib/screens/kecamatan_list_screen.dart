import 'package:flutter/material.dart';
import '../models/wilayah.dart';
import '../services/wilayah_service.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/input_dialog.dart';
import 'kelurahan_list_screen.dart';

class KecamatanListScreen extends StatefulWidget {
  final Wilayah propinsi;
  final Wilayah kabupaten;
  const KecamatanListScreen({super.key, required this.propinsi, required this.kabupaten});
  @override
  State<KecamatanListScreen> createState() => _S();
}

class _S extends State<KecamatanListScreen> {
  final _service = WilayahService();
  late Future<List<Wilayah>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() => setState(() => _future = _service.getChildren('kecamatan', widget.kabupaten.id));

  Future<void> _tambah() async {
    final nama = await showTextInputDialog(context, 'Tambah Kecamatan');
    if (nama != null && nama.trim().isNotEmpty) {
      await _service.create(nama.trim(), 'kecamatan', widget.kabupaten.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithHome(context, widget.kabupaten.nama),
      body: Column(
        children: [
          BreadcrumbBar(items: [
            BreadcrumbItem(widget.propinsi.nama, 'kabupaten'),
            BreadcrumbItem(widget.kabupaten.nama, 'kecamatan'),
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
                  return const Center(child: Text('Belum ada kecamatan.\nTap tombol + untuk menambah.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final w = items[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.map_outlined),
                        title: Text(w.nama),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: 'kelurahan'),
                            builder: (_) => KelurahanListScreen(
                              propinsi: widget.propinsi, kabupaten: widget.kabupaten, kecamatan: w,
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
