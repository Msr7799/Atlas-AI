# Atlas AI Advanced Features

![alt text](assets/icons/app_icon4.png?width=50&height=50)
[![Read in Arabic](https://img.shields.io/badge/Read%20in%20Arabic-white?style=for-the-badge&logo=readme&logoColor=black)](FEATURES-ar.md)

## ✨ Complete Feature Overview

Atlas AI provides comprehensive AI assistance with advanced features, multiple model integrations, and robust performance optimizations. This document outlines all available features and capabilities.

## 🔑 Enhanced API Key Management System

### Free Default Keys

- **Groq**: Free default key for immediate use
- **GPTGod**: Free default key with 17 models  
- **Tavily**: Default key for web search

### Smart Fallback System

```dart
// If user doesn't enter a key, the default key is used
final groqKey = await ApiKeyManager.getApiKey('groq');
```

### Custom Keys

- Enter your private API keys
- Override default keys when custom key is provided
- Secure local key storage on device

## 🤖 Available AI Models

### Groq Models (10 Models)

#### 1. Llama 3.1 8B
- **Speed**: Very Fast | **Quality**: Good | **Context**: 8K tokens
- Fast and balanced model for general conversations

#### 2. Llama 3.1 70B  
- **Speed**: Fast | **Quality**: Excellent | **Context**: 8K tokens
- Advanced model for complex reasoning and analysis

#### 3. Mixtral 8x7B
- **Speed**: Fast | **Quality**: Excellent | **Context**: 32K tokens
- Specialized in programming and technical analysis

#### 4. Gemma 2 9B
- **Speed**: Very Fast | **Quality**: Very Good | **Context**: 8K tokens  
- Google's updated model for balanced performance

#### 5. Gemma 2 27B
- **Speed**: Medium | **Quality**: Excellent | **Context**: 8K tokens
- Google's advanced model for complex tasks

#### 6. Llama 3.1 8B Instant
- **Speed**: Ultra Fast | **Quality**: Good | **Context**: 8K tokens
- Lightning-fast responses for real-time conversations

#### 7. Llama 3.1 70B Versatile
- **Speed**: Fast | **Quality**: Excellent | **Context**: 8K tokens
- Multi-purpose model for diverse applications

#### 8. Llama 3.1 405B Reasoning
- **Speed**: Medium | **Quality**: Outstanding | **Context**: 8K tokens
- Specialized in logical reasoning and complex problem-solving

#### 9. Llama 3.1 1B Instruct
- **Speed**: Ultra Fast | **Quality**: Good | **Context**: 8K tokens
- Lightweight model for simple instructions

#### 10. Llama 3.1 3B Instruct  
- **Speed**: Very Fast | **Quality**: Very Good | **Context**: 8K tokens
- Medium-sized model for advanced instructions

### GPTGod Models (17 Models)

#### Premium Models
- **Claude 3 Opus**: Anthropic's flagship model (200K context)
- **Claude 3.5 Sonnet**: Balanced performance and speed
- **Claude 3 Haiku**: Ultra-fast for simple tasks
- **GPT-4 Turbo**: OpenAI's latest and fastest
- **GPT-4o**: Multimodal enhanced model
- **GPT-4o Mini**: Lightweight GPT-4 variant

#### Advanced Models
- **Gemini Pro 1.5**: Google's advanced model (1M context)
- **Gemini Flash 1.5**: Ultra-fast Google model
- **Mistral Large**: Powerful model for complex tasks  
- **Mistral Small**: Fast and efficient
- **Codestral**: Programming specialized model
- **Command R+**: Cohere's advanced model
- **Command R**: Balanced general-purpose model

#### Specialized Models
- **Perplexity Llama 3.1 70B**: Enhanced with web search
- **Perplexity Llama 3.1 8B**: Fast web-enhanced model
- **Llama 3.1 8B (GPTGod)**: Via GPTGod platform
- **Llama 3.1 70B (GPTGod)**: Advanced via GPTGod

## 🌐 Web Search Integration

### Tavily Smart Search
- **Real-time web search**: Extract latest information from the internet
- **Intelligent summarization**: Smart summaries of search results
- **Trusted sources**: Search from reliable and verified sources
- **Arabic language support**: Search and summarize in Arabic

```dart
// Using Tavily service for search
final searchResults = await TavilyService.search(
  query: 'latest AI news',
  language: 'en',
  maxResults: 10
);
```

## 🧠 Advanced AI Capabilities

### Fine-Tuning Advisor Service
- **Data analysis**: Intelligent analysis of training data
- **Parameter suggestions**: Recommend optimal training parameters
- **Performance monitoring**: Real-time training progress tracking
- **Automatic optimization**: Auto-optimize models during training

### Simple Model Training Service
```dart
// Start simplified model training
final trainingSession = await SimpleModelTrainingService.startTraining(
  dataPath: 'path/to/training/data',
  modelType: 'llama',
  epochs: 10
);
```

## 📱 Advanced App Features

### Smart Memory Management
- **MCP Protocol**: Model Context Protocol for enhanced memory
- **Long-term memory**: Save conversations and context for extended periods
- **Smart retrieval**: Retrieve relevant information from past conversations

### Performance Optimizations
- **App optimizer**: Comprehensive app performance enhancement
- **Database optimizer**: Optimize database queries and operations
- **Image optimizer**: Automatic image compression and optimization
- **Network optimizer**: Optimize network requests and caching

### Advanced Speech Service
```dart
// Voice recognition service
final speechResult = await SpeechService.recognizeSpeech(
  language: 'en-US',
  timeout: 30
);
```

## 🔧 API & Key Management

### Advanced Key Management
```dart
// Get API key
final groqKey = await ApiKeyManager.getApiKey('groq');

// Check if using default keys
final isUsingDefault = await ApiKeyManager.isUsingDefaultKeys();

// Save custom key
await ApiKeyManager.saveCustomKey('groq', 'your_custom_key');

// Remove custom key and revert to default
await ApiKeyManager.removeCustomKey('groq');
```

### Fallback Key System
- **Default keys**: Free keys for immediate use
- **Custom keys**: User's private API keys
- **Smart switching**: Automatic key switching when needed
- **Key protection**: Encryption and protection of API keys

## 💾 Data Export & Management

### Chat Export Service
- **Multiple formats**: Export in JSON, CSV, TXT formats
- **Custom export**: Select specific conversations and time periods
- **Data compression**: Automatic compression of large files
- **Data protection**: Encryption of exported data

```dart
// Export conversations
final exportResult = await ChatExportService.exportChats(
  format: ExportFormat.json,
  dateRange: DateRange.lastMonth,
  includeMedia: true
);
```

## 🎨 Advanced User Interface

### Smart Theming System
- **Material Design 3**: Latest design standards
- **Dynamic themes**: Color changes based on content
- **RTL support**: Full support for right-to-left languages
- **Advanced animations**: Smooth transitions and visual effects

### Specialized Widgets
- **Message bubbles**: Modern chat message design
- **Debug panel**: Advanced development tools
- **Training widgets**: Interfaces for monitoring model training
- **Search widgets**: Advanced conversation search interface

## 🔒 Security & Permissions

### Permission Manager
```dart
// Request multiple permissions
final permissions = await PermissionsManager.requestPermissions([
  Permission.microphone,
  Permission.storage,
  Permission.camera
]);
```

### Security Features
- **Data encryption**: Local database encryption
- **Memory protection**: Clear sensitive data from memory
- **User authentication**: Multiple authentication options
- **Activity logging**: Log sensitive operations

## 🚀 Development Features

### Lazy Service Initializer
- **Smart loading**: Load services only when needed
- **Optimized memory**: Reduce memory consumption
- **Fast startup**: Accelerate app startup time

### Prompt Enhancement Service
```dart
// Automatically enhance prompts
final enhancedPrompt = await PromptEnhancerService.enhancePrompt(
  originalPrompt: 'Explain artificial intelligence',
  context: ConversationContext.technical,
  language: 'en'
);
```

## 📞 Support

- **Email**: <alromaihi2224@gmail.com>
- **GitHub Issues**: [https://github.com/Msr7799/Atlas-AI.git](https://github.com/Msr7799/Atlas-AI.git)
- **Documentation**: README.md, FEATURES.md, README-ar.md

---

**Atlas AI** - Your intelligent AI assistant 🤖

**Developer**: Mohamed S AL-Romaihi  
**Email**: alromaihi2224@gmail.com  
**GitHub**: [@Msr7799](https://github.com/Msr7799)

#### 5. Gemma 2 27B

- **الوصف**: نموذج Google المتقدم للاستخدامات المعقدة
- **السرعة**: متوسط
- **الجودة**: ممتاز
- **السياق**: 8K tokens
- **المميزات**: دقة عالية، منطق متقدم، مناسب للمهام المعقدة

#### 6. Llama 3.1 8B Instant

- **الوصف**: نموذج سريع جداً للاستجابة الفورية
- **السرعة**: سريع جداً
- **الجودة**: جيد
- **السياق**: 8K tokens
- **المميزات**: سريع جداً، استجابة فورية، مناسب للمحادثات

#### 7. Llama 3.1 70B Versatile

- **الوصف**: نموذج متعدد الاستخدامات للاستخدامات المختلفة
- **السرعة**: سريع
- **الجودة**: ممتاز
- **السياق**: 8K tokens
- **المميزات**: متعدد الاستخدامات، دقة عالية، منطق متقدم

#### 8. Llama 3.1 405B Reasoning

- **الوصف**: نموذج متخصص في التفكير المنطقي والتحليل
- **السرعة**: متوسط
- **الجودة**: ممتاز جداً
- **السياق**: 8K tokens
- **المميزات**: تفكير منطقي متقدم، تحليل دقيق، منطق قوي

#### 9. Llama 3.1 1B Instruct

- **الوصف**: نموذج صغير وسريع للتعليمات البسيطة
- **السرعة**: سريع جداً
- **الجودة**: جيد
- **السياق**: 8K tokens
- **المميزات**: صغير وسريع، مناسب للتعليمات البسيطة، استجابة سريعة

#### 10. Llama 3.1 3B Instruct

- **الوصف**: نموذج متوازن للتعليمات والمحادثات
- **السرعة**: سريع جداً
- **الجودة**: جيد
- **السياق**: 8K tokens
- **المميزات**: متوازن، مناسب للتعليمات، استجابة جيدة

### GPTGod Models (17 نموذج)

#### 1. GPT-3.5 Turbo

- **الوصف**: نموذج OpenAI المتوازن للاستخدام العام
- **السرعة**: سريع
- **الجودة**: جيد جداً
- **السياق**: 4K tokens
- **المميزات**: متوازن، مناسب للاستخدام العام، استجابة سريعة

#### 2. GPT-3.5 Turbo 16K

- **الوصف**: نموذج OpenAI مع سياق أطول
- **السرعة**: سريع
- **الجودة**: جيد جداً
- **السياق**: 16K tokens
- **المميزات**: سياق طويل، متوازن، مناسب للمحادثات الطويلة

#### 3. GPT-4

- **الوصف**: نموذج OpenAI المتقدم للاستخدامات المعقدة
- **السرعة**: متوسط
- **الجودة**: ممتاز
- **السياق**: 8K tokens
- **المميزات**: دقة عالية، منطق متقدم، مناسب للمهام المعقدة

#### 4. GPT-4 Turbo

- **الوصف**: نموذج OpenAI الأحدث والأسرع
- **السرعة**: سريع
- **الجودة**: ممتاز
- **السياق**: 128K tokens
- **المميزات**: أحدث إصدار، سريع، دقة عالية

#### 5. GPT-4 Turbo Preview

- **الوصف**: نموذج OpenAI التجريبي مع أحدث الميزات
- **السرعة**: متوسط
- **الجودة**: ممتاز
- **السياق**: 128K tokens
- **المميزات**: تجريبي، أحدث الميزات، دقة عالية

#### 6. GPT-4 32K

- **الوصف**: نموذج OpenAI مع سياق طويل جداً
- **السرعة**: بطيء
- **الجودة**: ممتاز
- **السياق**: 32K tokens
- **المميزات**: سياق طويل جداً، دقة عالية، مناسب للمستندات الطويلة

#### 7. Claude 3 Opus

- **الوصف**: نموذج Anthropic الأكثر تقدماً
- **السرعة**: بطيء
- **الجودة**: ممتاز جداً
- **السياق**: 200K tokens
- **المميزات**: الأكثر تقدماً، دقة عالية جداً، منطق متقدم

#### 8. Claude 3 Sonnet

- **الوصف**: نموذج Anthropic المتوازن
- **السرعة**: متوسط
- **الجودة**: ممتاز
- **السياق**: 200K tokens
- **المميزات**: متوازن، دقة عالية، منطق جيد

#### 9. Claude 3 Haiku

- **الوصف**: نموذج Anthropic السريع
- **السرعة**: سريع
- **الجودة**: جيد جداً
- **السياق**: 200K tokens
- **المميزات**: سريع، مناسب للاستخدام العام، استجابة سريعة

#### 10. Gemini Pro

- **الوصف**: نموذج Google المتقدم
- **السرعة**: متوسط
- **الجودة**: ممتاز
- **السياق**: 32K tokens
- **المميزات**: متقدم، دقة عالية، منطق جيد

#### 11. Gemini Pro Vision

- **الوصف**: نموذج Google مع دعم الصور
- **السرعة**: متوسط
- **الجودة**: ممتاز
- **السياق**: 32K tokens
- **المميزات**: دعم الصور، تحليل مرئي، دقة عالية

#### 12. Llama 2 7B Chat

- **الوصف**: نموذج Meta للمحادثات
- **السرعة**: سريع
- **الجودة**: جيد
- **السياق**: 4K tokens
- **المميزات**: مناسب للمحادثات، سريع، متوازن

#### 13. Llama 2 13B Chat

- **الوصف**: نموذج Meta المتقدم للمحادثات
- **السرعة**: متوسط
- **الجودة**: جيد جداً
- **السياق**: 4K tokens
- **المميزات**: متقدم للمحادثات، دقة عالية، منطق جيد

#### 14. Llama 2 70B Chat

- **الوصف**: نموذج Meta الأكثر تقدماً للمحادثات
- **السرعة**: بطيء
- **الجودة**: ممتاز
- **السياق**: 4K tokens
- **المميزات**: الأكثر تقدماً، دقة عالية جداً، منطق متقدم

#### 15. Code Llama 7B Instruct

- **الوصف**: نموذج Meta المتخصص في البرمجة
- **السرعة**: سريع
- **الجودة**: جيد
- **السياق**: 4K tokens
- **المميزات**: متخصص في البرمجة، سريع، مناسب للكود

#### 16. Code Llama 13B Instruct

- **الوصف**: نموذج Meta المتقدم للبرمجة
- **السرعة**: متوسط
- **الجودة**: جيد جداً
- **السياق**: 4K tokens
- **المميزات**: متقدم في البرمجة، دقة عالية، منطق جيد

#### 17. Code Llama 34B Instruct

- **الوصف**: نموذج Meta الأكثر تقدماً للبرمجة
- **السرعة**: بطيء
- **الجودة**: ممتاز
- **السياق**: 4K tokens
- **المميزات**: الأكثر تقدماً في البرمجة، دقة عالية جداً، منطق متقدم

## 🎯 ميزة Tooltip للنماذج

### معلومات تفصيلية

عند hover على أي نموذج تظهر المعلومات التالية:

- **اسم النموذج**: الاسم الكامل للنموذج
- **الوصف**: شرح مفصل للنموذج
- **المميزات**: قائمة المميزات الخاصة
- **السرعة**: مستوى السرعة (سريع جداً، سريع، متوسط، بطيء)
- **الجودة**: مستوى الجودة (جيد، جيد جداً، ممتاز، ممتاز جداً)
- **السياق**: عدد الـ tokens المدعومة

### واجهة تفاعلية

- **Dialog مخصص**: عرض جميع النماذج في dialog منفصل
- **تصنيف حسب الخدمة**: Groq و GPTGod منفصلين
- **عرض بصري**: بطاقات ملونة لكل نموذج
- **معلومات سريعة**: سرعة وجودة في كل بطاقة

## 🔧 الميزات التقنية

### إدارة API Keys

```dart
// الحصول على مفتاح مع fallback
final groqKey = await ApiKeyManager.getApiKey('groq');

// التحقق من استخدام المفاتيح الافتراضية
final isUsingDefault = await ApiKeyManager.isUsingDefaultKeys();

// الحصول على حالة المفاتيح
final keysStatus = await ApiKeyManager.getKeysStatus();
```

### النماذج المجانية

```dart
// الحصول على قائمة النماذج
final groqModels = ApiKeyManager.getFreeModels('groq');
final gptgodModels = ApiKeyManager.getFreeModels('gptgod');

// الحصول على معلومات نموذج محدد
final modelInfo = ApiKeyManager.getModelInfo('groq', 'llama3-8b-8192');

// الحصول على قائمة أسماء النماذج فقط
final model = ApiKeyManager.getFreemodels('groq');
```

### Tooltip للنماذج

```dart
Tooltip(
  message: _buildModelTooltip(model),
  preferBelow: false,
  child: Text(model['name']),
)
```

## 🚀 كيفية الاستخدام

### 1. التثبيت الأولي

- تشغيل التطبيق مباشرة
- التطبيق يعمل مع المفاتيح الافتراضية
- لا حاجة لإدخال أي مفاتيح

### 2. إدخال المفاتيح المخصصة (اختياري)

- اذهب إلى إعدادات API
- أدخل مفاتيحك الخاصة
- أو اترك الحقول فارغة لاستخدام المفاتيح الافتراضية

### 3. اختيار النموذج

- اذهب إلى إعدادات النموذج
- اختر من بين 27 نموذج متاح
- استخدم tooltip لمعرفة تفاصيل كل نموذج

### 4. عرض معلومات النماذج

- اضغط على زر "النماذج المتاحة" في إعدادات API
- أو اضغط على أيقونة المعلومات في إعدادات النموذج
- استعرض جميع النماذج مع تفاصيلها

## 🔒 الأمان والخصوصية

- **تشفير محلي**: جميع المفاتيح مشفرة محلياً
- **لا توجد بيانات في السحابة**: جميع البيانات محفوظة على الجهاز
- **مفاتيح افتراضية آمنة**: المفاتيح الافتراضية آمنة ومجانية
- **حماية البيانات**: لا يتم إرسال أي بيانات شخصية

## 📱 الدعم

- **البريد الإلكتروني**: <alromaihi2224@gmail.com>
- **GitHub Issues**:[https://github.com/Msr7799/Atlas-AI.git]
- **التوثيق**: README.md و FEATURES.md و README-ar.md

---

**Atlas AI** - مساعد ذكي يدعم اللغة العربية مع إمكانيات تدريب متقدمة للنماذج 🚀
