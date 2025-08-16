import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedSuggestionsDropdown extends StatefulWidget {
  final TextEditingController messageController;

  const AnimatedSuggestionsDropdown({
    super.key,
    required this.messageController,
  });

  @override
  State<AnimatedSuggestionsDropdown> createState() => _AnimatedSuggestionsDropdownState();
}

class _AnimatedSuggestionsDropdownState extends State<AnimatedSuggestionsDropdown>
    with TickerProviderStateMixin {
  
  bool _isExpanded = false;
  late AnimationController _arrowController;
  late AnimationController _contentController;

  // قائمة الأسئلة المقترحة مقسمة لفئات - كل سؤال 5 كلمات بالضبط
  // List of suggested questions divided into categories - each question exactly 5 words
  List<Map<String, dynamic>> _getSuggestedQuestions(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return [
      {
        'category': isArabic ? '💻 البرمجة والتطوير' : '💻 Programming & Development',
        'questions': isArabic ? [
          'اكتب كود بايثون لحل مشكلة',
          'ساعدني بإصلاح خطأ جافاسكريبت',
          'اشرح مفهوم البرمجة كائنية التوجه',
          'أنشئ تطبيق فلتر بسيط ومتقدم',
          'راجع وحسن هذا الكود المكتوب',
        ] : [
          'Write Python code to solve problem',
          'Help me fix JavaScript error',
          'Explain object-oriented programming concept clearly',
          'Create simple and advanced Flutter app',
          'Review and improve this written code',
        ],
      },
      {
        'category': isArabic ? '🔍 البحث والمعلومات' : '🔍 Search & Information',
        'questions': isArabic ? [
          'ابحث عن آخر أخبار التقنية',
          'ما أفضل ممارسات تطوير التطبيقات؟',
          'اشرح تقنية الذكاء الاصطناعي بوضوح',
          'كيف تعمل تقنية البلوك تشين؟',
          'أعطني معلومات عن لغة البرمجة',
        ] : [
          'Search for latest technology news',
          'What are best app development practices?',
          'Explain artificial intelligence technology clearly',
          'How does blockchain technology work?',
          'Give me information about programming language',
        ],
      },
      {
        'category': isArabic ? '⚙️ المساعدة والإعدادات' : '⚙️ Help & Settings',
        'questions': isArabic ? [
          'ساعدني بضبط إعدادات هذا البرنامج',
          'كيف أغير لون وشكل الواجهة؟',
          'اشرح كيفية استخدام الصوت والنطق',
          'كيف أحفظ واسترجع المحادثات السابقة؟',
          'ما طريقة تغيير الخط والحجم؟',
        ] : [
          'Help me configure this program settings',
          'How to change interface color and style?',
          'Explain how to use voice and speech',
          'How to save and retrieve previous conversations?',
          'What is the way to change font and size?',
        ],
      },
      {
        'category': isArabic ? '📋 التحليل والترجمة' : '📋 Analysis & Translation',
        'questions': isArabic ? [
          'حلل هذا النص وأعطني الملخص',
          'اقترح نصائح مفيدة للإنتاجية اليومية',
          'ترجم هذا النص للغة العربية',
          'اكتب مقال احترافي عن موضوع',
          'صحح واعدل قواعد هذا النص',
        ] : [
          'Analyze this text and give me summary',
          'Suggest useful tips for daily productivity',
          'Translate this text to Arabic language',
          'Write professional article about topic',
          'Correct and edit this text grammar',
        ],
      },
    ];
  }

  // الأسئلة المختصرة للعرض الافتراضي - كل سؤال 5 كلمات
  // Short questions for default display - each question 5 words
  List<String> _getQuickQuestions(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? [
      'اكتب لي كود بايثون متقدم',
      'ابحث عن آخر الأخبار التقنية',
      'كيف أغير لون الواجهة بسهولة؟',
      'ترجم هذا النص للغة العربية',
      'ساعدني بحل مشكلة برمجية',
      'اشرح مفهوم الذكاء الاصطناعي بوضوح',
    ] : [
      'Write advanced Python code for me',
      'Search for latest technical news',
      'How to change interface color easily?',
      'Translate this text to Arabic language',
      'Help me solve programming problem',
      'Explain artificial intelligence concept clearly',
    ];
  }

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _arrowController.forward();
      _contentController.forward();
    } else {
      _arrowController.reverse();
      _contentController.reverse();
    }
  }

  Widget _buildQuickSuggestions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _getQuickQuestions(context)
          .asMap()
          .entries
          .map((entry) => _buildSuggestionChip(
                entry.value,
                delay: entry.key * 100,
              ))
          .toList(),
    );
  }

  Widget _buildExpandedSuggestions() {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: _contentController,
            curve: Curves.easeInOut,
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _contentController,
              curve: Curves.easeInOut,
            ),
            child: Container(
              // إضافة حد أقصى للارتفاع لتفعيل السحب
              // Add maximum height to enable scrolling
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ..._getSuggestedQuestions(context).asMap().entries.map((categoryEntry) {
                      final categoryIndex = categoryEntry.key;
                      final categoryData = categoryEntry.value;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // عنوان الفئة // Category title
                            Text(
                              categoryData['category'],
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                                // استخدام خط المظهر المحدد
                                fontFamily: Theme.of(context).textTheme.titleSmall?.fontFamily,
                              ),
                            ).animate(delay: (categoryIndex * 200).ms)
                             .fadeIn(duration: 300.ms)
                             .slideX(begin: -0.3, end: 0),
                        
                        const SizedBox(height: 8),
                        
                            // أزرار الأسئلة للفئة - مع عرض ثابت ومتسق
                            // Question buttons for category - with consistent fixed width
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: (categoryData['questions'] as List<String>).asMap().entries.map((questionEntry) {
                                final questionIndex = questionEntry.key;
                                final question = questionEntry.value;
                                
                                return _buildSuggestionChip(
                                  question,
                                  delay: (categoryIndex * 5 + questionIndex + 1) * 100,
                                  isConsistent: true, // عرض متسق للأزرار // Consistent display for buttons
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionChip(String text, {int delay = 0, bool isExpanded = false, bool isConsistent = false}) {
    return SizedBox(
      // عرض ثابت ومتسق للأزرار عند isConsistent = true
      // Fixed and consistent width for buttons when isConsistent = true
      width: isConsistent ? 200 : null,
      child: ActionChip(
        label: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: isExpanded ? 13 : 12,
            // استخدام الخط المختار من الإعدادات
            // Use the selected font from settings
            fontFamily: Theme.of(context).textTheme.bodySmall?.fontFamily,
          ),
          maxLines: isConsistent ? 2 : 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          widget.messageController.text = text;
        },
        backgroundColor: Theme.of(context).colorScheme.surface,
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded || isConsistent ? 12 : 8,
          vertical: isExpanded || isConsistent ? 8 : 4,
        ),
      ),
    ).animate(delay: delay.ms)
     .fadeIn(duration: 300.ms)
     .scale(
       begin: const Offset(0.8, 0.8),
       end: const Offset(1.0, 1.0),
       duration: 300.ms,
       curve: Curves.elasticOut,
     );
  }

  Widget _buildDropdownButton() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: _toggleExpanded,
        child: AnimatedBuilder(
          animation: _arrowController,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isExpanded 
                        ? (Localizations.localeOf(context).languageCode == 'ar' ? 'إخفاء الأسئلة' : 'Hide Questions')
                        : (Localizations.localeOf(context).languageCode == 'ar' ? 'عرض المزيد من الأسئلة' : 'Show More Questions'),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      // التأكد من استخدام الخط المحدد
                      // Ensure using the specified font
                      fontFamily: Theme.of(context).textTheme.labelMedium?.fontFamily,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Transform.rotate(
                    angle: _arrowController.value * 3.14159,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد ما إذا كانت الشاشة صغيرة
        // Determine if the screen is small
        final isSmallScreen = constraints.maxWidth < 600;
        
        return Column(
          children: [
            // الأسئلة السريعة (تظهر دائماً)
            // Quick questions (always visible)
            _buildQuickSuggestions(),
            
            // زر الـ Dropdown (يظهر فقط في الشاشات الصغيرة أو عندما نريد المزيد)
            // Dropdown button (shows only on small screens or when we want more)
            if (isSmallScreen || !_isExpanded)
              _buildDropdownButton(),
            
            // الأسئلة المفصلة (تظهر عند التوسيع)
            // Detailed questions (appear when expanded)
            _buildExpandedSuggestions(),
          ],
        );
      },
    );
  }
}
