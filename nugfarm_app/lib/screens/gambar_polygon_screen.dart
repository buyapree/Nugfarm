import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/area_lahan.dart';
import '../services/area_lahan_service.dart';

class GambarPolygonScreen extends StatefulWidget {
  final AreaLahan area;
  const GambarPolygonScreen({super.key, required this.area});

  @override
  State<GambarPolygonScreen> createState() => _GambarPolygonScreenState();
}

class _GambarPolygonScreenState extends State<GambarPolygonScreen> {
  final _service = AreaLahanService();
  final List<LatLng> _titik = [];
  bool _saving = false;

  void _tambahTitik(TapPosition tapPos, LatLng point) {
    setState(() => _titik.add(point));
  }

  void _undo() {
    if (_titik.isNotEmpty) setState(() => _titik.removeLast());
  }

  void _reset() {
    setState(() => _titik.clear());
  }

  Future<void> _simpan() async {
    if (_titik.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Minimal 3 titik untuk membentuk area')));
      return;
    }
    setState(() => _saving = true);
    try {
      final ring = [..._titik, _titik.first];
      final coords = ring.map((p) => '${p.longitude} ${p.latitude}').join(', ');
      final wkt = 'SRID=4326;POLYGON(($coords))';
      await _service.updatePolygon(widget.area.id!, wkt);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Batas area berhasil disimpan')));
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
      appBar: AppBar(title: Text('Gambar Batas: ${widget.area.nama}')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.brown.shade50,
            padding: const EdgeInsets.all(12),
            child: Text(
              'Tap di peta untuk menandai batas lahan (minimal 3 titik), urut mengelilingi area. Titik terpilih: ${_titik.length}',
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(-7.2575, 112.7521), // Surabaya
                initialZoom: 14,
                onTap: _tambahTitik,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.nugfarm.app',
                ),
                if (_titik.length >= 3)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: _titik,
                        color: Colors.green.withValues(alpha: 0.3),
                        borderColor: Colors.green.shade800,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: _titik
                      .map((p) => Marker(
                            point: p,
                            width: 20,
                            height: 20,
                            child: const Icon(Icons.circle, color: Colors.red, size: 12),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _titik.isEmpty ? null : _undo,
                  icon: const Icon(Icons.undo),
                  label: const Text('Undo'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _titik.isEmpty ? null : _reset,
                  icon: const Icon(Icons.clear),
                  label: const Text('Reset'),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _simpan,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
