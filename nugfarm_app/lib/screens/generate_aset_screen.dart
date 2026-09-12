import 'package:flutter/material.dart';
import '../models/area_lahan.dart';
import '../services/area_lahan_service.dart';
import '../services/aset_service.dart';

class GenerateAsetScreen extends StatefulWidget {
  final String? initialAreaId;
  const GenerateAsetScreen({super.key, this.initialAreaId});

  @override
  State<GenerateAsetScreen> createState() => _GenerateAsetScreenState();
}

class _GenerateAsetScreenState extends State<GenerateAsetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _areaService = AreaLahanService();
  final _asetService = AsetService();
  late Future<List<AreaLahan>> _areaFuture;

  String? _selectedAreaId;
  final _prefixCtrl = TextEditingController(text: 'AST');
  final _jumlahCtrl = TextEditingController(text: '10');
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedAreaId = widget.initialAreaId;
    _areaFuture = _areaService.getAll();
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAreaId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pilih area lahan dulu')));
      return;
    }
    setState(() => _saving = true);
    try {
      final jumlah = int.parse(_jumlahCtrl.text.trim());
      await _asetService.generateBatch(
        areaLahanId: _selectedAreaId!,
        prefixKode: _prefixCtrl.text.trim(),
        jumlah: jumlah,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$jumlah record aset berhasil dibuat')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generate Aset Baru')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FutureBuilder<List<AreaLahan>>(
                future: _areaFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final areas = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedAreaId,
                    decoration: const InputDecoration(labelText: 'Area Lahan'),
                    items: areas
                        .map((a) => DropdownMenuItem(value: a.id, child: Text(a.nama)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedAreaId = val),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _prefixCtrl,
                decoration: const InputDecoration(labelText: 'Prefix Kode (misal: AST, POHON)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jumlahCtrl,
                decoration: const InputDecoration(labelText: 'Jumlah Record'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib diisi';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Harus angka > 0';
                  if (n > 500) return 'Maksimal 500 sekali generate';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _generate,
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Generate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
