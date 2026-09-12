import 'package:flutter/material.dart';
import '../models/aset.dart';
import 'aset_log_list_screen.dart';

class MonitoringAsetListScreen extends StatelessWidget {
  final String areaNama;
  final List<Aset> asetList;
  const MonitoringAsetListScreen({super.key, required this.areaNama, required this.asetList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(areaNama)),
      body: ListView.builder(
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
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AsetLogListScreen(aset: aset)),
            ),
          );
        },
      ),
    );
  }
}
