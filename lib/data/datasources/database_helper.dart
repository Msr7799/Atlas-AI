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
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'chat_history.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
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
    await db.execute('CREATE INDEX idx_messages_session_id ON messages(session_id)');
    await db.execute('CREATE INDEX idx_messages_timestamp ON messages(timestamp)');
    await db.execute('CREATE INDEX idx_message_history_session_id ON message_history(session_id)');
    await db.execute('CREATE INDEX idx_message_history_created_at ON message_history(created_at)');
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
        createdAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['created_at'] as int),
        updatedAt: DateTime.fromMillisecondsSinceEpoch(maps[i]['updated_at'] as int),
        messages: [], // Will be loaded separately when needed
      );
    });
  }

  Future<void> updateChatSession(String sessionId, String title) async {
    final db = await database;
    await db.update(
      'chat_sessions',
      {
        'title': title,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<void> deleteChatSession(String sessionId) async {
    final db = await database;
    await db.delete(
      'chat_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
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
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );

    List<MessageModel> messages = [];
    for (final map in maps) {
      // Get attachments for this message
      final attachmentMaps = await db.query(
        'attachments',
        where: 'message_id = ?',
        whereArgs: [map['id']],
      );

      List<AttachmentModel>? attachments;
      if (attachmentMaps.isNotEmpty) {
        attachments = attachmentMaps.map((attachmentMap) {
          return AttachmentModel(
            id: attachmentMap['id'] as String,
            name: attachmentMap['name'] as String,
            type: attachmentMap['type'] as String,
            size: attachmentMap['size'] as int,
            path: attachmentMap['path'] as String,
            uploadedAt: DateTime.fromMillisecondsSinceEpoch(attachmentMap['uploaded_at'] as int),
          );
        }).toList();
      }

      messages.add(MessageModel(
        id: map['id'] as String,
        content: map['content'] as String,
        role: MessageRole.values.firstWhere((e) => e.name == (map['role'] as String)),
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        status: MessageStatus.values.firstWhere((e) => e.name == (map['status'] as String)),
        attachments: attachments,
      ));
    }

    return messages;
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
