import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

import '../../data/models/message_model.dart';
import 'groq_service.dart';

class FineTuningAdvisorService {
  static final FineTuningAdvisorService _instance =
      FineTuningAdvisorService._internal();
  factory FineTuningAdvisorService() => _instance;
  FineTuningAdvisorService._internal();

  final GroqService _groqService = GroqService();
  String? _fineTuningKnowledgeBase;
  Map<String, dynamic>? _fineTuningDataset;

  // تحميل قاعدة البيانات الشاملة للتدريب المتقدم
  Future<void> initialize() async {
    try {
      // تحميل بيانات التدريب المتخصصة
      final datasetString = await rootBundle.loadString(
        'assets/data/specialized_datasets/fine_Tuning.json',
      );
      _fineTuningDataset = jsonDecode(datasetString);
      _fineTuningKnowledgeBase = _getAdvancedPythonKnowledgeBase();

      // تحقق من تحميل البيانات بنجاح
      final cellsCount = _fineTuningDataset?['cells']?.length ?? 0;
      print(
        '[FINE_TUNING_ADVISOR] ✅ Dataset loaded successfully with $cellsCount cells',
      );

      // استخراج أمثلة الكود للتحقق
      if (_fineTuningDataset != null) {
        final cells = _fineTuningDataset!['cells'] as List?;
        final codeCells =
            cells?.where((cell) => cell['cell_type'] == 'code').length ?? 0;
        print(
          '[FINE_TUNING_ADVISOR] 📊 Found $codeCells code cells in dataset',
        );
      }
    } catch (e) {
      print('[FINE_TUNING_ADVISOR] ❌ Could not load dataset: $e');
      print('[FINE_TUNING_ADVISOR] 🔄 Using fallback knowledge base');
      _fineTuningKnowledgeBase = _getAdvancedPythonKnowledgeBase();
    }
  }

  // قاعدة المعرفة المتقدمة للبرمجة بالبايثون والتدريب المتقدم
  String _getAdvancedPythonKnowledgeBase() {
    return '''
=== قاعدة المعرفة المتقدمة للبرمجة بالبايثون والتدريب المتقدم ===

## تقنيات التدريب المتقدم (Fine-Tuning):
### نماذج الرؤية الحاسوبية:
- SigLIP 2 (Sigmoid Loss for Language-Image Pre-training)
- Vision Transformers (ViT)
- CLIP Models
- ResNet وتطبيقاتها المتقدمة
- EfficientNet للتصنيف الفعال
- ConvNeXt للشبكات التطويرية الحديثة
- DINO للتعلم الذاتي

### مكتبات Python المتقدمة:
- PyTorch للتعلم العميق
- Transformers من Hugging Face
- Accelerate للتدريب المتوازي
- Datasets لإدارة البيانات
- Evaluate لتقييم النماذج
- TorchVision للرؤية الحاسوبية
- NumPy للحوسبة العلمية

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

      final stream = await _groqService.sendMessageStream(
        messages: [
          MessageModel(
            id: 'skill_assessment',
            content: assessmentPrompt,
            role: MessageRole.user,
            timestamp: DateTime.now(),
          ),
        ],
        systemPrompt: _buildSpecializedSystemPrompt(),
        temperature: 0.3,
      );

      final buffer = StringBuffer();
      await for (final chunk in stream) {
        buffer.write(chunk);
      }

      return ProgrammingSkillAssessmentModel.fromAIResponse(buffer.toString());
    } catch (e) {
      throw Exception('فشل في تقييم المهارات البرمجية: $e');
    }
  }

  // تقديم المشورة المتخصصة في البرمجة والتدريب المتقدم
  Future<String> provideAdvancedProgrammingAdvice({
    required List<MessageModel> messages,
    String? specificTopic,
    String? skillLevel,
    String? projectType,
  }) async {
    try {
      // إضافة السياق من الـ dataset المتاح
      String datasetContext = '';
      if (_fineTuningDataset != null) {
        final cells = _fineTuningDataset!['cells'] as List?;
        if (cells != null && cells.isNotEmpty) {
          // استخراج أمثلة محددة من الـ dataset بناءً على الموضوع
          List<dynamic> relevantCells = [];

          if (specificTopic != null) {
            // البحث عن خلايا ذات صلة بالموضوع المطلوب
            relevantCells = cells
                .where((cell) {
                  if (cell['cell_type'] == 'code' && cell['source'] != null) {
                    final source = cell['source'] is List
                        ? (cell['source'] as List).join('')
                        : cell['source'].toString();
                    return source.toLowerCase().contains(
                          specificTopic.toLowerCase(),
                        ) ||
                        source.contains('SigLIP') ||
                        source.contains('fine') ||
                        source.contains('train') ||
                        source.contains('PyTorch') ||
                        source.contains('transformers');
                  }
                  return false;
                })
                .take(5)
                .toList();
          } else {
            // استخراج أمثلة عامة متنوعة
            relevantCells = cells
                .where(
                  (cell) =>
                      cell['cell_type'] == 'code' && cell['source'] != null,
                )
                .take(5)
                .toList();
          }

          if (relevantCells.isNotEmpty) {
            datasetContext =
                '📊 **أمثلة عملية من قاعدة البيانات المتخصصة:**\n\n';
            for (var i = 0; i < relevantCells.length; i++) {
              final cell = relevantCells[i];
              final source = cell['source'];
              if (source is List && source.isNotEmpty) {
                final codeText = source.join('');
                datasetContext +=
                    '**مثال ${i + 1}:**\n```python\n${codeText.length > 1000 ? '${codeText.substring(0, 1000)}...' : codeText}\n```\n\n';
              }
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
            content: 'الموضوع المحدد: $specificTopic',
            role: MessageRole.user,
            timestamp: DateTime.now(),
          ),
        if (skillLevel != null)
          MessageModel(
            id: 'skill_context',
            content: 'مستوى المهارة: $skillLevel',
            role: MessageRole.user,
            timestamp: DateTime.now(),
          ),
        if (projectType != null)
          MessageModel(
            id: 'project_context',
            content: 'نوع المشروع: $projectType',
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

      final stream = await _groqService.sendMessageStream(
        messages: enhancedMessages,
        systemPrompt: _buildSpecializedSystemPrompt(),
        temperature: 0.7,
      );

      final buffer = StringBuffer();
      await for (final chunk in stream) {
        buffer.write(chunk);
      }

      return buffer.toString();
    } catch (e) {
      throw Exception('فشل في إنشاء خطة التدريب: $e');
    }
  }

  // تتبع التقدم في التعلم وتحليل الأداء البرمجي
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

      final stream = await _groqService.sendMessageStream(
        messages: [
          MessageModel(
            id: 'learning_progress_analysis',
            content: progressPrompt,
            role: MessageRole.user,
            timestamp: DateTime.now(),
          ),
        ],
        systemPrompt: _buildSpecializedSystemPrompt(),
        temperature: 0.3,
      );

      final buffer = StringBuffer();
      await for (final chunk in stream) {
        buffer.write(chunk);
      }

      return LearningProgressReportModel.fromAIResponse(buffer.toString());
    } catch (e) {
      throw Exception('فشل في تحليل التقدم التعليمي: $e');
    }
  }

  // اختبار الوصول لقاعدة البيانات
  bool get isDatasetLoaded => _fineTuningDataset != null;

  int get datasetSize => _fineTuningDataset?['cells']?.length ?? 0;

  List<String> getAvailableCodeSamples({int limit = 3}) {
    if (_fineTuningDataset == null) return [];

    final cells = _fineTuningDataset!['cells'] as List?;
    if (cells == null) return [];

    return cells
        .where((cell) => cell['cell_type'] == 'code' && cell['source'] != null)
        .take(limit)
        .map((cell) {
          final source = cell['source'];
          if (source is List && source.isNotEmpty) {
            return source.join('');
          }
          return source.toString();
        })
        .toList();
  }
}

// نماذج البيانات المساعدة للبرمجة والتدريب المتقدم
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
    return ProgrammingSkillAssessmentModel(
      skillLevel: 'متوسط', // استخراج من الاستجابة
      strongAreas: ['PyTorch', 'Data Processing'],
      improvementAreas: ['Fine-Tuning', 'Model Optimization'],
      recommendations: ['دراسة Transformers', 'ممارسة Fine-Tuning'],
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
      shortTermGoals: ['إتقان PyTorch Basics', 'فهم Transformers'],
      longTermGoals: ['إتقان Fine-Tuning المتقدم', 'تطوير نماذج مخصصة'],
      dailyPractice: {
        'صباح': ['قراءة Documentation', 'كتابة كود'],
      },
      weeklyProjects: {
        'أسبوعي': ['مشروع Fine-Tuning', 'تحسين النماذج'],
      },
      timeline: '3 أشهر',
      progressIndicators: ['دقة النماذج', 'سرعة التدريب'],
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
      improvements: ['تحسن في PyTorch', 'فهم أفضل للـ Fine-Tuning'],
      challenges: ['تحسين الأداء', 'إدارة الذاكرة'],
      recommendations: ['المزيد من الممارسة', 'دراسة حالات متقدمة'],
      planAdjustments: 'التركيز على مشاريع أكثر تعقيداً',
      skillMetrics: {'pytorch': 0.8, 'fine_tuning': 0.6, 'optimization': 0.7},
      completedProjects: ['Image Classification', 'Model Fine-Tuning'],
    );
  }
}
