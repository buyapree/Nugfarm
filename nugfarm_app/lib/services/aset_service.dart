import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/aset.dart';

class AsetService {
  final _client = Supabase.instance.client;
  final _table = 'tbl_aset';

  Future<List<Aset>> getAll() async {
    final data = await _client
        .from(_table)
        .select('*, tbl_area_lahan(nama, lokasi)')
        .order('created_at', ascending: false);
    return (data as List).map((e) => Aset.fromMap(e)).toList();
  }

  Future<List<Aset>> getBelumDicetak() async {
    final data = await _client
        .from(_table)
        .select('*, tbl_area_lahan(nama, lokasi)')
        .eq('qr_dicetak', false)
        .order('kode_aset', ascending: true);
    return (data as List).map((e) => Aset.fromMap(e)).toList();
  }

  Future<Aset?> getByKode(String kode) async {
    final data = await _client
        .from(_table)
        .select('*, tbl_area_lahan(nama, lokasi)')
        .eq('kode_aset', kode)
        .maybeSingle();
    return data != null ? Aset.fromMap(data) : null;
  }

  Future<void> create(Aset aset) async {
    await _client.from(_table).insert(aset.toMap());
  }

  Future<void> update(String id, Aset aset) async {
    await _client.from(_table).update(aset.toMap()).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  Future<void> registrasi({
    required String id,
    required String nama,
    required String jenis,
    required String umur,
  }) async {
    await _client.from(_table).update({
      'nama': nama,
      'jenis': jenis,
      'umur': umur,
      'status': 'terpasang',
    }).eq('id', id);
  }

  Future<void> generateBatch({
    required String areaLahanId,
    required String prefixKode,
    required int jumlah,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final rows = List.generate(jumlah, (i) {
      final urutan = (i + 1).toString().padLeft(4, '0');
      return {
        'kode_aset': '$prefixKode-$timestamp-$urutan',
        'area_lahan_id': areaLahanId,
        'status': 'belum_dipasang',
        'qr_dicetak': false,
      };
    });
    await _client.from(_table).insert(rows);
  }

  Future<void> tandaiSudahDicetak(List<String> ids) async {
    await _client.from(_table).update({'qr_dicetak': true}).inFilter('id', ids);
  }
}
