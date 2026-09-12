import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/aset.dart';
import '../models/area_lahan.dart';
import '../models/aset_log.dart';
import '../services/aset_service.dart';
import '../services/area_lahan_service.dart';
import '../services/aset_log_service.dart';
import 'foto_zoom_screen.dart';

class AsetFormScreen extends StatefulWidget {
  final Aset? aset;
  final String? initialAreaId;
  const AsetFormScreen({super.key, this.aset, this.initialAreaId});

  @override
  State<AsetFormScreen> createState() => _AsetFormScreenState();
}

class _AsetFormScreenState extends State<AsetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _asetService = AsetService();
  final _areaService = AreaLahanService();
  final _logService = AsetLogService();

  late TextEditingController _kodeCtrl;
  late TextEditingController _namaCtrl;
  late TextEditingController _jenisCtrl;
  String? _selectedAreaId;
  bool _saving = false;
  late Future<List<AreaLahan>> _areaFuture;
  Future<List<AsetLog>>? _logFuture;

  @override
  void initState() {
    super.initState();
    _kodeCtrl = TextEditingController(text: widget.aset?.kodeAset ?? '');
    _namaCtrl = TextEditingController(text: widget.aset?.nama ?? '');
    _jenisCtrl = TextEditingController(text: widget.aset?.jenis ?? '');
    _selectedAreaId = widget.aset?.areaLahanId ?? widget.initialAreaId;
    _areaFuture = _areaService.getAll();
    if (widget.aset != null) {
      _logFuture = _logService.getByAset(widget.aset!.id!);
    }
  }

  Future<void> _bukaMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/place/$lat,$lng/@$lat,$lng,19z');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAreaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih area lahan dulu')));
      return;
    }
    setState(() => _saving = true);

    final aset = Aset(
      kodeAset: _kodeCtrl.text.trim(),
      nama: _namaCtrl.text.trim(),
      jenis: _jenisCtrl.text.trim(),
      areaLahanId: _selectedAreaId!,
    );

    try {
      if (widget.aset == null) {
        await _asetService.create(aset);
      } else {
        await _asetService.update(widget.aset!.id!, aset);
      }
      if (mounted) Navigator.pop(context);
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
    final isEdit = widget.aset != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Aset' : 'Tambah Aset')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _kodeCtrl,
                  decoration: const InputDecoration(labelText: 'Kode Aset'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _namaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Aset'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _jenisCtrl,
                  decoration: const InputDecoration(labelText: 'Jenis'),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<AreaLahan>>(
                  future: _areaFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final areas = snapshot.data!;
                    return DropdownButtonFormField<String>(
                      initialValue: _selectedAreaId,
                      decoration:
                          const InputDecoration(labelText: 'Area Lahan'),
                      items: areas
                          .map((a) => DropdownMenuItem(
                                value: a.id,
                                child: Text(a.nama),
                              ))
                          .toList(),
                      onChanged: (val) {
                        setState(() => _selectedAreaId = val);
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Simpan'),
                ),
                if (isEdit) ...[
                  const SizedBox(height: 28),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Riwayat & Foto',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  FutureBuilder<List<AsetLog>>(
                    future: _logFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final logs = snapshot.data ?? [];
                      if (logs.isEmpty) {
                        return const Text('Belum ada riwayat kunjungan.',
                            style: TextStyle(color: Colors.grey));
                      }
                      return Column(
                        children: logs.map((log) {
                          final adaKoordinat = log.lat != null && log.lng != null;
                          return Card(
                            child: ListTile(
                              leading: log.fotoUrl != null
                                  ? GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              FotoZoomScreen(url: log.fotoUrl!),
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
                                      child: const Icon(Icons.image_not_supported,
                                          size: 20),
                                    ),
                              title: Text(log.jenisLog == 'pendataan'
                                  ? 'Registrasi awal'
                                  : 'Perawatan'),
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
                                          const Icon(Icons.location_on,
                                              size: 14, color: Colors.blue),
                                          const SizedBox(width: 2),
                                          Text('Lihat di Maps',
                                              style: TextStyle(
                                                  color: Colors.blue.shade700,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    )
                                  else
                                    const Text('Lokasi tidak tersedia',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
