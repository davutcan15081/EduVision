import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/visual_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'Tarihe Göre';
  String _selectedSubject = 'Derse Göre';
  List<VisualItem> _allVisuals = [];
  List<VisualItem> _filteredVisuals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVisuals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVisuals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final visuals = await _databaseService.getAllVisuals();
      setState(() {
        _allVisuals = visuals;
        _filteredVisuals = visuals;
        _isLoading = false;
      });
      _applyFilters();
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

  void _applyFilters() {
    List<VisualItem> filtered = List.from(_allVisuals);

    // Arama filtresi
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((visual) {
        return visual.dersAdi.toLowerCase().contains(query) ||
            visual.konu.toLowerCase().contains(query);
      }).toList();
    }

    // Ders filtresi
    if (_selectedSubject != 'Derse Göre') {
      filtered = filtered.where((visual) {
        return visual.dersAdi == _selectedSubject;
      }).toList();
    }

    // Tarih sıralaması
    if (_selectedFilter == 'Yeniden Eskiye') {
      filtered.sort((a, b) => b.tarih.compareTo(a.tarih));
    } else if (_selectedFilter == 'Eskiden Yeniye') {
      filtered.sort((a, b) => a.tarih.compareTo(b.tarih));
    } else {
      // Tarihe Göre - varsayılan yeniden eskiye
      filtered.sort((a, b) => b.tarih.compareTo(a.tarih));
    }

    setState(() {
      _filteredVisuals = filtered;
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'tr_TR').format(date);
  }

  Future<void> _deleteVisual(VisualItem visual) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A3A47),
        title: const Text(
          'Görseli Sil',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Bu görseli silmek istediğinize emin misiniz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true && visual.id != null) {
      try {
        await _databaseService.deleteVisual(visual.id!);
        _loadVisuals();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Görsel silindi'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silme hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showVisualDetails(VisualItem visual) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0D2B36),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A3A47),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visual.dersAdi,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            visual.konu,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4DD0E1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Görsel
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildVisualImage(visual.gorselUrl),
                      ),
                      const SizedBox(height: 16),
                      // Bilgiler
                      Row(
                        children: [
                          _buildInfoChip(Icons.school, visual.seviye),
                          const SizedBox(width: 8),
                          _buildInfoChip(Icons.calendar_today, _formatDate(visual.tarih)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Açıklama
                      const Text(
                        'Görsel Açıklaması',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4DD0E1),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        visual.aciklama,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A47),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4DD0E1)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Geçmiş Görseller',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A47),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF4DD0E1)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Ders veya konuda ara...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => _applyFilters(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    icon: Icons.calendar_today,
                    value: _selectedFilter,
                    items: ['Tarihe Göre', 'Yeniden Eskiye', 'Eskiden Yeniye'],
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterDropdown(
                    icon: Icons.subject,
                    value: _selectedSubject,
                    items: ['Derse Göre', ...Set.from(_allVisuals.map((v) => v.dersAdi))],
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value!;
                      });
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00BCD4),
                      ),
                    )
                  : _filteredVisuals.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported_outlined,
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
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _filteredVisuals.length,
                          itemBuilder: (context, index) {
                            return _buildHistoryCard(_filteredVisuals[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown({
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A47),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          isExpanded: true,
          dropdownColor: const Color(0xFF1A3A47),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Row(
                children: [
                  Icon(icon, color: const Color(0xFF4DD0E1), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildHistoryCard(VisualItem visual) {
    return GestureDetector(
      onTap: () => _showVisualDetails(visual),
      onLongPress: () => _deleteVisual(visual),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A3A47),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _buildVisualImage(visual.gorselUrl, isThumbnail: true),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visual.dersAdi,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visual.konu,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4DD0E1),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        size: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          visual.seviye,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildVisualImage(String imageUrl, {bool isThumbnail = false}) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64String = imageUrl.split(',')[1];
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: isThumbnail ? double.infinity : null,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFF1A3A47),
              child: Center(
                child: Icon(Icons.error, color: Colors.red, size: isThumbnail ? 40 : 50),
              ),
            );
          },
        );
      } catch (e) {
        return Container(
          color: const Color(0xFF1A3A47),
          child: Center(
            child: Icon(Icons.error, color: Colors.red, size: isThumbnail ? 40 : 50),
          ),
        );
      }
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: isThumbnail ? double.infinity : null,
      placeholder: (context, url) => Container(
        color: const Color(0xFF1A3A47),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF00BCD4),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: const Color(0xFF1A3A47),
        child: Center(
          child: Icon(Icons.error, color: Colors.red, size: isThumbnail ? 40 : 50),
        ),
      ),
    );
  }
}
