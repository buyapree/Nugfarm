class AreaLahan {
  final String? id;
  final String nama;
  final String? lokasi;
  final String? wilayahId;
  final DateTime? createdAt;

  AreaLahan({this.id, required this.nama, this.lokasi, this.wilayahId, this.createdAt});

  factory AreaLahan.fromMap(Map<String, dynamic> map) {
    return AreaLahan(
      id: map['id'],
      nama: map['nama'],
      lokasi: map['lokasi'],
      wilayahId: map['wilayah_id'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'lokasi': lokasi,
      if (wilayahId != null) 'wilayah_id': wilayahId,
    };
  }
}
