class Wilayah {
  final String id;
  final String nama;
  final String level;
  final String? parentId;
  Wilayah({required this.id, required this.nama, required this.level, this.parentId});

  factory Wilayah.fromMap(Map<String, dynamic> map) {
    return Wilayah(
      id: map['id'],
      nama: map['nama'],
      level: map['level'],
      parentId: map['parent_id'],
    );
  }
}
