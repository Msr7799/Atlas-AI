import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/training_provider.dart';

class TrainingLogsWidget extends StatefulWidget {
  const TrainingLogsWidget({super.key});

  @override
  State<TrainingLogsWidget> createState() => _TrainingLogsWidgetState();
}

class _TrainingLogsWidgetState extends State<TrainingLogsWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_autoScroll && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TrainingProvider>(
      builder: (context, provider, child) {
        // التمرير التلقائي عند إضافة سجلات جديدة
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return Column(
          children: [
            // شريط التحكم
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.terminal, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'سجلات التدريب',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),

                  // عدد السجلات
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${provider.trainingLogs.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // تبديل التمرير التلقائي
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _autoScroll = !_autoScroll;
                      });
                      if (_autoScroll) {
                        _scrollToBottom();
                      }
                    },
                    icon: Icon(
                      _autoScroll
                          ? Icons.vertical_align_bottom
                          : Icons.pan_tool,
                      color: _autoScroll ? Colors.green : Colors.orange,
                    ),
                    tooltip: _autoScroll
                        ? 'إيقاف التمرير التلقائي'
                        : 'تفعيل التمرير التلقائي',
                  ),

                  // مسح السجلات
                  IconButton(
                    onPressed: provider.trainingLogs.isNotEmpty
                        ? () => _showClearDialog(context, provider)
                        : null,
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'مسح السجلات',
                  ),

                  // التمرير للأسفل
                  IconButton(
                    onPressed: () => _scrollToBottom(),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    tooltip: 'التمرير للأسفل',
                  ),
                ],
              ),
            ),

            // منطقة السجلات
            Expanded(
              child: provider.trainingLogs.isEmpty
                  ? _buildEmptyState()
                  : Container(
                      color: Colors.black87,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: provider.trainingLogs.length,
                        itemBuilder: (context, index) {
                          final log = provider.trainingLogs[index];
                          return _buildLogEntry(log, index);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'لا توجد سجلات حتى الآن',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر سجلات التدريب هنا عند بدء العملية',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(String log, int index) {
    // تحليل نوع الرسالة
    Color textColor = Colors.white;
    Color backgroundColor = Colors.transparent;
    IconData? icon;

    if (log.contains('❌') || log.contains('ERROR') || log.contains('خطأ')) {
      textColor = Colors.red.shade300;
      icon = Icons.error_outline;
    } else if (log.contains('⚠️') ||
        log.contains('WARNING') ||
        log.contains('تحذير')) {
      textColor = Colors.orange.shade300;
      icon = Icons.warning_outlined;
    } else if (log.contains('✅') ||
        log.contains('SUCCESS') ||
        log.contains('نجح')) {
      textColor = Colors.green.shade300;
      icon = Icons.check_circle_outline;
    } else if (log.contains('🚀') || log.contains('بدء')) {
      textColor = Colors.blue.shade300;
      icon = Icons.rocket_launch;
    } else if (log.contains('📊') || log.contains('معلومات')) {
      textColor = Colors.cyan.shade300;
      icon = Icons.info_outline;
    } else if (log.contains('🔄') || log.contains('%')) {
      textColor = Colors.yellow.shade300;
      icon = Icons.refresh;
    }

    // استخراج الوقت من السجل
    String timeStamp = '';
    final timeMatch = RegExp(r'\\[([^\\]]+)\\]').firstMatch(log);
    if (timeMatch != null) {
      timeStamp = timeMatch.group(1) ?? '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رقم السطر
          Container(
            width: 40,
            alignment: Alignment.centerRight,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),

          const SizedBox(width: 8),

          // الأيقونة
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 8),
          ],

          // النص
          Expanded(
            child: SelectableText(
              log,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontFamily: 'monospace',
                height: 1.3,
              ),
            ),
          ),

          // الوقت
          if (timeStamp.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              timeStamp,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, TrainingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح السجلات'),
        content: const Text(
          'هل أنت متأكد من مسح جميع سجلات التدريب؟\\n'
          'لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearLogs();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم مسح السجلات'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }
}
