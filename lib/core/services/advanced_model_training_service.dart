import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// نماذج التدريب المدعومة
enum TrainingType {
  fineTuning('Fine-tuning', 'تحسين نموذج موجود'),
  instructionTuning('Instruction Tuning', 'تدريب على التعليمات'),
  conversationTuning('Conversation Tuning', 'تدريب على المحادثات'),
  domainSpecific('Domain Specific', 'تخصص مجال معين');

  const TrainingType(this.englishName, this.arabicName);
  final String englishName;
  final String arabicName;
}

/// أنواع الملفات المدعومة
enum SupportedFileType {
  txt('.txt', 'Text Files', 'ملفات نصية', 50 * 1024 * 1024), // 50MB
  json('.json', 'JSON Files', 'ملفات JSON', 100 * 1024 * 1024), // 100MB
  jsonl('.jsonl', 'JSONL Files', 'ملفات JSONL', 100 * 1024 * 1024), // 100MB
  csv('.csv', 'CSV Files', 'ملفات CSV', 25 * 1024 * 1024), // 25MB
  md('.md', 'Markdown Files', 'ملفات Markdown', 10 * 1024 * 1024); // 10MB

  const SupportedFileType(this.extension, this.englishName, this.arabicName, this.maxSize);
  final String extension;
  final String englishName;
  final String arabicName;
  final int maxSize; // بالبايت
}

/// حالة التدريب
enum TrainingStatus {
  idle('Idle', 'في الانتظار'),
  preparing('Preparing', 'جاري التحضير'),
  training('Training', 'جاري التدريب'),
  validating('Validating', 'جاري التحقق'),
  completed('Completed', 'مكتمل'),
  failed('Failed', 'فشل'),
  cancelled('Cancelled', 'ملغي');

  const TrainingStatus(this.englishName, this.arabicName);
  final String englishName;
  final String arabicName;
}

/// معلومات التدريب
class TrainingInfo {
  final String id;
  final String name;
  final TrainingType type;
  final TrainingStatus status;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double progress;
  final String? error;
  final Map<String, dynamic> config;
  final List<String> dataFiles;
  final Map<String, dynamic> metrics;

  TrainingInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    required this.progress,
    this.error,
    required this.config,
    required this.dataFiles,
    required this.metrics,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'startedAt': startedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'progress': progress,
    'error': error,
    'config': config,
    'dataFiles': dataFiles,
    'metrics': metrics,
  };

  factory TrainingInfo.fromJson(Map<String, dynamic> json) => TrainingInfo(
    id: json['id'],
    name: json['name'],
    type: TrainingType.values.firstWhere((e) => e.name == json['type']),
    status: TrainingStatus.values.firstWhere((e) => e.name == json['status']),
    createdAt: DateTime.parse(json['createdAt']),
    startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    progress: json['progress']?.toDouble() ?? 0.0,
    error: json['error'],
    config: Map<String, dynamic>.from(json['config']),
    dataFiles: List<String>.from(json['dataFiles']),
    metrics: Map<String, dynamic>.from(json['metrics']),
  );
}

/// إعدادات التدريب
class TrainingConfig {
  final double learningRate;
  final int epochs;
  final int batchSize;
  final double validationSplit;
  final bool useEarlyStopping;
  final int patience;
  final double dropoutRate;
  final String optimizer;
  final Map<String, dynamic> customParams;

  TrainingConfig({
    this.learningRate = 0.001,
    this.epochs = 10,
    this.batchSize = 32,
    this.validationSplit = 0.2,
    this.useEarlyStopping = true,
    this.patience = 3,
    this.dropoutRate = 0.1,
    this.optimizer = 'adam',
    this.customParams = const {},
  });

  Map<String, dynamic> toJson() => {
    'learningRate': learningRate,
    'epochs': epochs,
    'batchSize': batchSize,
    'validationSplit': validationSplit,
    'useEarlyStopping': useEarlyStopping,
    'patience': patience,
    'dropoutRate': dropoutRate,
    'optimizer': optimizer,
    'customParams': customParams,
  };

  factory TrainingConfig.fromJson(Map<String, dynamic> json) => TrainingConfig(
    learningRate: json['learningRate']?.toDouble() ?? 0.001,
    epochs: json['epochs'] ?? 10,
    batchSize: json['batchSize'] ?? 32,
    validationSplit: json['validationSplit']?.toDouble() ?? 0.2,
    useEarlyStopping: json['useEarlyStopping'] ?? true,
    patience: json['patience'] ?? 3,
    dropoutRate: json['dropoutRate']?.toDouble() ?? 0.1,
    optimizer: json['optimizer'] ?? 'adam',
    customParams: Map<String, dynamic>.from(json['customParams'] ?? {}),
  );
}

/// خدمة تدريب النماذج المتقدمة
class AdvancedModelTrainingService extends ChangeNotifier {
  static const String _dbName = 'training_data.db';
  static const int _dbVersion = 1;
  
  Database? _database;
  final StreamController<String> _logController = StreamController<String>.broadcast();
  final StreamController<TrainingInfo> _trainingController = StreamController<TrainingInfo>.broadcast();
  
  TrainingInfo? _currentTraining;
  final List<TrainingInfo> _trainingSessions = [];
  bool _isInitialized = false;

  /// Stream للسجلات
  Stream<String> get logStream => _logController.stream;
  
  /// Stream لحالة التدريب
  Stream<TrainingInfo> get trainingStream => _trainingController.stream;
  
  /// التدريب الحالي
  TrainingInfo? get currentTraining => _currentTraining;
  
  /// جلسات التدريب
  List<TrainingInfo> get trainingSessions => List.unmodifiable(_trainingSessions);
  
  /// هل الخدمة مهيأة
  bool get isInitialized => _isInitialized;

  /// تهيئة الخدمة
  Future<void> initialize() async {
    try {
      _log('🚀 بدء تهيئة خدمة تدريب النماذج المتقدمة...');
      
      await _initializeDatabase();
      await _loadTrainingSessions();
      
      _isInitialized = true;
      _log('✅ تم تهيئة خدمة التدريب بنجاح');
      
    } catch (e) {
      _log('❌ خطأ في تهيئة خدمة التدريب: $e');
      rethrow;
    }
  }

  /// تهيئة قاعدة البيانات
  Future<void> _initializeDatabase() async {
    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, _dbName);
    
    _database = await openDatabase(
      fullPath,
      version: _dbVersion,
      onCreate: _createTables,
      onUpgrade: _upgradeTables,
    );
  }

  /// إنشاء الجداول
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE training_sessions (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        started_at TEXT,
        completed_at TEXT,
        progress REAL NOT NULL DEFAULT 0,
        error TEXT,
        config TEXT NOT NULL,
        data_files TEXT NOT NULL,
        metrics TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE training_data (
        id TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        uploaded_at TEXT NOT NULL,
        processed BOOLEAN NOT NULL DEFAULT 0,
        FOREIGN KEY (session_id) REFERENCES training_sessions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE training_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        level TEXT NOT NULL,
        message TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES training_sessions (id) ON DELETE CASCADE
      )
    ''');
  }

  /// ترقية الجداول
  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    // سيتم إضافة منطق الترقية هنا عند الحاجة
    // للآن، لا توجد ترقيات مطلوبة
    return;
  }

  /// تحميل جلسات التدريب
  Future<void> _loadTrainingSessions() async {
    if (_database == null) return;

    final List<Map<String, dynamic>> maps = await _database!.query(
      'training_sessions',
      orderBy: 'created_at DESC',
    );

    _trainingSessions.clear();
    for (final map in maps) {
      final session = TrainingInfo(
        id: map['id'],
        name: map['name'],
        type: TrainingType.values.firstWhere((e) => e.name == map['type']),
        status: TrainingStatus.values.firstWhere((e) => e.name == map['status']),
        createdAt: DateTime.parse(map['created_at']),
        startedAt: map['started_at'] != null ? DateTime.parse(map['started_at']) : null,
        completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
        progress: map['progress']?.toDouble() ?? 0.0,
        error: map['error'],
        config: jsonDecode(map['config']),
        dataFiles: List<String>.from(jsonDecode(map['data_files'])),
        metrics: jsonDecode(map['metrics']),
      );
      _trainingSessions.add(session);
    }

    // العثور على التدريب النشط
    try {
      _currentTraining = _trainingSessions.firstWhere(
        (session) => session.status == TrainingStatus.training || session.status == TrainingStatus.preparing,
      );
    } catch (e) {
      _currentTraining = null;
    }
  }

  /// إنشاء جلسة تدريب جديدة
  Future<String> createTrainingSession({
    required String name,
    required TrainingType type,
    required TrainingConfig config,
  }) async {
    try {
      final sessionId = 'training_${DateTime.now().millisecondsSinceEpoch}';
      
      final session = TrainingInfo(
        id: sessionId,
        name: name,
        type: type,
        status: TrainingStatus.idle,
        createdAt: DateTime.now(),
        progress: 0.0,
        config: config.toJson(),
        dataFiles: [],
        metrics: {},
      );

      // حفظ في قاعدة البيانات
      await _database!.insert('training_sessions', {
        'id': session.id,
        'name': session.name,
        'type': session.type.name,
        'status': session.status.name,
        'created_at': session.createdAt.toIso8601String(),
        'progress': session.progress,
        'config': jsonEncode(session.config),
        'data_files': jsonEncode(session.dataFiles),
        'metrics': jsonEncode(session.metrics),
      });

      _trainingSessions.insert(0, session);
      notifyListeners();

      _log('✅ تم إنشاء جلسة تدريب جديدة: $name');
      return sessionId;

    } catch (e) {
      _log('❌ خطأ في إنشاء جلسة التدريب: $e');
      rethrow;
    }
  }

  /// التحقق من صحة الملف
  Future<bool> validateFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _log('❌ الملف غير موجود: $filePath');
        return false;
      }

      final extension = path.extension(filePath).toLowerCase();
      final fileType = SupportedFileType.values.where((type) => type.extension == extension).firstOrNull;
      
      if (fileType == null) {
        _log('❌ نوع الملف غير مدعوم: $extension');
        return false;
      }

      final fileSize = await file.length();
      if (fileSize > fileType.maxSize) {
        _log('❌ حجم الملف كبير جداً: ${_formatFileSize(fileSize)} > ${_formatFileSize(fileType.maxSize)}');
        return false;
      }

      // فحص محتوى الملف
      final isValid = await _validateFileContent(file, fileType);
      if (!isValid) {
        _log('❌ محتوى الملف غير صحيح');
        return false;
      }

      _log('✅ الملف صالح: ${path.basename(filePath)}');
      return true;

    } catch (e) {
      _log('❌ خطأ في التحقق من الملف: $e');
      return false;
    }
  }

  /// التحقق من محتوى الملف
  Future<bool> _validateFileContent(File file, SupportedFileType fileType) async {
    try {
      final content = await file.readAsString();
      
      switch (fileType) {
        case SupportedFileType.json:
          jsonDecode(content);
          break;
        case SupportedFileType.jsonl:
          final lines = content.split('\n').where((line) => line.trim().isNotEmpty);
          for (final line in lines) {
            jsonDecode(line);
          }
          break;
        case SupportedFileType.csv:
          final lines = content.split('\n');
          if (lines.length < 2) return false; // على الأقل header + row واحد
          break;
        case SupportedFileType.txt:
        case SupportedFileType.md:
          if (content.trim().isEmpty) return false;
          break;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// إضافة ملف بيانات
  Future<bool> addDataFile(String sessionId, String filePath) async {
    try {
      if (!await validateFile(filePath)) {
        return false;
      }

      final file = File(filePath);
      final fileName = path.basename(filePath);
      final fileSize = await file.length();
      final fileType = path.extension(filePath).toLowerCase();

      // إنشاء مجلد البيانات للجلسة
      final dataDir = await _getSessionDataDirectory(sessionId);
      await dataDir.create(recursive: true);

      // نسخ الملف إلى مجلد البيانات
      final targetPath = path.join(dataDir.path, fileName);
      await file.copy(targetPath);

      // حفظ معلومات الملف في قاعدة البيانات
      await _database!.insert('training_data', {
        'id': 'data_${DateTime.now().millisecondsSinceEpoch}',
        'session_id': sessionId,
        'file_name': fileName,
        'file_path': targetPath,
        'file_type': fileType,
        'file_size': fileSize,
        'uploaded_at': DateTime.now().toIso8601String(),
        'processed': 0,
      });

      // تحديث قائمة الملفات في الجلسة
      final sessionIndex = _trainingSessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex != -1) {
        final session = _trainingSessions[sessionIndex];
        final updatedDataFiles = [...session.dataFiles, targetPath];
        
        final updatedSession = TrainingInfo(
          id: session.id,
          name: session.name,
          type: session.type,
          status: session.status,
          createdAt: session.createdAt,
          startedAt: session.startedAt,
          completedAt: session.completedAt,
          progress: session.progress,
          error: session.error,
          config: session.config,
          dataFiles: updatedDataFiles,
          metrics: session.metrics,
        );

        _trainingSessions[sessionIndex] = updatedSession;
        
        // تحديث قاعدة البيانات
        await _database!.update(
          'training_sessions',
          {'data_files': jsonEncode(updatedDataFiles)},
          where: 'id = ?',
          whereArgs: [sessionId],
        );
      }

      notifyListeners();
      _log('✅ تم إضافة ملف البيانات: $fileName (${_formatFileSize(fileSize)})');
      return true;

    } catch (e) {
      _log('❌ خطأ في إضافة ملف البيانات: $e');
      return false;
    }
  }

  /// بدء التدريب
  Future<bool> startTraining(String sessionId) async {
    try {
      final sessionIndex = _trainingSessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) {
        _log('❌ جلسة التدريب غير موجودة: $sessionId');
        return false;
      }

      final session = _trainingSessions[sessionIndex];
      if (session.dataFiles.isEmpty) {
        _log('❌ لا توجد ملفات بيانات للتدريب');
        return false;
      }

      if (_currentTraining != null && 
          (_currentTraining!.status == TrainingStatus.training || 
           _currentTraining!.status == TrainingStatus.preparing)) {
        _log('❌ يوجد تدريب نشط حالياً');
        return false;
      }

      _log('🚀 بدء التدريب: ${session.name}');
      
      // تحديث حالة الجلسة
      await _updateTrainingStatus(sessionId, TrainingStatus.preparing);
      _currentTraining = _trainingSessions[sessionIndex];

      // بدء عملية التدريب في الخلفية
      _runTrainingProcess(sessionId);

      return true;

    } catch (e) {
      _log('❌ خطأ في بدء التدريب: $e');
      await _updateTrainingStatus(sessionId, TrainingStatus.failed, error: e.toString());
      return false;
    }
  }

  /// تشغيل عملية التدريب
  Future<void> _runTrainingProcess(String sessionId) async {
    try {
      final session = _trainingSessions.firstWhere((s) => s.id == sessionId);
      final config = TrainingConfig.fromJson(session.config);

      await _updateTrainingStatus(sessionId, TrainingStatus.training, startedAt: DateTime.now());

      // مرحلة تحضير البيانات
      _log('📊 تحضير البيانات...');
      await _updateProgress(sessionId, 0.1);
      await _prepareTrainingData(sessionId);

      // مرحلة التدريب الفعلي
      _log('🎯 بدء التدريب...');
      await _performTraining(sessionId, config);

      // مرحلة التحقق
      _log('🔍 التحقق من النموذج...');
      await _updateTrainingStatus(sessionId, TrainingStatus.validating);
      await _validateModel(sessionId);

      // اكتمال التدريب
      await _updateTrainingStatus(
        sessionId, 
        TrainingStatus.completed, 
        completedAt: DateTime.now(),
      );
      await _updateProgress(sessionId, 1.0);

      _log('🎉 اكتمل التدريب بنجاح!');

    } catch (e) {
      _log('❌ فشل التدريب: $e');
      await _updateTrainingStatus(sessionId, TrainingStatus.failed, error: e.toString());
    } finally {
      if (_currentTraining?.id == sessionId) {
        _currentTraining = null;
      }
    }
  }

  /// تحضير بيانات التدريب
  Future<void> _prepareTrainingData(String sessionId) async {
    final session = _trainingSessions.firstWhere((s) => s.id == sessionId);
    
    for (int i = 0; i < session.dataFiles.length; i++) {
      final filePath = session.dataFiles[i];
      _log('📄 معالجة ملف: ${path.basename(filePath)}');
      
      // محاكاة معالجة الملف
      await Future.delayed(const Duration(seconds: 2));
      
      // تحديث التقدم
      final progress = 0.1 + (0.3 * (i + 1) / session.dataFiles.length);
      await _updateProgress(sessionId, progress);
    }
  }

  /// تنفيذ التدريب
  Future<void> _performTraining(String sessionId, TrainingConfig config) async {
    final totalEpochs = config.epochs;
    
    for (int epoch = 1; epoch <= totalEpochs; epoch++) {
      _log('📈 Epoch $epoch/$totalEpochs');
      
      // محاكاة epoch
      await Future.delayed(Duration(milliseconds: 1000 + (epoch * 100)));
      
      // محاكاة metrics
      final loss = 2.0 * (1.0 - epoch / totalEpochs) + 0.1;
      final accuracy = 0.5 + (0.4 * epoch / totalEpochs);
      
      _log('   Loss: ${loss.toStringAsFixed(4)}, Accuracy: ${accuracy.toStringAsFixed(4)}');
      
      // تحديث المقاييس
      await _updateMetrics(sessionId, {
        'epoch': epoch,
        'loss': loss,
        'accuracy': accuracy,
        'learning_rate': config.learningRate,
      });
      
      // تحديث التقدم
      final progress = 0.4 + (0.5 * epoch / totalEpochs);
      await _updateProgress(sessionId, progress);

      // فحص Early Stopping
      if (config.useEarlyStopping && epoch > config.patience) {
        if (loss < 0.2) {
          _log('⏹️ إيقاف مبكر - تم الوصول للهدف');
          break;
        }
      }
    }
  }

  /// التحقق من النموذج
  Future<void> _validateModel(String sessionId) async {
    _log('🧪 تشغيل اختبارات التحقق...');
    
    // محاكاة اختبارات التحقق
    await Future.delayed(const Duration(seconds: 3));
    
    final validationAccuracy = 0.85 + (0.1 * (DateTime.now().millisecond % 100) / 100);
    
    await _updateMetrics(sessionId, {
      'validation_accuracy': validationAccuracy,
      'validation_completed': true,
    });
    
    await _updateProgress(sessionId, 0.95);
    _log('✅ دقة التحقق: ${validationAccuracy.toStringAsFixed(4)}');
  }

  /// تحديث حالة التدريب
  Future<void> _updateTrainingStatus(
    String sessionId,
    TrainingStatus status, {
    DateTime? startedAt,
    DateTime? completedAt,
    String? error,
  }) async {
    final sessionIndex = _trainingSessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    final session = _trainingSessions[sessionIndex];
    final updatedSession = TrainingInfo(
      id: session.id,
      name: session.name,
      type: session.type,
      status: status,
      createdAt: session.createdAt,
      startedAt: startedAt ?? session.startedAt,
      completedAt: completedAt ?? session.completedAt,
      progress: session.progress,
      error: error ?? session.error,
      config: session.config,
      dataFiles: session.dataFiles,
      metrics: session.metrics,
    );

    _trainingSessions[sessionIndex] = updatedSession;

    // تحديث قاعدة البيانات
    await _database!.update(
      'training_sessions',
      {
        'status': status.name,
        if (startedAt != null) 'started_at': startedAt.toIso8601String(),
        if (completedAt != null) 'completed_at': completedAt.toIso8601String(),
        if (error != null) 'error': error,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    _trainingController.add(updatedSession);
    notifyListeners();
  }

  /// تحديث التقدم
  Future<void> _updateProgress(String sessionId, double progress) async {
    final sessionIndex = _trainingSessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    final session = _trainingSessions[sessionIndex];
    final updatedSession = TrainingInfo(
      id: session.id,
      name: session.name,
      type: session.type,
      status: session.status,
      createdAt: session.createdAt,
      startedAt: session.startedAt,
      completedAt: session.completedAt,
      progress: progress.clamp(0.0, 1.0),
      error: session.error,
      config: session.config,
      dataFiles: session.dataFiles,
      metrics: session.metrics,
    );

    _trainingSessions[sessionIndex] = updatedSession;

    await _database!.update(
      'training_sessions',
      {'progress': progress},
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    _trainingController.add(updatedSession);
    notifyListeners();
  }

  /// تحديث المقاييس
  Future<void> _updateMetrics(String sessionId, Map<String, dynamic> newMetrics) async {
    final sessionIndex = _trainingSessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    final session = _trainingSessions[sessionIndex];
    final updatedMetrics = {...session.metrics, ...newMetrics};
    
    final updatedSession = TrainingInfo(
      id: session.id,
      name: session.name,
      type: session.type,
      status: session.status,
      createdAt: session.createdAt,
      startedAt: session.startedAt,
      completedAt: session.completedAt,
      progress: session.progress,
      error: session.error,
      config: session.config,
      dataFiles: session.dataFiles,
      metrics: updatedMetrics,
    );

    _trainingSessions[sessionIndex] = updatedSession;

    await _database!.update(
      'training_sessions',
      {'metrics': jsonEncode(updatedMetrics)},
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    _trainingController.add(updatedSession);
    notifyListeners();
  }

  /// إيقاف التدريب
  Future<bool> stopTraining(String sessionId) async {
    try {
      if (_currentTraining?.id != sessionId) {
        _log('❌ لا يوجد تدريب نشط لإيقافه');
        return false;
      }

      _log('⏹️ إيقاف التدريب...');
      await _updateTrainingStatus(sessionId, TrainingStatus.cancelled);
      _currentTraining = null;

      return true;
    } catch (e) {
      _log('❌ خطأ في إيقاف التدريب: $e');
      return false;
    }
  }

  /// حذف جلسة تدريب
  Future<bool> deleteTrainingSession(String sessionId) async {
    try {
      // التأكد من عدم وجود تدريب نشط
      if (_currentTraining?.id == sessionId) {
        await stopTraining(sessionId);
      }

      // حذف ملفات البيانات
      final dataDir = await _getSessionDataDirectory(sessionId);
      if (await dataDir.exists()) {
        await dataDir.delete(recursive: true);
      }

      // حذف من قاعدة البيانات
      await _database!.delete(
        'training_sessions',
        where: 'id = ?',
        whereArgs: [sessionId],
      );

      // حذف من القائمة
      _trainingSessions.removeWhere((s) => s.id == sessionId);
      notifyListeners();

      _log('✅ تم حذف جلسة التدريب');
      return true;

    } catch (e) {
      _log('❌ خطأ في حذف جلسة التدريب: $e');
      return false;
    }
  }

  /// الحصول على مجلد بيانات الجلسة
  Future<Directory> _getSessionDataDirectory(String sessionId) async {
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(path.join(appDir.path, 'training_data', sessionId));
  }

  /// تنسيق حجم الملف
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// إضافة سجل
  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message';
    
    if (kDebugMode) print(logMessage); // استخدام print بدلاً من AppLogger
    _logController.add(logMessage);

    // حفظ في قاعدة البيانات إذا كان هناك تدريب نشط
    if (_currentTraining != null) {
      _database?.insert('training_logs', {
        'session_id': _currentTraining!.id,
        'timestamp': timestamp,
        'level': 'INFO',
        'message': message,
      });
    }
  }

  @override
  void dispose() {
    _logController.close();
    _trainingController.close();
    _database?.close();
    super.dispose();
  }
}

