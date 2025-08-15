import 'dart:async';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/message_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal() {
    // Initialize database factory for Linux/Desktop platforms
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      databaseFactory = databaseFactoryFfi;
    }
  }

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // استخدام مجلد المشروع بدلاً من Documents
    String currentDir = Directory.current.path;
    String dbDir = join(currentDir, 'lib', 'data', 'datasources');
    
    // التأكد من وجود المجلد
    Directory(dbDir).createSync(recursive: true);
    
    String path = join(dbDir, 'chat_history.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create chat_sessions table
    await db.execute('''
      CREATE TABLE chat_sessions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        settings TEXT
      )
    ''');

    // Create messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        content TEXT NOT NULL,
        role TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        status TEXT DEFAULT 'sent',
        metadata TEXT,
        FOREIGN KEY (session_id) REFERENCES chat_sessions (id) ON DELETE CASCADE
      )
    ''');

    // Create message_history table for input history per session
    await db.execute('''
      CREATE TABLE message_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        input_text TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (session_id) REFERENCES chat_sessions (id) ON DELETE CASCADE
      )
    ''');

    // Create attachments table
    await db.execute('''
      CREATE TABLE attachments (
        id TEXT PRIMARY KEY,
        message_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        size INTEGER NOT NULL,
        path TEXT NOT NULL,
        uploaded_at INTEGER NOT NULL,
        FOREIGN KEY (message_id) REFERENCES messages (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_messages_session_id ON messages(session_id)',
    );
    await db.execute(
      'CREATE INDEX idx_messages_timestamp ON messages(timestamp)',
    );
    await db.execute(
      'CREATE INDEX idx_message_history_session_id ON message_history(session_id)',
    );
    await db.execute(
      'CREATE INDEX idx_message_history_created_at ON message_history(created_at)',
    );
  }

  // Chat Sessions Methods
  Future<String> createChatSession(String title) async {
    final db = await database;
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert('chat_sessions', {
      'id': sessionId,
      'title': title,
      'created_at': now,
      'updated_at': now,
    });

    return sessionId;
  }

  Future<List<ChatSessionModel>> getAllChatSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chat_sessions',
      orderBy: 'updated_at DESC',
    );

    return List.generate(maps.length, (i) {
      return ChatSessionModel(
        id: maps[i]['id'] as String,
        title: maps[i]['title'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          maps[i]['created_at'] as int,
        ),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(
          maps[i]['updated_at'] as int,
        ),
        messages: [], // Will be loaded separately when needed
      );
    });
  }

  Future<void> updateChatSession(String sessionId, String title) async {
    final db = await database;
    await db.update(
      'chat_sessions',
      {'title': title, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> deleteChatSession(String sessionId) async {
    final db = await database;
    await db.delete('chat_sessions', where: 'id = ?', whereArgs: [sessionId]);
  }

  // Messages Methods
  Future<void> insertMessage(MessageModel message, String sessionId) async {
    final db = await database;

    await db.insert('messages', {
      'id': message.id,
      'session_id': sessionId,
      'content': message.content,
      'role': message.role.name,
      'timestamp': message.timestamp.millisecondsSinceEpoch,
      'status': message.status.name,
      'metadata': message.metadata?.toString(),
    });

    // Insert attachments if any
    if (message.attachments != null) {
      for (final attachment in message.attachments!) {
        await db.insert('attachments', {
          'id': attachment.id,
          'message_id': message.id,
          'name': attachment.name,
          'type': attachment.type,
          'size': attachment.size,
          'path': attachment.path,
          'uploaded_at': attachment.uploadedAt.millisecondsSinceEpoch,
        });
      }
    }

    // Update session's updated_at
    await db.update(
      'chat_sessions',
      {'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<List<MessageModel>> getMessagesForSession(String sessionId) async {
    final db = await database;
    
    // 🚀 تحسين الأداء: استخدام JOIN بدلاً من N+1 queries
    // جلب الرسائل مع المرفقات في استعلام واحد محسن
    final List<Map<String, dynamic>> joinedMaps = await db.rawQuery('''
      SELECT 
        m.id as message_id,
        m.content as message_content,
        m.role as message_role,
        m.timestamp as message_timestamp,
        m.status as message_status,
        a.id as attachment_id,
        a.name as attachment_name,
        a.type as attachment_type,
        a.size as attachment_size,
        a.path as attachment_path,
        a.uploaded_at as attachment_uploaded_at
      FROM messages m
      LEFT JOIN attachments a ON m.id = a.message_id
      WHERE m.session_id = ?
      ORDER BY m.timestamp ASC, a.uploaded_at ASC
    ''', [sessionId]);

    // تجميع النتائج - كل رسالة مع مرفقاتها
    final Map<String, MessageModel> messagesMap = {};
    
    for (final row in joinedMaps) {
      final messageId = row['message_id'] as String;
      
      // إنشاء الرسالة إذا لم تكن موجودة
      if (!messagesMap.containsKey(messageId)) {
        messagesMap[messageId] = MessageModel(
          id: messageId,
          content: row['message_content'] as String,
          role: MessageRole.values.firstWhere(
            (e) => e.name == (row['message_role'] as String),
          ),
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            row['message_timestamp'] as int,
          ),
          status: MessageStatus.values.firstWhere(
            (e) => e.name == (row['message_status'] as String),
          ),
          attachments: [],
        );
      }
      
      // إضافة المرفق إذا كان موجوداً
      final attachmentId = row['attachment_id'] as String?;
      if (attachmentId != null) {
        final attachment = AttachmentModel(
          id: attachmentId,
          name: row['attachment_name'] as String,
          type: row['attachment_type'] as String,
          size: row['attachment_size'] as int,
          path: row['attachment_path'] as String,
          uploadedAt: DateTime.fromMillisecondsSinceEpoch(
            row['attachment_uploaded_at'] as int,
          ),
        );
        
        // تجنب المرفقات المكررة
        final currentAttachments = messagesMap[messageId]!.attachments ?? [];
        if (!currentAttachments.any((a) => a.id == attachmentId)) {
          messagesMap[messageId] = messagesMap[messageId]!.copyWith(
            attachments: [...currentAttachments, attachment],
          );
        }
      }
    }

    // ترتيب الرسائل حسب التوقيت وإرجاعها كقائمة
    final messagesList = messagesMap.values.toList();
    messagesList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    print('🚀 [DB_PERFORMANCE] تم تحميل ${messagesList.length} رسالة مع المرفقات في استعلام واحد محسن');
    return messagesList;
  }

  // Message History Methods (for input history per session)
  Future<void> addToMessageHistory(String sessionId, String inputText) async {
    final db = await database;

    // Check if this input already exists in history for this session
    final existing = await db.query(
      'message_history',
      where: 'session_id = ? AND input_text = ?',
      whereArgs: [sessionId, inputText],
    );

    if (existing.isEmpty) {
      await db.insert('message_history', {
        'session_id': sessionId,
        'input_text': inputText,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Keep only last 50 entries per session
      final allHistory = await db.query(
        'message_history',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'created_at DESC',
      );

      if (allHistory.length > 50) {
        final idsToDelete = allHistory.skip(50).map((e) => e['id']).toList();
        await db.delete(
          'message_history',
          where: 'id IN (${idsToDelete.map((_) => '?').join(',')})',
          whereArgs: idsToDelete,
        );
      }
    }
  }

  Future<List<String>> getMessageHistory(String sessionId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'message_history',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at DESC',
      limit: 50,
    );

    return maps.map((map) => map['input_text'] as String).toList();
  }

  Future<void> clearMessageHistory(String sessionId) async {
    final db = await database;
    await db.delete(
      'message_history',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );
  }

  // حذف جميع رسائل جلسة معينة مع الإبقاء على الجلسة نفسها
  Future<void> deleteMessagesForSession(String sessionId) async {
    final db = await database;
    await db.delete(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
    );

    // تحديث وقت آخر تعديل للجلسة
    await db.update(
      'chat_sessions',
      {'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // Utility Methods
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<void> deleteDatabaseFile() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'chat_history.db');
    await databaseFactory.deleteDatabase(path);
  }
}
