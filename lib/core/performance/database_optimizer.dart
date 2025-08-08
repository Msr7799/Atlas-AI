import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// محسن قاعدة البيانات
class DatabaseOptimizer {
  static Database? _database;
  static const String _databaseName = 'arabic_agent.db';
  static const int _databaseVersion = 1;

  /// الحصول على قاعدة البيانات المحسّنة
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// تهيئة قاعدة البيانات مع تحسينات
  static Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      // تحسينات الأداء
      singleInstance: true,
      readOnly: false,
    );
  }

  /// إنشاء الجداول مع تحسينات
  static Future<void> _onCreate(Database db, int version) async {
    // جدول الرسائل مع فهارس محسّنة
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        content TEXT NOT NULL,
        sender TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        messageType TEXT NOT NULL,
        attachmentPath TEXT,
        thinkingProcess TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // إنشاء فهارس لتحسين الأداء
    await db.execute('CREATE INDEX idx_messages_timestamp ON messages(timestamp)');
    await db.execute('CREATE INDEX idx_messages_sender ON messages(sender)');
    await db.execute('CREATE INDEX idx_messages_type ON messages(messageType)');

    // جدول الإعدادات
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // جدول المحادثات
    await db.execute('''
      CREATE TABLE chats (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        messageCount INTEGER DEFAULT 0
      )
    ''');

    // فهرس للمحادثات
    await db.execute('CREATE INDEX idx_chats_updatedAt ON chats(updatedAt)');
  }

  /// ترقية قاعدة البيانات
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      // إضافة التحسينات الجديدة
      await _addPerformanceIndexes(db);
    }
  }

  /// إضافة فهارس الأداء
  static Future<void> _addPerformanceIndexes(Database db) async {
    // فهارس إضافية لتحسين الأداء
    await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_createdAt ON messages(createdAt)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_updatedAt ON messages(updatedAt)');
  }

  /// تحسين استعلام قاعدة البيانات
  static Future<List<Map<String, dynamic>>> optimizedQuery(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    
    // تحسين الاستعلام
    final query = '''
      SELECT * FROM $table
      ${where != null ? 'WHERE $where' : ''}
      ${orderBy != null ? 'ORDER BY $orderBy' : ''}
      ${limit != null ? 'LIMIT $limit' : ''}
      ${offset != null ? 'OFFSET $offset' : ''}
    ''';

    return await db.rawQuery(query, whereArgs);
  }

  /// تحسين إدراج البيانات
  static Future<int> optimizedInsert(
    String table,
    Map<String, Object?> values,
  ) async {
    final db = await database;
    
    // تحسين الإدراج
    return await db.insert(
      table,
      values,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// تحسين تحديث البيانات
  static Future<int> optimizedUpdate(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    
    return await db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// تحسين حذف البيانات
  static Future<int> optimizedDelete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  /// تنظيف قاعدة البيانات
  static Future<void> cleanupDatabase() async {
    final db = await database;
    
    // حذف الرسائل القديمة (أكثر من 30 يوم)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch;
    await db.delete(
      'messages',
      where: 'createdAt < ?',
      whereArgs: [thirtyDaysAgo],
    );

    // تحسين قاعدة البيانات
    await db.execute('VACUUM');
    await db.execute('ANALYZE');
  }

  /// الحصول على إحصائيات قاعدة البيانات
  static Future<Map<String, int>> getDatabaseStats() async {
    final db = await database;
    
    final messageCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM messages')
    ) ?? 0;
    
    final chatCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM chats')
    ) ?? 0;
    
    final settingsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM settings')
    ) ?? 0;

    return {
      'messages': messageCount,
      'chats': chatCount,
      'settings': settingsCount,
    };
  }

  /// إغلاق قاعدة البيانات
  static Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

/// مدير الذاكرة المؤقتة لقاعدة البيانات
class DatabaseCache {
  static final Map<String, dynamic> _cache = {};
  static const int _maxCacheSize = 100;

  /// إضافة عنصر للذاكرة المؤقتة
  static void cacheItem(String key, dynamic value) {
    if (_cache.length >= _maxCacheSize) {
      // إزالة العنصر الأقدم
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  /// الحصول على عنصر من الذاكرة المؤقتة
  static dynamic getCachedItem(String key) {
    return _cache[key];
  }

  /// تنظيف الذاكرة المؤقتة
  static void clearCache() {
    _cache.clear();
  }

  /// الحصول على حجم الذاكرة المؤقتة
  static int getCacheSize() {
    return _cache.length;
  }
} 