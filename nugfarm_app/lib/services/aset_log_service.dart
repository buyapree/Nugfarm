import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/aset_log.dart';

class AsetLogService {
  final _client = Supabase.instance.client;

  Future<String?> uploadFoto(XFile file, String asetId) async {
    final bytes = await file.readAsBytes();
    final path = 'log_${asetId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await _client.storage.from('foto-lahan').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return _client.storage.from('foto-lahan').getPublicUrl(path);
  }

  Future<void> tambahLog({
    required String asetId,
    required String jenisLog,
    double? lat,
    double? lng,
    String? fotoUrl,
    String? keterangan,
  }) async {
    final userId = _client.auth.currentUser?.id;
    await _client.from('tbl_aset_log').insert({
      'aset_id': asetId,
      'jenis_log': jenisLog,
      'koordinat':
          (lat != null && lng != null) ? 'SRID=4326;POINT($lng $lat)' : null,
      'foto_url': fotoUrl,
      'keterangan': keterangan,
      'operator_id': userId,
    });
  }

  Future<List<AsetLog>> getByAset(String asetId) async {
    final data = await _client
        .from('tbl_aset_log')
        .select('id, aset_id, jenis_log, foto_url, keterangan, tgl_entry, lat, lng')
        .eq('aset_id', asetId)
        .order('tgl_entry', ascending: false);
    return (data as List).map((e) => AsetLog.fromMap(e)).toList();
  }
}
