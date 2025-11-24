import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;

  const SettingsScreen({super.key, required this.onThemeToggle});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
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
          'Ayarlar',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'APPEARANCE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF607D8B),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.dark_mode,
              iconColor: const Color(0xFF4DD0E1),
              title: 'Tema',
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  widget.onThemeToggle(value);
                },
                activeColor: const Color(0xFF00BCD4),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'GENERAL',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF607D8B),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.notifications,
              iconColor: const Color(0xFF4DD0E1),
              title: 'Bildirimler',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveNotificationSetting(value);
                },
                activeColor: const Color(0xFF00BCD4),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'INFORMATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF607D8B),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.info,
              iconColor: const Color(0xFF4DD0E1),
              title: 'Hakkında',
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1A3A47),
                    title: const Text(
                      'Hakkında',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'EduVision v1.0.0\nGörsel Destekli Öğrenme Asistanı',
                      style: TextStyle(color: Color(0xFF4DD0E1)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Tamam',
                          style: TextStyle(color: Color(0xFF00BCD4)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              icon: Icons.privacy_tip,
              iconColor: const Color(0xFF4DD0E1),
              title: 'Gizlilik Politikası',
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {},
            ),
            const SizedBox(height: 32),
            _buildSettingCard(
              icon: Icons.logout,
              iconColor: const Color(0xFFEF5350),
              title: 'Çıkış Yap',
              titleColor: const Color(0xFFEF5350),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1A3A47),
                    title: const Text(
                      'Çıkış Yap',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Çıkış yapmak istediğinize emin misiniz?',
                      style: TextStyle(color: Color(0xFF4DD0E1)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'İptal',
                          style: TextStyle(color: Color(0xFF4DD0E1)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Çıkış',
                          style: TextStyle(color: Color(0xFFEF5350)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A3A47),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: titleColor ?? Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
