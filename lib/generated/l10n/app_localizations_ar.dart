// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أطلس الذكي';

  @override
  String get settingsTitle => 'إعدادات التطبيق';

  @override
  String get close => 'إغلاق';

  @override
  String get aiTab => 'الذكاء الاصطناعي';

  @override
  String get appearanceTab => 'المظهر';

  @override
  String get advancedTab => 'خيارات متقدمة';

  @override
  String get aboutTab => 'حول التطبيق';

  @override
  String get themeMode => 'وضع المظهر';

  @override
  String get lightTheme => '🌞';

  @override
  String get darkTheme => '🌙';

  @override
  String get primaryColor => '🎨 لون التطبيق الأساسي';

  @override
  String get chooseNewColor => 'اختيار لون جديد';

  @override
  String currentColor(String color) {
    return 'اللون الحالي: $color';
  }

  @override
  String get fontFamily => '🔤 الخط المستخدم';

  @override
  String get fontSize => '📏 حجم الخط';

  @override
  String get small => 'صغير';

  @override
  String get large => 'كبير';

  @override
  String fontSizePreview(int size) {
    return 'نموذج للنص بالحجم المحدد ($size)';
  }

  @override
  String get customBackground => '🖼️ الخلفية المخصصة';

  @override
  String get currentBackground => '✨ الخلفية الحالية ✨';

  @override
  String get changeBackground => 'تغيير الخلفية';

  @override
  String get chooseBackground => 'اختيار خلفية';

  @override
  String get removeBackground => 'بدون خلفية';

  @override
  String get useTheme => 'استخدام الثيم';

  @override
  String get backgroundAppliedSuccess => '✅ تم تطبيق الخلفية المخصصة بنجاح';

  @override
  String get backgroundSelectionFailed => '❌ فشل في اختيار الصورة';

  @override
  String get backgroundRemovedSuccess =>
      '🔄 تم العودة للوضع العادي (ليلي/نهاري)';

  @override
  String get language => '🌐 اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String languageChanged(String language) {
    return 'تم تغيير اللغة إلى $language';
  }

  @override
  String get restartRequired => 'يرجى إعادة تشغيل التطبيق لتطبيق تغييرات اللغة';

  @override
  String get welcome => 'مرحباً بك في أطلس الذكي';

  @override
  String get chatWithAI => 'تحدث مع الذكاء الاصطناعي';

  @override
  String get typeMessage => 'اكتب رسالتك...';

  @override
  String get send => 'إرسال';

  @override
  String get newChat => 'محادثة جديدة';

  @override
  String get chatHistory => 'سجل المحادثات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get menu => 'القائمة';

  @override
  String get search => 'البحث';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get copy => 'نسخ';

  @override
  String get share => 'مشاركة';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get ok => 'موافق';

  @override
  String get welcomeMessage1 => 'هلا بلي له الخافق يهلي 🚀';

  @override
  String get welcomeMessage2 =>
      'مساعدك أطلس يسموني ابوالعريف باجاوب جميع أسئلتك 🤖';

  @override
  String get welcomeMessage3 => 'قول أسأل عن أي شي أيي في بالك؟ 💭';

  @override
  String get welcomeMessage4 => 'قول اللي في قلبك أنا واحد مافتن ! 🌟';

  @override
  String get programming => 'البرمجة';

  @override
  String get dataAnalysis => 'تحليل البيانات';

  @override
  String get translation => 'الترجمة';

  @override
  String get creativeIdeas => 'أفكار إبداعية';

  @override
  String get learning => 'التعلم';

  @override
  String get helpMeCode => 'أبيك تبرمج لي: ';

  @override
  String get analyzeData => 'حلل هذه البيانات: ';

  @override
  String get translateThis => 'ترجم هذي: ';

  @override
  String get creativeIdeasAbout => 'عطني افكارك وأتحفي في  ';

  @override
  String get teachMeAbout => 'أبيك تعلمني على  ';

  @override
  String get thinkingProcess => 'عملية التفكير';

  @override
  String get completed => 'مكتملة';

  @override
  String get inProgress => 'جارية';

  @override
  String completedIn(String duration) {
    return 'اكتملت في $duration';
  }

  @override
  String revisionOfStep(int step) {
    return 'تنقيح للخطوة $step';
  }

  @override
  String get listening => 'جاري الاستماع...';

  @override
  String get speechInitError =>
      'فشل في تهيئة خدمة الصوت. تأكد من منح الأذونات المطلوبة.';

  @override
  String speechControlError(String error) {
    return 'خطأ في التحكم بالصوت: $error';
  }

  @override
  String get webSearch => 'البحث في الويب';

  @override
  String get enterSearchQuery => 'أدخل استعلام البحث...';

  @override
  String get enhancingPrompt =>
      'جاري تحسين البرومبت باستخدام الذكاء الاصطناعي...';

  @override
  String get listening2 => 'أستمع...';

  @override
  String get typeAnything => 'أكتب أي شي يدور في خاطرك...';

  @override
  String get shareYourThoughts => 'أتحفني بأي شي يدور في خاطرك...';

  @override
  String get apiSettings => 'إعدادات API';

  @override
  String get showKeys => 'إظهار المفاتيح';

  @override
  String get hideKeys => 'إخفاء المفاتيح';

  @override
  String get advancedModelTraining => 'Advanced Model Training';

  @override
  String get trainingSettings => 'الإعدادات';

  @override
  String get trainingProgress => 'Progress';

  @override
  String get trainingLogs => 'Logs';

  @override
  String trainingStatus(String status) {
    return 'حالة التدريب: $status';
  }

  @override
  String trainingProgress2(int progress) {
    return 'التقدم: $progress%';
  }

  @override
  String epoch(int current, int total) {
    return 'الحقبة: $current/$total';
  }

  @override
  String get startTraining => 'بدء التدريب';

  @override
  String get pauseTraining => 'إيقاف مؤقت';

  @override
  String get stopTraining => 'إيقاف التدريب';

  @override
  String get selectModel => 'اختيار النموذج';

  @override
  String get baseModel => 'النموذج الأساسي';

  @override
  String get trainingParameters => 'معاملات التدريب';

  @override
  String learningRate(String rate) {
    return 'معدل التعلم: $rate';
  }

  @override
  String batchSize(int size) {
    return 'حجم الدفعة: $size';
  }

  @override
  String epochs(int epochs) {
    return 'عدد الحقب: $epochs';
  }

  @override
  String get dataset => 'مجموعة البيانات';

  @override
  String get uploadDatasetFile => 'رفع ملف البيانات';

  @override
  String get noFileSelected => 'لم يتم اختيار ملف';

  @override
  String datasetInfo(String info) {
    return 'معلومات البيانات: $info';
  }

  @override
  String get overallProgress => 'التقدم الإجمالي';

  @override
  String get metrics => 'المقاييس';

  @override
  String get timeRemaining => 'الوقت المتبقي';

  @override
  String get speed => 'السرعة';

  @override
  String get progressChart => 'رسم بياني للتقدم\n(سيتم إضافته لاحقاً)';

  @override
  String get refresh => 'تحديث';

  @override
  String get clear => 'مسح';

  @override
  String get export => 'تصدير';

  @override
  String get idle => 'في الانتظار';

  @override
  String get training => 'قيد التدريب';

  @override
  String get errorStatus => 'خطأ';

  @override
  String get pausedStatus => 'متوقف مؤقتاً';

  @override
  String get stoppedStatus => 'متوقف';

  @override
  String get voiceInputButton =>
      'Voice input button with advanced visual effects';

  @override
  String get pulseAnimation => 'Pulse animation';

  @override
  String get waveAnimation => 'Wave animation';

  @override
  String get speechServiceInitFailed =>
      'فشل في تهيئة خدمة الصوت. تأكد من منح الأذونات المطلوبة.';

  @override
  String speechServiceError(String error) {
    return 'Speech service error: $error';
  }

  @override
  String voiceControlError(String error) {
    return 'خطأ في التحكم بالصوت';
  }

  @override
  String get startAnimation => 'Start animation';

  @override
  String get callbackInvocation => 'Callback invocation';

  @override
  String get startListening => 'Start listening';

  @override
  String get finalResultCheck =>
      'If result is final, send it and stop listening';

  @override
  String get stopAnimation => 'Stop animation';

  @override
  String get stopListening => 'Stop listening';

  @override
  String get sendFinalResult => 'Send final result if found';

  @override
  String get outerWaves => 'Outer waves (shown during listening)';

  @override
  String get mainButton => 'Main button';

  @override
  String get activityIndicator => 'Activity indicator';

  @override
  String get voiceInputDisplay =>
      'Widget to display recognized text during recording';

  @override
  String get unifiedTrainingWidget =>
      'Unified widget for all training functions';

  @override
  String get quickInfoHeader => 'Header with quick information';

  @override
  String trainingStatusDisplay(String status) {
    return 'Training status: $status';
  }

  @override
  String progressDisplay(int progress) {
    return 'Progress: $progress%';
  }

  @override
  String epochDisplay(int current, int total) {
    return 'Epoch: $current/$total';
  }

  @override
  String get startTrainingTooltip => 'Start Training';

  @override
  String get pauseTrainingTooltip => 'Pause';

  @override
  String get stopTrainingTooltip => 'Stop Training';

  @override
  String get modelSelection => 'Model Selection';

  @override
  String get baseModelLabel => 'Base Model';

  @override
  String get trainingParametersSection => 'Training Parameters';

  @override
  String learningRateDisplay(String rate) {
    return 'Learning Rate: $rate';
  }

  @override
  String batchSizeDisplay(int size) {
    return 'Batch Size: $size';
  }

  @override
  String epochsDisplay(int epochs) {
    return 'Epochs: $epochs';
  }

  @override
  String get datasetSection => 'Dataset';

  @override
  String get uploadDatasetButton => 'Upload Dataset File';

  @override
  String get noFileSelectedMessage => 'No file selected';

  @override
  String datasetInfoDisplay(String info) {
    return 'Dataset Info: $info';
  }

  @override
  String get trainingInProgress => 'Training in progress';

  @override
  String get trainingCompleted => 'Training completed';

  @override
  String get trainingError => 'Training error';

  @override
  String get trainingPaused => 'Training paused';

  @override
  String get trainingStopped => 'تم إيقاف التدريب';

  @override
  String get scrollDown => 'التمرير للأسفل';

  @override
  String get copySelected => 'نسخ المحدد';

  @override
  String get deleteSelected => 'حذف المحدد';

  @override
  String get exportSelected => 'تصدير المحدد';

  @override
  String get you => 'أنت';

  @override
  String get messagesCopied => 'تم نسخ الرسائل المحددة';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String confirmDeleteMessages(int count) {
    return 'هل أنت متأكد من حذف $count رسالة؟';
  }

  @override
  String get messagesDeleted => 'تم حذف الرسائل المحددة';

  @override
  String get messagesExported => 'تم تصدير الرسائل المحددة';

  @override
  String get debugModel => 'النموذج';

  @override
  String get debugTemperature => 'درجة الحرارة';

  @override
  String get debugMaxTokens => 'الحد الأقصى للرموز';

  @override
  String get debugStreamResponse => 'الاستجابة المتدفقة';

  @override
  String get debugWebSearch => 'البحث في الويب';

  @override
  String get debugMcpServers => 'خوادم MCP';

  @override
  String get debugAutoTextFormatting => 'المعالجة التلقائية للنص';

  @override
  String get debugEnabled => 'مفعل';

  @override
  String get debugDisabled => 'معطل';

  @override
  String get debugMessageCount => 'عدد الرسائل';

  @override
  String get debugSessionCount => 'عدد الجلسات';

  @override
  String get debugAttachmentCount => 'عدد المرفقات';

  @override
  String get debugMode => 'وضع التشخيص';

  @override
  String get debugIsTyping => 'يكتب الآن';

  @override
  String get debugIsThinking => 'يفكر الآن';

  @override
  String get debugYes => 'نعم';

  @override
  String get debugNo => 'لا';

  @override
  String get debugApiKeyStatus => 'حالة مفاتيح API';

  @override
  String get debugApiKeyAvailable => 'متوفر';

  @override
  String get debugApiKeyNotAvailable => 'غير متوفر';

  @override
  String get debugMcpServerStatus => 'حالة خوادم MCP';

  @override
  String get debugMemoryServer => 'خادم الذاكرة';

  @override
  String get debugSequentialThinking => 'التفكير التسلسلي';

  @override
  String get debugCurrentThinking => 'عملية التفكير الحالية';

  @override
  String get debugStepCount => 'عدد الخطوات';

  @override
  String get debugIsComplete => 'مكتملة';

  @override
  String get debugStartedAt => 'بدأت في';

  @override
  String get debugCompletedAt => 'انتهت في';

  @override
  String get enableMcpServers => 'تفعيل خوادم MCP';

  @override
  String get connectionTimeout => 'مهلة الاتصال';

  @override
  String get connectionTimeoutValue => '10 ثوان';

  @override
  String get retryAttempts => 'إعادة المحاولة';

  @override
  String get retryAttemptsValue => '3 محاولات';

  @override
  String get addServer => 'إضافة خادم';

  @override
  String get addCustomMcpServer => 'إضافة خادم MCP مخصص';

  @override
  String get advancedMcpSettings => 'إعدادات MCP المتقدمة';

  @override
  String get enableMcpServersSubtitle =>
      'تمكين استخدام خوادم Model Context Protocol';

  @override
  String get autoRetry => 'إعادة المحاولة التلقائية';

  @override
  String get autoRetrySubtitle => '3 محاولات';

  @override
  String get connectionDiagnostics => 'تشخيص الاتصال';

  @override
  String get connectionDiagnosticsSubtitle => 'فحص حالة خوادم MCP';

  @override
  String get clearCache => 'مسح ذاكرة التخزين المؤقت';

  @override
  String get clearCacheSubtitle => 'حذف البيانات المؤقتة لخوادم MCP';

  @override
  String get mcpDiagnosticsTitle => 'تشخيص خوادم MCP';

  @override
  String get memoryServerStatus => 'خادم الذاكرة';

  @override
  String get memoryServerConnected => 'متصل ويعمل بشكل طبيعي';

  @override
  String get sequentialThinkingServerStatus => 'خادم التفكير التسلسلي';

  @override
  String get sequentialThinkingConnected => 'متصل ويعمل بشكل طبيعي';

  @override
  String get customServers => 'الخوادم المخصصة';

  @override
  String get noCustomServers => 'لا توجد خوادم مخصصة';

  @override
  String get clearCacheTitle => 'مسح ذاكرة التخزين المؤقت';

  @override
  String get clearCacheConfirm =>
      'هل تريد مسح جميع البيانات المؤقتة لخوادم MCP؟';

  @override
  String get cacheCleared => 'تم مسح ذاكرة التخزين المؤقت';

  @override
  String get mcpServersTitle => 'خوادم MCP';

  @override
  String get trainingServiceInitError => 'خطأ في تهيئة خدمة التدريب';

  @override
  String get advancedModelTrainingPage => 'تدريب النماذج المتقدم';

  @override
  String get help => 'مساعدة';

  @override
  String get exportData => 'تصدير البيانات';

  @override
  String get initializingTrainingService => 'جاري تهيئة خدمة التدريب...';

  @override
  String get sessionType => 'النوع';

  @override
  String get sessionStatus => 'الحالة';

  @override
  String get sessionDate => 'التاريخ';

  @override
  String get exportModel => 'تصدير النموذج';

  @override
  String get details => 'التفاصيل';

  @override
  String get restart => 'إعادة التشغيل';

  @override
  String get exportModelFeatureInDevelopment =>
      'ميزة تصدير النموذج قيد التطوير';

  @override
  String get sessionDetails => 'تفاصيل';

  @override
  String get errorLabel => 'خطأ';

  @override
  String get deleteTrainingSession => 'حذف جلسة التدريب';

  @override
  String get deleteSessionConfirm =>
      'هل تريد حذف هذه الجلسة نهائياً؟ سيتم حذف جميع البيانات المرتبطة بها.';

  @override
  String get modelTrainingHelp => 'مساعدة - تدريب النماذج';

  @override
  String get trainingSettingsTitle => 'إعدادات التدريب';

  @override
  String get advancedTrainingSettingsInDevelopment =>
      'إعدادات التدريب المتقدمة قيد التطوير';

  @override
  String get exportTrainingDataFeatureInDevelopment =>
      'ميزة تصدير بيانات التدريب قيد التطوير';

  @override
  String get active => 'نشط';
}
