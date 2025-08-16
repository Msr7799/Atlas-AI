import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Atlas AI'**
  String get appTitle;

  /// Title for the settings dialog
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get settingsTitle;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// AI settings tab
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiTab;

  /// Appearance settings tab
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTab;

  /// Advanced options tab
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advancedTab;

  /// About app tab
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTab;

  /// Theme mode section title
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// Primary color section title
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get primaryColor;

  /// Choose color button text
  ///
  /// In en, this message translates to:
  /// **'Choose New Color'**
  String get chooseNewColor;

  /// Current color display text
  ///
  /// In en, this message translates to:
  /// **'Current Color: {color}'**
  String currentColor(String color);

  /// Font family section title
  ///
  /// In en, this message translates to:
  /// **'Font Family'**
  String get fontFamily;

  /// Font size section title
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// Small font size
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get small;

  /// Large font size
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get large;

  /// Font size preview text
  ///
  /// In en, this message translates to:
  /// **'Text sample with selected size ({size})'**
  String fontSizePreview(int size);

  /// Custom background section title
  ///
  /// In en, this message translates to:
  /// **'Custom Background'**
  String get customBackground;

  /// Current background preview text
  ///
  /// In en, this message translates to:
  /// **'✨ Current Background ✨'**
  String get currentBackground;

  /// Change background button text
  ///
  /// In en, this message translates to:
  /// **'Change Background'**
  String get changeBackground;

  /// Choose background button text
  ///
  /// In en, this message translates to:
  /// **'Choose Background'**
  String get chooseBackground;

  /// Remove background button text
  ///
  /// In en, this message translates to:
  /// **'Remove Background'**
  String get removeBackground;

  /// Use theme button text
  ///
  /// In en, this message translates to:
  /// **'Use Theme'**
  String get useTheme;

  /// Success message for background application
  ///
  /// In en, this message translates to:
  /// **'✅ Custom background applied successfully'**
  String get backgroundAppliedSuccess;

  /// Error message for background selection failure
  ///
  /// In en, this message translates to:
  /// **'❌ Failed to select image'**
  String get backgroundSelectionFailed;

  /// Success message for background removal
  ///
  /// In en, this message translates to:
  /// **'🔄 Returned to normal mode (light/dark)'**
  String get backgroundRemovedSuccess;

  /// Language section title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Arabic language option
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Language change confirmation message
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChanged(String language);

  /// Restart required message for language changes
  ///
  /// In en, this message translates to:
  /// **'Please restart the app to apply language changes'**
  String get restartRequired;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome to Atlas AI'**
  String get welcome;

  /// Chat with AI button text
  ///
  /// In en, this message translates to:
  /// **'Chat with AI'**
  String get chatWithAI;

  /// Message input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get typeMessage;

  /// Send button text
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// New chat button text
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// Chat history title
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

  /// Settings button text
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Menu button text
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// Search button text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Copy button text
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error text
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Yes button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// First welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome to Atlas AI! 🚀'**
  String get welcomeMessage1;

  /// Second welcome message
  ///
  /// In en, this message translates to:
  /// **'Your AI assistant Atlas is here to answer all your questions 🤖'**
  String get welcomeMessage2;

  /// Third welcome message
  ///
  /// In en, this message translates to:
  /// **'Ask me about anything on your mind! 💭'**
  String get welcomeMessage3;

  /// Fourth welcome message
  ///
  /// In en, this message translates to:
  /// **'Tell me what\'s in your heart, I\'m here to help! 🌟'**
  String get welcomeMessage4;

  /// Programming welcome chip
  ///
  /// In en, this message translates to:
  /// **'Programming'**
  String get programming;

  /// Data analysis welcome chip
  ///
  /// In en, this message translates to:
  /// **'Data Analysis'**
  String get dataAnalysis;

  /// Translation welcome chip
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// Creative ideas welcome chip
  ///
  /// In en, this message translates to:
  /// **'Creative Ideas'**
  String get creativeIdeas;

  /// Learning welcome chip
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get learning;

  /// Programming prompt prefix
  ///
  /// In en, this message translates to:
  /// **'Help me code: '**
  String get helpMeCode;

  /// Data analysis prompt prefix
  ///
  /// In en, this message translates to:
  /// **'Analyze this data: '**
  String get analyzeData;

  /// Translation prompt prefix
  ///
  /// In en, this message translates to:
  /// **'Translate this: '**
  String get translateThis;

  /// Creative ideas prompt prefix
  ///
  /// In en, this message translates to:
  /// **'Give me creative ideas about: '**
  String get creativeIdeasAbout;

  /// Learning prompt prefix
  ///
  /// In en, this message translates to:
  /// **'Teach me about: '**
  String get teachMeAbout;

  /// Thinking process widget title
  ///
  /// In en, this message translates to:
  /// **'Thinking Process'**
  String get thinkingProcess;

  /// Completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// In progress status
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// Completion time message
  ///
  /// In en, this message translates to:
  /// **'Completed in {duration}'**
  String completedIn(String duration);

  /// Revision indicator
  ///
  /// In en, this message translates to:
  /// **'Revision of step {step}'**
  String revisionOfStep(int step);

  /// Voice input listening status
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// Speech initialization error
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize speech service. Make sure to grant required permissions.'**
  String get speechInitError;

  /// Speech control error
  ///
  /// In en, this message translates to:
  /// **'Error controlling voice: {error}'**
  String speechControlError(String error);

  /// Web search dialog title
  ///
  /// In en, this message translates to:
  /// **'Web Search'**
  String get webSearch;

  /// Search query input hint
  ///
  /// In en, this message translates to:
  /// **'Enter search query...'**
  String get enterSearchQuery;

  /// Prompt enhancement status
  ///
  /// In en, this message translates to:
  /// **'Enhancing prompt with AI...'**
  String get enhancingPrompt;

  /// Voice listening status
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening2;

  /// Desktop input hint
  ///
  /// In en, this message translates to:
  /// **'Type anything on your mind...'**
  String get typeAnything;

  /// Mobile input hint
  ///
  /// In en, this message translates to:
  /// **'Share anything on your mind...'**
  String get shareYourThoughts;

  /// API settings page title
  ///
  /// In en, this message translates to:
  /// **'API Settings'**
  String get apiSettings;

  /// Show API keys tooltip
  ///
  /// In en, this message translates to:
  /// **'Show Keys'**
  String get showKeys;

  /// Hide API keys tooltip
  ///
  /// In en, this message translates to:
  /// **'Hide Keys'**
  String get hideKeys;

  /// Advanced model training page title
  ///
  /// In en, this message translates to:
  /// **'Advanced Model Training'**
  String get advancedModelTraining;

  /// Training settings tab
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get trainingSettings;

  /// Training progress tab
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get trainingProgress;

  /// Training logs tab
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get trainingLogs;

  /// Training status display
  ///
  /// In en, this message translates to:
  /// **'Training Status: {status}'**
  String trainingStatus(String status);

  /// Training progress display
  ///
  /// In en, this message translates to:
  /// **'Progress: {progress}%'**
  String trainingProgress2(int progress);

  /// Epoch display
  ///
  /// In en, this message translates to:
  /// **'Epoch: {current}/{total}'**
  String epoch(int current, int total);

  /// Start training button
  ///
  /// In en, this message translates to:
  /// **'Start Training'**
  String get startTraining;

  /// Pause training button
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTraining;

  /// Stop training button
  ///
  /// In en, this message translates to:
  /// **'Stop Training'**
  String get stopTraining;

  /// Model selection section
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get selectModel;

  /// Base model field label
  ///
  /// In en, this message translates to:
  /// **'Base Model'**
  String get baseModel;

  /// Training parameters section
  ///
  /// In en, this message translates to:
  /// **'Training Parameters'**
  String get trainingParameters;

  /// Learning rate display
  ///
  /// In en, this message translates to:
  /// **'Learning Rate: {rate}'**
  String learningRate(String rate);

  /// Batch size display
  ///
  /// In en, this message translates to:
  /// **'Batch Size: {size}'**
  String batchSize(int size);

  /// Epochs display
  ///
  /// In en, this message translates to:
  /// **'Epochs: {epochs}'**
  String epochs(int epochs);

  /// Dataset section
  ///
  /// In en, this message translates to:
  /// **'Dataset'**
  String get dataset;

  /// Upload dataset file button
  ///
  /// In en, this message translates to:
  /// **'Upload Dataset File'**
  String get uploadDatasetFile;

  /// No file selected message
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// Dataset info display
  ///
  /// In en, this message translates to:
  /// **'Dataset Info: {info}'**
  String datasetInfo(String info);

  /// Overall progress section
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get overallProgress;

  /// Metrics section
  ///
  /// In en, this message translates to:
  /// **'Metrics'**
  String get metrics;

  /// Time remaining metric
  ///
  /// In en, this message translates to:
  /// **'Time Remaining'**
  String get timeRemaining;

  /// Speed metric
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// Progress chart placeholder
  ///
  /// In en, this message translates to:
  /// **'Progress Chart\n(Coming Soon)'**
  String get progressChart;

  /// Refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Export button
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Idle status
  ///
  /// In en, this message translates to:
  /// **'Idle'**
  String get idle;

  /// Training status
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// Error status
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorStatus;

  /// Paused status
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get pausedStatus;

  /// Stopped status
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get stoppedStatus;

  /// Voice input button description
  ///
  /// In en, this message translates to:
  /// **'Voice input button with advanced visual effects'**
  String get voiceInputButton;

  /// Animation for pulse effect
  ///
  /// In en, this message translates to:
  /// **'Pulse animation'**
  String get pulseAnimation;

  /// Animation for wave effect
  ///
  /// In en, this message translates to:
  /// **'Wave animation'**
  String get waveAnimation;

  /// Speech service initialization failure
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize speech service. Make sure to grant required permissions.'**
  String get speechServiceInitFailed;

  /// Speech service error message
  ///
  /// In en, this message translates to:
  /// **'Speech service error: {error}'**
  String speechServiceError(String error);

  /// Voice control error message
  ///
  /// In en, this message translates to:
  /// **'Voice control error: {error}'**
  String voiceControlError(String error);

  /// Start animation process
  ///
  /// In en, this message translates to:
  /// **'Start animation'**
  String get startAnimation;

  /// Callback function call
  ///
  /// In en, this message translates to:
  /// **'Callback invocation'**
  String get callbackInvocation;

  /// Begin listening process
  ///
  /// In en, this message translates to:
  /// **'Start listening'**
  String get startListening;

  /// Check if speech result is final
  ///
  /// In en, this message translates to:
  /// **'If result is final, send it and stop listening'**
  String get finalResultCheck;

  /// Stop animation process
  ///
  /// In en, this message translates to:
  /// **'Stop animation'**
  String get stopAnimation;

  /// Stop listening process
  ///
  /// In en, this message translates to:
  /// **'Stop listening'**
  String get stopListening;

  /// Send final speech recognition result
  ///
  /// In en, this message translates to:
  /// **'Send final result if found'**
  String get sendFinalResult;

  /// Outer wave effects during listening
  ///
  /// In en, this message translates to:
  /// **'Outer waves (shown during listening)'**
  String get outerWaves;

  /// Main voice input button
  ///
  /// In en, this message translates to:
  /// **'Main button'**
  String get mainButton;

  /// Activity indicator during voice input
  ///
  /// In en, this message translates to:
  /// **'Activity indicator'**
  String get activityIndicator;

  /// Voice input display widget description
  ///
  /// In en, this message translates to:
  /// **'Widget to display recognized text during recording'**
  String get voiceInputDisplay;

  /// Unified training widget description
  ///
  /// In en, this message translates to:
  /// **'Unified widget for all training functions'**
  String get unifiedTrainingWidget;

  /// Quick information header
  ///
  /// In en, this message translates to:
  /// **'Header with quick information'**
  String get quickInfoHeader;

  /// Training status display format
  ///
  /// In en, this message translates to:
  /// **'Training status: {status}'**
  String trainingStatusDisplay(String status);

  /// Progress display format
  ///
  /// In en, this message translates to:
  /// **'Progress: {progress}%'**
  String progressDisplay(int progress);

  /// Epoch display format
  ///
  /// In en, this message translates to:
  /// **'Epoch: {current}/{total}'**
  String epochDisplay(int current, int total);

  /// Start training button tooltip
  ///
  /// In en, this message translates to:
  /// **'Start Training'**
  String get startTrainingTooltip;

  /// Pause training button tooltip
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pauseTrainingTooltip;

  /// Stop training button tooltip
  ///
  /// In en, this message translates to:
  /// **'Stop Training'**
  String get stopTrainingTooltip;

  /// Model selection section title
  ///
  /// In en, this message translates to:
  /// **'Model Selection'**
  String get modelSelection;

  /// Base model field label
  ///
  /// In en, this message translates to:
  /// **'Base Model'**
  String get baseModelLabel;

  /// Training parameters section title
  ///
  /// In en, this message translates to:
  /// **'Training Parameters'**
  String get trainingParametersSection;

  /// Learning rate display format
  ///
  /// In en, this message translates to:
  /// **'Learning Rate: {rate}'**
  String learningRateDisplay(String rate);

  /// Batch size display format
  ///
  /// In en, this message translates to:
  /// **'Batch Size: {size}'**
  String batchSizeDisplay(int size);

  /// Epochs display format
  ///
  /// In en, this message translates to:
  /// **'Epochs: {epochs}'**
  String epochsDisplay(int epochs);

  /// Dataset section title
  ///
  /// In en, this message translates to:
  /// **'Dataset'**
  String get datasetSection;

  /// Upload dataset file button text
  ///
  /// In en, this message translates to:
  /// **'Upload Dataset File'**
  String get uploadDatasetButton;

  /// No file selected message
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelectedMessage;

  /// Dataset info display format
  ///
  /// In en, this message translates to:
  /// **'Dataset Info: {info}'**
  String datasetInfoDisplay(String info);

  /// Training in progress status
  ///
  /// In en, this message translates to:
  /// **'Training in progress'**
  String get trainingInProgress;

  /// Training completed status
  ///
  /// In en, this message translates to:
  /// **'Training completed'**
  String get trainingCompleted;

  /// Training error status
  ///
  /// In en, this message translates to:
  /// **'Training error'**
  String get trainingError;

  /// Training paused status
  ///
  /// In en, this message translates to:
  /// **'Training paused'**
  String get trainingPaused;

  /// Training stopped status
  ///
  /// In en, this message translates to:
  /// **'Training stopped'**
  String get trainingStopped;

  /// No description provided for @scrollDown.
  ///
  /// In en, this message translates to:
  /// **'Scroll Down'**
  String get scrollDown;

  /// No description provided for @copySelected.
  ///
  /// In en, this message translates to:
  /// **'Copy Selected'**
  String get copySelected;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @exportSelected.
  ///
  /// In en, this message translates to:
  /// **'Export Selected'**
  String get exportSelected;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @messagesCopied.
  ///
  /// In en, this message translates to:
  /// **'Selected messages copied'**
  String get messagesCopied;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// Confirm delete messages dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {count} messages?'**
  String confirmDeleteMessages(int count);

  /// No description provided for @messagesDeleted.
  ///
  /// In en, this message translates to:
  /// **'Selected messages deleted'**
  String get messagesDeleted;

  /// No description provided for @messagesExported.
  ///
  /// In en, this message translates to:
  /// **'Selected messages exported'**
  String get messagesExported;

  /// No description provided for @debugModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get debugModel;

  /// No description provided for @debugTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get debugTemperature;

  /// No description provided for @debugMaxTokens.
  ///
  /// In en, this message translates to:
  /// **'Max Tokens'**
  String get debugMaxTokens;

  /// No description provided for @debugStreamResponse.
  ///
  /// In en, this message translates to:
  /// **'Stream Response'**
  String get debugStreamResponse;

  /// No description provided for @debugWebSearch.
  ///
  /// In en, this message translates to:
  /// **'Web Search'**
  String get debugWebSearch;

  /// No description provided for @debugMcpServers.
  ///
  /// In en, this message translates to:
  /// **'MCP Servers'**
  String get debugMcpServers;

  /// No description provided for @debugAutoTextFormatting.
  ///
  /// In en, this message translates to:
  /// **'Auto Text Formatting'**
  String get debugAutoTextFormatting;

  /// No description provided for @debugEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get debugEnabled;

  /// No description provided for @debugDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get debugDisabled;

  /// No description provided for @debugMessageCount.
  ///
  /// In en, this message translates to:
  /// **'Message Count'**
  String get debugMessageCount;

  /// No description provided for @debugSessionCount.
  ///
  /// In en, this message translates to:
  /// **'Session Count'**
  String get debugSessionCount;

  /// No description provided for @debugAttachmentCount.
  ///
  /// In en, this message translates to:
  /// **'Attachment Count'**
  String get debugAttachmentCount;

  /// No description provided for @debugMode.
  ///
  /// In en, this message translates to:
  /// **'Debug Mode'**
  String get debugMode;

  /// No description provided for @debugIsTyping.
  ///
  /// In en, this message translates to:
  /// **'Is Typing'**
  String get debugIsTyping;

  /// No description provided for @debugIsThinking.
  ///
  /// In en, this message translates to:
  /// **'Is Thinking'**
  String get debugIsThinking;

  /// No description provided for @debugYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get debugYes;

  /// No description provided for @debugNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get debugNo;

  /// No description provided for @debugApiKeyStatus.
  ///
  /// In en, this message translates to:
  /// **'API Key Status'**
  String get debugApiKeyStatus;

  /// No description provided for @debugApiKeyAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get debugApiKeyAvailable;

  /// No description provided for @debugApiKeyNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get debugApiKeyNotAvailable;

  /// No description provided for @debugMcpServerStatus.
  ///
  /// In en, this message translates to:
  /// **'MCP Server Status'**
  String get debugMcpServerStatus;

  /// No description provided for @debugMemoryServer.
  ///
  /// In en, this message translates to:
  /// **'Memory Server'**
  String get debugMemoryServer;

  /// No description provided for @debugSequentialThinking.
  ///
  /// In en, this message translates to:
  /// **'Sequential Thinking'**
  String get debugSequentialThinking;

  /// No description provided for @debugCurrentThinking.
  ///
  /// In en, this message translates to:
  /// **'Current Thinking Process'**
  String get debugCurrentThinking;

  /// No description provided for @debugStepCount.
  ///
  /// In en, this message translates to:
  /// **'Step Count'**
  String get debugStepCount;

  /// No description provided for @debugIsComplete.
  ///
  /// In en, this message translates to:
  /// **'Is Complete'**
  String get debugIsComplete;

  /// No description provided for @debugStartedAt.
  ///
  /// In en, this message translates to:
  /// **'Started At'**
  String get debugStartedAt;

  /// No description provided for @debugCompletedAt.
  ///
  /// In en, this message translates to:
  /// **'Completed At'**
  String get debugCompletedAt;

  /// No description provided for @enableMcpServers.
  ///
  /// In en, this message translates to:
  /// **'Enable MCP Servers'**
  String get enableMcpServers;

  /// No description provided for @connectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection Timeout'**
  String get connectionTimeout;

  /// No description provided for @connectionTimeoutValue.
  ///
  /// In en, this message translates to:
  /// **'10 seconds'**
  String get connectionTimeoutValue;

  /// No description provided for @retryAttempts.
  ///
  /// In en, this message translates to:
  /// **'Retry Attempts'**
  String get retryAttempts;

  /// No description provided for @retryAttemptsValue.
  ///
  /// In en, this message translates to:
  /// **'3 attempts'**
  String get retryAttemptsValue;

  /// No description provided for @addServer.
  ///
  /// In en, this message translates to:
  /// **'Add Server'**
  String get addServer;

  /// No description provided for @addCustomMcpServer.
  ///
  /// In en, this message translates to:
  /// **'Add Custom MCP Server'**
  String get addCustomMcpServer;

  /// No description provided for @advancedMcpSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced MCP Settings'**
  String get advancedMcpSettings;

  /// No description provided for @enableMcpServersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Model Context Protocol servers'**
  String get enableMcpServersSubtitle;

  /// No description provided for @autoRetry.
  ///
  /// In en, this message translates to:
  /// **'Auto Retry'**
  String get autoRetry;

  /// No description provided for @autoRetrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'3 attempts'**
  String get autoRetrySubtitle;

  /// No description provided for @connectionDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Connection Diagnostics'**
  String get connectionDiagnostics;

  /// No description provided for @connectionDiagnosticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check MCP server status'**
  String get connectionDiagnosticsSubtitle;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @clearCacheSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete MCP server temporary data'**
  String get clearCacheSubtitle;

  /// No description provided for @mcpDiagnosticsTitle.
  ///
  /// In en, this message translates to:
  /// **'MCP Server Diagnostics'**
  String get mcpDiagnosticsTitle;

  /// No description provided for @memoryServerStatus.
  ///
  /// In en, this message translates to:
  /// **'Memory Server'**
  String get memoryServerStatus;

  /// No description provided for @memoryServerConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected and working normally'**
  String get memoryServerConnected;

  /// No description provided for @sequentialThinkingServerStatus.
  ///
  /// In en, this message translates to:
  /// **'Sequential Thinking Server'**
  String get sequentialThinkingServerStatus;

  /// No description provided for @sequentialThinkingConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected and working normally'**
  String get sequentialThinkingConnected;

  /// No description provided for @customServers.
  ///
  /// In en, this message translates to:
  /// **'Custom Servers'**
  String get customServers;

  /// No description provided for @noCustomServers.
  ///
  /// In en, this message translates to:
  /// **'No custom servers'**
  String get noCustomServers;

  /// No description provided for @clearCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCacheTitle;

  /// No description provided for @clearCacheConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to clear all temporary data for MCP servers?'**
  String get clearCacheConfirm;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// No description provided for @mcpServersTitle.
  ///
  /// In en, this message translates to:
  /// **'MCP Servers'**
  String get mcpServersTitle;

  /// No description provided for @trainingServiceInitError.
  ///
  /// In en, this message translates to:
  /// **'Training service initialization error'**
  String get trainingServiceInitError;

  /// No description provided for @advancedModelTrainingPage.
  ///
  /// In en, this message translates to:
  /// **'Advanced Model Training'**
  String get advancedModelTrainingPage;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @initializingTrainingService.
  ///
  /// In en, this message translates to:
  /// **'Initializing training service...'**
  String get initializingTrainingService;

  /// No description provided for @sessionType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get sessionType;

  /// No description provided for @sessionStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get sessionStatus;

  /// No description provided for @sessionDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sessionDate;

  /// No description provided for @exportModel.
  ///
  /// In en, this message translates to:
  /// **'Export Model'**
  String get exportModel;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @exportModelFeatureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Model export feature is under development'**
  String get exportModelFeatureInDevelopment;

  /// No description provided for @sessionDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get sessionDetails;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorLabel;

  /// No description provided for @deleteTrainingSession.
  ///
  /// In en, this message translates to:
  /// **'Delete Training Session'**
  String get deleteTrainingSession;

  /// No description provided for @deleteSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to permanently delete this session? All associated data will be deleted.'**
  String get deleteSessionConfirm;

  /// No description provided for @modelTrainingHelp.
  ///
  /// In en, this message translates to:
  /// **'Help - Model Training'**
  String get modelTrainingHelp;

  /// No description provided for @trainingSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Training Settings'**
  String get trainingSettingsTitle;

  /// No description provided for @advancedTrainingSettingsInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Advanced training settings are under development'**
  String get advancedTrainingSettingsInDevelopment;

  /// No description provided for @exportTrainingDataFeatureInDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Training data export feature is under development'**
  String get exportTrainingDataFeatureInDevelopment;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
