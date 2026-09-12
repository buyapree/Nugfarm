import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wilayah.dart';

class WilayahService {
  final _client = Supabase.instance.client;
  final _table = 'tbl_wilayah';

  Future<List<Wilayah>> getChildren(String level, String? parentId) async {
    final query = _client.from(_table).select().eq('level', level);
    final filtered = parentId == null
        ? query.filter('parent_id', 'is', null)
        : query.eq('parent_id', parentId);
    final data = await filtered.order('nama');
    return (data as List).map((e) => Wilayah.fromMap(e)).toList();
  }

  Future<Wilayah> create(String nama, String level, String? parentId) async {
    final data = await _client
        .from(_table)
        .insert({'nama': nama, 'level': level, 'parent_id': parentId})
        .select()
        .single();
    return Wilayah.fromMap(data);
  }
}
