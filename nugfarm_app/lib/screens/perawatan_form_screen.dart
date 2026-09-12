import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/aset.dart';
import '../models/aset_log.dart';
import '../services/aset_log_service.dart';
import 'foto_zoom_screen.dart';

class PerawatanFormScreen extends StatefulWidget {
  final Aset aset;
  const PerawatanFormScreen({super.key, required this.aset});

  @override
  State<PerawatanFormScreen> createState() => _PerawatanFormScreenState();
}

class _PerawatanFormScreenState extends State<PerawatanFormScreen> {
  final _logService = AsetLogService();
  final _keteranganCtrl = TextEditingController();

  late Future<List<AsetLog>> _riwayatFuture;
  XFile? _foto;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _riwayatFuture = _logService.getByAset(widget.aset.id!);
  }

  void _muatUlangRiwayat() {
    setState(() {
      _riwayatFuture = _logService.getByAset(widget.aset.id!);
    });
  }

  Future<void> _ambilFoto() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) setState(() => _foto = picked);
  }

  Future<void> _bukaMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/place/$lat,$lng/@$lat,$lng,19z');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _simpan() async {
    if (_keteranganCtrl.text.trim().isEmpty && _foto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Isi catatan atau ambil foto dulu')));
      return;
    }
    setState(() => _saving = true);

    try {
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 15));
      } catch (_) {
        pos = null;
      }

      String? fotoUrl;
      if (_foto != null) {
        fotoUrl = await _logService.uploadFoto(_foto!, widget.aset.id!);
      }

      await _logService.tambahLog(
        asetId: widget.aset.id!,
        jenisLog: 'perawatan',
        lat: pos?.latitude,
        lng: pos?.longitude,
        fotoUrl: fotoUrl,
        keterangan: _keteranganCtrl.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Catatan perawatan disimpan')));
        _keteranganCtrl.clear();
        setState(() => _foto = null);
        _muatUlangRiwayat();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perawatan: ${widget.aset.kodeAset}')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Colors.green.shade50,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.aset.nama ?? widget.aset.kodeAset,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    '${widget.aset.jenis ?? '-'} • Umur: ${widget.aset.umur ?? '-'} • Area: ${widget.aset.areaLahanNama ?? '-'}',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tambah Catatan Perawatan',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _keteranganCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (kondisi, tindakan, dll)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  if (_foto != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Image.file(File(_foto!.path), height: 120),
                    ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _ambilFoto,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(_foto == null ? 'Ambil Foto' : 'Ganti Foto'),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _saving ? null : _simpan,
                        icon: _saving
                            ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save),
                        label: const Text('Simpan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text('Riwayat Kunjungan',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
            ),
            FutureBuilder<List<AsetLog>>(
              future: _riwayatFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final logs = snapshot.data ?? [];
                if (logs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Belum ada riwayat kunjungan.'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                                child: Image.network(log.fotoUrl!,
                                    width: 44, height: 44, fit: BoxFit.cover),
                              ),
                            )
                          : Container(
                              width: 44,
                              height: 44,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported, size: 18),
                            ),
                      title: Text(log.jenisLog == 'pendataan' ? 'Registrasi awal' : 'Perawatan'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(log.keterangan ?? '-'),
                          Text('${log.tglEntry.toLocal()}', style: const TextStyle(fontSize: 11)),
                          if (adaKoordinat)
                            GestureDetector(
                              onTap: () => _bukaMaps(log.lat!, log.lng!),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on, size: 12, color: Colors.blue),
                                  Text(' Lihat di Maps',
                                      style: TextStyle(color: Colors.blue.shade700, fontSize: 11)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      isThreeLine: true,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
