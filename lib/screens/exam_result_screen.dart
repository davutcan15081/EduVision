import 'package:flutter/material.dart';
import '../models/question.dart';
import '../models/exam_result.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class ExamResultScreen extends StatefulWidget {
  final String dersAdi;
  final String konu;
  final String seviye;
  final List<Question> questions;
  final int elapsedTime; // Geçen süre (saniye)

  const ExamResultScreen({
    super.key,
    required this.dersAdi,
    required this.konu,
    required this.seviye,
    required this.questions,
    required this.elapsedTime,
  });

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen> {
  final DatabaseService _databaseService = DatabaseService();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _saveToDatabase();
  }

  Future<void> _saveToDatabase() async {
    if (_isSaved) return;

    try {
      final examResult = ExamResult(
        dersAdi: widget.dersAdi,
        konu: widget.konu,
        seviye: widget.seviye,
        sorular: widget.questions,
        tarih: DateTime.now(),
        toplamSure: widget.elapsedTime,
      );

      await _databaseService.insertExamResult(examResult);
      setState(() {
        _isSaved = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kaydetme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int get _dogruSayisi => widget.questions.where((q) => q.isCorrect).length;
  int get _yanlisSayisi =>
      widget.questions.where((q) => q.isAnswered && !q.isCorrect).length;
  int get _bosSayisi => widget.questions.where((q) => !q.isAnswered).length;
  double get _basariYuzdesi =>
      (_dogruSayisi / widget.questions.length) * 100;

  String get _basariDurumu {
    if (_basariYuzdesi >= 85) return 'Mükemmel';
    if (_basariYuzdesi >= 70) return 'İyi';
    if (_basariYuzdesi >= 50) return 'Orta';
    return 'Geliştirilmeli';
  }

  Color get _performansRengi {
    if (_basariYuzdesi >= 85) return Colors.green;
    if (_basariYuzdesi >= 70) return const Color(0xFF00BCD4);
    if (_basariYuzdesi >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Sınav Sonucu',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Başarı İkonu
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _performansRengi.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _basariYuzdesi >= 70
                    ? Icons.emoji_events
                    : Icons.thumb_up_outlined,
                size: 80,
                color: _performansRengi,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _basariDurumu,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _performansRengi,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_basariYuzdesi.toStringAsFixed(0)}% Başarı',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            // İstatistikler
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A47),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    'Toplam Soru',
                    widget.questions.length.toString(),
                    Icons.quiz,
                    Colors.white,
                  ),
                  const Divider(color: Color(0xFF2C5364), height: 32),
                  _buildStatRow(
                    'Doğru',
                    _dogruSayisi.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                  const Divider(color: Color(0xFF2C5364), height: 32),
                  _buildStatRow(
                    'Yanlış',
                    _yanlisSayisi.toString(),
                    Icons.cancel,
                    Colors.red,
                  ),
                  const Divider(color: Color(0xFF2C5364), height: 32),
                  _buildStatRow(
                    'Boş',
                    _bosSayisi.toString(),
                    Icons.radio_button_unchecked,
                    Colors.grey,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Soru Detayları
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A47),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Soru Detayları',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4DD0E1),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(
                    widget.questions.length,
                    (index) => _buildQuestionReview(
                      index + 1,
                      widget.questions[index],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Öneriler
            if (_basariYuzdesi < 70)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.orange,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Öneriler',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.konu} konusunu tekrar çalışmanızı öneririz. Yanlış cevapladığınız soruların açıklamalarını inceleyin.',
                      style: const TextStyle(
                        color: Colors.white,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Ana Sayfa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00BCD4),
                      side: const BorderSide(color: Color(0xFF00BCD4)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionReview(int questionNumber, Question question) {
    final isCorrect = question.isCorrect;
    final isAnswered = question.isAnswered;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D2B36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: !isAnswered
              ? Colors.grey
              : isCorrect
                  ? Colors.green
                  : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: !isAnswered
                      ? Colors.grey
                      : isCorrect
                          ? Colors.green
                          : Colors.red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Soru $questionNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                !isAnswered
                    ? Icons.remove_circle_outline
                    : isCorrect
                        ? Icons.check_circle
                        : Icons.cancel,
                color: !isAnswered
                    ? Colors.grey
                    : isCorrect
                        ? Colors.green
                        : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.soru,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (isAnswered) ...[
            Row(
              children: [
                const Text(
                  'Cevabınız: ',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  question.kullaniciCevabiHarfi ?? '',
                  style: TextStyle(
                    color: isCorrect ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (!isCorrect) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Doğru Cevap: ',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    question.dogruCevapHarfi,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A47),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF4DD0E1), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Açıklama',
                        style: TextStyle(
                          color: Color(0xFF4DD0E1),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question.aciklama,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              'Bu soruyu cevaplamadınız',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
