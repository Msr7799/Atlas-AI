import '../../data/models/message_model.dart';

/// خدمة الذكاء الاصطناعي الأساسية
/// تحتوي على الدوال المشتركة بين جميع خدمات الذكاء الاصطناعي
abstract class BaseAIService {
  
  /// خوارزميات ذكية لتحسين ردود النماذج - مشتركة بين جميع الخدمات
  String applySmartFormatting(String content) {
    String processedContent = content;
    
    // 1. تحسين القوائم والأرقام
    processedContent = enhanceListFormatting(processedContent);
    
    // 2. تحسين عرض الكود غير المنسق
    processedContent = enhanceCodeFormatting(processedContent);
    
    // 3. تحسين العناوين
    processedContent = enhanceHeaderFormatting(processedContent);
    
    // 4. تحسين الأمثلة
    processedContent = enhanceExampleFormatting(processedContent);
    
    // 5. إضافة رسالة ترحيب محسنة
    processedContent = addWelcomeEnhancement(processedContent);
    
    return processedContent;
  }

  /// تحسين تنسيق القوائم
  String enhanceListFormatting(String content) {
    String result = content;
    
    // تحسين القوائم المرقمة (مع المسافات في البداية)
    result = result.replaceAllMapped(
      RegExp(r'^(\s*)(\d+)[\.\)][\s]*(.+)$', multiLine: true),
      (match) => '${match.group(1)}${match.group(2)}. **${match.group(3)}**'
    );
    
    // تحسين القوائم النقطية (مع المسافات في البداية)
    result = result.replaceAllMapped(
      RegExp(r'^(\s*)[-\*\+][\s]*(.+)$', multiLine: true),
      (match) => '${match.group(1)}- **${match.group(2)}**'
    );
    
    return result;
  }

  /// تحسين تنسيق الكود
  String enhanceCodeFormatting(String content) {
    String result = content;
    
    final lines = result.split('\n');
    final List<String> processedLines = [];
    
    bool inCodeBlock = false;
    List<String> currentCodeLines = [];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      if (trimmedLine.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        processedLines.add(line);
        continue;
      }
      
      if (inCodeBlock) {
        processedLines.add(line);
        continue;
      }
      
      if (looksLikeCode(trimmedLine) && trimmedLine.isNotEmpty) {
        currentCodeLines.add(line);
      } else {
        if (currentCodeLines.isNotEmpty) {
          final codeContent = currentCodeLines.join('\n');
          final language = detectCodeLanguage(codeContent);
          processedLines.add('```$language');
          processedLines.addAll(currentCodeLines);
          processedLines.add('```');
          currentCodeLines.clear();
        }
        processedLines.add(line);
      }
    }
    
    if (currentCodeLines.isNotEmpty) {
      final codeContent = currentCodeLines.join('\n');
      final language = detectCodeLanguage(codeContent);
      processedLines.add('```$language');
      processedLines.addAll(currentCodeLines);
      processedLines.add('```');
    }
    
    return processedLines.join('\n');
  }

  /// فحص إذا كان السطر يبدو كأنه كود
  bool looksLikeCode(String line) {
    if (line.isEmpty) return false;
    
    final codePatterns = [
      RegExp(r'^\$\s+\w+'), // أوامر Terminal
      RegExp(r'^(sudo|apt|npm|pip|git|docker|curl|wget)\s+'), // أوامر نظام
      RegExp(r'^(def|class|function|const|let|var|import|from)\s+'), // كلمات مفتاحية
      RegExp(r'[{}()\[\];].*[{}()\[\];]'), // رموز برمجية
      RegExp(r'^\s*[a-zA-Z_]\w*\s*='), // تعيين متغيرات
    ];
    
    return codePatterns.any((pattern) => pattern.hasMatch(line));
  }

  /// كشف لغة البرمجة
  String detectCodeLanguage(String content) {
    final contentLower = content.toLowerCase();
    
    // فحص أنواع الملفات والأكواد المختلفة
    if (contentLower.contains('def ') || contentLower.contains('import ') || 
        contentLower.contains('print(') || contentLower.contains('python')) {
      return 'python';
    }
    
    if (contentLower.contains('function ') || contentLower.contains('const ') || 
        contentLower.contains('let ') || contentLower.contains('var ') ||
        contentLower.contains('console.log') || contentLower.contains('javascript')) {
      return 'javascript';
    }
    
    if (contentLower.contains('class ') && (contentLower.contains('extends') || 
        contentLower.contains('implements')) || contentLower.contains('java')) {
      return 'java';
    }
    
    if (contentLower.contains('flutter') || contentLower.contains('widget') ||
        contentLower.contains('dart') || contentLower.contains('build(')) {
      return 'dart';
    }
    
    if (contentLower.contains('<html') || contentLower.contains('<div') ||
        contentLower.contains('<body') || contentLower.contains('html')) {
      return 'html';
    }
    
    if (contentLower.contains('body {') || contentLower.contains('.class') ||
      contentLower.contains('#id') || contentLower.contains('css') ||
      contentLower.contains('{') && contentLower.contains('}') && 
      (contentLower.contains('color:') || contentLower.contains('font-size:') || 
       contentLower.contains('margin:') || contentLower.contains('padding:'))) {
    return 'css';
  }
    
    if (contentLower.contains('select ') || contentLower.contains('insert ') ||
        contentLower.contains('update ') || contentLower.contains('delete ') ||
        contentLower.contains('sql')) {
      return 'sql';
    }
    
    if (contentLower.contains('cd ') || contentLower.contains('ls ') ||
        contentLower.contains('mkdir ') || contentLower.contains('sudo ')) {
      return 'bash';
    }
    
    // افتراضي إذا لم نتمكن من الكشف
    return '';
  }

  /// تحسين تنسيق العناوين
  String enhanceHeaderFormatting(String content) {
    String result = content;
    
    // تحسين العناوين الرئيسية
    result = result.replaceAllMapped(
      RegExp(r'^([^#\n]*?):\s*$', multiLine: true),
      (match) => '## ${match.group(1)?.trim()}'
    );
    
    // تحسين العناوين الفرعية
    result = result.replaceAllMapped(
      RegExp(r'^([^#\n]*?)[\-\:]\s*(.+)$', multiLine: true),
      (match) {
        final title = match.group(1)?.trim() ?? '';
        final content = match.group(2)?.trim() ?? '';
        if (title.length < 50 && content.isNotEmpty) {
          return '### $title\n$content';
        }
        return match.group(0) ?? '';
      }
    );
    
    return result;
  }

  /// تحسين تنسيق الأمثلة
  String enhanceExampleFormatting(String content) {
    String result = content;
    
    // تحسين أمثلة الكود
    result = result.replaceAllMapped(
      RegExp(r'مثال:?\s*\n?([\s\S]*?)(?=\n\n|\n[^\s]|$)', multiLine: true),
      (match) {
        final example = match.group(1)?.trim() ?? '';
        if (example.isNotEmpty) {
          return '**مثال:**\n```\n$example\n```';
        }
        return match.group(0) ?? '';
      }
    );
    
    return result;
  }

  /// إضافة رسالة ترحيب محسنة
  String addWelcomeEnhancement(String content) {
    // يمكن تخصيص هذه الدالة حسب كل خدمة
    return content;
  }
  
  // دوال مجردة يجب تطبيقها في كل خدمة
  Future<void> initialize();
  Future<Stream<String>> sendMessageStream({
    required List<MessageModel> messages,
    String? model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
    List<Map<String, dynamic>>? tools,
  });
  Future<String> sendMessage({
    required List<MessageModel> messages,
    String? model,
    double? temperature,
    int? maxTokens,
    String? systemPrompt,
    List<String>? attachedFiles,
  });
  void dispose();
}
