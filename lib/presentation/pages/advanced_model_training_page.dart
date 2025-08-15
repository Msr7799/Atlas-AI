import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/advanced_model_training_service.dart';
import '../widgets/training/unified_training_widget.dart';

class AdvancedModelTrainingPage extends StatefulWidget {
  const AdvancedModelTrainingPage({super.key});

  @override
  State<AdvancedModelTrainingPage> createState() => _AdvancedModelTrainingPageState();
}

class _AdvancedModelTrainingPageState extends State<AdvancedModelTrainingPage> 
    with TickerProviderStateMixin {
  
  late TabController _tabController;
  late AdvancedModelTrainingService _trainingService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _trainingService = AdvancedModelTrainingService();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      await _trainingService.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تهيئة خدمة التدريب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _trainingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _trainingService,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(
                Icons.psychology,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('تدريب النماذج المتقدم'),
            ],
          ),
          actions: [
            if (_isInitialized)
              Consumer<AdvancedModelTrainingService>(
                builder: (context, service, child) {
                  final hasActiveTraining = service.currentTraining != null &&
                      (service.currentTraining!.status == TrainingStatus.training ||
                       service.currentTraining!.status == TrainingStatus.preparing);
                  
                  return Container(
                    margin: const EdgeInsets.only(right: 16),
                    child: Row(
                      children: [
                        if (hasActiveTraining) ...[
                          Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'نشط',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.circle,
                            color: Colors.grey,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'خامل',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'help',
                  child: Row(
                    children: [
                      Icon(Icons.help_outline),
                      SizedBox(width: 8),
                      Text('مساعدة'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('إعدادات'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('تصدير البيانات'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'help':
                    _showHelpDialog();
                    break;
                  case 'settings':
                    _showSettingsDialog();
                    break;
                  case 'export':
                    _exportTrainingData();
                    break;
                }
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.settings_outlined),
                text: 'الإعداد',
              ),
              Tab(
                icon: Icon(Icons.timeline),
                text: 'التقدم',
              ),
              Tab(
                icon: Icon(Icons.terminal),
                text: 'السجلات',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'السجل',
              ),
            ],
          ),
        ),
        body: _isInitialized
            ? const UnifiedTrainingWidget()
            : const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري تهيئة خدمة التدريب...'),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTrainingHistoryTab() {
    return Consumer<AdvancedModelTrainingService>(
      builder: (context, service, child) {
        final sessions = service.trainingSessions;
        
        if (sessions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'لا توجد جلسات تدريب سابقة',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'ستظهر هنا جلسات التدريب السابقة',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(session.status).withOpacity(0.2),
                  child: Icon(
                    _getStatusIcon(session.status),
                    color: _getStatusColor(session.status),
                  ),
                ),
                title: Text(session.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('النوع: ${session.type.arabicName}'),
                    Text('الحالة: ${session.status.arabicName}'),
                    Text('التاريخ: ${_formatDate(session.createdAt)}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(session.progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        if (session.status == TrainingStatus.completed)
                          const PopupMenuItem(
                            value: 'export',
                            child: Row(
                              children: [
                                Icon(Icons.download),
                                SizedBox(width: 8),
                                Text('تصدير النموذج'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(Icons.info),
                              SizedBox(width: 8),
                              Text('التفاصيل'),
                            ],
                          ),
                        ),
                        if (session.status == TrainingStatus.idle ||
                            session.status == TrainingStatus.failed ||
                            session.status == TrainingStatus.cancelled)
                          const PopupMenuItem(
                            value: 'restart',
                            child: Row(
                              children: [
                                Icon(Icons.refresh),
                                SizedBox(width: 8),
                                Text('إعادة التشغيل'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('حذف', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) => _handleSessionAction(value, session),
                    ),
                  ],
                ),
                onTap: () => _showSessionDetails(session),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getStatusIcon(TrainingStatus status) {
    switch (status) {
      case TrainingStatus.idle:
        return Icons.pause;
      case TrainingStatus.preparing:
        return Icons.settings;
      case TrainingStatus.training:
        return Icons.play_arrow;
      case TrainingStatus.validating:
        return Icons.verified;
      case TrainingStatus.completed:
        return Icons.check;
      case TrainingStatus.failed:
        return Icons.error;
      case TrainingStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(TrainingStatus status) {
    switch (status) {
      case TrainingStatus.idle:
        return Colors.grey;
      case TrainingStatus.preparing:
        return Colors.orange;
      case TrainingStatus.training:
        return Colors.blue;
      case TrainingStatus.validating:
        return Colors.purple;
      case TrainingStatus.completed:
        return Colors.green;
      case TrainingStatus.failed:
        return Colors.red;
      case TrainingStatus.cancelled:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleSessionAction(String action, TrainingInfo session) {
    switch (action) {
      case 'export':
        _exportModel(session.id);
        break;
      case 'details':
        _showSessionDetails(session);
        break;
      case 'restart':
        _restartSession(session.id);
        break;
      case 'delete':
        _deleteSession(session.id);
        break;
    }
  }

  void _exportModel(String sessionId) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة تصدير النموذج قيد التطوير'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showSessionDetails(TrainingInfo session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل: ${session.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', session.id),
              _buildDetailRow('النوع', session.type.arabicName),
              _buildDetailRow('الحالة', session.status.arabicName),
              _buildDetailRow('التقدم', '${(session.progress * 100).toStringAsFixed(1)}%'),
              _buildDetailRow('تاريخ الإنشاء', _formatDate(session.createdAt)),
              if (session.startedAt != null)
                _buildDetailRow('تاريخ البدء', _formatDate(session.startedAt!)),
              if (session.completedAt != null)
                _buildDetailRow('تاريخ الانتهاء', _formatDate(session.completedAt!)),
              _buildDetailRow('عدد ملفات البيانات', session.dataFiles.length.toString()),
              if (session.error != null) ...[
                const SizedBox(height: 8),
                const Text('خطأ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text(session.error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _restartSession(String sessionId) async {
    final success = await _trainingService.startTraining(sessionId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'تم بدء التدريب' : 'فشل في بدء التدريب'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      if (success) {
        _tabController.animateTo(1); // التبديل إلى تبويب التقدم
      }
    }
  }

  Future<void> _deleteSession(String sessionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف جلسة التدريب'),
        content: const Text('هل تريد حذف هذه الجلسة نهائياً؟ سيتم حذف جميع البيانات المرتبطة بها.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _trainingService.deleteTrainingSession(sessionId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'تم حذف الجلسة' : 'فشل في حذف الجلسة'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مساعدة - تدريب النماذج'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'أنواع التدريب المدعومة:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Fine-tuning: تحسين نموذج موجود'),
              Text('• Instruction Tuning: تدريب على التعليمات'),
              Text('• Conversation Tuning: تدريب على المحادثات'),
              Text('• Domain Specific: تخصص مجال معين'),
              SizedBox(height: 16),
              Text(
                'أنواع الملفات المدعومة:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• .txt - ملفات نصية (حد أقصى 50MB)'),
              Text('• .json - ملفات JSON (حد أقصى 100MB)'),
              Text('• .jsonl - ملفات JSONL (حد أقصى 100MB)'),
              Text('• .csv - ملفات CSV (حد أقصى 25MB)'),
              Text('• .md - ملفات Markdown (حد أقصى 10MB)'),
              SizedBox(height: 16),
              Text(
                'نصائح:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• استخدم بيانات عالية الجودة للحصول على أفضل النتائج'),
              Text('• ابدأ بمعدل تعلم منخفض (0.001)'),
              Text('• استخدم الإيقاف المبكر لتجنب فرط التعلم'),
              Text('• راقب السجلات لفهم تقدم التدريب'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعدادات التدريب'),
        content: const Text('إعدادات التدريب المتقدمة قيد التطوير'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _exportTrainingData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة تصدير بيانات التدريب قيد التطوير'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}