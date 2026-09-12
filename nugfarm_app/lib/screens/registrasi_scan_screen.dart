import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/aset_service.dart';
import 'registrasi_form_screen.dart';

class RegistrasiScanScreen extends StatefulWidget {
  const RegistrasiScanScreen({super.key});

  @override
  State<RegistrasiScanScreen> createState() => _RegistrasiScanScreenState();
}

class _RegistrasiScanScreenState extends State<RegistrasiScanScreen> {
  final _asetService = AsetService();
  bool _processing = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final kode = barcodes.first.rawValue;
    if (kode == null) return;

    setState(() => _processing = true);
    try {
      final aset = await _asetService.getByKode(kode);
      if (!mounted) return;

      if (aset == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Kode "$kode" tidak ditemukan')));
        setState(() => _processing = false);
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RegistrasiFormScreen(aset: aset)),
      );
      if (mounted) setState(() => _processing = false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _processing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Pohon')),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          if (_processing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
