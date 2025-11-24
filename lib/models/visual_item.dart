class VisualItem {
  final int? id;
  final String dersAdi;
  final String konu;
  final String seviye;
  final String gorselUrl;
  final String aciklama;
  final DateTime tarih;

  VisualItem({
    this.id,
    required this.dersAdi,
    required this.konu,
    required this.seviye,
    required this.gorselUrl,
    required this.aciklama,
    required this.tarih,
  });

  // JSON'dan nesne oluşturma
  factory VisualItem.fromMap(Map<String, dynamic> map) {
    return VisualItem(
      id: map['id'] as int?,
      dersAdi: map['dersAdi'] as String,
      konu: map['konu'] as String,
      seviye: map['seviye'] as String,
      gorselUrl: map['gorselUrl'] as String,
      aciklama: map['aciklama'] as String,
      tarih: DateTime.parse(map['tarih'] as String),
    );
  }

  // Nesneyi JSON'a çevirme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dersAdi': dersAdi,
      'konu': konu,
      'seviye': seviye,
      'gorselUrl': gorselUrl,
      'aciklama': aciklama,
      'tarih': tarih.toIso8601String(),
    };
  }

  // Kopyalama metodu (güncelleme için)
  VisualItem copyWith({
    int? id,
    String? dersAdi,
    String? konu,
    String? seviye,
    String? gorselUrl,
    String? aciklama,
    DateTime? tarih,
  }) {
    return VisualItem(
      id: id ?? this.id,
      dersAdi: dersAdi ?? this.dersAdi,
      konu: konu ?? this.konu,
      seviye: seviye ?? this.seviye,
      gorselUrl: gorselUrl ?? this.gorselUrl,
      aciklama: aciklama ?? this.aciklama,
      tarih: tarih ?? this.tarih,
    );
  }

  @override
  String toString() {
    return 'VisualItem(id: $id, dersAdi: $dersAdi, konu: $konu, seviye: $seviye, tarih: $tarih)';
  }
}
