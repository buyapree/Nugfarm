class Aset {
  final String? id;
  final String kodeAset;
  final String? nama;
  final String? jenis;
  final String? umur;
  final String areaLahanId;
  final String? areaLahanNama;
  final String? areaLahanLokasi;
  final String status;
  final bool qrDicetak;

  Aset({
    this.id,
    required this.kodeAset,
    this.nama,
    this.jenis,
    this.umur,
    required this.areaLahanId,
    this.areaLahanNama,
    this.areaLahanLokasi,
    this.status = 'belum_dipasang',
    this.qrDicetak = false,
  });

  factory Aset.fromMap(Map<String, dynamic> map) {
    return Aset(
      id: map['id'],
      kodeAset: map['kode_aset'],
      nama: map['nama'],
      jenis: map['jenis'],
      umur: map['umur'],
      areaLahanId: map['area_lahan_id'],
      areaLahanNama: map['tbl_area_lahan'] != null
          ? map['tbl_area_lahan']['nama']
          : null,
      areaLahanLokasi: map['tbl_area_lahan'] != null
          ? map['tbl_area_lahan']['lokasi']
          : null,
      status: map['status'] ?? 'belum_dipasang',
      qrDicetak: map['qr_dicetak'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kode_aset': kodeAset,
      'nama': nama,
      'jenis': jenis,
      'umur': umur,
      'area_lahan_id': areaLahanId,
      'status': status,
      'qr_dicetak': qrDicetak,
    };
  }
}
