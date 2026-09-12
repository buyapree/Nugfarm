import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../models/aset.dart';
import '../services/aset_service.dart';
import '../services/aset_log_service.dart';

class RegistrasiFormScreen extends StatefulWidget {
  final Aset aset;
  const RegistrasiFormScreen({super.key, required this.aset});

  @override
  State<RegistrasiFormScreen> createState() => _RegistrasiFormScreenState();
}

class _RegistrasiFormScreenState extends State<RegistrasiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _asetService = AsetService();
  final _logService = AsetLogService();

  final _namaCtrl = TextEditingController();
  final _jenisCtrl = TextEditingController();
  final _umurCtrl = TextEditingController();

  XFile? _foto;
  bool _saving = false;
  String? _gpsWarning;

  Future<void> _ambilFoto() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) setState(() => _foto = picked);
  }

  Future<Position?> _getPosisi() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _gpsWarning = 'GPS/Location service tidak aktif di HP';
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      _gpsWarning = 'Izin lokasi ditolak';
      return null;
    }
    if (permission == LocationPermission.deniedForever) {
      _gpsWarning = 'Izin lokasi ditolak permanen — aktifkan manual di Settings HP';
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
    } catch (e) {
      _gpsWarning = 'Gagal ambil GPS: $e';
      return null;
    }
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _gpsWarning = null;
    });

    try {
      final pos = await _getPosisi();

      String? fotoUrl;
      if (_foto != null) {
        fotoUrl = await _logService.uploadFoto(_foto!, widget.aset.id!);
      }

      await _asetService.registrasi(
        id: widget.aset.id!,
        nama: _namaCtrl.text.trim(),
        jenis: _jenisCtrl.text.trim(),
        umur: _umurCtrl.text.trim(),
      );

      await _logService.tambahLog(
        asetId: widget.aset.id!,
        jenisLog: 'pendataan',
        lat: pos?.latitude,
        lng: pos?.longitude,
        fotoUrl: fotoUrl,
        keterangan: 'Registrasi awal',
      );

      if (mounted) {
        final msg = pos == null
            ? 'Registrasi disimpan (GPS gagal: ${_gpsWarning ?? "tidak diketahui"})'
            : 'Registrasi berhasil disimpan (dengan lokasi GPS)';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        Navigator.pop(context);
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
      appBar: AppBar(title: Text('Registrasi: ${widget.aset.kodeAset}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kode: ${widget.aset.kodeAset}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Area: ${widget.aset.areaLahanNama ?? '-'}'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _namaCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Pohon'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _jenisCtrl,
                  decoration: const InputDecoration(labelText: 'Jenis'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _umurCtrl,
                  decoration: const InputDecoration(labelText: 'Umur'),
                ),
                const SizedBox(height: 16),
                if (_foto != null) Image.file(File(_foto!.path), height: 150),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _ambilFoto,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_foto == null ? 'Ambil Foto' : 'Ganti Foto'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _simpan,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
