[App-Icon](assets/icons/atlas.png)

# Arabic Agent - وكيل الذكاء الاصطناعي العربي 🤖

[![Flutter Version](https://img.shields.io/badge/Flutter-3.8.1+-blue.svg)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.8.1+-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

وكيل ذكاء اصطناعي متقدم مبني بـ Flutter يدعم اللغة العربية ويتخصص في **التدريب المتقدم للنماذج (Fine-Tuning)** مع واجهة محادثة ذكية وأدوات تطوير متقدمة.

## ✨ المميزات الرئيسية

### 🧠 **ذكاء اصطناعي متقدم**
- دعم كامل للغة العربية مع نماذج Groq المتطورة
- خدمة التدريب المتقدم (Fine-Tuning Advisor Service)
- نظام تفكير متسلسل للحلول المعقدة
- ذاكرة محادثة ذكية مع MCP (Model Context Protocol)

### 🎨 **واجهة مستخدم حديثة**
- تصميم Material Design 3 مع دعم الثيمات
- رسوم متحركة متقدمة ومؤثرات بصرية
- دعم الأنماط المظلمة والفاتحة
- واجهة محادثة تفاعلية مع دعم الملفات

### 🔧 **أدوات تطوير متطورة**
- تكامل مع Tavily API للبحث الذكي
- نظام MCP للذاكرة المتقدمة
- دعم تحليل البيانات المتخصصة
- لوحة تحكم للمطورين (Debug Panel)

### 📱 **منصات متعددة**
- دعم كامل لأنظمة Android, iOS, Web, Linux, Windows, macOS
- استجابة كاملة لجميع أحجام الشاشات
- أداء محسن لكافة المنصات

## 🚀 البدء السريع

### متطلبات النظام

```bash
# Flutter SDK
Flutter 3.8.1 أو أحدث
Dart 3.8.1 أو أحدث

# أدوات إضافية
Git
Node.js (لخدمات MCP)
```

### التثبيت

1. **استنساخ المشروع:**
```bash
git clone https://github.com/Msr7799/Fine_tuning_AI.git
cd Fine_tuning_AI
```

2. **تثبيت التبعيات:**
```bash
flutter pub get
```

3. **إعداد متغيرات البيئة:**
```bash
# إنشاء ملف .env في الجذر
cp .env.example .env

# تحرير الملف وإضافة مفاتيح API
GROQ_API_KEY=your_groq_api_key_here
TAVILY_API_KEY=your_tavily_api_key_here
TRAVILY_URL_API_PAIRED=your_mcp_endpoint_here
```

4. **تشغيل التطبيق:**
```bash
# لأجهزة Android/iOS
flutter run

# للويب
flutter run -d chrome

# لسطح المكتب
flutter run -d linux   # أو windows أو macos
```

## 🏗️ معمارية المشروع

```
lib/
├── 🔧 core/                    # النواة الأساسية
│   ├── config/                 # إعدادات التطبيق
│   ├── constants/              # الثوابت
│   ├── services/               # الخدمات الأساسية
│   │   ├── groq_service.dart          # خدمة Groq AI
│   │   ├── tavily_service.dart        # خدمة البحث الذكي
│   │   ├── mcp_service.dart           # خدمة الذاكرة
│   │   └── fine_tuning_advisor_service.dart  # مستشار التدريب
│   └── theme/                  # نظام الثيمات
├── 💾 data/                    # طبقة البيانات
│   ├── datasources/            # مصادر البيانات
│   ├── models/                 # نماذج البيانات
│   └── repositories/           # مستودعات البيانات
├── 🎯 domain/                  # المنطق التجاري
│   ├── entities/               # الكيانات
│   ├── repositories/           # واجهات المستودعات
│   └── usecases/              # حالات الاستخدام
├── 🎨 presentation/            # واجهة المستخدم
│   ├── pages/                  # الصفحات
│   ├── providers/              # مزودي الحالة
│   └── widgets/               # العناصر المخصصة
└── 🔨 utils/                   # أدوات مساعدة
```

## 🛠️ التقنيات المستخدمة

### 📱 **تطوير التطبيق**
- **Flutter 3.8.1+** - إطار العمل الأساسي
- **Dart 3.8.1+** - لغة البرمجة
- **Provider** - إدارة الحالة
- **Dio** - طلبات HTTP متقدمة

### 🤖 **ذكاء اصطناعي**
- **Groq API** - نماذج اللغة المتطورة
- **Tavily API** - البحث الذكي والاستخراج
- **MCP Protocol** - بروتوكول السياق للنماذج

### 💾 **قاعدة البيانات**
- **SQLite** - قاعدة بيانات محلية
- **Shared Preferences** - تخزين الإعدادات
- **File System** - إدارة الملفات

### 🎨 **واجهة المستخدم**
- **Material Design 3** - نظام التصميم
- **Google Fonts** - خطوط متنوعة
- **Lottie** - الرسوم المتحركة
- **Flutter Animate** - تأثيرات متقدمة

## 📖 دليل الاستخدام

### 💬 **المحادثة الذكية**
1. اكتب رسالتك في حقل النص
2. أرفق ملفات إضافية إذا لزم الأمر
3. اضغط إرسال للحصول على إجابة ذكية
4. استخدم أوامر خاصة مثل `/help` للمساعدة

### 🔧 **التدريب المتقدم**
```
/finetune [نوع المهمة] - بدء جلسة تدريب متقدم
/analyze [الملف] - تحليل البيانات للتدريب
/optimize [المعاملات] - تحسين النموذج
```

### 🎨 **تخصيص الواجهة**
- غيّر النمط من الإعدادات (فاتح/مظلم)
- اختر ألوان مخصصة من لوحة الألوان
- اضبط حجم الخط ونوعه

### 🔍 **البحث الذكي**
```
/search [استعلام] - بحث ذكي في الويب
/crawl [رابط] - استخراج محتوى موقع
/extract [نص] - استخراج معلومات محددة
```

## ⚙️ الإعدادات المتقدمة

### 🔑 **مفاتيح API**

احصل على مفاتيح API من:
- [Groq Console](https://console.groq.com/) - للذكاء الاصطناعي
- [Tavily API](https://tavily.com/) - للبحث الذكي

### 🐳 **نشر Docker**

```dockerfile
# Dockerfile مثال
FROM cirrusci/flutter:stable

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web

EXPOSE 8080
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080"]
```

### ☁️ **النشر السحابي**

```bash
# نشر على Firebase Hosting
firebase deploy

# نشر على Vercel
vercel --prod

# نشر على GitHub Pages
flutter build web --base-href="/Fine_tuning_AI/"
```

## 🤝 المساهمة

نرحب بمساهماتكم! يرجى اتباع الخطوات التالية:

1. **Fork** المستودع
2. إنشاء فرع للميزة (`git checkout -b feature/amazing-feature`)
3. Commit التغييرات (`git commit -m 'Add amazing feature'`)
4. Push للفرع (`git push origin feature/amazing-feature`)
5. فتح **Pull Request**

### 📋 **إرشادات المساهمة**

- اتبع [دليل أسلوب Dart](https://dart.dev/guides/language/effective-dart/style)
- اكتب اختبارات للميزات الجديدة
- حدث الوثائق عند الحاجة
- استخدم أسماء متغيرات واضحة

## 🧪 الاختبار

```bash
# تشغيل جميع الاختبارات
flutter test

# اختبارات مع تقرير التغطية
flutter test --coverage

# اختبارات التكامل
flutter test integration_test/

# تحليل جودة الكود
flutter analyze
```

## 📊 الأداء

- **وقت البدء:** < 2 ثانية
- **استهلاك الذاكرة:** < 100 MB
- **حجم التطبيق:** 
  - Android: ~25 MB
  - iOS: ~30 MB
  - Web: ~5 MB (مضغوط)

## 🔒 الأمان

- تشفير البيانات المحلية
- تأمين مفاتيح API
- عدم تخزين البيانات الحساسة
- اتصالات HTTPS فقط

## 📝 الترخيص

هذا المشروع مرخص تحت رخصة MIT - راجع ملف [LICENSE](LICENSE) للتفاصيل.

## 🙏 شكر وتقدير

- [Flutter Team](https://flutter.dev/) - إطار العمل الرائع
- [Groq](https://groq.com/) - نماذج الذكاء الاصطناعي المتطورة
- [Tavily](https://tavily.com/) - خدمة البحث الذكي
- [Material Design](https://material.io/) - نظام التصميم

## 📞 التواصل

- **المطور:** Msr7799
- **البريد الإلكتروني:** [your-email@example.com]
- **GitHub:** [@Msr7799](https://github.com/Msr7799)
- **المستودع:** [Fine_tuning_AI](https://github.com/Msr7799/Fine_tuning_AI)

---

<div align="center">
  <h3>صنع بـ ❤️ في العالم العربي</h3>
  <p>إذا أعجبك هذا المشروع، لا تنس إعطاؤه ⭐!</p>
</div>
