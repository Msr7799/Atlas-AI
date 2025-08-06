import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../core/services/simple_model_training_service.dart';

class TrainingProvider with ChangeNotifier {
  final ModelTrainingService _trainingService = ModelTrainingService();

  // حالة التدريب
  bool _isTraining = false;
  bool _isInitialized = false;
  double _trainingProgress = 0.0;
  String _currentStep = '';
  final List<String> _trainingLogs = [];
  String _errorMessage = '';

  // إعدادات التدريب
  final Map<String, dynamic> _trainingConfig = {
    'model_name': 'microsoft/DialoGPT-medium',
    'epochs': 3,
    'batch_size': 4,
    'learning_rate': 5e-5,
    'warmup_steps': 500,
    'max_length': 512,
    'save_steps': 1000,
    'logging_steps': 100,
    'gradient_accumulation_steps': 2,
    'fp16': false,
    'use_cuda': true,
  };

  // Getters
  bool get isTraining => _isTraining;
  bool get isInitialized => _isInitialized;
  double get trainingProgress => _trainingProgress;
  String get currentStep => _currentStep;
  List<String> get trainingLogs => List.unmodifiable(_trainingLogs);
  String get errorMessage => _errorMessage;
  Map<String, dynamic> get trainingConfig => Map.from(_trainingConfig);

  /// تهيئة خدمة التدريب
  Future<void> initializeTraining() async {
    try {
      _addLog('🔄 بدء تهيئة نظام التدريب...');

      final success = await _trainingService.initializeTrainingEnvironment();

      if (success) {
        _isInitialized = true;
        _addLog('✅ تم تهيئة نظام التدريب بنجاح');
        _errorMessage = '';
      } else {
        _addLog('❌ فشل في تهيئة نظام التدريب');
        _errorMessage = 'فشل في تهيئة نظام التدريب';
      }
    } catch (e) {
      _addLog('❌ خطأ في التهيئة: $e');
      _errorMessage = 'خطأ في التهيئة: $e';
    }

    notifyListeners();
  }

  /// بدء عملية التدريب
  Future<void> startTraining() async {
    if (!_isInitialized || _isTraining) return;

    _isTraining = true;
    _trainingProgress = 0.0;
    _currentStep = 'تحضير البيانات...';
    _errorMessage = '';
    _addLog('🚀 بدء عملية تدريب النموذج على البيانات الضخمة');
    notifyListeners();

    try {
      // تحضير ملف التدريب المتقدم
      _addLog('📝 إنشاء سكريبت التدريب المتقدم...');
      final scriptPath = await _trainingService.createTrainingScript(
        _trainingConfig,
      );
      _currentStep = 'تحضير النص البرمجي المتقدم...';
      _trainingProgress = 0.1;
      notifyListeners();

      _addLog('💾 سكريبت التدريب: $scriptPath');
      _addLog('📊 البيانات المتاحة: ${await _getDatasetSummary()}');

      // بدء التدريب مع مراقبة متقدمة
      _addLog('⚡ بدء عملية التدريب الفعلية...');
      _currentStep = 'تدريب النموذج على البيانات الضخمة...';
      _trainingProgress = 0.2;
      notifyListeners();

      final success = await _trainingService.startTraining(
        scriptPath: scriptPath,
        onProgress: _updateTrainingProgress,
        onLog: _addLog,
      );

      if (success) {
        _trainingProgress = 1.0;
        _currentStep = 'تم الانتهاء بنجاح';
        _addLog('🎉 تم تدريب النموذج بنجاح!');
        _addLog('📈 النموذج جاهز للاستخدام');

        // عرض معلومات النموذج المدرب
        final modelInfo = await _getModelInfo();
        _addLog('📊 معلومات النموذج: $modelInfo');
      } else {
        _errorMessage = 'فشل في عملية التدريب';
        _addLog('❌ فشل في عملية التدريب');
      }
    } catch (e) {
      _errorMessage = 'خطأ في التدريب: $e';
      _addLog('❌ خطأ في التدريب: $e');
    }

    _isTraining = false;
    notifyListeners();
  }

  /// الحصول على ملخص البيانات
  Future<String> _getDatasetSummary() async {
    try {
      final info = await _trainingService.getDatasetInfo();
      final jsonCells = info['json_cells'] ?? 0;
      final codeCells = info['json_code_cells'] ?? 0;
      final parquetSize = info['parquet_size_mb']?.toStringAsFixed(2) ?? '0';

      return 'JSON: $codeCells خلايا كود من $jsonCells إجمالي، Parquet: ${parquetSize}MB';
    } catch (e) {
      return 'غير متاح';
    }
  }

  /// معلومات النموذج المدرب
  Future<String> _getModelInfo() async {
    try {
      final evaluation = await _trainingService.evaluateModel();
      if (evaluation != null) {
        final trainingTime =
            evaluation['total_training_time_minutes']?.toStringAsFixed(1) ??
            '0';
        final trainSize = evaluation['train_dataset_size'] ?? 0;
        final loss = evaluation['training_loss']?.toStringAsFixed(4) ?? '0';

        return 'وقت التدريب: $trainingTimeدقيقة، عينات: $trainSize، Loss: $loss';
      }
      return 'معلومات محدودة متاحة';
    } catch (e) {
      return 'غير متاح';
    }
  }

  /// إيقاف عملية التدريب
  Future<void> stopTraining() async {
    if (!_isTraining) return;

    _addLog('⏹️ إيقاف عملية التدريب...');

    try {
      await _trainingService.stopTraining();
      _isTraining = false;
      _currentStep = 'تم الإيقاف';
      _addLog('✅ تم إيقاف التدريب بنجاح');
    } catch (e) {
      _addLog('❌ خطأ في إيقاف التدريب: $e');
    }

    notifyListeners();
  }

  /// تحديث إعدادات التدريب
  void updateTrainingConfig(Map<String, dynamic> newConfig) {
    _trainingConfig.addAll(newConfig);
    _addLog('⚙️ تم تحديث إعدادات التدريب');
    notifyListeners();
  }

  /// تحديث تقدم التدريب
  void _updateTrainingProgress(double progress, String step) {
    _trainingProgress = 0.2 + (progress * 0.8); // 20% للتحضير، 80% للتدريب
    _currentStep = step;
    notifyListeners();
  }

  /// إضافة سجل جديد
  void _addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    _trainingLogs.add('[$timestamp] $message');

    // الاحتفاظ بآخر 1000 سجل فقط
    if (_trainingLogs.length > 1000) {
      _trainingLogs.removeAt(0);
    }
  }

  /// مسح السجلات
  void clearLogs() {
    _trainingLogs.clear();
    notifyListeners();
  }

  /// الحصول على معلومات البيانات
  Future<Map<String, dynamic>> getDatasetInfo() async {
    try {
      return await _trainingService.getDatasetInfo();
    } catch (e) {
      _addLog('❌ خطأ في الحصول على معلومات البيانات: $e');
      return {};
    }
  }

  /// تصدير النموذج المدرب
  Future<String?> exportTrainedModel() async {
    try {
      _addLog('📦 بدء تصدير النموذج...');
      final exportPath = await _trainingService.exportTrainedModel();

      if (exportPath != null) {
        _addLog('✅ تم تصدير النموذج: $exportPath');
      } else {
        _addLog('❌ فشل في تصدير النموذج');
      }

      return exportPath;
    } catch (e) {
      _addLog('❌ خطأ في تصدير النموذج: $e');
      return null;
    }
  }

  /// تقييم النموذج
  Future<Map<String, dynamic>?> evaluateModel() async {
    try {
      _addLog('📊 بدء تقييم النموذج...');
      final evaluation = await _trainingService.evaluateModel();

      if (evaluation != null) {
        _addLog('✅ تم تقييم النموذج بنجاح');
      } else {
        _addLog('❌ فشل في تقييم النموذج');
      }

      return evaluation;
    } catch (e) {
      _addLog('❌ خطأ في تقييم النموذج: $e');
      return null;
    }
  }

  @override
  void dispose() {
    // تنظيف أي موارد مفتوحة
    super.dispose();
  }
}
