import 'package:flutter/material.dart';
import '../models/wilayah.dart';
import '../services/wilayah_service.dart';
import '../widgets/breadcrumb_bar.dart';
import '../widgets/input_dialog.dart';
import 'kecamatan_list_screen.dart';

class KabupatenListScreen extends StatefulWidget {
  final Wilayah propinsi;
  const KabupatenListScreen({super.key, required this.propinsi});
  @override
  State<KabupatenListScreen> createState() => _S();
}

class _S extends State<KabupatenListScreen> {
  final _service = WilayahService();
  late Future<List<Wilayah>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() => setState(() => _future = _service.getChildren('kabupaten', widget.propinsi.id));

  Future<void> _tambah() async {
    final nama = await showTextInputDialog(context, 'Tambah Kabupaten/Kota');
    if (nama != null && nama.trim().isNotEmpty) {
      await _service.create(nama.trim(), 'kabupaten', widget.propinsi.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBarWithHome(context, widget.propinsi.nama),
      body: Column(
        children: [
          BreadcrumbBar(items: [BreadcrumbItem(widget.propinsi.nama, 'kabupaten')]),
          Expanded(
            child: FutureBuilder<List<Wilayah>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? [];
                if (items.isEmpty) {
                  return const Center(child: Text('Belum ada kabupaten.\nTap tombol + untuk menambah.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final w = items[i];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.location_city),
                        title: Text(w.nama),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: 'kecamatan'),
                            builder: (_) => KecamatanListScreen(propinsi: widget.propinsi, kabupaten: w),
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
