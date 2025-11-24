import 'package:flutter/material.dart';
import 'dart:async';
import 'exam_result_screen.dart';
import '../models/question.dart';

class ExamScreen extends StatefulWidget {
  final String dersAdi;
  final String konu;
  final String seviye;
  final List<Question> questions;

  const ExamScreen({
    super.key,
    required this.dersAdi,
    required this.konu,
    required this.seviye,
    required this.questions,
  });

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int _currentQuestionIndex = 0;
  int _timeRemaining = 0; // seconds
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Süreyi hesapla: her soru için 1 dakika
    _timeRemaining = widget.questions.length * 60;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _timer?.cancel();
        _finishExam();
      }
    });
  }

  void _finishExam() {
    _timer?.cancel();

    // Geçen süreyi hesapla
    final totalTime = widget.questions.length * 60;
    final elapsedTime = totalTime - _timeRemaining;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ExamResultScreen(
          dersAdi: widget.dersAdi,
          konu: widget.konu,
          seviye: widget.seviye,
          questions: widget.questions,
          elapsedTime: elapsedTime,
        ),
      ),
    );
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      widget.questions[_currentQuestionIndex].kullaniciCevabi = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _finishExam();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  int _calculateScore() {
    int correct = 0;
    for (var q in widget.questions) {
      if (q.isAnswered && q.kullaniciCevabi == q.dogruCevapIndex) {
        correct++;
      }
    }
    return (correct * 100 / widget.questions.length).round();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / widget.questions.length;

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A3A47),
            title: const Text(
              'Sınavı Bitir',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Sınavdan çıkmak istediğinize emin misiniz?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Devam Et', style: TextStyle(color: Color(0xFF00BCD4))),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  _finishExam();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Bitir'),
              ),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D2B36),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D2B36),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () async {
              final shouldExit = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1A3A47),
                  title: const Text(
                    'Sınavı Bitir',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Sınavdan çıkmak istediğinize emin misiniz?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('İptal', style: TextStyle(color: Color(0xFF00BCD4))),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Bitir'),
                    ),
                  ],
                ),
              );
              if (shouldExit == true) {
                _finishExam();
              }
            },
          ),
          title: Text(
            '${widget.dersAdi}: ${widget.konu}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_calculateScore()} pts',
                  style: const TextStyle(
                    color: Color(0xFF00BCD4),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Soru numarası ve zaman bilgisi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} / ${widget.questions.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFF00BCD4), size: 20),
                      const SizedBox(width: 6),
                      Text(
                        _formatTime(_timeRemaining),
                        style: const TextStyle(
                          color: Color(0xFF00BCD4),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // İlerleme Çubuğu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFF1A3A47),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Soru İçeriği
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Soru Metni
                    Text(
                      currentQuestion.soru,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 60),
                    // Şıklar
                    ...List.generate(
                      currentQuestion.secenekler.length,
                      (index) => _buildAnswerOption(
                        index,
                        currentQuestion.secenekler[index],
                        currentQuestion.kullaniciCevabi == index,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Alt Navigasyon Butonu
            Padding(
              padding: const EdgeInsets.all(20),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentQuestionIndex == widget.questions.length - 1
                          ? 'Finish'
                          : 'Next',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerOption(int index, String text, bool isSelected) {
    const letters = ['A', 'B', 'C', 'D'];
    final currentQuestion = widget.questions[_currentQuestionIndex];

    // Kullanıcı cevap verdiyse doğru/yanlış kontrolü yap
    final bool isCorrectAnswer = index == currentQuestion.dogruCevapIndex;
    final bool isUserAnswer = isSelected;
    final bool showResult = currentQuestion.isAnswered;

    // Renk belirleme
    Color borderColor;
    Color radioColor;
    Color? backgroundColor;
    Color textColor;
    Widget? trailingIcon;

    if (showResult && isUserAnswer) {
      // Kullanıcının seçtiği cevap
      if (isCorrectAnswer) {
        // Doğru cevap - Yeşil
        borderColor = const Color(0xFF4CAF50);
        radioColor = const Color(0xFF4CAF50);
        backgroundColor = const Color(0xFF4CAF50).withOpacity(0.15);
        textColor = Colors.white;
        trailingIcon = const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 26);
      } else {
        // Yanlış cevap - Kırmızı
        borderColor = const Color(0xFFE53935);
        radioColor = const Color(0xFFE53935);
        backgroundColor = const Color(0xFFE53935).withOpacity(0.15);
        textColor = Colors.white;
        trailingIcon = const Icon(Icons.cancel, color: Color(0xFFE53935), size: 26);
      }
    } else if (showResult && isCorrectAnswer) {
      // Doğru cevabı göster (kullanıcı yanlış seçmişse)
      borderColor = const Color(0xFF4CAF50);
      radioColor = const Color(0xFF4CAF50);
      backgroundColor = const Color(0xFF4CAF50).withOpacity(0.1);
      textColor = const Color(0xFF4CAF50);
      trailingIcon = const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 26);
    } else if (isSelected) {
      // Henüz sonuç gösterilmemiş ama seçilmiş
      borderColor = const Color(0xFF00BCD4);
      radioColor = const Color(0xFF00BCD4);
      backgroundColor = const Color(0xFF00BCD4).withOpacity(0.1);
      textColor = Colors.white;
      trailingIcon = const Icon(Icons.check_circle, color: Color(0xFF00BCD4), size: 26);
    } else {
      // Seçilmemiş
      borderColor = const Color(0xFF3A4F5D);
      radioColor = const Color(0xFF5A6F7D);
      backgroundColor = const Color(0xFF1A3A47).withOpacity(0.5);
      textColor = const Color(0xFFB0BEC5);
      trailingIcon = null;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: (showResult && (isUserAnswer || isCorrectAnswer)) ? 2.5 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Radio button indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: radioColor,
                  width: 2,
                ),
                color: Colors.transparent,
              ),
              child: (showResult && (isUserAnswer || isCorrectAnswer)) || isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: radioColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                '${letters[index]}) $text',
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  fontWeight: (showResult && (isUserAnswer || isCorrectAnswer)) || isSelected
                      ? FontWeight.w500
                      : FontWeight.w400,
                  height: 1.3,
                ),
              ),
            ),
            if (trailingIcon != null) trailingIcon,
          ],
        ),
      ),
    );
  }
}
