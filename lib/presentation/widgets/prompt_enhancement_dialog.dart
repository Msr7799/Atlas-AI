
import 'package:flutter/material.dart';
import '../../core/services/prompt_enhancer_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';

class PromptEnhancementDialog extends StatefulWidget {
  final PromptEnhancementResult result;
  final Function(String) onUseEnhanced;
  final Function(String) onUseOriginal;
  final Function(String) onUseCustom;

  const PromptEnhancementDialog({
    super.key,
    required this.result,
    required this.onUseEnhanced,
    required this.onUseOriginal,
    required this.onUseCustom,
  });

  @override
  State<PromptEnhancementDialog> createState() =>
      _PromptEnhancementDialogState();
}

class _PromptEnhancementDialogState extends State<PromptEnhancementDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _customController = TextEditingController(
      text: widget.result.enhancedPrompt,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // منع إغلاق الحوار بطريقة خاطئة
        return true;
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: ResponsiveHelper.getResponsiveConstraints(
              context,
              mobile: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              tablet: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              desktop: const BoxConstraints(maxWidth: 1000, maxHeight: 700),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Confidence Score
                  _buildConfidenceScore(),

                  // Tab Bar
                  _buildTabBar(),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildComparisonTab(),
                        _buildAnalysisTab(),
                        _buildCustomEditTab(),
                      ],
                    ),
                  ),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(16),
        tablet: const EdgeInsets.all(20),
        desktop: const EdgeInsets.all(24),
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          colors: [
            AppTheme.gradientStart.withOpacity(0.8),
            AppTheme.gradientEnd.withOpacity(0.6),
          ],
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_fix_high,
            color: Colors.white,
            size: ResponsiveHelper.getResponsiveIconSize(
              context,
              mobile: 24,
              tablet: 28,
              desktop: 32,
            ),
          ),
          SizedBox(
            width: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محسن البرومبت الذكي',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'تم تحسين البرومبت باستخدام Llama3 8B',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: ResponsiveHelper.getResponsiveIconSize(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceScore() {
    return Container(
      margin: ResponsiveHelper.getResponsiveMargin(
        context,
        mobile: const EdgeInsets.all(12),
        tablet: const EdgeInsets.all(16),
        desktop: const EdgeInsets.all(20),
      ),
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        desktop: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.psychology,
            color: Theme.of(context).colorScheme.primary,
            size: ResponsiveHelper.getResponsiveIconSize(context),
          ),
          SizedBox(
            width: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
          ),
          Text(
            'درجة الثقة في التحسين:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 13,
                tablet: 14,
                desktop: 16,
              ),
            ),
          ),
          SizedBox(
            width: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 6,
              tablet: 8,
              desktop: 10,
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: widget.result.confidenceScore,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getConfidenceColor(widget.result.confidenceScore),
              ),
            ),
          ),
          SizedBox(
            width: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 6,
              tablet: 8,
              desktop: 10,
            ),
          ),
          Text(
            '${(widget.result.confidenceScore * 100).toInt()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getConfidenceColor(widget.result.confidenceScore),
              fontSize: ResponsiveHelper.getResponsiveFontSize(
                context,
                mobile: 13,
                tablet: 14,
                desktop: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Widget _buildTabBar() {
    return Container(
      margin: ResponsiveHelper.getResponsiveMargin(
        context,
        mobile: const EdgeInsets.symmetric(horizontal: 12),
        tablet: const EdgeInsets.symmetric(horizontal: 16),
        desktop: const EdgeInsets.symmetric(horizontal: 20),
      ),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(
          context,
        ).colorScheme.onSurface.withOpacity(0.7),
        labelStyle: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
        tabs: [
          Tab(
            icon: Icon(
              Icons.compare,
              size: ResponsiveHelper.getResponsiveIconSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 24,
              ),
            ),
            text: 'مقارنة',
          ),
          Tab(
            icon: Icon(
              Icons.analytics,
              size: ResponsiveHelper.getResponsiveIconSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 24,
              ),
            ),
            text: 'تحليل',
          ),
          Tab(
            icon: Icon(
              Icons.edit,
              size: ResponsiveHelper.getResponsiveIconSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 24,
              ),
            ),
            text: 'تعديل',
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTab() {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(12),
        tablet: const EdgeInsets.all(16),
        desktop: const EdgeInsets.all(20),
      ),
      child: ResponsiveHelper.isMobile(context)
          ? Column(
              children: [
                Expanded(
                  child: _buildPromptCard(
                    title: 'البرومبت الأصلي',
                    content: widget.result.originalPrompt,
                    icon: Icons.edit_note,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                Expanded(
                  child: _buildPromptCard(
                    title: 'البرومبت المحسن',
                    content: widget.result.enhancedPrompt,
                    icon: Icons.auto_fix_high,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                // Original Prompt
                Expanded(
                  child: _buildPromptCard(
                    title: 'البرومبت الأصلي',
                    content: widget.result.originalPrompt,
                    icon: Icons.edit_note,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(
                    context,
                    mobile: 12,
                    tablet: 16,
                    desktop: 20,
                  ),
                ),
                // Enhanced Prompt
                Expanded(
                  child: _buildPromptCard(
                    title: 'البرومبت المحسن',
                    content: widget.result.enhancedPrompt,
                    icon: Icons.auto_fix_high,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPromptCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: ResponsiveHelper.getResponsivePadding(
              context,
              mobile: const EdgeInsets.all(8),
              tablet: const EdgeInsets.all(12),
              desktop: const EdgeInsets.all(16),
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: ResponsiveHelper.getResponsiveIconSize(
                    context,
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  ),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(
                    context,
                    mobile: 6,
                    tablet: 8,
                    desktop: 10,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 13,
                      tablet: 14,
                      desktop: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.getResponsivePadding(
                context,
                mobile: const EdgeInsets.all(8),
                tablet: const EdgeInsets.all(12),
                desktop: const EdgeInsets.all(16),
              ),
              child: SelectableText(
                content,
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 12,
                    tablet: 14,
                    desktop: 16,
                  ),
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return SingleChildScrollView(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(12),
        tablet: const EdgeInsets.all(16),
        desktop: const EdgeInsets.all(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analysis
          Container(
            width: double.infinity,
            padding: ResponsiveHelper.getResponsivePadding(
              context,
              mobile: const EdgeInsets.all(12),
              tablet: const EdgeInsets.all(16),
              desktop: const EdgeInsets.all(20),
            ),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: Theme.of(context).colorScheme.primary,
                      size: ResponsiveHelper.getResponsiveIconSize(context),
                    ),
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveWidth(
                        context,
                        mobile: 6,
                        tablet: 8,
                        desktop: 10,
                      ),
                    ),
                    Text(
                      'تحليل التحسينات',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                Text(
                  widget.result.analysis,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),

          // Improvements List
          Container(
            width: double.infinity,
            padding: ResponsiveHelper.getResponsivePadding(
              context,
              mobile: const EdgeInsets.all(12),
              tablet: const EdgeInsets.all(16),
              desktop: const EdgeInsets.all(20),
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: ResponsiveHelper.getResponsiveIconSize(context),
                    ),
                    SizedBox(
                      width: ResponsiveHelper.getResponsiveWidth(
                        context,
                        mobile: 6,
                        tablet: 8,
                        desktop: 10,
                      ),
                    ),
                    Text(
                      'التحسينات المُطبقة',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                ...widget.result.improvements.map(
                  (improvement) => Padding(
                    padding: EdgeInsets.only(
                      bottom: ResponsiveHelper.getResponsiveHeight(
                        context,
                        mobile: 6,
                        tablet: 8,
                        desktop: 10,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.arrow_left,
                          color: Colors.green.shade600,
                          size: ResponsiveHelper.getResponsiveIconSize(
                            context,
                            mobile: 16,
                            tablet: 20,
                            desktop: 24,
                          ),
                        ),
                        SizedBox(
                          width: ResponsiveHelper.getResponsiveWidth(
                            context,
                            mobile: 6,
                            tablet: 8,
                            desktop: 10,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            improvement,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                mobile: 12,
                                tablet: 14,
                                desktop: 16,
                              ),
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomEditTab() {
    return Padding(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(12),
        tablet: const EdgeInsets.all(16),
        desktop: const EdgeInsets.all(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.primary,
                size: ResponsiveHelper.getResponsiveIconSize(context),
              ),
              SizedBox(
                width: ResponsiveHelper.getResponsiveWidth(
                  context,
                  mobile: 6,
                  tablet: 8,
                  desktop: 10,
                ),
              ),
              Text(
                'تعديل مخصص',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 16,
                    tablet: 18,
                    desktop: 20,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(
            height: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 12,
              tablet: 16,
              desktop: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _customController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
                height: 1.5,
              ),
              decoration: InputDecoration(
                hintText: 'قم بتعديل البرومبت كما تريد...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: ResponsiveHelper.getResponsivePadding(
                  context,
                  mobile: const EdgeInsets.all(12),
                  tablet: const EdgeInsets.all(16),
                  desktop: const EdgeInsets.all(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(12),
        tablet: const EdgeInsets.all(16),
        desktop: const EdgeInsets.all(20),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ResponsiveHelper.isMobile(context)
          ? Column(
              children: [
                // Use Original
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      try {
                        widget.onUseOriginal(widget.result.originalPrompt);
                        // لا نغلق الحوار هنا - سيتم إغلاقه من الصفحة الرئيسية
                      } catch (e) {
                        print('Error in onUseOriginal: $e');
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(
                      Icons.undo,
                      size: ResponsiveHelper.getResponsiveIconSize(context),
                    ),
                    label: Text(
                      'استخدام الأصلي',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveHeight(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),
                // Use Enhanced
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      try {
                        if (_tabController.index == 2) {
                          widget.onUseCustom(_customController.text);
                        } else {
                          widget.onUseEnhanced(widget.result.enhancedPrompt);
                        }
                        // لا نغلق الحوار هنا - سيتم إغلاقه من الصفحة الرئيسية
                      } catch (e) {
                        print('Error in onUseEnhanced/Custom: $e');
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(
                      _tabController.index == 2
                          ? Icons.edit
                          : Icons.auto_fix_high,
                      size: ResponsiveHelper.getResponsiveIconSize(context),
                    ),
                    label: Text(
                      _tabController.index == 2
                          ? 'استخدام المعدل'
                          : 'استخدام المحسن',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                // Use Original
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      try {
                        widget.onUseOriginal(widget.result.originalPrompt);
                        // لا نغلق الحوار هنا - سيتم إغلاقه من الصفحة الرئيسية
                      } catch (e) {
                        print('Error in onUseOriginal: $e');
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(
                      Icons.undo,
                      size: ResponsiveHelper.getResponsiveIconSize(context),
                    ),
                    label: Text(
                      'استخدام الأصلي',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: ResponsiveHelper.getResponsiveWidth(
                    context,
                    mobile: 8,
                    tablet: 12,
                    desktop: 16,
                  ),
                ),

                // Use Enhanced
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      try {
                        if (_tabController.index == 2) {
                          widget.onUseCustom(_customController.text);
                        } else {
                          widget.onUseEnhanced(widget.result.enhancedPrompt);
                        }
                        // لا نغلق الحوار هنا - سيتم إغلاقه من الصفحة الرئيسية
                      } catch (e) {
                        print('Error in onUseEnhanced/Custom: $e');
                        Navigator.of(context).pop();
                      }
                    },
                    icon: Icon(
                      _tabController.index == 2
                          ? Icons.edit
                          : Icons.auto_fix_high,
                      size: ResponsiveHelper.getResponsiveIconSize(context),
                    ),
                    label: Text(
                      _tabController.index == 2
                          ? 'استخدام المعدل'
                          : 'استخدام المحسن',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 14,
                          tablet: 16,
                          desktop: 18,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// Function to show the enhancement dialog
Future<void> showPromptEnhancementDialog({
  required BuildContext context,
  required PromptEnhancementResult result,
  required Function(String) onPromptSelected,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PromptEnhancementDialog(
      result: result,
      onUseEnhanced: onPromptSelected,
      onUseOriginal: onPromptSelected,
      onUseCustom: onPromptSelected,
    ),
  );
}
