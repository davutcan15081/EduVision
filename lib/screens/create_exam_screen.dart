import 'package:flutter/material.dart';
import 'exam_screen.dart';
import '../services/openrouter_service.dart';
import '../utils/constants.dart';

class CreateExamScreen extends StatefulWidget {
  final String examType;

  const CreateExamScreen({super.key, required this.examType});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  final OpenRouterService _openRouterService = OpenRouterService();

  String _selectedLevel = 'Lise';
  int _questionCount = 10;
  bool _isCreatingExam = false;

  @override
  void initState() {
    super.initState();
    // Placeholder metinleri temizle
    _subjectController.text = '';
    _topicController.text = '';
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _createExam() async {
    // Validasyon
    if (_subjectController.text.trim().isEmpty ||
        _topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorMessages.emptyFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingExam = true;
    });

    try {
      // OpenRouter ile sorular oluştur
      final questions = await _openRouterService.generateExamQuestions(
        dersAdi: _subjectController.text.trim(),
        konu: _topicController.text.trim(),
        seviye: _selectedLevel,
        soruSayisi: _questionCount,
      );

      setState(() {
        _isCreatingExam = false;
      });

      // Sınav ekranına git
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExamScreen(
            dersAdi: _subjectController.text.trim(),
            konu: _topicController.text.trim(),
            seviye: _selectedLevel,
            questions: questions,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isCreatingExam = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sınav oluşturma hatası: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.examType == 'Genel Karışık'
              ? 'Genel Karışık Sınav'
              : 'Sınav Oluştur',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ders Adı',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4DD0E1),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A47),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school, color: Color(0xFF4DD0E1)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _subjectController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Örn: Matematik, Fizik, Biyoloji',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Konu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4DD0E1),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A47),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.topic, color: Color(0xFF4DD0E1)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _topicController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Örn: Türev, Hücre Yapısı, Newton Yasaları',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Seviye Seçimi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4DD0E1),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A47),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school_outlined, color: Color(0xFF4DD0E1)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLevel,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1A3A47),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        items: AppConstants.seviyeler.map((String level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLevel = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Soru Sayısı',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4DD0E1),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A47),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$_questionCount Soru',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BCD4),
                        ),
                      ),
                      Text(
                        '~${AppConstants.sinavSureleri[_questionCount] ?? _questionCount} Dakika',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: _questionCount.toDouble(),
                    min: AppConstants.minSoruSayisi.toDouble(),
                    max: AppConstants.maxSoruSayisi.toDouble(),
                    divisions: (AppConstants.maxSoruSayisi - AppConstants.minSoruSayisi) ~/ 5,
                    activeColor: const Color(0xFF00BCD4),
                    inactiveColor: const Color(0xFF4DD0E1).withOpacity(0.3),
                    onChanged: (double value) {
                      setState(() {
                        _questionCount = value.round();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isCreatingExam ? null : _createExam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isCreatingExam
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Sınavı Başlat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
            if (_isCreatingExam) ...[
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Sorular oluşturuluyor, lütfen bekleyin...',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
