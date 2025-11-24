import 'dart:developer' as developer;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/visual_item.dart';
import '../models/exam_result.dart';
import '../utils/constants.dart';

class DatabaseService {
  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  // Get database instance
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }



  /// Veritabanı tablolarını oluştur
  Future<void> _onCreate(Database db, int version) async {
    // Görseller tablosu
    await db.execute('''
      CREATE TABLE ${AppConstants.visualsTableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dersAdi TEXT NOT NULL,
        konu TEXT NOT NULL,
        seviye TEXT NOT NULL,
        gorselUrl TEXT NOT NULL,
        aciklama TEXT NOT NULL,
        tarih TEXT NOT NULL
      )
    ''');

    // Sınav sonuçları tablosu
    await db.execute('''
      CREATE TABLE ${AppConstants.examsTableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dersAdi TEXT NOT NULL,
        konu TEXT NOT NULL,
        seviye TEXT NOT NULL,
        sorular TEXT NOT NULL,
        tarih TEXT NOT NULL,
        toplamSure INTEGER NOT NULL
      )
    ''');

    // İndeksler
    await db.execute('''
      CREATE INDEX idx_visuals_tarih ON ${AppConstants.visualsTableName}(tarih DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_visuals_ders ON ${AppConstants.visualsTableName}(dersAdi)
    ''');

    await db.execute('''
      CREATE INDEX idx_exams_tarih ON ${AppConstants.examsTableName}(tarih DESC)
    ''');
  }

  // Database upgrade handler
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Example upgrade for version 2
      // await db.execute('ALTER TABLE ${AppConstants.visualsTableName} ADD COLUMN yeniKolon TEXT');
    }
  }

  // ==================== VISUAL OPERATIONS ====================

  /// Insert a new visual
  Future<int> insertVisual(VisualItem visual) async {
    try {
      final db = await database;
      final id = await db.insert(
        AppConstants.visualsTableName,
        visual.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      developer.log('Error inserting visual: $e', name: 'DatabaseService');
      rethrow;
    }
  }
  


  /// Get all visuals
  Future<List<VisualItem>> getAllVisuals() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.visualsTableName,
        orderBy: 'tarih DESC',
      );
      return List.generate(maps.length, (i) => VisualItem.fromMap(maps[i]));
    } catch (e) {
      developer.log('Error getting all visuals: $e', name: 'DatabaseService');
      rethrow;
    }
  }

  /// Derse göre görselleri getir
  Future<List<VisualItem>> getVisualsByDers(String dersAdi) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.visualsTableName,
        where: 'dersAdi = ?',
        whereArgs: [dersAdi],
        orderBy: 'tarih DESC',
      );

      return List.generate(maps.length, (i) => VisualItem.fromMap(maps[i]));
    } catch (e) {
      throw Exception('${ErrorMessages.loadFailed}: $e');
    }
  }

  /// Seviyeye göre görselleri getir
  Future<List<VisualItem>> getVisualsBySeviye(String seviye) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.visualsTableName,
        where: 'seviye = ?',
        whereArgs: [seviye],
        orderBy: 'tarih DESC',
      );

      return List.generate(maps.length, (i) => VisualItem.fromMap(maps[i]));
    } catch (e) {
      throw Exception('${ErrorMessages.loadFailed}: $e');
    }
  }

  /// Search visuals
  Future<List<VisualItem>> searchVisuals(String query) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.visualsTableName,
        where: 'dersAdi LIKE ? OR konu LIKE ? OR aciklama LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'tarih DESC',
      );
      return List.generate(maps.length, (i) => VisualItem.fromMap(maps[i]));
    } catch (e) {
      developer.log('Error searching visuals: $e', name: 'DatabaseService');
      rethrow;
    }
  }

  /// Delete visual
  Future<int> deleteVisual(int id) async {
    try {
      final db = await database;
      return await db.delete(
        AppConstants.visualsTableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      developer.log('Error deleting visual: $e', name: 'DatabaseService');
      rethrow;
    }
  }

  /// Get visual by ID
  Future<VisualItem?> getVisualById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.visualsTableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return VisualItem.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      developer.log('Error getting visual by ID: $e', name: 'DatabaseService');
      rethrow;
    }
  }

  // ==================== EXAM OPERATIONS ====================

  /// Insert exam result
  Future<int> insertExamResult(ExamResult result) async {
    try {
      final db = await database;
      final id = await db.insert(
        AppConstants.examsTableName,
        result.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      developer.log('Error inserting exam result: $e', name: 'DatabaseService');
      rethrow;
    }
  }

  /// Get all exam results
  Future<List<ExamResult>> getAllExamResults() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.examsTableName,
        orderBy: 'tarih DESC',
      );
      return List.generate(maps.length, (i) => ExamResult.fromMap(maps[i]));
    } catch (e) {
      developer.log('Error getting all exam results: $e', name: 'DatabaseService');
      rethrow;
    }
  }

  /// Derse göre sınav sonuçlarını getir
  Future<List<ExamResult>> getExamResultsByDers(String dersAdi) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.examsTableName,
        where: 'dersAdi = ?',
        whereArgs: [dersAdi],
        orderBy: 'tarih DESC',
      );

      return List.generate(maps.length, (i) => ExamResult.fromMap(maps[i]));
    } catch (e) {
      throw Exception('${ErrorMessages.loadFailed}: $e');
    }
  }

  /// Sınav sonucu sil
  Future<int> deleteExamResult(int id) async {
    try {
      final db = await database;
      return await db.delete(
        AppConstants.examsTableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('${ErrorMessages.databaseError}: $e');
    }
  }

  /// Get exam result by ID
  Future<ExamResult?> getExamResultById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.examsTableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return ExamResult.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      developer.log('Error getting exam result by ID: $e', name: 'DatabaseService');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Clear all data (for testing)
  Future<void> clearAllData() async {
    try {
      final db = await database;
      await db.delete(AppConstants.visualsTableName);
      await db.delete(AppConstants.examsTableName);
    } catch (e) {
      developer.log('Error clearing database: $e', name: 'DatabaseService');
      rethrow;
    }
  }

  /// Close database
  Future<void> close() async {
    try {
      final db = await database;
      await db.close();
      _db = null;
    } catch (e) {
      developer.log('Error closing database: $e', name: 'DatabaseService');
      rethrow;
    }
  }

  /// Get database statistics
  Future<Map<String, int>> getStatistics() async {
    try {
      final db = await database;
      
      final visualCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.visualsTableName}'),
      ) ?? 0;

      final examCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.examsTableName}'),
      ) ?? 0;

      return {
        'visualCount': visualCount,
        'examCount': examCount,
      };
    } catch (e) {
      developer.log('Error getting statistics: $e', name: 'DatabaseService');
      rethrow;
    }
  }
}
