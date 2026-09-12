import 'package:flutter/material.dart';
import '../models/area_lahan.dart';
import '../services/area_lahan_service.dart';

class AreaLahanFormScreen extends StatefulWidget {
  final AreaLahan? area;
  final String? initialWilayahId;
  const AreaLahanFormScreen({super.key, this.area, this.initialWilayahId});

  @override
  State<AreaLahanFormScreen> createState() => _AreaLahanFormScreenState();
}

class _AreaLahanFormScreenState extends State<AreaLahanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AreaLahanService();
  late TextEditingController _namaCtrl;
  late TextEditingController _lokasiCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.area?.nama ?? '');
    _lokasiCtrl = TextEditingController(text: widget.area?.lokasi ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final area = AreaLahan(
      nama: _namaCtrl.text.trim(),
      lokasi: _lokasiCtrl.text.trim(),
      wilayahId: widget.area?.wilayahId ?? widget.initialWilayahId,
    );

    try {
      if (widget.area == null) {
        await _service.create(area);
      } else {
        await _service.update(widget.area!.id!, area);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal simpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.area != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Area' : 'Tambah Area')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaCtrl,
                decoration: const InputDecoration(labelText: 'Nama Area/Kebun'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lokasiCtrl,
                decoration: const InputDecoration(labelText: 'Keterangan Lokasi (opsional)'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
