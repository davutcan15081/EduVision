// API Anahtarları ve Endpoint'ler
class ApiConstants {
  // Cloudflare Workers AI API (Görsel oluşturma için)
  static const String cloudflareApiToken = 'wjXHvNvFYdS-mZPXNQFoyRkVw7HxKvCyjCXQlm5u';
  static const String cloudflareAccountId = '2b4431f6dba6b68d98303b33876b66e6';
  static const String cloudflareBaseUrl = 'https://api.cloudflare.com/client/v4/accounts';
  static const String cloudflareImageModel = '@cf/stabilityai/stable-diffusion-xl-base-1.0';

  // OpenRouter API (Açıklama ve sınav soruları için)
  static const String openRouterApiKey = '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';
  static const String openRouterBaseUrl = 'https://openrouter.ai/api/v1';
  static const String openRouterModel = 'mistralai/mistral-7b-instruct:free';

  // Gemini API (Yedek - kullanılmıyor)
  static const String geminiApiKey = 'AIzaSyBDW8sg7GL1Eq3_OznAAQaJSlojH9Pzy20';
  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const String geminiModel = 'gemini-2.0-flash-exp';

  // Timeout süreleri (milisaniye)
  static const int apiTimeout = 60000; // 60 saniye
  static const int imageTimeout = 90000; // 90 saniye

  // Pollinations API
  static const String pollinationsBaseUrl = 'https://pollinations.ai';
  static const String pollinationsModel = 'flux';
}

// Uygulama Sabitleri
class AppConstants {
  // Seviye seçenekleri
  static const List<String> seviyeler = [
    'İlkokul',
    'Ortaokul',
    'Lise',
    'Üniversite',
  ];

  // Ders kategorileri
  static const List<String> dersler = [
    'Matematik',
    'Fizik',
    'Kimya',
    'Biyoloji',
    'Tarih',
    'Coğrafya',
    'Edebiyat',
    'İngilizce',
  ];

  // Sınav ayarları
  static const int minSoruSayisi = 5;
  static const int maxSoruSayisi = 50;
  static const int defaultSoruSayisi = 10;

  // Sınav süreleri (dakika cinsinden)
  static const Map<int, int> sinavSureleri = {
    5: 5,
    10: 10,
    15: 15,
    20: 20,
    25: 25,
    30: 30,
    40: 40,
    50: 50,
  };

  // Başarı eşikleri
  static const double mukemmelEsik = 85.0;
  static const double iyiEsik = 70.0;
  static const double ortaEsik = 50.0;

  // Görsel boyutları
  static const String defaultImageSize = '1024x1024';
  static const int imageQuality = 90;

  // Veritabanı
  static const String databaseName = 'eduvision.db';
  static const int databaseVersion = 1;
  static const String visualsTableName = 'visuals';
  static const String examsTableName = 'exam_results';
}

// Hata Mesajları
class ErrorMessages {
  static const String networkError = 'İnternet bağlantınızı kontrol edin';
  static const String apiError = 'API isteği başarısız oldu';
  static const String invalidResponse = 'Geçersiz API yanıtı';
  static const String imageGenerationFailed = 'Görsel oluşturulamadı';
  static const String questionGenerationFailed = 'Sorular oluşturulamadı';
  static const String databaseError = 'Veritabanı hatası';
  static const String saveFailed = 'Kaydetme işlemi başarısız';
  static const String loadFailed = 'Yükleme işlemi başarısız';
  static const String emptyFields = 'Lütfen tüm alanları doldurun';
  static const String invalidInput = 'Geçersiz giriş';
}

// Başarı Mesajları
class SuccessMessages {
  static const String visualSaved = 'Görsel başarıyla kaydedildi';
  static const String examSaved = 'Sınav sonucu kaydedildi';
  static const String imageSavedToGallery = 'Görsel galerinize kaydedildi';
  static const String shareSuccess = 'Paylaşım başarılı';
}

