import 'package:flutter/material.dart';
import '../models/aset.dart';
import 'aset_form_screen.dart';
import 'generate_aset_screen.dart';

class AsetByAreaScreen extends StatelessWidget {
  final String areaNama;
  final String areaLahanId;
  final List<Aset> asetList;
  const AsetByAreaScreen({
    super.key, required this.areaNama, required this.areaLahanId, required this.asetList,
  });

  void _tampilkanOpsi(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah 1 Aset'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AsetFormScreen(initialAreaId: areaLahanId)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.dynamic_form),
              title: const Text('Generate Aset Massal'),
              subtitle: const Text('Buat banyak record kosong sekaligus'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GenerateAsetScreen(initialAreaId: areaLahanId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(areaNama)),
      body: asetList.isEmpty
          ? const Center(child: Text('Belum ada aset di area ini.'))
          : ListView.builder(
              itemCount: asetList.length,
              itemBuilder: (context, index) {
                final aset = asetList[index];
                final sudah = aset.status == 'terpasang';
                return ListTile(
                  leading: Icon(
                    sudah ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: sudah ? Colors.green : Colors.grey,
                  ),
                  title: Text(aset.kodeAset),
                  subtitle: Text(aset.nama ?? '(belum diregistrasi)'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AsetFormScreen(aset: aset)),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tampilkanOpsi(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
