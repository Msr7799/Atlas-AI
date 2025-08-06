import 'package:flutter/material.dart';
import '../../core/services/prompt_enhancer_service.dart';
import '../../core/theme/app_theme.dart';

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
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
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
    ); // إغلاق WillPopScope
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Icon(Icons.auto_fix_high, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'محسن البرومبت الذكي',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'تم تحسين البرومبت باستخدام Llama3 8B',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceScore() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            'درجة الثقة في التحسين:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: widget.result.confidenceScore,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getConfidenceColor(widget.result.confidenceScore),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(widget.result.confidenceScore * 100).toInt()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getConfidenceColor(widget.result.confidenceScore),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
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
        tabs: const [
          Tab(icon: Icon(Icons.compare), text: 'مقارنة'),
          Tab(icon: Icon(Icons.analytics), text: 'تحليل'),
          Tab(icon: Icon(Icons.edit), text: 'تعديل'),
        ],
      ),
    );
  }

  Widget _buildComparisonTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
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
          const SizedBox(width: 16),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                content,
                style: TextStyle(
                  fontSize: 14,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analysis
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تحليل التحسينات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.result.analysis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Improvements List
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'التحسينات المُطبقة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...widget.result.improvements.map(
                  (improvement) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.arrow_left,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            improvement,
                            style: TextStyle(
                              fontSize: 14,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'تعديل مخصص',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _customController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 14, height: 1.5),
              decoration: InputDecoration(
                hintText: 'قم بتعديل البرومبت كما تريد...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
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
              icon: const Icon(Icons.undo),
              label: const Text('استخدام الأصلي'),
            ),
          ),
          const SizedBox(width: 12),

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
                _tabController.index == 2 ? Icons.edit : Icons.auto_fix_high,
              ),
              label: Text(
                _tabController.index == 2 ? 'استخدام المعدل' : 'استخدام المحسن',
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
