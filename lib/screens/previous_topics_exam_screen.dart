import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/openrouter_service.dart';
import '../models/visual_item.dart';
import '../models/question.dart';
import '../utils/constants.dart';
import 'exam_screen.dart';

class PreviousTopicsExamScreen extends StatefulWidget {
  const PreviousTopicsExamScreen({super.key});

  @override
  State<PreviousTopicsExamScreen> createState() => _PreviousTopicsExamScreenState();
}

class _PreviousTopicsExamScreenState extends State<PreviousTopicsExamScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final OpenRouterService _openRouterService = OpenRouterService();

  List<VisualItem> _allVisuals = [];
  VisualItem? _selectedVisual;
  bool _isLoading = true;
  bool _isCreatingExam = false;

  int _soruSayisi = AppConstants.defaultSoruSayisi;

  @override
  void initState() {
    super.initState();
    _loadVisuals();
  }

  Future<void> _loadVisuals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final visuals = await _databaseService.getAllVisuals();
      setState(() {
        _allVisuals = visuals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yükleme hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createExam() async {
    if (_selectedVisual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir konu seçin'),
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
        dersAdi: _selectedVisual!.dersAdi,
        konu: _selectedVisual!.konu,
        seviye: _selectedVisual!.seviye,
        soruSayisi: _soruSayisi,
      );

      setState(() {
        _isCreatingExam = false;
      });

      // Sınav ekranına git
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExamScreen(
            dersAdi: _selectedVisual!.dersAdi,
            konu: _selectedVisual!.konu,
            seviye: _selectedVisual!.seviye,
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
        title: const Text(
          'Geçmiş Konulardan Sınav',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00BCD4),
              ),
            )
          : _allVisuals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_edu_outlined,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz kayıtlı görsel yok',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Önce bir görsel oluşturun',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Konu Seçin',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _allVisuals.length,
                        itemBuilder: (context, index) {
                          final visual = _allVisuals[index];
                          final isSelected = _selectedVisual?.id == visual.id;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00BCD4).withOpacity(0.2)
                                  : const Color(0xFF1A3A47),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00BCD4)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00BCD4).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.topic,
                                  color: Color(0xFF00BCD4),
                                ),
                              ),
                              title: Text(
                                visual.dersAdi,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    visual.konu,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF4DD0E1),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    visual.seviye,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF00BCD4),
                                    )
                                  : const Icon(
                                      Icons.radio_button_unchecked,
                                      color: Colors.white54,
                                    ),
                              onTap: () {
                                setState(() {
                                  _selectedVisual = visual;
                                });
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Soru Sayısı',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                  '$_soruSayisi Soru',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00BCD4),
                                  ),
                                ),
                                Text(
                                  '${AppConstants.sinavSureleri[_soruSayisi] ?? _soruSayisi} Dakika',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Slider(
                              value: _soruSayisi.toDouble(),
                              min: AppConstants.minSoruSayisi.toDouble(),
                              max: AppConstants.maxSoruSayisi.toDouble(),
                              divisions: (AppConstants.maxSoruSayisi -
                                      AppConstants.minSoruSayisi) ~/
                                  5,
                              activeColor: const Color(0xFF00BCD4),
                              inactiveColor: const Color(0xFF4DD0E1).withOpacity(0.3),
                              onChanged: (value) {
                                setState(() {
                                  _soruSayisi = value.round();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
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
                                  'Sınav Oluştur',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
