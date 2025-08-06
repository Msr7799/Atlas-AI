import 'package:flutter/material.dart';
import '../../data/models/message_model.dart';
import '../../core/services/chat_export_service.dart';

class ChatSelectionProvider extends ChangeNotifier {
  bool _isSelectionMode = false;
  final Set<String> _selectedMessageIds = {};
  final Map<String, List<MessageModel>> _availableChats = {};

  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedMessageIds => Set.from(_selectedMessageIds);
  int get selectedCount => _selectedMessageIds.length;
  bool get hasSelection => _selectedMessageIds.isNotEmpty;
  Map<String, List<MessageModel>> get availableChats =>
      Map.from(_availableChats);

  /// تفعيل/إلغاء وضع التحديد
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedMessageIds.clear();
    }
    notifyListeners();
  }

  /// تفعيل وضع التحديد
  void enableSelectionMode() {
    _isSelectionMode = true;
    notifyListeners();
  }

  /// إلغاء وضع التحديد
  void disableSelectionMode() {
    _isSelectionMode = false;
    _selectedMessageIds.clear();
    notifyListeners();
  }

  /// تحديد/إلغاء تحديد رسالة
  void selectMessage(String messageId) {
    if (_selectedMessageIds.contains(messageId)) {
      _selectedMessageIds.remove(messageId);
    } else {
      _selectedMessageIds.add(messageId);
    }
    notifyListeners();
  }

  /// إلغاء تحديد رسالة
  void deselectMessage(String messageId) {
    _selectedMessageIds.remove(messageId);
    notifyListeners();
  }

  /// تبديل تحديد رسالة
  void toggleMessageSelection(String messageId) {
    if (_selectedMessageIds.contains(messageId)) {
      _selectedMessageIds.remove(messageId);
    } else {
      _selectedMessageIds.add(messageId);
    }
    notifyListeners();
  }

  /// تحديد جميع الرسائل
  void selectAllMessages(List<MessageModel> messages) {
    _selectedMessageIds.addAll(messages.map((m) => m.id));
    notifyListeners();
  }

  /// إلغاء تحديد جميع الرسائل
  void deselectAllMessages() {
    _selectedMessageIds.clear();
    notifyListeners();
  }

  /// فحص ما إذا كانت الرسالة محددة
  bool isMessageSelected(String messageId) {
    return _selectedMessageIds.contains(messageId);
  }

  /// الحصول على الرسائل المحددة
  List<MessageModel> getSelectedMessages(List<MessageModel> allMessages) {
    return allMessages
        .where((m) => _selectedMessageIds.contains(m.id))
        .toList();
  }

  /// تحديث المحادثات المتاحة
  void updateAvailableChats(Map<String, List<MessageModel>> chats) {
    _availableChats.clear();
    _availableChats.addAll(chats);
    notifyListeners();
  }

  /// إضافة محادثة جديدة
  void addChat(String chatId, List<MessageModel> messages) {
    _availableChats[chatId] = messages;
    notifyListeners();
  }

  /// تصدير الرسائل المحددة
  Future<String> exportSelectedMessages({
    required List<MessageModel> allMessages,
    required String chatTitle,
    String format = 'json',
  }) async {
    final selectedMessages = getSelectedMessages(allMessages);
    if (selectedMessages.isEmpty) {
      throw Exception('لم يتم تحديد أي رسائل للتصدير');
    }

    return await ChatExportService.exportSingleChat(
      messages: selectedMessages,
      chatTitle: '$chatTitle (رسائل محددة)',
      format: format,
    );
  }

  /// تصدير محادثة كاملة
  Future<String> exportFullChat({
    required List<MessageModel> messages,
    required String chatTitle,
    String format = 'json',
  }) async {
    return await ChatExportService.exportSingleChat(
      messages: messages,
      chatTitle: chatTitle,
      format: format,
    );
  }

  /// تصدير جميع المحادثات
  Future<String> exportAllChats({String format = 'json'}) async {
    if (_availableChats.isEmpty) {
      throw Exception('لا توجد محادثات للتصدير');
    }

    return await ChatExportService.exportMultipleChats(
      chats: _availableChats,
      format: format,
    );
  }

  /// حفظ المحادثة في ملف
  Future<String> saveToFile({
    required String content,
    required String filename,
    String format = 'json',
  }) async {
    return await ChatExportService.saveToFile(
      content: content,
      filename: filename,
      format: format,
    );
  }

  /// مشاركة المحادثة
  Future<void> shareChat({
    required String content,
    required String filename,
    String format = 'json',
  }) async {
    await ChatExportService.shareChat(
      content: content,
      filename: filename,
      format: format,
    );
  }

  /// الحصول على إحصائيات الرسائل المحددة
  Map<String, dynamic> getSelectedMessagesStats(
    List<MessageModel> allMessages,
  ) {
    final selectedMessages = getSelectedMessages(allMessages);
    return ChatExportService.analyzeChat(selectedMessages);
  }

  /// الحصول على إحصائيات محادثة كاملة
  Map<String, dynamic> getChatStats(List<MessageModel> messages) {
    return ChatExportService.analyzeChat(messages);
  }
}
