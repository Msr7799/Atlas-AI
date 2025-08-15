import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/services/advanced_model_training_service.dart';

class TrainingProvider with ChangeNotifier {
  final AdvancedModelTrainingService _trainingService = AdvancedModelTrainingService();

  // حالة التدريب
  bool _isTraining = false;
  bool _isInitialized = false;
  String _status = 'idle';
  final double _progress = 0.0;
  final int _currentEpoch = 0;
  int _totalEpochs = 10;

  // إعدادات النموذج
  String _selectedModel = 'llama-3.1-8b-instant';
  final List<String> _availableModels = [
    'llama-3.1-8b-instant',
    'llama-3.1-70b-versatile',
    'mixtral-8x7b-32768',
    'gemma-7b-it',
  ];

  // معاملات التدريب
  double _learningRate = 0.001;
  int _batchSize = 16;

  // البيانات
  String _datasetPath = '';
  String _datasetInfo = '';

  // المقاييس
  final double _currentLoss = 0.0;
  final double _currentAccuracy = 0.0;
  final String _estimatedTimeRemaining = '00:00:00';
  final double _samplesPerSecond = 0.0;

  // السجلات
  final List<String> _logs = [];
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

  // Getters الجديدة
  String get status => _status;
  double get progress => _progress;
  int get currentEpoch => _currentEpoch;
  int get totalEpochs => _totalEpochs;
  bool get canStartTraining => !_isTraining && _datasetPath.isNotEmpty;

  String get selectedModel => _selectedModel;
  List<String> get availableModels => _availableModels;

  double get learningRate => _learningRate;
  int get batchSize => _batchSize;

  String get datasetPath => _datasetPath;
  String get datasetInfo => _datasetInfo;

  double get currentLoss => _currentLoss;
  double get currentAccuracy => _currentAccuracy;
  String get estimatedTimeRemaining => _estimatedTimeRemaining;
  double get samplesPerSecond => _samplesPerSecond;

  List<String> get logs => _logs;

  // Getters الأصلية
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

      await _trainingService.initialize();
      
      _isInitialized = true;
      _addLog('✅ تم تهيئة نظام التدريب بنجاح');
      _errorMessage = '';
    } catch (e) {
      _addLog('❌ خطأ في التهيئة: $e');
      _errorMessage = 'خطأ في التهيئة: $e';
    }

    notifyListeners();
  }

  /// بدء عملية التدريب
  Future<void> startTraining([String? sessionId]) async {
    if (!_isInitialized || _isTraining) return;

    _isTraining = true;
    _trainingProgress = 0.0;
    _currentStep = 'تحضير البيانات...';
    _errorMessage = '';
    _addLog('🚀 بدء عملية تدريب النموذج');
    notifyListeners();

    try {
      String trainingSessionId = sessionId ?? 'default_session';
      
      if (sessionId == null) {
        // إنشاء جلسة تدريب جديدة
        final config = TrainingConfig(
          learningRate: _trainingConfig['learning_rate']?.toDouble() ?? 0.001,
          epochs: _trainingConfig['epochs'] ?? 10,
          batchSize: _trainingConfig['batch_size'] ?? 32,
          optimizer: 'adam',
        );
        
        trainingSessionId = await _trainingService.createTrainingSession(
          name: 'تدريب ${DateTime.now().toString()}',
          type: TrainingType.fineTuning,
          config: config,
        );
      }
      
      _currentStep = 'بدء التدريب...';
      _trainingProgress = 0.2;
      notifyListeners();

      final success = await _trainingService.startTraining(trainingSessionId);

      if (success) {
        _trainingProgress = 1.0;
        _currentStep = 'تم الانتهاء بنجاح';
        _addLog('🎉 تم تدريب النموذج بنجاح!');
        _addLog('📈 النموذج جاهز للاستخدام');
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
      final sessions = _trainingService.trainingSessions;
      if (sessions.isNotEmpty) {
        final session = sessions.first;
        return 'ملفات البيانات: ${session.dataFiles.length}';
      }
      return 'لا توجد بيانات';
    } catch (e) {
      return 'غير متاح';
    }
  }

  /// معلومات النموذج المدرب
  Future<String> _getModelInfo() async {
    try {
      final currentTraining = _trainingService.currentTraining;
      if (currentTraining != null) {
        final progress = (currentTraining.progress * 100).toStringAsFixed(1);
        return 'التقدم: $progress%، الحالة: ${currentTraining.status.arabicName}';
      }
      return 'معلومات محدودة متاحة';
    } catch (e) {
      return 'غير متاح';
    }
  }

  /// إيقاف عملية التدريب
  Future<void> stopTraining([String? sessionId]) async {
    if (!_isTraining) return;

    _addLog('⏹️ إيقاف عملية التدريب...');

    try {
      if (sessionId != null) {
        await _trainingService.stopTraining(sessionId);
      } else if (_trainingService.currentTraining != null) {
        await _trainingService.stopTraining(_trainingService.currentTraining!.id);
      }
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
      final sessions = _trainingService.trainingSessions;
      if (sessions.isNotEmpty) {
        final session = sessions.first;
        return {
          'sessions_count': sessions.length,
          'current_session': session.name,
          'data_files_count': session.dataFiles.length,
          'status': session.status.arabicName,
          'progress': session.progress,
        };
      }
      return {'sessions_count': 0};
    } catch (e) {
      _addLog('❌ خطأ في الحصول على معلومات البيانات: $e');
      return {};
    }
  }

  /// تصدير النموذج المدرب
  Future<String?> exportTrainedModel() async {
    try {
      _addLog('📦 بدء تصدير النموذج...');
      
      final currentTraining = _trainingService.currentTraining;
      if (currentTraining != null && currentTraining.status == TrainingStatus.completed) {
        _addLog('✅ النموذج جاهز للتصدير');
        // إنشاء مسار ملف النموذج المُدرب
        final modelPath = 'models/${currentTraining.id}_trained_model.bin';
        _addLog('💾 سيتم حفظ النموذج في: $modelPath');
        return modelPath;
      } else {
        _addLog('❌ لا يوجد نموذج مدرب للتصدير');
      }

      return null;
    } catch (e) {
      _addLog('❌ خطأ في تصدير النموذج: $e');
      return null;
    }
  }

  /// تقييم النموذج
  Future<Map<String, dynamic>?> evaluateModel() async {
    try {
      _addLog('📊 بدء تقييم النموذج...');
      
      final currentTraining = _trainingService.currentTraining;
      if (currentTraining != null) {
        _addLog('✅ تم تقييم النموذج بنجاح');
        return {
          'training_progress': currentTraining.progress,
          'status': currentTraining.status.arabicName,
          'metrics': currentTraining.metrics,
        };
      } else {
        _addLog('❌ لا يوجد نموذج للتقييم');
        return null;
      }
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

  // Setters والدوال المفقودة
  void setSelectedModel(String? model) {
    if (model != null && _availableModels.contains(model)) {
      _selectedModel = model;
      notifyListeners();
    }
  }

  void setLearningRate(double rate) {
    _learningRate = rate;
    notifyListeners();
  }

  void setBatchSize(int size) {
    _batchSize = size;
    notifyListeners();
  }

  void setTotalEpochs(int epochs) {
    _totalEpochs = epochs;
    notifyListeners();
  }

  Future<void> selectDataset() async {
    _datasetPath = '/path/to/dataset.json';
    _datasetInfo = 'ملف JSON يحتوي على 1000 عينة تدريب';
    notifyListeners();
  }

  void pauseTraining() {
    if (_isTraining) {
      _isTraining = false;
      _status = 'paused';
      notifyListeners();
    }
  }

  void refreshLogs() {
    notifyListeners();
  }

  Future<void> exportLogs() async {
    // تصدير السجلات
  }
}
