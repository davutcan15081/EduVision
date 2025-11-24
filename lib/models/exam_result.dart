import 'dart:convert';
import 'question.dart';

class ExamResult {
  final int? id;
  final String dersAdi;
  final String konu;
  final String seviye;
  final List<Question> sorular;
  final DateTime tarih;
  final int toplamSure; // Saniye cinsinden

  ExamResult({
    this.id,
    required this.dersAdi,
    required this.konu,
    required this.seviye,
    required this.sorular,
    required this.tarih,
    required this.toplamSure,
  });

  // Toplam soru sayısı
  int get toplamSoru => sorular.length;

  // Doğru cevap sayısı
  int get dogruSayisi => sorular.where((s) => s.isCorrect).length;

  // Yanlış cevap sayısı
  int get yanlisSayisi => sorular.where((s) => s.isAnswered && !s.isCorrect).length;

  // Boş bırakılan soru sayısı
  int get bosSayisi => sorular.where((s) => !s.isAnswered).length;

  // Başarı yüzdesi
  double get basariYuzdesi => (dogruSayisi / toplamSoru) * 100;

  // Puan (100 üzerinden)
  int get puan => basariYuzdesi.round();

  // JSON'dan nesne oluşturma
  factory ExamResult.fromMap(Map<String, dynamic> map) {
    // Sorular JSON string olarak saklanıyor, decode edilmesi gerekiyor
    List<dynamic> sorularJson = jsonDecode(map['sorular'] as String);

    return ExamResult(
      id: map['id'] as int?,
      dersAdi: map['dersAdi'] as String,
      konu: map['konu'] as String,
      seviye: map['seviye'] as String,
      sorular: sorularJson.map((s) => Question.fromMap(s as Map<String, dynamic>)).toList(),
      tarih: DateTime.parse(map['tarih'] as String),
      toplamSure: map['toplamSure'] as int,
    );
  }

  // Nesneyi JSON'a çevirme
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dersAdi': dersAdi,
      'konu': konu,
      'seviye': seviye,
      'sorular': jsonEncode(sorular.map((s) => s.toMap()).toList()),
      'tarih': tarih.toIso8601String(),
      'toplamSure': toplamSure,
    };
  }

  // Süreyi formatla (örn: "5:30")
  String get formattedSure {
    int dakika = toplamSure ~/ 60;
    int saniye = toplamSure % 60;
    return '$dakika:${saniye.toString().padLeft(2, '0')}';
  }

  // Başarı durumu
  String get basariDurumu {
    if (basariYuzdesi >= 85) return 'Mükemmel';
    if (basariYuzdesi >= 70) return 'İyi';
    if (basariYuzdesi >= 50) return 'Orta';
    return 'Geliştirilmeli';
  }

  // Kopyalama metodu
  ExamResult copyWith({
    int? id,
    String? dersAdi,
    String? konu,
    String? seviye,
    List<Question>? sorular,
    DateTime? tarih,
    int? toplamSure,
  }) {
    return ExamResult(
      id: id ?? this.id,
      dersAdi: dersAdi ?? this.dersAdi,
      konu: konu ?? this.konu,
      seviye: seviye ?? this.seviye,
      sorular: sorular ?? this.sorular,
      tarih: tarih ?? this.tarih,
      toplamSure: toplamSure ?? this.toplamSure,
    );
  }

  @override
  String toString() {
    return 'ExamResult(id: $id, dersAdi: $dersAdi, konu: $konu, puan: $puan, tarih: $tarih)';
  }
}
