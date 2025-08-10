import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../data/models/message_model.dart';
import '../providers/chat_selection_provider.dart';
import 'thinking_process_widget.dart';



class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isUser;

  const MessageBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ChatSelectionProvider>(
      builder: (context, selectionProvider, child) {
        final isSelected = selectionProvider.selectedMessageIds.contains(
          message.id,
        );
        final isSelectionMode = selectionProvider.isSelectionMode;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selection checkbox - يظهر في وضع التحديد فقط
              if (isSelectionMode)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: GestureDetector(
                    onTap: () {
                      selectionProvider.selectMessage(message.id);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: theme.colorScheme.onPrimary,
                            )
                          : null,
                    ),
                  ),
                ),

              if (!isUser) _buildAvatar(context),
              if (!isUser) const SizedBox(width: 8),

              Expanded(
                child: GestureDetector(
                  // الضغط الطويل لتفعيل وضع التحديد
                  onLongPress: () {
                    if (!isSelectionMode) {
                      selectionProvider.toggleSelectionMode();
                    }
                    selectionProvider.selectMessage(message.id);
                  },
                  // النقر العادي فقط في وضع التحديد
                  onTap: isSelectionMode
                      ? () => selectionProvider.selectMessage(message.id)
                      : null,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      border: !isUser
                          ? Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Message content - مع دعم الاتجاه التلقائي
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildMessageContent(
                            message.content,
                            theme,
                            isUser,
                            context,
                          ),
                        ),

                        // Thinking Process - عرض عملية التفكير (مفتوح بشكل افتراضي)
                        if (!isUser && message.thinkingProcess != null)
                          ThinkingProcessWidget(
                            thinkingProcess: message.thinkingProcess!,
                            isExpanded: true, // ✅ مفتوح بشكل افتراضي ليراه المستخدم
                            onToggleExpanded: () {
                              // يمكن إضافة منطق للتحكم في التوسيع/الطي هنا
                            },
                          ),

                        // Copy button
                        if (!isSelectionMode)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: isUser
                                        ? theme.colorScheme.onPrimary
                                              .withOpacity(0.7)
                                        : theme.colorScheme.onSurface
                                              .withOpacity(0.7),
                                  ),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: message.content),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('تم نسخ النص'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  tooltip: 'نسخ النص',
                                ),
                                Text(
                                  _formatTime(message.timestamp),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isUser
                                        ? theme.colorScheme.onPrimary
                                              .withOpacity(0.7)
                                        : theme.colorScheme.onSurface
                                              .withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              if (isUser) const SizedBox(width: 8),
              if (isUser) _buildAvatar(context),
            ],
          ),
        );
      },
    );
  }

  // بناء محتوى الرسالة مع دعم Markdown الكامل
  Widget _buildMessageContent(String content, ThemeData theme, bool isUser, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
  
    // تطبيق الخوارزميات الذكية لتحسين المحتوى
    final processedContent = _applySmartFormatting(content, isUser);
  
    // التحقق من وجود code blocks وفصلها عن النص العادي
    final codeBlockRegex = RegExp(r'```(\w+)?\s*\n?([\s\S]*?)```', multiLine: true);
    final matches = codeBlockRegex.allMatches(processedContent).toList();
  
    if (matches.isEmpty) {
      // لا يوجد كود - استخدام Markdown عادي
      return Directionality(
        textDirection: _detectTextDirection(processedContent),
        child: MarkdownBody(
          data: processedContent,
          selectable: true,
          shrinkWrap: true,
          fitContent: true,
          styleSheet: _buildMarkdownStyleSheet(theme, isUser, isTablet, processedContent),
          onTapLink: (text, href, title) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم النقر على الرابط: $href'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      );
    }
    
    // يوجد كود - بناء layout مخصص
    List<Widget> widgets = [];
    int lastMatchEnd = 0;
    
    for (final match in matches) {
      // إضافة النص قبل الكود
      if (match.start > lastMatchEnd) {
        final textBefore = processedContent.substring(lastMatchEnd, match.start).trim();
        if (textBefore.isNotEmpty) {
          widgets.add(
            Directionality(
              textDirection: _detectTextDirection(textBefore),
              child: MarkdownBody(
                data: textBefore,
                selectable: true,
                shrinkWrap: true,
                fitContent: true,
                styleSheet: _buildMarkdownStyleSheet(theme, isUser, isTablet, textBefore),
              ),
            ),
          );
          widgets.add(SizedBox(height: isTablet ? 12 : 8));
        }
      }
      
      // إضافة code block مخصص
      final language = match.group(1)?.toLowerCase() ?? 'code';
      final codeContent = match.group(2) ?? '';
      
      widgets.add(_buildCustomCodeBlock(codeContent, language, isTablet, context));
      widgets.add(SizedBox(height: isTablet ? 12 : 8));
      
      lastMatchEnd = match.end;
    }
    
    // إضافة النص المتبقي بعد آخر كود
    if (lastMatchEnd < processedContent.length) {
      final textAfter = processedContent.substring(lastMatchEnd).trim();
      if (textAfter.isNotEmpty) {
        widgets.add(
          Directionality(
            textDirection: _detectTextDirection(textAfter),
            child: MarkdownBody(
              data: textAfter,
              selectable: true,
              shrinkWrap: true,
              fitContent: true,
              styleSheet: _buildMarkdownStyleSheet(theme, isUser, isTablet, textAfter),
            ),
          ),
        );
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  // بناء Markdown StyleSheet
  MarkdownStyleSheet _buildMarkdownStyleSheet(ThemeData theme, bool isUser, bool isTablet, String content) {
    return MarkdownStyleSheet(
          // النصوص العامة
          p: TextStyle(
            color: isUser 
                ? (theme.colorScheme.primary.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white)
                : theme.colorScheme.onSurface,
            fontSize: isTablet ? 18 : 16,
            height: 1.4,
            fontFamily: _containsArabic(content) ? 'Cairo' : null,
          ),
          // العناوين
          h1: TextStyle(
            color: isUser 
                ? (theme.colorScheme.primary.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white)
                : theme.colorScheme.onSurface,
            fontSize: isTablet ? 28 : 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
            fontFamily: _containsArabic(content) ? 'Cairo' : null,
          ),
          h2: TextStyle(
            color: isUser 
                ? (theme.colorScheme.primary.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white)
                : theme.colorScheme.onSurface,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            height: 1.3,
            fontFamily: _containsArabic(content) ? 'Cairo' : null,
          ),
          h3: TextStyle(
            color: isUser 
                ? (theme.colorScheme.primary.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white)
                : theme.colorScheme.onSurface,
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.bold,
            height: 1.3,
            fontFamily: _containsArabic(content) ? 'Cairo' : null,
          ),
          // القوائم
          listBullet: TextStyle(
            color: isUser 
                ? (theme.colorScheme.primary.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white)
                : theme.colorScheme.onSurface,
            fontSize: isTablet ? 18 : 16,
            fontFamily: _containsArabic(content) ? 'Cairo' : null,
          ),
          // الروابط
          a: TextStyle(
            color: theme.colorScheme.primary,
            decoration: TextDecoration.underline,
            fontSize: isTablet ? 18 : 16,
          ),
          // النص العريض والمائل
          strong: TextStyle(
            color: isUser 
                ? (theme.colorScheme.primary.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white)
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 18 : 16,
            fontFamily: _containsArabic(content) ? 'Cairo' : null,
          ),
          em: TextStyle(
            color: isUser 
                ? (theme.colorScheme.primary.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white)
                : theme.colorScheme.onSurface,
            fontStyle: FontStyle.italic,
            fontSize: isTablet ? 18 : 16,
            fontFamily: _containsArabic(content) ? 'Cairo' : null,
          ),
          // الاقتباسات
          blockquote: TextStyle(
            color: (isUser 
                ? (theme.colorScheme.primary.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white)
                : theme.colorScheme.onSurface).withOpacity(0.8),
            fontSize: isTablet ? 17 : 15,
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
          blockquoteDecoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border(
              left: BorderSide(
                color: theme.colorScheme.primary,
                width: 4,
              ),
            ),
          ),
          // الكود المضمن
          code: TextStyle(
            fontFamily: 'Courier',
            fontSize: isTablet ? 16 : 14,
            color: isUser 
                ? (theme.colorScheme.primary.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white)
                : theme.colorScheme.primary,
            height: 1.2,
            decoration: TextDecoration.none,
          ),
          // الجداول
          tableHead: TextStyle(
            color: isUser 
                ? (theme.colorScheme.primary.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white)
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 16 : 14,
          ),
          tableBody: TextStyle(
            color: isUser 
                ? (theme.colorScheme.primary.computeLuminance() > 0.5 
                    ? Colors.black 
                    : Colors.white)
                : theme.colorScheme.onSurface,
            fontSize: isTablet ? 16 : 14,
          ),
          tableBorder: TableBorder.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
          tableCellsPadding: EdgeInsets.all(isTablet ? 12 : 8),
        );
  }

  // بناء code block مخصص مثل ChatGPT
  // قائمة باللغات المدعومة
  static const Set<String> supportedLanguages = {
    'python', 'py', 'javascript', 'js', 'dart', 'java', 'cpp', 'c++', 'c',
    'html', 'css', 'json', 'xml', 'yaml', 'yml', 'sql', 'php', 'ruby',
    'go', 'rust', 'swift', 'kotlin', 'typescript', 'ts', 'bash', 'sh',
    'shell', 'powershell', 'cmd', 'batch', 'dockerfile', 'makefile',
    'perl', 'scala', 'r', 'matlab', 'latex', 'markdown', 'md'
  };

  // أنماط ثابتة لكشف Shell/Bash Commands
  static const List<String> shellCommands = [
    'cd', 'ls', 'mkdir', 'touch', 'rm', 'cp', 'mv', 'pwd', 'echo', 'cat',
    'grep', 'find', 'chmod', 'chown', 'sudo', 'apt', 'apt-get', 'yum',
    'npm', 'pip', 'git', 'docker', 'curl', 'wget', 'tar', 'unzip',
    'ps', 'kill', 'killall', 'top', 'htop', 'df', 'du', 'mount', 'umount'
  ];

  // أنماط ثابتة لكشف Python
  static const List<String> pythonKeywords = [
    'def ', 'class ', 'import ', 'from ', 'print(', 'if __name__',
    'try:', 'except:', 'finally:', 'with ', 'async def', 'await '
  ];

  // لغة افتراضية للكود غير المحدد
  static const String defaultCodeLanguage = 'bash';

  // خوارزميات ذكية لتحسين عرض ردود النماذج
  String _applySmartFormatting(String content, bool isUser) {
    // إذا كان من المستخدم، لا نحتاج تنسيق إضافي
    if (isUser) return content;
    
    String processedContent = content;
    
    // 1. تحسين تنسيق القوائم والأرقام
    processedContent = _enhanceListFormatting(processedContent);
    
    // 2. تحسين عرض الكود غير المنسق
    processedContent = _enhanceCodeFormatting(processedContent);
    
    // 3. تحسين تنسيق العناوين
    processedContent = _enhanceHeaderFormatting(processedContent);
    
    // 4. تحسين تنسيق الروابط والمراجع
    processedContent = _enhanceLinkFormatting(processedContent);
    
    // 5. إضافة فواصل منطقية بين الأقسام
    processedContent = _addLogicalSeparators(processedContent);
    
    // 6. تحسين عرض الأمثلة والتفسيرات
    processedContent = _enhanceExampleFormatting(processedContent);
    
    return processedContent;
  }

  // تحسين تنسيق القوائم
  String _enhanceListFormatting(String content) {
    String result = content;
    
    // تحويل القوائم المرقمة البسيطة إلى markdown منسق
    result = result.replaceAllMapped(
      RegExp(r'^(\d+)[\.\)][\s]*(.+)$', multiLine: true),
      (match) => '${match.group(1)}. **${match.group(2)}**'
    );
    
    // تحسين القوائم النقطية
    result = result.replaceAllMapped(
      RegExp(r'^[-\*\+][\s]*(.+)$', multiLine: true),
      (match) => '- **${match.group(1)}**'
    );
    
    return result;
  }

  // تحسين عرض الكود غير المنسق
  String _enhanceCodeFormatting(String content) {
    String result = content;
    
    // البحث عن أسطر تبدو كأكواد ولكن ليست في code blocks
    final lines = result.split('\n');
    final List<String> processedLines = [];
    
    bool inCodeBlock = false;
    List<String> currentCodeLines = [];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmedLine = line.trim();
      
      // تحقق من بداية أو نهاية code block موجود
      if (trimmedLine.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        processedLines.add(line);
        continue;
      }
      
      if (inCodeBlock) {
        processedLines.add(line);
        continue;
      }
      
      // تحقق إذا كان السطر يبدو كأنه كود
      if (_looksLikeCode(trimmedLine) && trimmedLine.isNotEmpty) {
        currentCodeLines.add(line);
      } else {
        // إذا كان لدينا أكواد متراكمة، أضفها كـ code block
        if (currentCodeLines.isNotEmpty) {
          final codeContent = currentCodeLines.join('\n');
          final detectedLanguage = _detectLanguageFromContent(codeContent);
          processedLines.add('```$detectedLanguage');
          processedLines.addAll(currentCodeLines);
          processedLines.add('```');
          currentCodeLines.clear();
        }
        processedLines.add(line);
      }
    }
    
    // معالجة أي كود متبقي في النهاية
    if (currentCodeLines.isNotEmpty) {
      final codeContent = currentCodeLines.join('\n');
      final detectedLanguage = _detectLanguageFromContent(codeContent);
      processedLines.add('```$detectedLanguage');
      processedLines.addAll(currentCodeLines);
      processedLines.add('```');
    }
    
    return processedLines.join('\n');
  }

  // تحديد إذا كان السطر يبدو كأنه كود
  bool _looksLikeCode(String line) {
    if (line.isEmpty) return false;
    
    // أنماط الكود الشائعة
    final codePatterns = [
      // Shell commands
      RegExp(r'^\$\s+\w+'),
      RegExp(r'^(sudo|apt|npm|pip|git|docker|curl|wget)\s+'),
      
      // Programming patterns
      RegExp(r'^(def|class|function|const|let|var|import|from)\s+'),
      RegExp(r'^\s*(if|for|while|try|catch|switch)\s*\('),
      RegExp(r'[{}()\[\];].*[{}()\[\];]'), // Contains multiple brackets/semicolons
      RegExp(r'^\s*[a-zA-Z_]\w*\s*='), // Variable assignment
      RegExp(r'^\s*[a-zA-Z_]\w*\([^)]*\)'), // Function calls
      
      // File paths and commands
      RegExp(r'^/[^\s]*'), // Unix paths
      RegExp(r'^[a-zA-Z]:\\'), // Windows paths
    ];
    
    return codePatterns.any((pattern) => pattern.hasMatch(line));
  }

  // كشف لغة الكود من المحتوى
  String _detectLanguageFromContent(String content) {
    final contentLower = content.toLowerCase();
    
    // Python
    if (pythonKeywords.any((keyword) => contentLower.contains(keyword))) {
      return 'python';
    }
    
    // Shell/Bash
    if (shellCommands.any((cmd) => contentLower.contains('$cmd ')) ||
        content.contains('\$') || content.startsWith('sudo ')) {
      return 'bash';
    }
    
    // JavaScript
    if (contentLower.contains('function ') || contentLower.contains('const ') ||
        contentLower.contains('let ') || contentLower.contains('=>')) {
      return 'javascript';
    }
    
    return defaultCodeLanguage;
  }

  // تحسين تنسيق العناوين
  String _enhanceHeaderFormatting(String content) {
    String result = content;
    
    // البحث عن أسطر تبدو كعناوين وتحويلها إلى markdown headers
    result = result.replaceAllMapped(
      RegExp(r'^([^#\n]+):$', multiLine: true),
      (match) {
        final title = match.group(1)!.trim();
        if (title.length < 50 && !title.contains('.')) {
          return '## $title';
        }
        return match.group(0)!;
      }
    );
    
    return result;
  }

  // تحسين تنسيق الروابط
  String _enhanceLinkFormatting(String content) {
    String result = content;
    
    // تحسين عرض URLs العادية
    result = result.replaceAllMapped(
      RegExp(r'(https?://[^\s]+)'),
      (match) => '[${match.group(1)}](${match.group(1)})'
    );
    
    return result;
  }

  // إضافة فواصل منطقية
  String _addLogicalSeparators(String content) {
    String result = content;
    
    // إضافة خطوط فاصلة قبل الأقسام المهمة
    result = result.replaceAllMapped(
      RegExp(r'\n(## .+)\n'),
      (match) => '\n---\n\n${match.group(1)}\n'
    );
    
    return result;
  }

  // تحسين عرض الأمثلة
  String _enhanceExampleFormatting(String content) {
    String result = content;
    
    // تحسين عرض الأمثلة
    result = result.replaceAllMapped(
      RegExp(r'(مثال|Example|example):\s*(.+)', multiLine: true),
      (match) => '**${match.group(1)}:**\n> ${match.group(2)}'
    );
    
    return result;
  }

  // تحديد اللغة بناءً على المحتوى والسياق
  String _detectLanguage(String content, String declaredLang) {
    String lang = declaredLang.toLowerCase();
    
    // إذا كانت اللغة المعلنة مدعومة، استخدمها
    if (supportedLanguages.contains(lang)) {
      return _normalizeLanguageName(lang);
    }
    
    // محاولة تخمين اللغة من المحتوى
    final contentLower = content.toLowerCase();
    final contentTrimmed = content.trim();
    
    // 1. فحص Shebang
    if (contentTrimmed.startsWith('#!')) {
      if (contentTrimmed.contains('#!/bin/bash') || contentTrimmed.contains('#!/bin/sh')) {
        return 'bash';
      }
      if (contentTrimmed.contains('#!/usr/bin/python') || contentTrimmed.contains('#!/usr/bin/env python')) {
        return 'python';
      }
    }
    
    // 2. فحص Shell Commands باستخدام الـ constants
    for (final command in shellCommands) {
      // فحص إذا كان السطر يبدأ بأمر shell
      if (RegExp(r'^\s*' + RegExp.escape(command) + r'(\s|$)', multiLine: true).hasMatch(contentLower) ||
          RegExp(r'^' + RegExp.escape(command) + r'(\s|$)', multiLine: true).hasMatch(contentLower)) {
        return 'bash';
      }
    }
    
    // 3. فحص أنماط Shell إضافية
    final shellPatterns = [
      RegExp(r'^\s*[\w\/\.]+\$\s', multiLine: true), // Command prompt pattern
      RegExp(r'^\s*\$\s+', multiLine: true),         // Dollar sign prompt
      RegExp(r'^\s*#\s+', multiLine: true),          // Comment in shell
      RegExp(r'export\s+\w+=', multiLine: true),     // Environment variables
      RegExp(r'source\s+', multiLine: true),         // Source command
      RegExp(r'\|\s*\w+', multiLine: true),          // Pipe operations
    ];
    
    for (final pattern in shellPatterns) {
      if (pattern.hasMatch(content)) {
        return 'bash';
      }
    }
    
    // 4. فحص Python Keywords باستخدام الـ constants
    for (final keyword in pythonKeywords) {
      if (contentLower.contains(keyword)) {
        return 'python';
      }
    }
    
    // 5. فحص JavaScript/TypeScript
    if (contentLower.contains('function ') || contentLower.contains('const ') ||
        contentLower.contains('let ') || contentLower.contains('var ') ||
        contentLower.contains('require(') || contentLower.contains('import ')) {
      return 'javascript';
    }
    
    // 6. فحص إذا كان يحتوي على أكواد تبدو كـ commands
    final lines = content.split('\n');
    int shellLikeLines = 0;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) continue;
      
      // إذا كان السطر يبدأ بـ $ أو يحتوي على commands
      if (trimmedLine.startsWith('\$') || 
          trimmedLine.startsWith('#') ||
          shellCommands.any((cmd) => trimmedLine.toLowerCase().startsWith(cmd + ' '))) {
        shellLikeLines++;
      }
    }
    
    // إذا كان أكثر من 30% من الأسطر تبدو كـ shell commands
    if (lines.length > 1 && shellLikeLines / lines.length > 0.3) {
      return 'bash';
    }
    
    // إذا لم نتمكن من التحديد، استخدم اللغة الافتراضية
    return supportedLanguages.contains(lang) ? lang : defaultCodeLanguage;
  }
  
  // تطبيع أسماء اللغات
  String _normalizeLanguageName(String lang) {
    switch (lang.toLowerCase()) {
      case 'py': return 'python';
      case 'js': return 'javascript';
      case 'ts': return 'typescript';
      case 'sh': return 'bash';
      case 'shell': return 'bash';
      case 'c++': return 'cpp';
      case 'yml': return 'yaml';
      case 'md': return 'markdown';
      default: return lang.toLowerCase();
    }
  }

  Widget _buildCustomCodeBlock(String codeContent, String language, bool isTablet, BuildContext context) {
    final theme = Theme.of(context);
    
    // تحديد اللغة الصحيحة
    final detectedLang = _detectLanguage(codeContent, language);
    
    // استخدام ألوان الثيم
    Color codeBackground;
    Color codeTextColor;
    Color borderColor;
    Color headerColor;
    
    // استخدام ألوان الثيم لجميع حالات الكود
    if (theme.brightness == Brightness.light) {
      // الوضع النهاري - خلفية داكنة للكود لسهولة القراءة
      codeBackground = theme.colorScheme.inverseSurface;
      codeTextColor = theme.colorScheme.onInverseSurface;
      borderColor = theme.colorScheme.outline;
      headerColor = theme.colorScheme.surfaceVariant;
    } else {
      // الوضع الليلي - استخدام ألوان الثيم مباشرة
      codeBackground = theme.colorScheme.surface;
      codeTextColor = theme.colorScheme.onSurface;
      borderColor = theme.colorScheme.outline;
      headerColor = theme.colorScheme.surfaceVariant;
    }
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: isTablet ? 8 : 4),
      decoration: BoxDecoration(
        color: codeBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // شريط علوي مع اسم اللغة وزر النسخ
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12, 
              vertical: isTablet ? 10 : 8,
            ),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getLanguageIcon(detectedLang),
                      size: isTablet ? 16 : 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getLanguageDisplayName(detectedLang),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: codeContent.trim()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم نسخ الكود'),
                        duration: Duration(seconds: 1),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: EdgeInsets.all(isTablet ? 6 : 4),
                    child: Icon(
                      Icons.copy,
                      size: isTablet ? 18 : 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // محتوى الكود (من اليسار لليمين)
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Directionality(
              textDirection: TextDirection.ltr, // فرض اتجاه LTR للكود
              child: SelectableText(
                codeContent.trim(),
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: isTablet ? 16 : 14,
                  color: codeTextColor,
                  height: 1.4,
                ),
                enableInteractiveSelection: true,
                showCursor: true,
              ),
            ),
          ),
        ],
      ),
    );
  }



  // دالة لتحديد اتجاه النص تلقائياً
  TextDirection _detectTextDirection(String text) {
    // Regular expression للحروف العربية
    final arabicRegex = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    );
    final englishRegex = RegExp(r'[a-zA-Z]');

    int arabicCount = arabicRegex.allMatches(text).length;
    int englishCount = englishRegex.allMatches(text).length;

    // إذا كانت نسبة العربية أكبر، استخدم RTL
    if (arabicCount > englishCount) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser ? theme.colorScheme.primary : theme.colorScheme.secondary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: isUser
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSecondary,
        size: 18,
      ),
    );
  }

  List<TextSpan> _parseMessageContent(String content, ThemeData theme) {
    final List<TextSpan> spans = [];
    final RegExp codeBlockRegex = RegExp(r'```(\w+)?\n(.*?)```', dotAll: true);
    final RegExp inlineCodeRegex = RegExp(r'`([^`]+)`');
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final RegExp italicRegex = RegExp(r'\*(.*?)\*');

    String remainingContent = content;
    int currentIndex = 0;

    while (currentIndex < remainingContent.length) {
      String textToProcess = remainingContent.substring(currentIndex);

      // البحث عن كود blocks
      Match? codeBlockMatch = codeBlockRegex.firstMatch(textToProcess);
      Match? inlineCodeMatch = inlineCodeRegex.firstMatch(textToProcess);
      Match? boldMatch = boldRegex.firstMatch(textToProcess);
      Match? italicMatch = italicRegex.firstMatch(textToProcess);

      // العثور على أقرب match
      List<Match?> matches = [
        codeBlockMatch,
        inlineCodeMatch,
        boldMatch,
        italicMatch,
      ];
      matches.removeWhere((match) => match == null);

      if (matches.isEmpty) {
        // لا توجد تنسيقات أخرى - إضافة النص مع اتجاه مناسب
        final text = textToProcess;
        spans.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: _containsArabic(text) ? 'Cairo' : null,
              height: 1.5, // تحسين المسافة بين الأسطر للنص العربي
            ),
          ),
        );
        break;
      }

      Match closestMatch = matches.reduce(
        (a, b) => a!.start < b!.start ? a : b,
      )!;

      // إضافة النص قبل التنسيق
      if (closestMatch.start > 0) {
        final text = textToProcess.substring(0, closestMatch.start);
        spans.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: _containsArabic(text) ? 'Cairo' : null,
              height: 1.5,
            ),
          ),
        );
      }

      // إضافة النص المنسق
      if (closestMatch == codeBlockMatch) {
        final codeContent = closestMatch.group(2) ?? '';
        final language = closestMatch.group(1) ?? '';

        // تحديد لون الخلفية حسب الثيم
        Color codeBackground;
        Color codeTextColor;

        if (theme.brightness == Brightness.light) {
          // النهار - خلفية داكنة للكود لسهولة القراءة
          codeBackground = theme.colorScheme.inverseSurface;
          codeTextColor = theme.colorScheme.onInverseSurface;
        } else {
          // الليل - خلفية فاتحة للكود
          codeBackground = theme.colorScheme.surfaceVariant;
          codeTextColor = theme.colorScheme.onSurfaceVariant;
        }

        spans.add(
          TextSpan(
            text: codeContent,
            style: TextStyle(
              fontFamily: 'Courier',
              backgroundColor: codeBackground,
              color: codeTextColor,
              height: 1.4,
              // فرض اتجاه من اليسار لليمين للكود فقط
              locale: const Locale('en', 'US'),
            ),
          ),
        );
      } else if (closestMatch == inlineCodeMatch) {
        final codeContent = closestMatch.group(1) ?? '';

        // تحديد لون الخلفية للكود المضمن
        Color inlineCodeBackground;
        Color inlineCodeTextColor;

        if (theme.brightness == Brightness.light) {
          // النهار - خلفية داكنة للكود المضمن
          inlineCodeBackground = theme.colorScheme.inverseSurface;
          inlineCodeTextColor = theme.colorScheme.onInverseSurface;
        } else {
          // الليل - خلفية فاتحة للكود المضمن
          inlineCodeBackground = theme.colorScheme.surfaceVariant;
          inlineCodeTextColor = theme.colorScheme.onSurfaceVariant;
        }

        spans.add(
          TextSpan(
            text: codeContent,
            style: TextStyle(
              fontFamily: 'Courier',
              backgroundColor: inlineCodeBackground,
              color: inlineCodeTextColor,
              height: 1.4,
              // فرض اتجاه من اليسار لليمين للكود المضمن
              locale: const Locale('en', 'US'),
            ),
          ),
        );
      } else if (closestMatch == boldMatch) {
        final text = closestMatch.group(1) ?? '';
        spans.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: _containsArabic(text) ? 'Cairo' : null,
              height: 1.5,
            ),
          ),
        );
      } else if (closestMatch == italicMatch) {
        final text = closestMatch.group(1) ?? '';
        spans.add(
          TextSpan(
            text: text,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontFamily: _containsArabic(text) ? 'Cairo' : null,
              height: 1.5,
            ),
          ),
        );
      }

      currentIndex += closestMatch.end;
    }

    return spans.isEmpty
        ? [
            TextSpan(
              text: content,
              style: TextStyle(
                fontFamily: _containsArabic(content) ? 'Cairo' : null,
                height: 1.5,
              ),
            ),
          ]
        : spans;
  }

  // دالة للتحقق من وجود نص عربي
  bool _containsArabic(String text) {
    final arabicRegex = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    );
    return arabicRegex.hasMatch(text);
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}س';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}د';
    } else {
      return 'الآن';
    }
  }
  

  
  // الحصول على أيقونة اللغة
  IconData _getLanguageIcon(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return Icons.code;
      case 'bash':
      case 'shell':
        return Icons.terminal;
      case 'javascript':
      case 'typescript':
        return Icons.code;
      case 'html':
        return Icons.web;
      case 'css':
        return Icons.style;
      case 'json':
        return Icons.data_object;
      case 'dart':
        return Icons.code;
      default:
        return Icons.code;
    }
  }
  
  // الحصول على اسم اللغة للعرض
  String _getLanguageDisplayName(String language) {
    switch (language.toLowerCase()) {
      case 'python': return 'Python';
      case 'bash': return 'Bash';
      case 'javascript': return 'JavaScript';
      case 'typescript': return 'TypeScript';
      case 'html': return 'HTML';
      case 'css': return 'CSS';
      case 'json': return 'JSON';
      case 'dart': return 'Dart';
      case 'java': return 'Java';
      case 'cpp': return 'C++';
      case 'c': return 'C';
      default: return language.toUpperCase();
    }
  }
}
