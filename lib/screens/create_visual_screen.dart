import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'drawing_screen.dart';
import '../services/cloudflare_image_service.dart';
import '../services/openrouter_service.dart';
import '../services/database_service.dart';
import '../models/visual_item.dart';
import '../utils/constants.dart';

class CreateVisualScreen extends StatefulWidget {
  const CreateVisualScreen({super.key});

  @override
  State<CreateVisualScreen> createState() => _CreateVisualScreenState();
}

class _CreateVisualScreenState extends State<CreateVisualScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();

  final CloudflareImageService _cloudflareService = CloudflareImageService();
  final OpenRouterService _openRouterService = OpenRouterService();
  final DatabaseService _databaseService = DatabaseService();

  String? _selectedSeviye;
  String? _generatedImageUrl;
  String? _imageDescription;
  bool _isGenerating = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateVisual() async {
    // Validasyon
    if (_subjectController.text.trim().isEmpty ||
        _topicController.text.trim().isEmpty ||
        _selectedSeviye == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorMessages.emptyFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedImageUrl = null;
      _imageDescription = null;
    });

    try {
      // Görseli oluştur
      final imageUrl = await _cloudflareService.generateImage(
        dersAdi: _subjectController.text.trim(),
        konu: _topicController.text.trim(),
        seviye: _selectedSeviye!,
      );

      // Görsel açıklamasını oluştur
      final description = await _openRouterService.generateImageDescription(
        dersAdi: _subjectController.text.trim(),
        konu: _topicController.text.trim(),
        seviye: _selectedSeviye!,
      );

      setState(() {
        _generatedImageUrl = imageUrl;
        _imageDescription = description;
      });

      // Veritabanına kaydet
      try {
        await _saveToDatabase();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Görsel başarıyla oluşturuldu ve kaydedildi.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        debugPrint('Veritabanı kaydı sırasında hata: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Görsel oluşturuldu ancak kaydedilemedi: ${e.toString()}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Görsel oluşturma hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Görsel oluşturulurken hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _saveToDatabase() async {
    if (_generatedImageUrl == null || _imageDescription == null) {
      throw Exception('Görsel veya açıklama bulunamadı');
    }

    try {
      final visualItem = VisualItem(
        dersAdi: _subjectController.text.trim(),
        konu: _topicController.text.trim(),
        seviye: _selectedSeviye ?? 'Belirtilmemiş',
        gorselUrl: _generatedImageUrl!,
        aciklama: _imageDescription!,
        tarih: DateTime.now(),
      );

      developer.log('Kaydedilecek görsel bilgileri:', name: 'CreateVisualScreen');
      developer.log('- Ders: ${visualItem.dersAdi}', name: 'CreateVisualScreen');
      developer.log('- Konu: ${visualItem.konu}', name: 'CreateVisualScreen');
      developer.log('- Seviye: ${visualItem.seviye}', name: 'CreateVisualScreen');
      developer.log(
        '- Görsel URL: ${visualItem.gorselUrl.substring(0, visualItem.gorselUrl.length > 50 ? 50 : visualItem.gorselUrl.length)}...', 
        name: 'CreateVisualScreen'
      );
      developer.log(
        '- Açıklama: ${visualItem.aciklama.substring(0, visualItem.aciklama.length > 30 ? 30 : visualItem.aciklama.length)}...', 
        name: 'CreateVisualScreen'
      );
      developer.log('- Tarih: ${visualItem.tarih}', name: 'CreateVisualScreen');

      final id = await _databaseService.insertVisual(visualItem);
      if (id == null) {
        throw Exception('Kayıt işlemi başarısız oldu');
      }
      
      developer.log('Görsel başarıyla kaydedildi. ID: $id', name: 'CreateVisualScreen');
      
      // Veritabanından tekrar okuyarak kontrol et
      final savedItem = await _databaseService.getVisualById(id);
      if (savedItem != null) {
        developer.log('Veritabanından okunan kayıt: $savedItem', name: 'CreateVisualScreen');
      } else {
        developer.log('UYARI: Kayıt yapıldı ancak okunamadı', name: 'CreateVisualScreen');
      }
    } catch (e, stackTrace) {
      developer.log('Veritabanına kayıt hatası: $e', name: 'CreateVisualScreen');
      developer.log('Stack Trace: $stackTrace', name: 'CreateVisualScreen');
      rethrow;
    }
  }

  Future<File?> _saveImageToFile() async {
    if (_generatedImageUrl == null) return null;

    try {
      if (_generatedImageUrl!.startsWith('data:image')) {
        final base64String = _generatedImageUrl!.split(',')[1];
        final bytes = base64Decode(base64String);
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/generated_visual_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(bytes);
        return file;
      }
      return null;
    } catch (e) {
      debugPrint('Dosya kaydetme hatası: $e');
      return null;
    }
  }

  Future<void> _downloadImage() async {
    if (_generatedImageUrl == null) return;

    try {
      final file = await _saveImageToFile();
      if (file != null) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'EduVision ile oluşturuldu: ${_subjectController.text}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Görsel paylaşım/kaydetme menüsü açıldı'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Fallback for URL
        await Share.shareUri(Uri.parse(_generatedImageUrl!));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İşlem hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareImage() async {
    if (_generatedImageUrl == null) return;

    try {
      final file = await _saveImageToFile();
      if (file != null) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'EduVision ile oluşturuldu:\n${_subjectController.text} - ${_topicController.text}',
          subject: '${_subjectController.text} - ${_topicController.text}',
        );
      } else {
        await Share.share(
          'EduVision ile oluşturuldu:\n${_subjectController.text} - ${_topicController.text}\n\n$_generatedImageUrl',
          subject: '${_subjectController.text} - ${_topicController.text}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Paylaşım hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildImageWidget() {
    if (_generatedImageUrl == null) {
      return const SizedBox.shrink();
    }

    try {
      // Base64 data URI formatını kontrol et
      if (_generatedImageUrl!.startsWith('data:image')) {
        // Data URI'dan base64 string'i ayıkla
        final base64String = _generatedImageUrl!.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error, color: Colors.red, size: 50),
            );
          },
        );
      } else {
        // Eğer normal URL ise (geriye dönük uyumluluk için)
        return Image.network(
          _generatedImageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.error, color: Colors.red, size: 50),
            );
          },
        );
      }
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 50),
            const SizedBox(height: 8),
            Text('Görsel yükleme hatası: $e',
                style: const TextStyle(color: Colors.red)),
          ],
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
          'Görsel Öğrenme',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DrawingScreen(),
                ),
              );
            },
          ),
        ],
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
                        hintText: 'Ders adını girin',
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
                        hintText: 'Konuyu girin',
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
              'Seviye',
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
                        value: _selectedSeviye,
                        hint: Text(
                          'Seviye seçin',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1A3A47),
                        style: const TextStyle(color: Colors.white),
                        items: AppConstants.seviyeler.map((seviye) {
                          return DropdownMenuItem(
                            value: seviye,
                            child: Text(seviye),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSeviye = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateVisual,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isGenerating
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Görsel Oluştur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
            if (_generatedImageUrl != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3A47),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildImageWidget(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Görsel Açıklaması',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4DD0E1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3A47),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _imageDescription!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              )
            else if (!_isGenerating)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3A47),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.image_search,
                        size: 80,
                        color: const Color(0xFF00BCD4).withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Başlamak için bir görsel oluşturun',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ders, konu ve seviye girerek öğrenme sürecinizi görselleştirin.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: _generatedImageUrl != null
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1A3A47),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _downloadImage,
                        icon: const Icon(Icons.download, size: 20),
                        label: const Text('Cihaza İndir'),
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
                        onPressed: _shareImage,
                        icon: const Icon(Icons.share, size: 20),
                        label: const Text('Paylaş'),
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
              ),
            )
          : null,
    );
  }
}


