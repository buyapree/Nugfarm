import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/aset.dart';
import '../services/aset_service.dart';
import '../services/qr_print_service.dart';

class CetakQrScreen extends StatefulWidget {
  const CetakQrScreen({super.key});

  @override
  State<CetakQrScreen> createState() => _CetakQrScreenState();
}

class _CetakQrScreenState extends State<CetakQrScreen> {
  final _service = AsetService();
  late Future<List<Aset>> _future;
  final Set<String> _selected = {};
  List<Aset> _cached = [];
  bool _printing = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _future = _service.getBelumDicetak();
      _selected.clear();
    });
  }

  void _pilihSemua() {
    setState(() {
      if (_selected.length == _cached.length) {
        _selected.clear();
      } else {
        _selected
          ..clear()
          ..addAll(_cached.map((a) => a.id!));
      }
    });
  }

  Future<void> _cetak(String tipe) async {
    setState(() => _printing = true);
    try {
      final terpilih = _cached.where((a) => _selected.contains(a.id)).toList();
      if (terpilih.isEmpty) throw Exception('Tidak ada aset terpilih');
      if (tipe == 'a4') {
        await QrPrintService().cetakStiker(terpilih);
      } else {
        await QrPrintService().cetakLabelZebra(terpilih);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal cetak: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  Future<void> _tandaiDicetak() async {
    if (_selected.isEmpty) return;
    await _service.tandaiSudahDicetak(_selected.toList());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selected.length} aset ditandai sudah dicetak')));
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cetak QR (belum dicetak)')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.green.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: _cached.isEmpty ? null : _pilihSemua,
                  child: Text(_selected.length == _cached.length && _cached.isNotEmpty
                      ? 'Batalkan Semua'
                      : 'Pilih Semua (${_cached.length})'),
                ),
                if (_selected.isNotEmpty) ...[
                  ElevatedButton.icon(
                    onPressed: _printing ? null : () => _cetak('a4'),
                    icon: _printing
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.print),
                    label: Text('Cetak A4 (${_selected.length})'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _printing ? null : () => _cetak('zebra'),
                    icon: _printing
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.label),
                    label: Text('Cetak Label Zebra (${_selected.length})'),
                  ),
                  OutlinedButton(
                    onPressed: _tandaiDicetak,
                    child: const Text('Tandai Dicetak'),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Aset>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final items = snapshot.data ?? [];
                _cached = items;
                if (items.isEmpty) {
                  return const Center(child: Text('Semua aset sudah dicetak QR-nya.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final aset = items[index];
                    final isSelected = _selected.contains(aset.id);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(aset.id);
                          } else {
                            _selected.add(aset.id!);
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            QrImageView(data: aset.kodeAset, version: QrVersions.auto, size: 100),
                            const SizedBox(height: 4),
                            Text(aset.kodeAset,
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ],
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
    );
  }
}
