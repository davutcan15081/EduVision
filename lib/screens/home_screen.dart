import 'package:flutter/material.dart';
import 'settings_screen.dart';
import 'create_visual_screen.dart';
import 'history_screen.dart';
import 'exam_mode_screen.dart';
import 'exam_history_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(bool) onThemeToggle;

  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with logo and action icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/eduviz_logo.png',
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'EduViz',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                            color: Colors.white,
                            size: 22,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            onThemeToggle(!isDark);
                          },
                        ),
                        const SizedBox(width: 16),
                        // YARDIM BUTONU (GÜNCELLENDİ)
                        IconButton(
                          icon: const Icon(Icons.help_outline, color: Colors.white, size: 22),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: const Color(0xFF0D2B36), // Koyu tema arka planı
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                insetPadding: const EdgeInsets.all(20),
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Başlık Kısmı
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00BCD4),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(Icons.help_outline, color: Colors.white, size: 24),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Nasıl Kullanılır?',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        
                                        // 1. Görsel Oluştur
                                        _buildHelpItem(
                                          icon: Icons.auto_awesome,
                                          title: 'Görsel Oluştur',
                                          description: 'Öğrenmek istediğiniz konuyu girin. AI, konuyu açıklayan bir görsel ve detaylı açıklama oluşturacaktır.',
                                        ),
                                        
                                        // 2. Görsel Üzerinde Çizim
                                        _buildHelpItem(
                                          icon: Icons.edit_outlined,
                                          title: 'Görsel Üzerinde Çizim',
                                          description: 'Oluşturulan görseller üzerinde not alabilir, önemli yerleri işaretleyebilirsiniz.',
                                        ),
                                        
                                        // 3. Sınav Yap
                                        _buildHelpItem(
                                          icon: Icons.quiz_outlined,
                                          title: 'Sınav Yap',
                                          description: 'Öğrendiğiniz konuları test edin. Geçmiş konulardan veya yeni konulardan sınav oluşturabilirsiniz.',
                                        ),
                                        
                                        // 4. Geçmiş Görseller
                                        _buildHelpItem(
                                          icon: Icons.history,
                                          title: 'Geçmiş Görseller',
                                          description: 'Daha önce oluşturduğunuz tüm görselleri, notları ve açıklamaları görüntüleyin.',
                                        ),

                                        const SizedBox(height: 16),
                                        
                                        // Anladım Butonu
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          child: const Text(
                                            'Anladım',
                                            style: TextStyle(
                                              color: Color(0xFF00BCD4),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.history, color: Colors.white, size: 22),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Logo in center
                Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF00BCD4).withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/eduviz_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title and description
                const Text(
                  'EduViz',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Görselleştirerek öğrenme sürecinizi hızlandırın ve kalıcı hale getirin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF9DB5BC),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                _buildMenuCard(
                  context,
                  icon: Icons.auto_awesome,
                  title: 'Görsel Oluştur',
                  subtitle: 'Yapay zeka ile yeni görseller oluşturun.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateVisualScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.quiz,
                  title: 'Sınav Yap',
                  subtitle: 'Bilginizi test etmek için sınav çözün.',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExamModeScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF0D2B36), Color(0xFF0A1E26)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF00BCD4), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // YENİ EKLENEN YARDIMCI FONKSİYON
  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF153745), // Kart arka planı (Dialog içi)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00BCD4), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}