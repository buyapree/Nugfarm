class AsetLog {
  final String id;
  final String asetId;
  final String jenisLog;
  final String? fotoUrl;
  final String? keterangan;
  final DateTime tglEntry;
  final double? lat;
  final double? lng;

  AsetLog({
    required this.id,
    required this.asetId,
    required this.jenisLog,
    this.fotoUrl,
    this.keterangan,
    required this.tglEntry,
    this.lat,
    this.lng,
  });

  factory AsetLog.fromMap(Map<String, dynamic> map) {
    return AsetLog(
      id: map['id'],
      asetId: map['aset_id'],
      jenisLog: map['jenis_log'],
      fotoUrl: map['foto_url'],
      keterangan: map['keterangan'],
      tglEntry: DateTime.parse(map['tgl_entry']),
      lat: map['lat'] != null ? (map['lat'] as num).toDouble() : null,
      lng: map['lng'] != null ? (map['lng'] as num).toDouble() : null,
    );
  }
}
