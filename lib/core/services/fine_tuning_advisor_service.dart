import 'dart:async';
import 'dart:convert';
import 'unified_ai_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/message_model.dart';


class FineTuningAdvisorService {
  static final FineTuningAdvisorService _instance =
      FineTuningAdvisorService._internal();
  factory FineTuningAdvisorService() => _instance;
  FineTuningAdvisorService._internal();

  final UnifiedAIService _aiService = UnifiedAIService();
  String? _fineTuningKnowledgeBase;
  Map<String, dynamic>? _fineTuningDataset;

  // تحميل قاعدة البيانات الشاملة للتدريب المتقدم
  // Load comprehensive database for advanced training
  Future<void> initialize() async {
    try {
      // تحميل بيانات التدريب المتخصصة
      // Load specialized training data
      final datasetString = await rootBundle.loadString(
        'assets/data/specialized_datasets/your_traning_Dataset.csv',
      );
      _fineTuningDataset = _parseCSVDataset(datasetString);
      _fineTuningKnowledgeBase = _getAdvancedPythonKnowledgeBase();

      // تحقق من تحميل البيانات بنجاح
      // Verify successful data loading
      final samplesCount = _fineTuningDataset?['samples']?.length ?? 0;
      if (kDebugMode) {
        print(
        '[FINE_TUNING_ADVISOR] ✅ Dataset loaded successfully with $samplesCount samples',
      );
      }

      // استخراج أمثلة البيانات للتحقق
      // Extract data samples for verification
      if (_fineTuningDataset != null) {
        final samples = _fineTuningDataset?['samples'] as List?;
        final positiveCount = samples?.where((sample) => sample['polarity'] == '1').length ?? 0;
        final negativeCount = samples?.where((sample) => sample['polarity'] == '0').length ?? 0;
        if (kDebugMode) {
          print(
          '[FINE_TUNING_ADVISOR] 📊 Found $positiveCount positive and $negativeCount negative samples',
        );
        }
      }
    } catch (e) {
      if (kDebugMode) print('[FINE_TUNING_ADVISOR] ❌ Could not load dataset / لا يمكن تحميل البيانات: $e');
      if (kDebugMode) print('[FINE_TUNING_ADVISOR] 🔄 Using fallback knowledge base / استخدام قاعدة المعرفة الاحتياطية');
      _fineTuningKnowledgeBase = _getAdvancedPythonKnowledgeBase();
    }
  }

  // تحليل ملف CSV وتحويله إلى تنسيق قابل للاستخدام
  // Parse CSV file and convert to usable format
  Map<String, dynamic> _parseCSVDataset(String csvContent) {
    final lines = csvContent.split('\n');
    if (lines.isEmpty) return {'samples': []};
    
    // تخطي العنوان الأول
    final samples = <Map<String, dynamic>>[];
    
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      
      // تحليل CSV مع التعامل مع النصوص المحاطة بعلامات اقتباس
      final parts = _parseCSVLine(line);
      if (parts.length >= 2) {
        samples.add({
          'polarity': parts[0],
          'text': parts[1],
          'language': 'ar', // اللغة العربية
          'domain': 'sentiment_analysis', // تحليل المشاعر
        });
      }
    }
    
    return {
      'samples': samples,
      'total_count': samples.length,
      'positive_count': samples.where((s) => s['polarity'] == '1').length,
      'negative_count': samples.where((s) => s['polarity'] == '0').length,
      'language': 'ar',
      'task_type': 'sentiment_analysis',
    };
  }
  
  // تحليل سطر CSV مع التعامل مع علامات الاقتباس
  // Parse CSV line handling quotes
  List<String> _parseCSVLine(String line) {
    final result = <String>[];
    bool inQuotes = false;
    String current = '';
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    
    if (current.isNotEmpty) {
      result.add(current.trim());
    }
    
    return result;
  }

  // قاعدة المعرفة المتقدمة للبرمجة بالبايثون والتدريب المتقدم
  // Advanced knowledge base for Python programming and advanced training
  String _getAdvancedPythonKnowledgeBase() {
    return '''
=== قاعدة المعرفة المتقدمة للبرمجة بالبايثون والتدريب المتقدم ===

## تقنيات التدريب المتقدم (Fine-Tuning):
### نماذج معالجة اللغات الطبيعية:
- BERT وتطبيقاته في اللغة العربية (AraBERT, CAMeLBERT)
- GPT Models للنصوص العربية
- T5 للمهام المتعددة
- RoBERTa للفهم العميق
- XLM-R للغات المتعددة
- ELECTRA للتدريب الفعال
- DeBERTa للأداء المحسن

### نماذج تحليل المشاعر:
- Sentiment Analysis Models
- Emotion Detection Systems
- Opinion Mining Techniques
- Aspect-Based Sentiment Analysis
- Multi-lingual Sentiment Models

### مكتبات Python المتقدمة:
- PyTorch للتعلم العميق
- Transformers من Hugging Face
- Accelerate للتدريب المتوازي
- Datasets لإدارة البيانات
- Evaluate لتقييم النماذج
- Scikit-learn للتعلم الآلي
- Pandas لمعالجة البيانات
- NumPy للحوسبة العلمية
- NLTK ومعالجة اللغة العربية
- spaCy للمعالجة المتقدمة
- Farasapy للمعالجة العربية

## تقنيات التدريب المتقدمة:
### استراتيجيات التحسين:
- AdamW Optimizer
- Learning Rate Scheduling
- Gradient Accumulation
- Mixed Precision Training
- Data Parallel Training
- Model Parallel Training
- Gradient Checkpointing

### تقنيات التنظيم (Regularization):
- Dropout وتطبيقاته المتقدمة
- Batch Normalization
- Layer Normalization
- Weight Decay
- Early Stopping
- Data Augmentation
- Mixup وCutMix

### معمارية النماذج المتقدمة:
- Attention Mechanisms
- Multi-Head Attention
- Transformer Architecture
- Vision Transformer (ViT)
- Convolutional Neural Networks
- Residual Connections
- Skip Connections

## تقنيات البرمجة المتقدمة:
### إدارة البيانات والذاكرة:
- Memory Management في PyTorch
- Gradient Checkpointing
- DataLoader Optimization
- Batch Processing
- Memory Profiling
- GPU Memory Management

### تحسين الأداء:
- Vectorization مع NumPy
- JIT Compilation مع TorchScript
- Model Quantization
- Pruning للنماذج
- Knowledge Distillation
- Model Compression

## مؤشرات التقدم في التعلم:
### مؤشرات الأداء:
- Training Loss Convergence
- Validation Accuracy
- Learning Rate Scheduling
- Gradient Norm Monitoring
- Model Checkpoint Saving

### تقييم النماذج:
- Cross-Validation Techniques
- Confusion Matrix Analysis
- Precision, Recall, F1-Score
- ROC Curves وAUC
- Classification Reports
- Model Interpretability

### تحسين الهايبر بارامترز:
- Grid Search
- Random Search
- Bayesian Optimization
- Hyperband Algorithm
- Population Based Training
- AutoML Techniques

## استراتيجيات العلاج المتقدمة:
### التقنيات العلاجية:
- العلاج السلوكي المعرفي (CBT)
- علاج القبول والالتزام (ACT)
- العلاج الجدلي السلوكي (DBT)
- تقنيات اليقظة الذهنية
- العلاج الجماعي

### الأدوات التقنية:
- تطبيقات الحجب (Cold Turkey, Qustodio, Circle)
- مرشحات DNS (OpenDNS, CleanBrowsing)
- إعدادات الرقابة الأبوية
- تطبيقات المراقبة الذاتية
- أدوات تتبع الوقت

### البدائل الصحية:
- الرياضة والنشاط البدني
- الهوايات الإبداعية
- التعلم والتطوير الشخصي
- الأنشطة الاجتماعية
- الممارسات الروحية والتأمل

## خطط العلاج المرحلية:
### المرحلة الأولى (الإقرار):
- الاعتراف بوجود المشكلة
- فهم الآثار السلبية
- تحديد المحفزات
- وضع أهداف واقعية

### المرحلة الثانية (التخلص من السموم):
- فترة امتناع كاملة
- إزالة المحفزات
- بناء روتين جديد
- التعامل مع أعراض الانسحاب

### المرحلة الثالثة (إعادة البناء):
- تطوير مهارات التأقلم
- بناء علاقات صحية
- استكشاف الهوايات
- تحسين الصحة العامة

### المرحلة الرابعة (الحفاظ على التعافي):
- منع الانتكاس
- المراقبة المستمرة
- الدعم المجتمعي
- التطوير المستمر

## نصائح للأهل والمربين:
### علامات التحذير:
- تغييرات سلوكية مفاجئة
- العزلة والانطواء
- تراجع الدرجات
- تغيير أصدقاء
- سلوك سري حول الإنترنت

### استراتيجيات الوقاية:
- التواصل المفتوح
- التعليم المبكر
- وضع حدود صحية
- المراقبة المناسبة
- كون قدوة إيجابية

## الموارد والمساعدة:
### خطوط المساعدة:
- خطوط الدعم النفسي
- مراكز العلاج المتخصصة
- مجموعات الدعم
- المعالجين المتخصصين

### المواقع التعليمية:
- Fight the New Drug
- NoFap Community
- Porn Recovery Resources
- Educational Websites

هذه المعرفة الشاملة تمكن المستشار من:
1. فهم طبيعة المشكلة بعمق
2. تحديد مستوى الإدمان
3. تقديم نصائح مخصصة
4. اقتراح استراتيجيات علاج مناسبة
5. توفير الدعم المستمر والمتابعة
''';
  }

  // بناء النظام التعليمي المتخصص
  // Build specialized educational system
  String _buildSpecializedSystemPrompt() {
    return '''
You are an AI assistant specialized in advanced Python programming and Fine-Tuning techniques, with deep expertise in machine learning and artificial intelligence.

Language Guidelines:
- Default to Arabic when responding, but you can communicate in any language if the user requests it
- Adapt your language to match the user's preference naturally
- Do not restrict yourself to only Arabic - be multilingual and flexible
- Format your responses clearly using Markdown for better readability

Your expertise includes:
- Deep understanding of advanced training techniques and Fine-Tuning
- Comprehensive knowledge of advanced Python libraries (PyTorch, Transformers, etc.)
- Experience in performance optimization and memory management
- Ability to evaluate and improve models accurately
- Creating customized and effective training strategies
- Expertise in Vision Transformers and computer vision models

Knowledge Base:
${_fineTuningKnowledgeBase ?? _getAdvancedPythonKnowledgeBase()}

Important Instructions:
1. Provide advanced, executable Python code
2. Explain complex techniques clearly
3. Use best programming practices
4. Offer optimized solutions for performance and memory
5. Connect solutions to practical problems
6. Use the latest techniques and libraries
7. Provide practical examples from the available dataset
8. Help understand and apply advanced Fine-Tuning techniques
9. Be helpful, accurate, and adapt to the user's communication style
10. Format code blocks properly and use clear markdown formatting
''';
  }

  // تقييم مستوى المهارات البرمجية والتدريب المتقدم
  // Assess programming skills and advanced training level
  Future<ProgrammingSkillAssessmentModel> assessProgrammingLevel(
    List<String> responses,
  ) async {
    try {
      final assessmentPrompt =
          '''
بناءً على الإجابات التالية، قم بتقييم مستوى المهارات البرمجية في Python والتدريب المتقدم:

الإجابات: ${responses.join('\n')}

يجب أن يتضمن التقييم:
1. مستوى المهارة (مبتدئ/متوسط/متقدم/خبير)
2. المجالات القوية (PyTorch، Transformers، تحسين الأداء، إدارة البيانات)
3. المجالات التي تحتاج تطوير
4. التوصيات للتعلم والتحسين
5. خطة التدريب المقترحة على Fine-Tuning
6. مشاريع عملية مناسبة للمستوى
''';

      final response = await _aiService.sendMessage(
        messages: [
          MessageModel(
            id: 'skill_assessment',
            content: assessmentPrompt,
            role: MessageRole.user,
            timestamp: DateTime.now(),
          ),
        ],
        model: 'llama-3.1-70b-versatile', // Default model for assessment
        systemPrompt: _buildSpecializedSystemPrompt(),
        temperature: 0.3,
      );

      return ProgrammingSkillAssessmentModel.fromAIResponse(response);
    } catch (e) {
      throw Exception('فشل في تقييم المهارات البرمجية / Failed to assess programming skills: $e');
    }
  }

  // تقديم المشورة المتخصصة في البرمجة والتدريب المتقدم
  // Provide specialized advice in programming and advanced training
  Future<String> provideAdvancedProgrammingAdvice({
    required List<MessageModel> messages,
    String? specificTopic,
    String? skillLevel,
    String? projectType,
  }) async {
    try {
      // إضافة السياق من الـ dataset المتاح
      // Add context from available dataset
      String datasetContext = '';
      if (_fineTuningDataset != null) {
        final samples = _fineTuningDataset?['samples'] as List?;
        if (samples != null && samples.isNotEmpty) {
          // استخراج أمثلة محددة من الـ dataset بناءً على الموضوع
          List<dynamic> relevantSamples = [];

          if (specificTopic != null) {
            // البحث عن عينات ذات صلة بالموضوع المطلوب
            // Search for samples related to requested topic
            relevantSamples = samples
                .where((sample) {
                  if (sample['text'] != null) {
                    final text = sample['text'].toString();
                    return text.toLowerCase().contains(
                          specificTopic.toLowerCase(),
                        ) ||
                        specificTopic.toLowerCase().contains('sentiment') ||
                        specificTopic.toLowerCase().contains('تحليل') ||
                        specificTopic.toLowerCase().contains('مشاعر');
                  }
                  return false;
                })
                .take(3)
                .toList();
          } else {
            // استخراج أمثلة عامة متنوعة
            // Extract diverse general examples
            relevantSamples = samples.take(3).toList();
          }

          if (relevantSamples.isNotEmpty) {
            datasetContext =
                '📊 **أمثلة عملية من قاعدة البيانات المتخصصة / Practical examples from specialized database:**\n\n';
            for (var i = 0; i < relevantSamples.length; i++) {
              final sample = relevantSamples[i];
              final text = sample['text']?.toString() ?? '';
              final polarity = sample['polarity'] == '1' ? 'إيجابي / Positive' : 'سلبي / Negative';
              datasetContext +=
                  '**مثال / Example ${i + 1} ($polarity):**\n${text.length > 200 ? '${text.substring(0, 200)}...' : text}\n\n';
            }
            datasetContext += '---\n\n';
          }
        }
      }

      final enhancedMessages = <MessageModel>[
        ...messages,
        if (specificTopic != null)
          MessageModel(
            id: 'topic_context',
            content: 'الموضوع المحدد / Specific topic: $specificTopic',
            role: MessageRole.user,
            timestamp: DateTime.now(),
          ),
        if (skillLevel != null)
          MessageModel(
            id: 'skill_context',
            content: 'مستوى المهارة / Skill level: $skillLevel',
            role: MessageRole.user,
            timestamp: DateTime.now(),
          ),
        if (projectType != null)
          MessageModel(
            id: 'project_context',
            content: 'نوع المشروع / Project type: $projectType',
            role: MessageRole.user,
            timestamp: DateTime.now(),
          ),
        if (datasetContext.isNotEmpty)
          MessageModel(
            id: 'dataset_context',
            content: datasetContext,
            role: MessageRole.user,
            timestamp: DateTime.now(),
          ),
      ];

      final response = await _aiService.sendMessage(
        messages: enhancedMessages,
        model: 'llama-3.1-70b-versatile', // Default model for advice
        systemPrompt: _buildSpecializedSystemPrompt(),
        temperature: 0.7,
      );

      return response;
    } catch (e) {
      throw Exception('فشل في إنشاء خطة التدريب / Failed to create training plan: $e');
    }
  }

  // تتبع التقدم في التعلم وتحليل الأداء البرمجي
  // Track learning progress and analyze programming performance
  Future<LearningProgressReportModel> trackLearningProgress({
    required String userId,
    required List<LearningProgressEntryModel> entries,
  }) async {
    try {
      final progressData = entries
          .map(
            (e) => {
              'date': e.date.toIso8601String(),
              'skill_rating': e.skillRating,
              'topics_studied': e.topicsStudied,
              'practice_activities': e.practiceActivities,
              'challenges': e.challenges,
              'achievements': e.achievements,
              'model_metrics': e.modelMetrics,
            },
          )
          .toList();

      final progressPrompt =
          '''
حلل التقدم في التعلم البرمجي والـ Fine-Tuning وقدم تقريراً شاملاً:

بيانات التقدم: ${jsonEncode(progressData)}

يجب أن يتضمن التقرير:
1. تحليل الاتجاهات في المهارات البرمجية
2. المجالات التي تحسنت (PyTorch, Fine-Tuning, Optimization)
3. التحديات التقنية المستمرة
4. توصيات للأسبوع القادم في التعلم
5. تعديلات مقترحة على خطة التدريب
6. تحليل مؤشرات أداء النماذج (دقة، سرعة، استهلاك الذاكرة)
7. مشاريع جديدة مقترحة بناءً على التقدم
8. تقييم جودة الكود والممارسات المتبعة
9. اقتراحات لتحسين كفاءة التدريب
''';

      final response = await _aiService.sendMessage(
        messages: [
          MessageModel(
            id: 'learning_progress_analysis',
            content: progressPrompt,
            role: MessageRole.user,
            timestamp: DateTime.now(),
          ),
        ],
        model: 'llama-3.1-70b-versatile', // Default model for progress tracking
        systemPrompt: _buildSpecializedSystemPrompt(),
        temperature: 0.3,
      );

      return LearningProgressReportModel.fromAIResponse(response);
    } catch (e) {
      throw Exception('فشل في تحليل التقدم التعليمي / Failed to analyze learning progress: $e');
    }
  }

  // اختبار الوصول لقاعدة البيانات
  // Test database access
  bool get isDatasetLoaded => _fineTuningDataset != null;

  int get datasetSize => _fineTuningDataset?['samples']?.length ?? 0;

  List<Map<String, dynamic>> getAvailableTextSamples({int limit = 3}) {
    if (_fineTuningDataset == null) return [];

    final samples = _fineTuningDataset?['samples'] as List?;
    if (samples == null) return [];

    return samples
        .where((sample) => sample['text'] != null)
        .take(limit)
        .map((sample) => {
          'text': sample['text'].toString(),
          'polarity': sample['polarity'],
          'language': sample['language'] ?? 'ar',
          'domain': sample['domain'] ?? 'sentiment_analysis',
        })
        .toList();
  }
  
  // الحصول على إحصائيات البيانات
  // Get dataset statistics
  Map<String, dynamic> getDatasetStats() {
    if (_fineTuningDataset == null) return {};
    
    return {
      'total_samples': _fineTuningDataset?['total_count'] ?? 0,
      'positive_samples': _fineTuningDataset?['positive_count'] ?? 0,
      'negative_samples': _fineTuningDataset?['negative_count'] ?? 0,
      'language': _fineTuningDataset?['language'] ?? 'ar',
      'task_type': _fineTuningDataset?['task_type'] ?? 'sentiment_analysis',
    };
  }
}

// نماذج البيانات المساعدة للبرمجة والتدريب المتقدم
// Helper data models for programming and advanced training
class ProgrammingSkillAssessmentModel {
  final String skillLevel;
  final List<String> strongAreas;
  final List<String> improvementAreas;
  final List<String> recommendations;
  final String learningPlan;
  final List<String> suggestedProjects;

  ProgrammingSkillAssessmentModel({
    required this.skillLevel,
    required this.strongAreas,
    required this.improvementAreas,
    required this.recommendations,
    required this.learningPlan,
    required this.suggestedProjects,
  });

  factory ProgrammingSkillAssessmentModel.fromAIResponse(String response) {
    // تحليل الاستجابة وإنشاء النموذج
    // Analyze response and create model
    return ProgrammingSkillAssessmentModel(
      skillLevel: 'متوسط', // استخراج من الاستجابة // Extract from response
      strongAreas: ['PyTorch', 'Data Processing'],
      improvementAreas: ['Fine-Tuning', 'Model Optimization'],
      recommendations: ['دراسة Transformers', 'ممارسة Fine-Tuning'], // Study Transformers, Practice Fine-Tuning
      learningPlan: response,
      suggestedProjects: ['Image Classification', 'Text Analysis'],
    );
  }
}

class FineTuningPlanModel {
  final List<String> shortTermGoals;
  final List<String> longTermGoals;
  final Map<String, List<String>> dailyPractice;
  final Map<String, List<String>> weeklyProjects;
  final String timeline;
  final List<String> progressIndicators;
  final List<String> datasets;
  final List<String> models;

  FineTuningPlanModel({
    required this.shortTermGoals,
    required this.longTermGoals,
    required this.dailyPractice,
    required this.weeklyProjects,
    required this.timeline,
    required this.progressIndicators,
    required this.datasets,
    required this.models,
  });

  factory FineTuningPlanModel.fromAIResponse(String response) {
    return FineTuningPlanModel(
      shortTermGoals: ['إتقان PyTorch Basics', 'فهم Transformers'], // Master PyTorch Basics, Understand Transformers
      longTermGoals: ['إتقان Fine-Tuning المتقدم', 'تطوير نماذج مخصصة'], // Master Advanced Fine-Tuning, Develop Custom Models
      dailyPractice: {
        'صباح': ['قراءة Documentation', 'كتابة كود'], // Morning: Read Documentation, Write Code
      },
      weeklyProjects: {
        'أسبوعي': ['مشروع Fine-Tuning', 'تحسين النماذج'], // Weekly: Fine-Tuning Project, Model Optimization
      },
      timeline: '3 أشهر', // 3 months
      progressIndicators: ['دقة النماذج', 'سرعة التدريب'], // Model Accuracy, Training Speed
      datasets: ['MNIST', 'CIFAR-10', 'Custom Dataset'],
      models: ['SigLIP 2', 'ViT', 'ResNet'],
    );
  }
}

class LearningProgressEntryModel {
  final DateTime date;
  final int skillRating;
  final List<String> topicsStudied;
  final List<String> practiceActivities;
  final List<String> challenges;
  final List<String> achievements;
  final Map<String, double> modelMetrics;

  LearningProgressEntryModel({
    required this.date,
    required this.skillRating,
    required this.topicsStudied,
    required this.practiceActivities,
    required this.challenges,
    required this.achievements,
    required this.modelMetrics,
  });
}

class LearningProgressReportModel {
  final String analysis;
  final List<String> improvements;
  final List<String> challenges;
  final List<String> recommendations;
  final String planAdjustments;
  final Map<String, double> skillMetrics;
  final List<String> completedProjects;

  LearningProgressReportModel({
    required this.analysis,
    required this.improvements,
    required this.challenges,
    required this.recommendations,
    required this.planAdjustments,
    required this.skillMetrics,
    required this.completedProjects,
  });

  factory LearningProgressReportModel.fromAIResponse(String response) {
    return LearningProgressReportModel(
      analysis: response,
      improvements: ['تحسن في PyTorch', 'فهم أفضل للـ Fine-Tuning'], // Improved in PyTorch, Better Understanding of Fine-Tuning
      challenges: ['تحسين الأداء', 'إدارة الذاكرة'], // Performance Optimization, Memory Management
      recommendations: ['المزيد من الممارسة', 'دراسة حالات متقدمة'], // More Practice, Study Advanced Cases
      planAdjustments: 'التركيز على مشاريع أكثر تعقيد', // Focus on More Complex Projects
      skillMetrics: {'pytorch': 0.8, 'fine_tuning': 0.6, 'optimization': 0.7},
      completedProjects: ['Image Classification', 'Model Fine-Tuning'],
    );
  }
}
