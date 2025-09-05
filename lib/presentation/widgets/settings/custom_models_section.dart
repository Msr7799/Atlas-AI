import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/services/custom_models_manager.dart';
import '../../../core/utils/curl_parser.dart';

/// قسم النماذج المخصصة - Custom LLMs API
class CustomModelsSection extends StatefulWidget {
  const CustomModelsSection({super.key});

  @override
  State<CustomModelsSection> createState() => _CustomModelsSectionState();
}

class _CustomModelsSectionState extends State<CustomModelsSection> {
  final CustomModelsManager _modelsManager = CustomModelsManager.instance;
  List<CustomApiConfig> _customModels = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() {
      _isLoading = true;
    });
    
    await _modelsManager.initialize();
    setState(() {
      _customModels = _modelsManager.customModels;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        leading: Icon(
          Icons.api,
          color: Theme.of(context).primaryColor,
          size: isTablet ? 28 : 24,
        ),
        title: Text(
          isArabic ? 'نماذج API مخصصة' : 'Custom LLMs API',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 18 : 16,
          ),
        ),
        subtitle: Text(
          isArabic 
            ? 'إضافة وإدارة نماذج ذكية مخصصة من أوامر cURL' 
            : 'Add and manage custom AI models from cURL commands',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: isTablet ? 14 : 12,
          ),
        ),
        children: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Column(
              children: [
                // زر إضافة نموذج جديد
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(isTablet ? 20 : 16),
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddModelDialog(),
                    icon: Icon(Icons.add, size: isTablet ? 24 : 20),
                    label: Text(
                      isArabic ? 'إضافة نموذج من cURL' : 'Add Model from cURL',
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // قائمة النماذج المخصصة
                if (_customModels.isNotEmpty)
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: isTablet ? 600 : 400,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _customModels.length,
                      itemBuilder: (context, index) {
                        final model = _customModels[index];
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: isTablet ? 20 : 16,
                            vertical: 6,
                          ),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                radius: isTablet ? 24 : 20,
                                child: Icon(
                                  Icons.smart_toy, 
                                  color: Theme.of(context).primaryColor,
                                  size: isTablet ? 24 : 20,
                                ),
                              ),
                              title: Text(
                                model.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 16 : 14,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    model.description.isNotEmpty 
                                        ? model.description 
                                        : (isArabic ? 'لا يوجد وصف' : 'No description'),
                                    style: TextStyle(
                                      fontSize: isTablet ? 13 : 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    model.url,
                                    style: TextStyle(
                                      fontSize: isTablet ? 12 : 10,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              children: [
                                Container(
                                  padding: EdgeInsets.all(isTablet ? 16 : 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // تفاصيل النموذج
                                      _buildModelDetails(model, isArabic, isTablet),
                                      const SizedBox(height: 12),
                                      
                                      // أزرار الإجراءات
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // زر التعديل
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _showEditModelDialog(model),
                                              icon: const Icon(Icons.edit, size: 18),
                                              label: Text(
                                                isArabic ? 'تعديل' : 'Edit',
                                                style: TextStyle(fontSize: isTablet ? 14 : 12),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.orange,
                                                side: const BorderSide(color: Colors.orange),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          
                                          // زر الاختبار
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _testModel(model),
                                              icon: const Icon(Icons.play_arrow, size: 18),
                                              label: Text(
                                                isArabic ? 'اختبار' : 'Test',
                                                style: TextStyle(fontSize: isTablet ? 14 : 12),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.blue,
                                                side: const BorderSide(color: Colors.blue),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          
                                          // زر الحذف
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () => _showDeleteConfirmation(model),
                                              icon: const Icon(Icons.delete, size: 18),
                                              label: Text(
                                                isArabic ? 'حذف' : 'Delete',
                                                style: TextStyle(fontSize: isTablet ? 14 : 12),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.red,
                                                side: const BorderSide(color: Colors.red),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.api_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isArabic 
                            ? 'لا توجد نماذج مخصصة' 
                            : 'No custom models yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isArabic 
                            ? 'انقر على "إضافة نموذج من cURL" لبدء إضافة نماذج مخصصة' 
                            : 'Click "Add Model from cURL" to start adding custom models',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildModelCard(CustomApiConfig model, bool isArabic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.api,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    switch (value) {
                      case 'test':
                        await _testModel(model);
                        break;
                      case 'edit':
                        _showEditModelDialog(model);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(model);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'test',
                      child: Row(
                        children: [
                          const Icon(Icons.play_arrow, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(isArabic ? 'اختبار' : 'Test'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(isArabic ? 'تحرير' : 'Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(isArabic ? 'حذف' : 'Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          model.url,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getMethodColor(model.method).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _getMethodColor(model.method).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          model.method,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getMethodColor(model.method),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${model.headers.length} ${isArabic ? 'رؤوس' : 'headers'}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isArabic 
                          ? 'تم الإنشاء: ${_formatDate(model.createdAt)}' 
                          : 'Created: ${_formatDate(model.createdAt)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddModelDialog() {
    final curlController = TextEditingController();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String? errorMessage;
    bool isLoading = false;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.add_circle_outline, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic ? 'إضافة نموذج مخصص' : 'Add Custom Model',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            height: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic 
                      ? 'الصق أمر cURL هنا:' 
                      : 'Paste your cURL command here:',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: TextField(
                        controller: curlController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        decoration: InputDecoration(
                          hintText: '''curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent" \\
  -H 'Content-Type: application/json' \\
  -H 'X-goog-api-key: YOUR_API_KEY' \\
  -X POST \\
  -d '{
    "contents": [
      {
        "parts": [
          {
            "text": "{message}"
          }
        ]
      }
    ]
  }'
''',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                          border: const OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isArabic ? 'اسم النموذج (اختياري):' : 'Model Name (Optional):',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: isArabic 
                        ? 'سيتم استخراجه تلقائياً من cURL' 
                        : 'Will be extracted automatically from cURL',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isArabic ? 'الوصف (اختياري):' : 'Description (Optional):',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: isArabic 
                        ? 'وصف مختصر للنموذج' 
                        : 'Brief description of the model',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final curlText = curlController.text.trim();
                if (curlText.isEmpty) {
                  setState(() {
                    errorMessage = isArabic 
                      ? 'يرجى إدخال أمر cURL' 
                      : 'Please enter a cURL command';
                  });
                  return;
                }

                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });

                try {
                  final config = CurlParser.parseCurlCommand(curlText);
                  if (config == null) {
                    setState(() {
                      errorMessage = isArabic 
                        ? 'خطأ في تحليل أمر cURL' 
                        : 'Error parsing cURL command';
                    });
                    return;
                  }

                  // استخدام الاسم المدخل أو المستخرج تلقائياً
                  final finalConfig = CustomApiConfig(
                    name: nameController.text.trim().isEmpty 
                      ? config.name 
                      : nameController.text.trim(),
                    url: config.url,
                    method: config.method,
                    headers: config.headers,
                    bodyTemplate: config.bodyTemplate,
                    description: descriptionController.text.trim().isEmpty 
                      ? config.description 
                      : descriptionController.text.trim(),
                  );

                  final success = await _modelsManager.addModel(finalConfig);
                  if (success) {
                    await _loadModels();
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isArabic 
                              ? '✅ تم إضافة النموذج بنجاح' 
                              : '✅ Model added successfully',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    setState(() {
                      errorMessage = isArabic 
                        ? 'خطأ في إضافة النموذج' 
                        : 'Error adding model';
                    });
                  }
                } catch (e) {
                  setState(() {
                    errorMessage = e.toString();
                  });
                } finally {
                  setState(() {
                    isLoading = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(isArabic ? 'إضافة النموذج' : 'Add Model'),
            ),
          ],
        ),
      ),
    );
  }

  // بناء تفاصيل النموذج
  Widget _buildModelDetails(CustomApiConfig model, bool isArabic, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // URL
        Row(
          children: [
            Icon(Icons.link, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                model.url,
                style: TextStyle(
                  fontSize: isTablet ? 13 : 12,
                  color: Colors.grey[700],
                  fontFamily: 'monospace',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Headers (إن وجدت)
        if (model.headers.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.security, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'رؤوس HTTP:' : 'HTTP Headers:',
                style: TextStyle(
                  fontSize: isTablet ? 12 : 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              model.headers.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join('\n'),
              style: TextStyle(
                fontSize: isTablet ? 11 : 10,
                fontFamily: 'monospace',
                color: Colors.grey[700],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  void _showEditModelDialog(CustomApiConfig model) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final nameController = TextEditingController(text: model.name);
    final descController = TextEditingController(text: model.description);
    final curlController = TextEditingController();
    
    // تحويل النموذج إلى cURL للتعديل
    final curlCommand = _buildCurlFromConfig(model);
    curlController.text = curlCommand;
    
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.edit, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isArabic ? 'تعديل النموذج' : 'Edit Model',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 500,
            height: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم النموذج
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'اسم النموذج' : 'Model Name',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // وصف النموذج
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'الوصف (اختياري)' : 'Description (Optional)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // أمر cURL
                  Text(
                    isArabic ? 'أمر cURL:' : 'cURL Command:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: curlController,
                    decoration: InputDecoration(
                      hintText: isArabic ? 'الصق أمر cURL المحدث هنا...' : 'Paste updated cURL command here...',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.terminal),
                    ),
                    maxLines: 8,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(isArabic ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty || curlController.text.trim().isEmpty) {
                        return;
                      }

                      setState(() => isLoading = true);
                      
                      try {
                        // حذف النموذج القديم
                        await _modelsManager.removeModel(model.name);
                        
                        // إضافة النموذج المحدث
                        final success = await _modelsManager.addModelFromCurl(
                          nameController.text.trim(),
                          descController.text.trim(),
                          curlController.text.trim(),
                        );

                        if (success) {
                          await _loadModels();
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isArabic ? '✅ تم تحديث النموذج' : '✅ Model updated',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isArabic ? '❌ فشل في تحديث النموذج' : '❌ Failed to update model',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                      
                      setState(() => isLoading = false);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(isArabic ? 'تحديث' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  String _buildCurlFromConfig(CustomApiConfig config) {
    final headers = config.headers.entries
        .map((e) => '-H "${e.key}: ${e.value}"')
        .join(' ');
    
    return 'curl -X POST "${config.url}" $headers -d \'{"model": "your-model", "messages": [{"role": "user", "content": "test"}]}\'';
  }

  void _showDeleteConfirmation(CustomApiConfig model) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 8),
            Text(isArabic ? 'حذف النموذج' : 'Delete Model'),
          ],
        ),
        content: Text(
          isArabic 
            ? 'هل تريد حذف النموذج "${model.name}"؟'
            : 'Do you want to delete the model "${model.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await _modelsManager.removeModel(model.name);
              if (success) {
                await _loadModels();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isArabic 
                          ? '✅ تم حذف النموذج' 
                          : '✅ Model deleted',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isArabic ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _testModel(CustomApiConfig model) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.play_arrow, color: Colors.blue),
            const SizedBox(width: 8),
            Text(isArabic ? 'اختبار النموذج' : 'Test Model'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              isArabic 
                ? 'جاري اختبار النموذج...' 
                : 'Testing model...',
            ),
          ],
        ),
      ),
    );

    try {
      final success = await _modelsManager.testModel(
        model, 
        testMessage: isArabic ? 'مرحبا' : 'Hello',
      );
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                ? (isArabic ? '✅ النموذج يعمل بشكل صحيح' : '✅ Model is working correctly')
                : (isArabic ? '❌ فشل في اختبار النموذج' : '❌ Model test failed'),
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isArabic 
                ? '❌ خطأ في الاختبار: ${e.toString()}' 
                : '❌ Test error: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
