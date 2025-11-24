import 'dart:async';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class PollinationsService {
  static final PollinationsService _instance = PollinationsService._internal();
  factory PollinationsService() => _instance;
  PollinationsService._internal();

  Future<String> generateImage({
    required String dersAdi,
    required String konu,
    required String seviye,
  }) async {
    final prompt = buildPrompt(dersAdi, konu, seviye);
    final encodedPrompt = Uri.encodeQueryComponent(prompt);

    final baseUrl =
        '${ApiConstants.pollinationsBaseUrl}/api/v2/?prompt=$encodedPrompt'
        '&model=${ApiConstants.pollinationsModel}'
        '&width=1024&height=1024&nologo=true';

    return await _requestWithRetry(baseUrl);
  }

  /// --------------------------------------------------------------
  /// 524, 520, 522, 500 ve timeout durumları için retry + fallback
  /// --------------------------------------------------------------
  Future<String> _requestWithRetry(String url) async {
    int attempts = 0;

    while (attempts < 3) {
      attempts++;

      try {
        final response = await http
            .get(Uri.parse(url), headers: {'Accept': 'image/*'})
            .timeout(Duration(milliseconds: ApiConstants.imageTimeout));

        final code = response.statusCode;

        if (code == 200) {
          return url;
        }

        // 403 → Azure block → safe prompt fallback
        if (code == 403) {
          final safe = _safeFallbackUrl();
          return safe;
        }

        // 524 / 520 / 522 → Cloudflare issue
        if (code == 524 || code == 520 || code == 522 || code == 500) {
          print("Cloudflare/Pollinations hatası: $code. Tekrar deniyor ($attempts/3)");
          await Future.delayed(Duration(seconds: 1));
          continue;
        }

        // Diğer durum → hata
        throw Exception('HTTP $code');
      } on TimeoutException {
        print("Timeout oldu. Tekrar deniyor ($attempts/3)");
        await Future.delayed(Duration(milliseconds: 800));
      } catch (e) {
        print("İstek hatası: $e");
        await Future.delayed(Duration(milliseconds: 500));
      }
    }

    // 3 deneme de çözülemedi → Fast model fallback
    print("Tüm denemeler başarısız. Fast model fallback kullanılıyor.");

    final fastUrl =
        '${ApiConstants.pollinationsBaseUrl}/api/v2/?prompt=technical+diagram'
        '&model=flux'
        '&width=1024&height=1024&nologo=true';

    return fastUrl;
  }

  /// Safe prompt fallback URL (403 olduğunda)
  String _safeFallbackUrl() {
    final safePrompt =
        Uri.encodeQueryComponent("Simple labeled technical diagram. No humans.");
    return '${ApiConstants.pollinationsBaseUrl}/api/v2/?prompt=$safePrompt&model=flux&width=1024&height=1024&nologo=true';
  }

  /// --------------------------------------------------------------

  String buildPrompt(String dersAdi, String konu, String seviye) {
    return '$dersAdi dersi, "$konu" konusu için sade, açıklayıcı bir teknik diyagram. '
        'Temel şekiller ve etiketli bağlantılar bulunsun. '
        'Nötr ve temiz bir şema olsun. İnsan figürü veya duygusal içerik olmasın.';
  }
}
