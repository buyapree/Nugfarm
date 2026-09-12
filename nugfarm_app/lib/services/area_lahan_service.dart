import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/area_lahan.dart';

class AreaLahanService {
  final _client = Supabase.instance.client;
  final _table = 'tbl_area_lahan';

  Future<List<AreaLahan>> getAll() async {
    final data = await _client.from(_table).select().order('created_at', ascending: false);
    return (data as List).map((e) => AreaLahan.fromMap(e)).toList();
  }

  Future<List<AreaLahan>> getByWilayah(String wilayahId) async {
    final data = await _client.from(_table).select().eq('wilayah_id', wilayahId).order('nama');
    return (data as List).map((e) => AreaLahan.fromMap(e)).toList();
  }

  Future<void> create(AreaLahan area) async {
    await _client.from(_table).insert(area.toMap());
  }

  Future<void> update(String id, AreaLahan area) async {
    await _client.from(_table).update(area.toMap()).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  Future<void> updatePolygon(String id, String wkt) async {
    await _client.from(_table).update({'koordinat_polygon': wkt}).eq('id', id);
  }
}
