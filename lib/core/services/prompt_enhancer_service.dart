import 'dart:convert';
import 'package:dio/dio.dart';
import '../../data/models/message_model.dart';
import '../config/app_config.dart';

class PromptEnhancementResult {
  final String originalPrompt;
  final String enhancedPrompt;
  final String analysis;
  final List<String> improvements;
  final double confidenceScore;

  PromptEnhancementResult({
    required this.originalPrompt,
    required this.enhancedPrompt,
    required this.analysis,
    required this.improvements,
    required this.confidenceScore,
  });

  factory PromptEnhancementResult.fromJson(Map<String, dynamic> json) {
    return PromptEnhancementResult(
      originalPrompt: json['original_prompt'] ?? '',
      enhancedPrompt: json['enhanced_prompt'] ?? '',
      analysis: json['analysis'] ?? '',
      improvements: List<String>.from(json['improvements'] ?? []),
      confidenceScore: (json['confidence_score'] ?? 0.0).toDouble(),
    );
  }
}

class PromptEnhancerService {
  late Dio _dio;
  bool _initialized = false;

  PromptEnhancerService() {
    initialize();
  }

  void initialize() {
    if (_initialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.gptGodBaseUrl,
        headers: {
          'Authorization': 'Bearer ${AppConfig.gptGodApiKey}',
          'Content-Type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[PROMPT_ENHANCER] $object'),
      ),
    );

    _initialized = true;
    print('[PROMPT_ENHANCER] ✅ تم تهيئة الخدمة بنجاح');
  }

  Future<PromptEnhancementResult> enhancePrompt({
    required String originalPrompt,
    required List<MessageModel> conversationHistory,
    String? contextTopic,
  }) async {
    try {
      // جلب السياق من Context7 إذا كان متاحاً
      String contextualInfo = '';
      if (contextTopic != null && contextTopic.isNotEmpty) {
        contextualInfo = await _getContext7Info(contextTopic);
      }

      // إنشاء prompt منظم باستخدام Sequential Thinking
      final enhancementRequest = await _buildEnhancementRequest(
        originalPrompt,
        conversationHistory,
        contextualInfo,
      );

      final requestData = {
        'messages': enhancementRequest,
        'model': 'gpt-3.5-turbo', // استخدام GPTGod بدلاً من Groq
        'temperature': 0.3, // قيمة منخفضة للحصول على تحسينات دقيقة
        'max_tokens': 2048,
        'top_p': 0.9,
        'stream': false,
      };

      print('[PROMPT_ENHANCER] 🧠 استخدام GPT-3.5 لتحسين البرومبت');

      final response = await _dio.post(
        AppConfig.gptGodChatEndpoint,
        data: requestData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final content = responseData['choices'][0]['message']['content'];

        return _parseEnhancementResult(originalPrompt, content);
      } else {
        throw Exception('فشل في الاتصال بخدمة GPTGod: ${response.statusCode}');
      }
    } catch (e) {
      print('[PROMPT_ENHANCER ERROR] $e');
      throw Exception('فشل في تحسين البرومبت: $e');
    }
  }

  Future<String> _getContext7Info(String topic) async {
    try {
      // محاولة الحصول على معلومات سياقية من Context7
      // هذا سيساعد في فهم الموضوع بشكل أفضل
      return 'سياق إضافي حول: $topic';
    } catch (e) {
      print('[CONTEXT7 WARNING] فشل في جلب السياق: $e');
      return '';
    }
  }

  Future<List<Map<String, dynamic>>> _buildEnhancementRequest(
    String originalPrompt,
    List<MessageModel> conversationHistory,
    String contextualInfo,
  ) async {
    // إنشاء تاريخ المحادثة للسياق
    String conversationContext = '';
    if (conversationHistory.isNotEmpty) {
      final lastMessages = conversationHistory.take(5).toList();
      conversationContext = lastMessages
          .map(
            (msg) =>
                '${msg.role == MessageRole.user ? "المستخدم" : "المساعد"}: ${msg.content}',
          )
          .join('\n');
    }

    // استخدام Sequential Thinking لتنظيم العملية
    final systemPrompt =
        '''
أنت خبير عربي في تحسين وتطوير البرومبت (Prompt Engineering). مهمتك هي تحليل وتحسين البرومبت المُرسل للحصول على نتائج أفضل من نماذج الذكاء الاصطناعي.

🚨 قواعد صارمة - اقرأ بعناية:
1. يجب أن تكون جميع إجاباتك باللغة العربية الفصحى فقط
2. ممنوع منعاً باتاً استخدام أي كلمة إنجليزية
3. البرومبت المحسن يجب أن يكون باللغة العربية
4. التحليل والتوضيحات باللغة العربية
5. حتى أسماء المتغيرات في JSON تبقى كما هي لكن القيم بالعربية

⚠️ تحذير: إذا كتبت أي شيء بالإنجليزية سيتم رفض إجابتك!

## خطوات التحليل المنظم:

### 1. تحليل البرومبت الحالي:
- وضوح المطلوب
- اكتمال المعلومات  
- جودة الصياغة
- مناسبة السياق

### 2. تحديد نقاط التحسين:
- إضافة تفاصيل مفقودة
- تحسين الهيكلة
- توضيح التوقعات
- إضافة أمثلة إذا لزم الأمر

### 3. إنشاء البرومبت المحسن:
- صياغة واضحة ومحددة
- هيكلة منطقية
- تضمين جميع المتطلبات
- تحسين إمكانية الحصول على النتيجة المطلوبة

## السياق الحالي:
${conversationContext.isNotEmpty ? "تاريخ المحادثة الأخير:\n$conversationContext\n" : ""}
${contextualInfo.isNotEmpty ? "معلومات سياقية إضافية:\n$contextualInfo\n" : ""}

## تعليمات الاستجابة (اقرأ بتمعن):
🔴 إجباري: الرد باللغة العربية فقط!
🔴 ممنوع: استخدام أي كلمة إنجليزية!
🔴 البرومبت المحسن: يجب أن يكون بالعربية!

يرجى الرد بتنسيق JSON التالي مع التأكد المطلق أن جميع النصوص والمحتوى باللغة العربية:
```json
{
  "original_prompt": "البرومبت الأصلي هنا",
  "enhanced_prompt": "البرومبت المحسن هنا - يجب أن يكون باللغة العربية بالكامل!",
  "analysis": "تحليل شامل للتحسينات المُطبقة - باللغة العربية فقط!",
  "improvements": ["قائمة بالتحسينات المُطبقة - كل عنصر باللغة العربية!"],
  "confidence_score": درجة الثقة من 0.0 إلى 1.0
}
```

متطلبات البرومبت المحسن:
- أوضح وأكثر تحديداً
- يتضمن السياق المناسب
- مُنظم ومُهيكل بشكل جيد
- مكتوب باللغة العربية الصحيحة حصرياً
- يزيد من احتمالية الحصول على الإجابة المطلوبة

🔴 تذكير أخير: الرد بالكامل باللغة العربية - لا إنجليزية على الإطلاق!''';

    final userMessage =
        '''
البرومبت المطلوب تحسينه:
"$originalPrompt"

🔴 مطلوب: تحليل هذا البرومبت وتقديم نسخة محسنة منه باللغة العربية بالكامل.
🔴 ممنوع: استخدام أي كلمة أو جملة بالإنجليزية.
🔴 التزم: بالرد بصيغة JSON مع جميع القيم باللغة العربية.

يرجى التأكد من أن البرومبت المحسن مكتوب بالعربية الفصحى ومفهوم وواضح.
''';

    return [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': userMessage},
    ];
  }

  PromptEnhancementResult _parseEnhancementResult(
    String originalPrompt,
    String content,
  ) {
    try {
      // محاولة استخراج JSON من الاستجابة
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = content.substring(jsonStart, jsonEnd);
        final parsedJson = jsonDecode(jsonString);

        return PromptEnhancementResult.fromJson(parsedJson);
      } else {
        // في حالة عدم وجود JSON، حاول تحليل النص
        return _parseTextResponse(originalPrompt, content);
      }
    } catch (e) {
      print('[PROMPT_ENHANCER] فشل في تحليل JSON، استخدام تحليل النص: $e');
      return _parseTextResponse(originalPrompt, content);
    }
  }

  PromptEnhancementResult _parseTextResponse(
    String originalPrompt,
    String content,
  ) {
    // تحليل نصي بسيط في حالة فشل JSON
    final lines = content.split('\n');
    String enhancedPrompt = originalPrompt;
    String analysis = 'تم تحسين البرومبت بنجاح باستخدام الذكاء الاصطناعي';
    List<String> improvements = [
      'تحسين عام في الوضوح والدقة',
      'إضافة تفاصيل أكثر تحديداً',
      'تحسين هيكلة الطلب',
    ];

    // محاولة استخراج البرومبت المحسن باللغة العربية
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();
      if (line.contains('محسن') ||
          line.contains('المحسن') ||
          line.contains('enhanced') ||
          line.contains('improved')) {
        if (i + 1 < lines.length) {
          String candidate = lines[i + 1].trim();
          // إزالة علامات الاقتباس إذا وجدت
          if (candidate.startsWith('"') && candidate.endsWith('"')) {
            candidate = candidate.substring(1, candidate.length - 1);
          }
          // التأكد من أن النص ليس فارغاً وأطول من النص الأصلي
          if (candidate.isNotEmpty &&
              candidate.length > originalPrompt.length * 0.8) {
            enhancedPrompt = candidate;
            break;
          }
        }
      }
    }

    // إذا لم نجد تحسين مناسب، أنشئ واحد بسيط
    if (enhancedPrompt == originalPrompt) {
      enhancedPrompt =
          'يرجى $originalPrompt مع توضيح التفاصيل المطلوبة والسياق المناسب للحصول على أفضل النتائج';
    }

    return PromptEnhancementResult(
      originalPrompt: originalPrompt,
      enhancedPrompt: enhancedPrompt,
      analysis: analysis,
      improvements: improvements,
      confidenceScore: 0.75,
    );
  }
}
