import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';
import '../utils/constants.dart';

class GeminiService {
  // Singleton pattern
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  /// Görsel açıklama oluşturma
  ///
  /// [dersAdi]: Ders adı
  /// [konu]: Konu adı
  /// [seviye]: Eğitim seviyesi
  ///
  /// Returns: Görselin açıklaması
  Future<String> generateImageDescription({
    required String dersAdi,
    required String konu,
    required String seviye,
  }) async {
    try {
      final prompt = '''
$dersAdi dersi $konu konusu için $seviye seviyesinde bir eğitim görseli oluşturuldu.

Bu görseli öğrencilere anlatır gibi, öğretici ve açıklayıcı bir metin yaz. Görselin ne anlattığını, hangi kavramları içerdiğini ve öğrencilerin bu görsel üzerinden ne öğrenebileceğini açıkla.

Açıklama 3-4 paragraf olsun ve şunları içersin:
1. Görselin genel konusu ve amacı
2. Görselde yer alan önemli kavramlar ve açıklamaları
3. Öğrencilerin bu görselden neleri öğrenmesi gerektiği

Açıklama Türkçe ve öğrencilere hitap eden, anlaşılır bir dilde olsun.
''';

      final response = await _callGeminiApi(prompt);
      return response.trim();
    } catch (e) {
      throw Exception('Görsel açıklama oluşturulamadı: $e');
    }
  }

  /// Sınav soruları oluşturma
  ///
  /// [dersAdi]: Ders adı
  /// [konu]: Konu adı
  /// [seviye]: Eğitim seviyesi
  /// [soruSayisi]: Oluşturulacak soru sayısı
  ///
  /// Returns: Soru listesi
  Future<List<Question>> generateExamQuestions({
    required String dersAdi,
    required String konu,
    required String seviye,
    required int soruSayisi,
  }) async {
    try {
      final prompt = '''
$dersAdi dersi, $konu konusu için $seviye seviyesinde $soruSayisi adet çoktan seçmeli sınav sorusu oluştur.

ÖNEMLİ KURALLAR:
1. Her soru 4 şıklı olmalı (A, B, C, D)
2. Her sorunun sadece 1 doğru cevabı olmalı
3. Her sorunun sonunda doğru cevabın neden doğru olduğunu açıklayan bir açıklama olmalı
4. Sorular $seviye seviyesine uygun zorlukta olmalı
5. Sorular konuyu farklı açılardan değerlendirmeli

ÇIKTI FORMATI (JSON):
Sadece aşağıdaki JSON formatında yanıt ver, başka hiçbir metin ekleme:

{
  "sorular": [
    {
      "soru": "Soru metni buraya",
      "secenekler": ["A şıkkı", "B şıkkı", "C şıkkı", "D şıkkı"],
      "dogruCevapIndex": 0,
      "aciklama": "Doğru cevabın neden A olduğunun açıklaması"
    }
  ]
}

NOT: dogruCevapIndex değeri 0, 1, 2 veya 3 olmalı (0=A, 1=B, 2=C, 3=D)

Şimdi $soruSayisi adet soru oluştur:
''';

      final response = await _callGeminiApi(prompt);

      // JSON parse
      final jsonResponse = _extractJson(response);
      final data = jsonDecode(jsonResponse);

      if (data['sorular'] == null || data['sorular'].isEmpty) {
        throw Exception('Gemini API\'den sorular alınamadı');
      }

      // Question nesnelerine dönüştür
      final List<Question> questions = [];
      for (var soruData in data['sorular']) {
        questions.add(Question.fromMap(soruData));
      }

      if (questions.length != soruSayisi) {
        throw Exception(
            'İstenen soru sayısı ($soruSayisi) ile oluşturulan soru sayısı (${questions.length}) eşleşmiyor');
      }

      return questions;
    } catch (e) {
      throw Exception('${ErrorMessages.questionGenerationFailed}: $e');
    }
  }

  /// Gemini API çağrısı
  Future<String> _callGeminiApi(String prompt) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.geminiBaseUrl}/${ApiConstants.geminiModel}:generateContent?key=${ApiConstants.geminiApiKey}',
      );

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 8192,
        }
      };

      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      )
          .timeout(
        Duration(milliseconds: ApiConstants.apiTimeout),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Gemini API hatası: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (data['candidates'] == null || data['candidates'].isEmpty) {
        throw Exception('Gemini API\'den yanıt alınamadı');
      }

      final text = data['candidates'][0]['content']['parts'][0]['text'];
      return text;
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('${ErrorMessages.apiError}: Zaman aşımı');
      }
      throw Exception('${ErrorMessages.apiError}: $e');
    }
  }

  /// JSON extraction helper
  /// Gemini bazen ekstra metin ekleyebilir, bu yüzden JSON'u çıkartmamız gerekir
  String _extractJson(String text) {
    // Önce tam JSON var mı kontrol et
    if (text.trim().startsWith('{') && text.trim().endsWith('}')) {
      return text.trim();
    }

    // Markdown code block içinde JSON arama
    final jsonBlockPattern = RegExp(r'```json\s*([\s\S]*?)\s*```');
    final match = jsonBlockPattern.firstMatch(text);
    if (match != null) {
      return match.group(1)!.trim();
    }

    // Sadece ``` içinde JSON arama
    final codeBlockPattern = RegExp(r'```\s*([\s\S]*?)\s*```');
    final codeMatch = codeBlockPattern.firstMatch(text);
    if (codeMatch != null) {
      return codeMatch.group(1)!.trim();
    }

    // { ile başlayan ilk JSON objesini bul
    final jsonPattern = RegExp(r'\{[\s\S]*\}');
    final jsonMatch = jsonPattern.firstMatch(text);
    if (jsonMatch != null) {
      return jsonMatch.group(0)!.trim();
    }

    // Hiçbir şey bulunamazsa orijinal metni döndür
    return text.trim();
  }

  /// Test için örnek soru oluşturma
  Future<List<Question>> getTestQuestions() async {
    return [
      Question(
        soru: 'Test sorusu',
        secenekler: ['Şık A', 'Şık B', 'Şık C', 'Şık D'],
        dogruCevapIndex: 0,
        aciklama: 'Test açıklaması',
      ),
    ];
  }
}
