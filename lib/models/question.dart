class Question {
  final String soru;
  final List<String> secenekler;
  final int dogruCevapIndex; // 0-3 arası (A, B, C, D)
  final String aciklama;
  int? kullaniciCevabi; // Kullanıcının seçtiği cevap indexi

  Question({
    required this.soru,
    required this.secenekler,
    required this.dogruCevapIndex,
    required this.aciklama,
    this.kullaniciCevabi,
  }) {
    // Validasyon: 4 seçenek olmalı
    assert(secenekler.length == 4, 'Her soruda tam 4 seçenek olmalı');
    assert(dogruCevapIndex >= 0 && dogruCevapIndex < 4, 'Doğru cevap indexi 0-3 arası olmalı');
  }

  // JSON'dan nesne oluşturma
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      soru: map['soru'] as String,
      secenekler: List<String>.from(map['secenekler'] as List),
      dogruCevapIndex: map['dogruCevapIndex'] as int,
      aciklama: map['aciklama'] as String,
      kullaniciCevabi: map['kullaniciCevabi'] as int?,
    );
  }

  // Nesneyi JSON'a çevirme
  Map<String, dynamic> toMap() {
    return {
      'soru': soru,
      'secenekler': secenekler,
      'dogruCevapIndex': dogruCevapIndex,
      'aciklama': aciklama,
      'kullaniciCevabi': kullaniciCevabi,
    };
  }

  // Cevap doğru mu kontrolü
  bool get isCorrect => kullaniciCevabi == dogruCevapIndex;

  // Cevap verilmiş mi kontrolü
  bool get isAnswered => kullaniciCevabi != null;

  // Seçenek harfi alma (0->A, 1->B, 2->C, 3->D)
  String getOptionLetter(int index) {
    const letters = ['A', 'B', 'C', 'D'];
    return letters[index];
  }

  String get dogruCevapHarfi => getOptionLetter(dogruCevapIndex);

  String? get kullaniciCevabiHarfi =>
      kullaniciCevabi != null ? getOptionLetter(kullaniciCevabi!) : null;

  // Kopyalama metodu
  Question copyWith({
    String? soru,
    List<String>? secenekler,
    int? dogruCevapIndex,
    String? aciklama,
    int? kullaniciCevabi,
  }) {
    return Question(
      soru: soru ?? this.soru,
      secenekler: secenekler ?? this.secenekler,
      dogruCevapIndex: dogruCevapIndex ?? this.dogruCevapIndex,
      aciklama: aciklama ?? this.aciklama,
      kullaniciCevabi: kullaniciCevabi ?? this.kullaniciCevabi,
    );
  }

  @override
  String toString() {
    return 'Question(soru: $soru, dogruCevap: $dogruCevapHarfi, kullaniciCevabi: $kullaniciCevabiHarfi)';
  }
}
