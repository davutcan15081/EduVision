import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class CloudflareImageService {
  static final CloudflareImageService _instance = CloudflareImageService._internal();
  factory CloudflareImageService() => _instance;
  CloudflareImageService._internal();

  /// Cloudflare Workers AI kullanarak görsel oluşturur
  /// Dönen base64 string'i data URI olarak döner
  Future<String> generateImage({
    required String dersAdi,
    required String konu,
    required String seviye,
  }) async {
    final prompt = _buildPrompt(dersAdi, konu, seviye);

    try {
      final imageBase64 = await _requestImageGeneration(prompt);
      // Base64'ü data URI formatına çevir
      return 'data:image/png;base64,$imageBase64';
    } catch (e) {
      print('Cloudflare image generation error: $e');
      rethrow;
    }
  }

  /// Cloudflare Workers AI API'sine istek gönderir
  Future<String> _requestImageGeneration(String prompt) async {
    final url = '${ApiConstants.cloudflareBaseUrl}/${ApiConstants.cloudflareAccountId}/ai/run/${ApiConstants.cloudflareImageModel}';

    print('Cloudflare API URL: $url');
    print('Using token: ${ApiConstants.cloudflareApiToken.substring(0, 10)}...');

    final headers = {
      'Authorization': 'Bearer ${ApiConstants.cloudflareApiToken}',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'prompt': prompt,
    });

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: body,
          )
          .timeout(Duration(seconds: ApiConstants.imageTimeout ~/ 1000));

      print('Response status: ${response.statusCode}');
      print('Response content type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        // Stable Diffusion XL doğrudan binary PNG döndürür
        // FLUX modelleri ise JSON formatında base64 döndürür

        // İçerik tipini kontrol et
        final contentType = response.headers['content-type'] ?? '';

        if (contentType.contains('image/')) {
          // Binary image geldi - base64'e çevir
          print('Binary image received, size: ${response.bodyBytes.length} bytes');
          final base64Image = base64Encode(response.bodyBytes);
          print('Image converted to base64, length: ${base64Image.length}');
          return base64Image;
        } else {
          // JSON response geldi
          try {
            final responseData = jsonDecode(response.body);
            print('Response parsed as JSON successfully');

            if (responseData['success'] == true &&
                responseData['result'] != null &&
                responseData['result']['image'] != null) {
              // Base64 string'i direkt dön
              print('Image base64 received, length: ${responseData['result']['image'].length}');
              return responseData['result']['image'];
            } else {
              print('Invalid JSON response format');
              print('Response: ${response.body}');
              throw Exception('Invalid response format: ${response.body}');
            }
          } catch (e) {
            print('JSON parse error: $e');
            print('Response body preview: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}');
            rethrow;
          }
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Image generation timeout');
    } catch (e) {
      throw Exception('Image generation failed: $e');
    }
  }

  /// Prompt oluşturur
  String _buildPrompt(String dersAdi, String konu, String seviye) {
    return 'Educational diagram for $dersAdi subject, topic: $konu, level: $seviye. '
           'Create a clear, simple, and informative technical diagram with labels. '
           'Use basic shapes and labeled connections. Neutral and clean schema. '
           'No human figures or emotional content.';
  }
}
