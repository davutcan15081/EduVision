import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:edu_vision/services/pollinations_service.dart';
import 'package:edu_vision/utils/constants.dart';

// Generate mocks
@GenerateMocks([http.Client])
void main() {
  late PollinationsService pollinationsService;
  late http.Client mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    pollinationsService = PollinationsService();
  });

  group('PollinationsService', () {
    test('buildPrompt generates correct prompt', () {
      // Arrange
      final dersAdi = 'Matematik';
      final konu = 'Üçgenler';
      final seviye = 'Lise';

      // Act
      final result = pollinationsService.buildPrompt(dersAdi, konu, seviye);

      // Assert
      expect(result, contains(dersAdi));
      expect(result, contains(konu));
      expect(result, contains(seviye));
      expect(result, contains('teknik diyagram'));
      expect(result, contains('vektör tarzı'));
    });

    test('validateImageUrl returns true for valid URL', () async {
      // Arrange
      final validUrl = 'https://example.com/image.jpg';
      when(mockHttpClient.head(any)).thenAnswer(
        (_) async => http.Response('', 200),
      );

      // Act
      final result = await pollinationsService.validateImageUrl(validUrl);

      // Assert
      expect(result, true);
    });

    test('validateImageUrl returns false for invalid URL', () async {
      // Arrange
      final invalidUrl = 'https://example.com/nonexistent.jpg';
      when(mockHttpClient.head(any)).thenThrow(Exception('Failed to load'));

      // Act
      final result = await pollinationsService.validateImageUrl(invalidUrl);

      // Assert
      expect(result, false);
    });

    // Note: For testing generateImage, you would typically mock the http client
    // and test the success and error cases. However, since we're using a real
    // API key and service, we'll skip that in this test file.
  });
}
