import '../datasources/database_helper.dart';
import '../models/message_model.dart';

class ChatRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Session Management
  Future<String> createNewSession([String? title]) async {
    final sessionTitle = title ?? 'محادثة جديدة ${DateTime.now().day}/${DateTime.now().month}';
    return await _databaseHelper.createChatSession(sessionTitle);
  }

  Future<List<ChatSessionModel>> getAllSessions() async {
    return await _databaseHelper.getAllChatSessions();
  }

  Future<void> updateSessionTitle(String sessionId, String title) async {
    await _databaseHelper.updateChatSession(sessionId, title);
  }

  Future<void> deleteSession(String sessionId) async {
    await _databaseHelper.deleteChatSession(sessionId);
  }

  // Message Management
  Future<void> saveMessage(MessageModel message, String sessionId) async {
    await _databaseHelper.insertMessage(message, sessionId);
  }

  Future<List<MessageModel>> getSessionMessages(String sessionId) async {
    return await _databaseHelper.getMessagesForSession(sessionId);
  }

  // Message History Management (for input history)
  Future<void> addToInputHistory(String sessionId, String inputText) async {
    if (inputText.trim().isNotEmpty) {
      await _databaseHelper.addToMessageHistory(sessionId, inputText.trim());
    }
  }

  Future<List<String>> getInputHistory(String sessionId) async {
    return await _databaseHelper.getMessageHistory(sessionId);
  }

  Future<void> clearInputHistory(String sessionId) async {
    await _databaseHelper.clearMessageHistory(sessionId);
  }

  // Utility Methods
  Future<void> closeDatabase() async {
    await _databaseHelper.close();
  }

  Future<void> deleteAllData() async {
    await _databaseHelper.deleteDatabaseFile();
  }
}
