import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/aset.dart';
import '../models/aset_log.dart';
import '../services/aset_log_service.dart';
import 'foto_zoom_screen.dart';

class AsetLogListScreen extends StatefulWidget {
  final Aset aset;
  const AsetLogListScreen({super.key, required this.aset});

  @override
  State<AsetLogListScreen> createState() => _AsetLogListScreenState();
}

class _AsetLogListScreenState extends State<AsetLogListScreen> {
  final _service = AsetLogService();
  late Future<List<AsetLog>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getByAset(widget.aset.id!);
  }

  Future<void> _bukaMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/place/$lat,$lng/@$lat,$lng,19z');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat: ${widget.aset.kodeAset}')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.aset.nama ?? '(belum diregistrasi)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.aset.jenis ?? '-'} • Umur: ${widget.aset.umur ?? '-'} • Area: ${widget.aset.areaLahanNama ?? '-'}',
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<AsetLog>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final logs = snapshot.data ?? [];
                if (logs.isEmpty) {
                  return const Center(child: Text('Belum ada riwayat kunjungan.'));
                }
                return ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final adaKoordinat = log.lat != null && log.lng != null;
                    return ListTile(
                      leading: log.fotoUrl != null
                          ? GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FotoZoomScreen(url: log.fotoUrl!),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  log.fotoUrl!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported, size: 20),
                            ),
                      title: Text(log.jenisLog == 'pendataan' ? 'Registrasi awal' : 'Perawatan'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.keterangan ?? '-'),
                          Text('${log.tglEntry.toLocal()}'),
                          if (adaKoordinat)
                            GestureDetector(
                              onTap: () => _bukaMaps(log.lat!, log.lng!),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.blue),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Lihat di Maps',
                                    style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          else
                            const Text('Lokasi tidak tersedia',
                                style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
