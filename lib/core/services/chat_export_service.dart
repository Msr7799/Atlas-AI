import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/message_model.dart';

class ChatExportService {
  /// تصدير محادثة واحدة
  static Future<String> exportSingleChat({
    required List<MessageModel> messages,
    required String chatTitle,
    String format = 'json',
  }) async {
    final timestamp = DateTime.now().toIso8601String();

    final chatData = {
      'export_info': {
        'title': chatTitle,
        'exported_at': timestamp,
        'message_count': messages.length,
        'format_version': '1.0',
      },
      'messages': messages
          .map(
            (msg) => {
              'id': msg.id,
              'role': msg.role.name,
              'content': msg.content,
              'timestamp': msg.timestamp.toIso8601String(),
              'has_attachments': msg.attachments?.isNotEmpty ?? false,
              'thinking_process': msg.thinkingProcess?.toJson(),
            },
          )
          .toList(),
    };

    switch (format.toLowerCase()) {
      case 'json':
        return _formatAsJson(chatData);
      case 'txt':
        return _formatAsText(chatData);
      case 'markdown':
        return _formatAsMarkdown(chatData);
      default:
        return _formatAsJson(chatData);
    }
  }

  /// تصدير محادثات متعددة
  static Future<String> exportMultipleChats({
    required Map<String, List<MessageModel>> chats,
    String format = 'json',
  }) async {
    final timestamp = DateTime.now().toIso8601String();

    final exportData = {
      'export_info': {
        'exported_at': timestamp,
        'chat_count': chats.length,
        'total_messages': chats.values.fold(
          0,
          (sum, messages) => sum + messages.length,
        ),
        'format_version': '1.0',
      },
      'chats': chats.entries
          .map(
            (entry) => {
              'title': entry.key,
              'message_count': entry.value.length,
              'messages': entry.value
                  .map(
                    (msg) => {
                      'id': msg.id,
                      'role': msg.role.name,
                      'content': msg.content,
                      'timestamp': msg.timestamp.toIso8601String(),
                      'has_attachments': msg.attachments?.isNotEmpty ?? false,
                      'thinking_process': msg.thinkingProcess?.toJson(),
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
    };

    switch (format.toLowerCase()) {
      case 'json':
        return _formatAsJson(exportData);
      case 'txt':
        return _formatAsTextMultiple(exportData);
      case 'markdown':
        return _formatAsMarkdownMultiple(exportData);
      default:
        return _formatAsJson(exportData);
    }
  }

  /// حفظ المحادثة في ملف محلي
  static Future<String> saveToFile({
    required String content,
    required String filename,
    String format = 'json',
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _getFileExtension(format);
      final fullFilename = '${filename}_$timestamp.$extension';

      final file = File('${directory.path}/$fullFilename');
      await file.writeAsString(content, encoding: utf8);

      return file.path;
    } catch (e) {
      throw Exception('فشل في حفظ الملف: $e');
    }
  }

  /// مشاركة المحادثة
  static Future<void> shareChat({
    required String content,
    required String filename,
    String format = 'json',
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _getFileExtension(format);
      final fullFilename = '${filename}_$timestamp.$extension';

      final file = File('${tempDir.path}/$fullFilename');
      await file.writeAsString(content, encoding: utf8);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'محادثة مُصدرة من العميل العربي الذكي');
    } catch (e) {
      throw Exception('فشل في مشاركة الملف: $e');
    }
  }

  // التنسيقات المختلفة
  static String _formatAsJson(Map<String, dynamic> data) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  static String _formatAsText(Map<String, dynamic> chatData) {
    final buffer = StringBuffer();
    final exportInfo = chatData['export_info'] as Map<String, dynamic>;
    final messages = chatData['messages'] as List<dynamic>;

    buffer.writeln('=====================================================');
    buffer.writeln('          تصدير محادثة - العميل العربي الذكي');
    buffer.writeln('=====================================================');
    buffer.writeln('العنوان: ${exportInfo['title']}');
    buffer.writeln('تاريخ التصدير: ${exportInfo['exported_at']}');
    buffer.writeln('عدد الرسائل: ${exportInfo['message_count']}');
    buffer.writeln('=====================================================\n');

    for (final msg in messages) {
      final role = msg['role'] == 'user' ? 'المستخدم' : 'المساعد';
      final timestamp = DateTime.parse(msg['timestamp']).toLocal();

      buffer.writeln('[$role] - ${timestamp.toString().substring(0, 19)}');
      buffer.writeln('${msg['content']}\n');

      if (msg['thinking_process'] != null) {
        buffer.writeln('--- عملية التفكير ---');
        buffer.writeln('${msg['thinking_process']}\n');
      }

      buffer.writeln('-----------------------------------------------------\n');
    }

    return buffer.toString();
  }

  static String _formatAsMarkdown(Map<String, dynamic> chatData) {
    final buffer = StringBuffer();
    final exportInfo = chatData['export_info'] as Map<String, dynamic>;
    final messages = chatData['messages'] as List<dynamic>;

    buffer.writeln('# محادثة مُصدرة - العميل العربي الذكي\n');
    buffer.writeln('**العنوان:** ${exportInfo['title']}  ');
    buffer.writeln('**تاريخ التصدير:** ${exportInfo['exported_at']}  ');
    buffer.writeln('**عدد الرسائل:** ${exportInfo['message_count']}\n');
    buffer.writeln('---\n');

    for (final msg in messages) {
      final role = msg['role'] == 'user' ? 'المستخدم' : 'المساعد';
      final timestamp = DateTime.parse(msg['timestamp']).toLocal();

      buffer.writeln('## $role');
      buffer.writeln('*${timestamp.toString().substring(0, 19)}*\n');
      buffer.writeln('${msg['content']}\n');

      if (msg['thinking_process'] != null) {
        buffer.writeln('### عملية التفكير');
        buffer.writeln('```');
        buffer.writeln('${msg['thinking_process']}');
        buffer.writeln('```\n');
      }

      buffer.writeln('---\n');
    }

    return buffer.toString();
  }

  static String _formatAsTextMultiple(Map<String, dynamic> exportData) {
    final buffer = StringBuffer();
    final exportInfo = exportData['export_info'] as Map<String, dynamic>;
    final chats = exportData['chats'] as List<dynamic>;

    buffer.writeln('=====================================================');
    buffer.writeln('       تصدير محادثات متعددة - العميل العربي الذكي');
    buffer.writeln('=====================================================');
    buffer.writeln('تاريخ التصدير: ${exportInfo['exported_at']}');
    buffer.writeln('عدد المحادثات: ${exportInfo['chat_count']}');
    buffer.writeln('إجمالي الرسائل: ${exportInfo['total_messages']}');
    buffer.writeln('=====================================================\n\n');

    for (int chatIndex = 0; chatIndex < chats.length; chatIndex++) {
      final chat = chats[chatIndex];
      buffer.writeln('📝 محادثة ${chatIndex + 1}: ${chat['title']}');
      buffer.writeln('عدد الرسائل: ${chat['message_count']}');
      buffer.writeln('═══════════════════════════════════════════════════\n');

      final messages = chat['messages'] as List<dynamic>;
      for (final msg in messages) {
        final role = msg['role'] == 'user' ? 'المستخدم' : 'المساعد';
        final timestamp = DateTime.parse(msg['timestamp']).toLocal();

        buffer.writeln('[$role] - ${timestamp.toString().substring(0, 19)}');
        buffer.writeln('${msg['content']}\n');
        buffer.writeln(
          '-----------------------------------------------------\n',
        );
      }

      buffer.writeln('\n\n');
    }

    return buffer.toString();
  }

  static String _formatAsMarkdownMultiple(Map<String, dynamic> exportData) {
    final buffer = StringBuffer();
    final exportInfo = exportData['export_info'] as Map<String, dynamic>;
    final chats = exportData['chats'] as List<dynamic>;

    buffer.writeln('# محادثات مُصدرة - العميل العربي الذكي\n');
    buffer.writeln('**تاريخ التصدير:** ${exportInfo['exported_at']}  ');
    buffer.writeln('**عدد المحادثات:** ${exportInfo['chat_count']}  ');
    buffer.writeln('**إجمالي الرسائل:** ${exportInfo['total_messages']}\n');
    buffer.writeln('---\n');

    for (int chatIndex = 0; chatIndex < chats.length; chatIndex++) {
      final chat = chats[chatIndex];
      buffer.writeln('# محادثة ${chatIndex + 1}: ${chat['title']}\n');
      buffer.writeln('**عدد الرسائل:** ${chat['message_count']}\n');

      final messages = chat['messages'] as List<dynamic>;
      for (final msg in messages) {
        final role = msg['role'] == 'user' ? 'المستخدم' : 'المساعد';
        final timestamp = DateTime.parse(msg['timestamp']).toLocal();

        buffer.writeln('## $role');
        buffer.writeln('*${timestamp.toString().substring(0, 19)}*\n');
        buffer.writeln('${msg['content']}\n');
        buffer.writeln('---\n');
      }

      buffer.writeln('\n');
    }

    return buffer.toString();
  }

  static String _getFileExtension(String format) {
    switch (format.toLowerCase()) {
      case 'json':
        return 'json';
      case 'txt':
        return 'txt';
      case 'markdown':
      case 'md':
        return 'md';
      default:
        return 'json';
    }
  }

  /// تحليل إحصائيات المحادثة
  static Map<String, dynamic> analyzeChat(List<MessageModel> messages) {
    final userMessages = messages
        .where((m) => m.role == MessageRole.user)
        .length;
    final assistantMessages = messages
        .where((m) => m.role == MessageRole.assistant)
        .length;
    final totalChars = messages.fold(0, (sum, m) => sum + m.content.length);
    final avgMessageLength = messages.isNotEmpty
        ? totalChars / messages.length
        : 0;

    final firstMessage = messages.isNotEmpty
        ? messages.first.timestamp
        : DateTime.now();
    final lastMessage = messages.isNotEmpty
        ? messages.last.timestamp
        : DateTime.now();
    final duration = lastMessage.difference(firstMessage);

    return {
      'total_messages': messages.length,
      'user_messages': userMessages,
      'assistant_messages': assistantMessages,
      'total_characters': totalChars,
      'average_message_length': avgMessageLength.round(),
      'chat_duration_minutes': duration.inMinutes,
      'first_message': firstMessage.toIso8601String(),
      'last_message': lastMessage.toIso8601String(),
    };
  }
}
