// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Atlas AI';

  @override
  String get settingsTitle => 'App Settings';

  @override
  String get close => 'Close';

  @override
  String get aiTab => 'AI';

  @override
  String get appearanceTab => 'Appearance';

  @override
  String get advancedTab => 'Advanced';

  @override
  String get aboutTab => 'About';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get primaryColor => 'Primary Color';

  @override
  String get chooseNewColor => 'Choose New Color';

  @override
  String currentColor(String color) {
    return 'Current Color: $color';
  }

  @override
  String get fontFamily => 'Font Family';

  @override
  String get fontSize => 'Font Size';

  @override
  String get small => 'Small';

  @override
  String get large => 'Large';

  @override
  String fontSizePreview(int size) {
    return 'Text sample with selected size ($size)';
  }

  @override
  String get customBackground => 'Custom Background';

  @override
  String get currentBackground => '✨ Current Background ✨';

  @override
  String get changeBackground => 'Change Background';

  @override
  String get chooseBackground => 'Choose Background';

  @override
  String get removeBackground => 'Remove Background';

  @override
  String get useTheme => 'Use Theme';

  @override
  String get backgroundAppliedSuccess =>
      '✅ Custom background applied successfully';

  @override
  String get backgroundSelectionFailed => '❌ Failed to select image';

  @override
  String get backgroundRemovedSuccess =>
      '🔄 Returned to normal mode (light/dark)';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get restartRequired =>
      'Please restart the app to apply language changes';

  @override
  String get welcome => 'Welcome to Atlas AI';

  @override
  String get chatWithAI => 'Chat with AI';

  @override
  String get typeMessage => 'Type your message...';

  @override
  String get send => 'Send';

  @override
  String get newChat => 'New Chat';

  @override
  String get chatHistory => 'Chat History';

  @override
  String get settings => 'Settings';

  @override
  String get menu => 'Menu';

  @override
  String get search => 'Search';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get welcomeMessage1 => 'Welcome to Atlas AI! 🚀';

  @override
  String get welcomeMessage2 =>
      'Your AI assistant Atlas is here to answer all your questions 🤖';

  @override
  String get welcomeMessage3 => 'Ask me about anything on your mind! 💭';

  @override
  String get welcomeMessage4 =>
      'Tell me what\'s in your heart, I\'m here to help! 🌟';

  @override
  String get programming => 'Programming';

  @override
  String get dataAnalysis => 'Data Analysis';

  @override
  String get translation => 'Translation';

  @override
  String get creativeIdeas => 'Creative Ideas';

  @override
  String get learning => 'Learning';

  @override
  String get helpMeCode => 'Help me code: ';

  @override
  String get analyzeData => 'Analyze this data: ';

  @override
  String get translateThis => 'Translate this: ';

  @override
  String get creativeIdeasAbout => 'Give me creative ideas about: ';

  @override
  String get teachMeAbout => 'Teach me about: ';

  @override
  String get thinkingProcess => 'Thinking Process';

  @override
  String get completed => 'Completed';

  @override
  String get inProgress => 'In Progress';

  @override
  String completedIn(String duration) {
    return 'Completed in $duration';
  }

  @override
  String revisionOfStep(int step) {
    return 'Revision of step $step';
  }

  @override
  String get listening => 'Listening...';

  @override
  String get speechInitError =>
      'Failed to initialize speech service. Make sure to grant required permissions.';

  @override
  String speechControlError(String error) {
    return 'Error controlling voice: $error';
  }

  @override
  String get webSearch => 'Web Search';

  @override
  String get enterSearchQuery => 'Enter search query...';

  @override
  String get enhancingPrompt => 'Enhancing prompt with AI...';

  @override
  String get listening2 => 'Listening...';

  @override
  String get typeAnything => 'Type anything on your mind...';

  @override
  String get shareYourThoughts => 'Share anything on your mind...';

  @override
  String get apiSettings => 'API Settings';

  @override
  String get showKeys => 'Show Keys';

  @override
  String get hideKeys => 'Hide Keys';

  @override
  String get advancedModelTraining => 'Advanced Model Training';

  @override
  String get trainingSettings => 'Settings';

  @override
  String get trainingProgress => 'Progress';

  @override
  String get trainingLogs => 'Logs';

  @override
  String trainingStatus(String status) {
    return 'Training Status: $status';
  }

  @override
  String trainingProgress2(int progress) {
    return 'Progress: $progress%';
  }

  @override
  String epoch(int current, int total) {
    return 'Epoch: $current/$total';
  }

  @override
  String get startTraining => 'Start Training';

  @override
  String get pauseTraining => 'Pause';

  @override
  String get stopTraining => 'Stop Training';

  @override
  String get selectModel => 'Select Model';

  @override
  String get baseModel => 'Base Model';

  @override
  String get trainingParameters => 'Training Parameters';

  @override
  String learningRate(String rate) {
    return 'Learning Rate: $rate';
  }

  @override
  String batchSize(int size) {
    return 'Batch Size: $size';
  }

  @override
  String epochs(int epochs) {
    return 'Epochs: $epochs';
  }

  @override
  String get dataset => 'Dataset';

  @override
  String get uploadDatasetFile => 'Upload Dataset File';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String datasetInfo(String info) {
    return 'Dataset Info: $info';
  }

  @override
  String get overallProgress => 'Overall Progress';

  @override
  String get metrics => 'Metrics';

  @override
  String get timeRemaining => 'Time Remaining';

  @override
  String get speed => 'Speed';

  @override
  String get progressChart => 'Progress Chart\n(Coming Soon)';

  @override
  String get refresh => 'Refresh';

  @override
  String get clear => 'Clear';

  @override
  String get export => 'Export';

  @override
  String get idle => 'Idle';

  @override
  String get training => 'Training';

  @override
  String get errorStatus => 'Error';

  @override
  String get pausedStatus => 'Paused';

  @override
  String get stoppedStatus => 'Stopped';

  @override
  String get voiceInputButton =>
      'Voice input button with advanced visual effects';

  @override
  String get pulseAnimation => 'Pulse animation';

  @override
  String get waveAnimation => 'Wave animation';

  @override
  String get speechServiceInitFailed =>
      'Failed to initialize speech service. Make sure to grant required permissions.';

  @override
  String speechServiceError(String error) {
    return 'Speech service error: $error';
  }

  @override
  String voiceControlError(String error) {
    return 'Voice control error: $error';
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
  String get trainingStopped => 'Training stopped';

  @override
  String get scrollDown => 'Scroll Down';

  @override
  String get copySelected => 'Copy Selected';

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String get exportSelected => 'Export Selected';

  @override
  String get you => 'You';

  @override
  String get messagesCopied => 'Selected messages copied';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteMessages(int count) {
    return 'Are you sure you want to delete $count messages?';
  }

  @override
  String get messagesDeleted => 'Selected messages deleted';

  @override
  String get messagesExported => 'Selected messages exported';

  @override
  String get debugModel => 'Model';

  @override
  String get debugTemperature => 'Temperature';

  @override
  String get debugMaxTokens => 'Max Tokens';

  @override
  String get debugStreamResponse => 'Stream Response';

  @override
  String get debugWebSearch => 'Web Search';

  @override
  String get debugMcpServers => 'MCP Servers';

  @override
  String get debugAutoTextFormatting => 'Auto Text Formatting';

  @override
  String get debugEnabled => 'Enabled';

  @override
  String get debugDisabled => 'Disabled';

  @override
  String get debugMessageCount => 'Message Count';

  @override
  String get debugSessionCount => 'Session Count';

  @override
  String get debugAttachmentCount => 'Attachment Count';

  @override
  String get debugMode => 'Debug Mode';

  @override
  String get debugIsTyping => 'Is Typing';

  @override
  String get debugIsThinking => 'Is Thinking';

  @override
  String get debugYes => 'Yes';

  @override
  String get debugNo => 'No';

  @override
  String get debugApiKeyStatus => 'API Key Status';

  @override
  String get debugApiKeyAvailable => 'Available';

  @override
  String get debugApiKeyNotAvailable => 'Not Available';

  @override
  String get debugMcpServerStatus => 'MCP Server Status';

  @override
  String get debugMemoryServer => 'Memory Server';

  @override
  String get debugSequentialThinking => 'Sequential Thinking';

  @override
  String get debugCurrentThinking => 'Current Thinking Process';

  @override
  String get debugStepCount => 'Step Count';

  @override
  String get debugIsComplete => 'Is Complete';

  @override
  String get debugStartedAt => 'Started At';

  @override
  String get debugCompletedAt => 'Completed At';

  @override
  String get enableMcpServers => 'Enable MCP Servers';

  @override
  String get connectionTimeout => 'Connection Timeout';

  @override
  String get connectionTimeoutValue => '10 seconds';

  @override
  String get retryAttempts => 'Retry Attempts';

  @override
  String get retryAttemptsValue => '3 attempts';

  @override
  String get addServer => 'Add Server';

  @override
  String get addCustomMcpServer => 'Add Custom MCP Server';

  @override
  String get advancedMcpSettings => 'Advanced MCP Settings';

  @override
  String get enableMcpServersSubtitle =>
      'Enable Model Context Protocol servers';

  @override
  String get autoRetry => 'Auto Retry';

  @override
  String get autoRetrySubtitle => '3 attempts';

  @override
  String get connectionDiagnostics => 'Connection Diagnostics';

  @override
  String get connectionDiagnosticsSubtitle => 'Check MCP server status';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get clearCacheSubtitle => 'Delete MCP server temporary data';

  @override
  String get mcpDiagnosticsTitle => 'MCP Server Diagnostics';

  @override
  String get memoryServerStatus => 'Memory Server';

  @override
  String get memoryServerConnected => 'Connected and working normally';

  @override
  String get sequentialThinkingServerStatus => 'Sequential Thinking Server';

  @override
  String get sequentialThinkingConnected => 'Connected and working normally';

  @override
  String get customServers => 'Custom Servers';

  @override
  String get noCustomServers => 'No custom servers';

  @override
  String get clearCacheTitle => 'Clear Cache';

  @override
  String get clearCacheConfirm =>
      'Do you want to clear all temporary data for MCP servers?';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get mcpServersTitle => 'MCP Servers';

  @override
  String get trainingServiceInitError =>
      'Training service initialization error';

  @override
  String get advancedModelTrainingPage => 'Advanced Model Training';

  @override
  String get help => 'Help';

  @override
  String get exportData => 'Export Data';

  @override
  String get initializingTrainingService => 'Initializing training service...';

  @override
  String get sessionType => 'Type';

  @override
  String get sessionStatus => 'Status';

  @override
  String get sessionDate => 'Date';

  @override
  String get exportModel => 'Export Model';

  @override
  String get details => 'Details';

  @override
  String get restart => 'Restart';

  @override
  String get exportModelFeatureInDevelopment =>
      'Model export feature is under development';

  @override
  String get sessionDetails => 'Details';

  @override
  String get errorLabel => 'Error';

  @override
  String get deleteTrainingSession => 'Delete Training Session';

  @override
  String get deleteSessionConfirm =>
      'Do you want to permanently delete this session? All associated data will be deleted.';

  @override
  String get modelTrainingHelp => 'Help - Model Training';

  @override
  String get trainingSettingsTitle => 'Training Settings';

  @override
  String get advancedTrainingSettingsInDevelopment =>
      'Advanced training settings are under development';

  @override
  String get exportTrainingDataFeatureInDevelopment =>
      'Training data export feature is under development';

  @override
  String get active => 'Active';

  @override
  String get apiKeysStatus => 'API Keys Status';

  @override
  String get appReadyToWork => 'App ready to work ✅';

  @override
  String get groqKeyRequired => 'Groq key required ⚠️';

  @override
  String get usingFreeDefaultKeys => 'Using free default keys';

  @override
  String get keysDetails => 'Keys Details:';

  @override
  String get statistics => 'Statistics:';

  @override
  String availableKeys(int count) {
    return 'Available keys: $count/5';
  }

  @override
  String requiredKeys(String status) {
    return 'Required keys: $status';
  }

  @override
  String usingDefaultKeys(String status) {
    return 'Using default keys: $status';
  }

  @override
  String get available => 'Available';

  @override
  String get missing => 'Missing';

  @override
  String get required => 'Required';

  @override
  String get defaultKey => 'Default Key';

  @override
  String get clearApiKeys => 'Clear API Keys';

  @override
  String get warning => 'Warning';

  @override
  String get clearKeysConfirmation =>
      'Do you want to clear all saved API keys?\n\nThis action cannot be undone.';

  @override
  String get clearKeysWarning =>
      '• All saved keys will be cleared\n• Free default keys will be used\n• You can add your keys again anytime';

  @override
  String get keysSavedSuccess => 'Keys saved successfully! ✅';

  @override
  String errorSavingKeys(String error) {
    return 'Error saving keys: $error';
  }

  @override
  String get activeModel => 'Active Model';

  @override
  String processingImages(int count) {
    return 'Processing $count images...';
  }

  @override
  String errorProcessingImages(String error) {
    return 'Error processing images: $error';
  }

  @override
  String errorAddingImage(String error) {
    return 'Error adding image: $error';
  }

  @override
  String get trainingHistory => 'History';

  @override
  String get noPreviousTrainingSessions => 'No previous training sessions';

  @override
  String get previousSessionsWillAppearHere =>
      'Previous training sessions will appear here';

  @override
  String get trainingSessionStarted => 'Training started';

  @override
  String get trainingSessionStartFailed => 'Failed to start training';

  @override
  String get sessionDeleted => 'Session deleted';

  @override
  String get sessionDeleteFailed => 'Failed to delete session';

  @override
  String get supportedTrainingTypes => 'Supported Training Types:';

  @override
  String get fineTuning => '• Fine-tuning: Improve existing model';

  @override
  String get instructionTuning => '• Instruction Tuning: Train on instructions';

  @override
  String get conversationTuning =>
      '• Conversation Tuning: Train on conversations';

  @override
  String get domainSpecific =>
      '• Domain Specific: Specialize in specific domain';

  @override
  String get supportedFileTypes => 'Supported File Types:';

  @override
  String get txtFiles => '• .txt - Text files (max 50MB)';

  @override
  String get jsonFiles => '• .json - JSON files (max 100MB)';

  @override
  String get jsonlFiles => '• .jsonl - JSONL files (max 100MB)';

  @override
  String get csvFiles => '• .csv - CSV files (max 25MB)';

  @override
  String get mdFiles => '• .md - Markdown files (max 10MB)';

  @override
  String get tips => 'Tips:';

  @override
  String get useHighQualityData => '• Use high-quality data for best results';

  @override
  String get startWithLowLearningRate =>
      '• Start with low learning rate (0.001)';

  @override
  String get useEarlyStopping => '• Use early stopping to avoid overfitting';

  @override
  String get monitorLogs => '• Monitor logs to understand training progress';
}
