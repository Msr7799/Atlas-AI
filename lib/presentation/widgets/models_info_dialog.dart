import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/services/api_key_manager.dart';

class ModelsInfoDialog extends StatefulWidget {
  const ModelsInfoDialog({super.key});

  @override
  State<ModelsInfoDialog> createState() => _ModelsInfoDialogState();
}

class _ModelsInfoDialogState extends State<ModelsInfoDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedFilter = 'all';
  final Set<String> _selectedModelsForComparison = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints, deviceType) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getResponsiveWidth(
                context,
                mobile: 12,
                tablet: 16,
                desktop: 20,
              ),
            ),
          ),
          child: Container(
            width: ResponsiveHelper.getResponsiveConstraints(
              context,
              mobile: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              tablet: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              desktop: BoxConstraints(
                maxWidth: 1000,
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
            ).maxWidth,
            height: ResponsiveHelper.getResponsiveConstraints(
              context,
              mobile: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.95,
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              tablet: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              desktop: BoxConstraints(
                maxWidth: 1000,
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
            ).maxHeight,
            padding: ResponsiveHelper.getResponsivePadding(
              context,
              mobile: const EdgeInsets.all(12),
              tablet: const EdgeInsets.all(16),
              desktop: const EdgeInsets.all(20),
            ),
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                const Divider(),

                // Search and Filter Bar
                _buildSearchAndFilterBar(context),

                // Statistics Bar
                _buildStatisticsBar(context),

                // Tab Bar
                _buildTabBar(context),

                // Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllModelsTab(context),
                      _buildFreeModelsTab(context),
                      _buildPremiumModelsTab(context),
                    ],
                  ),
                ),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: ResponsiveHelper.getResponsivePadding(
                        context,
                        mobile: const EdgeInsets.symmetric(vertical: 12),
                        tablet: const EdgeInsets.symmetric(vertical: 14),
                        desktop: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    child: Text(
                      'إغلاق',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.psychology,
            color: Colors.blue,
            size: ResponsiveHelper.getResponsiveIconSize(
              context,
              mobile: 24,
              tablet: 28,
              desktop: 32,
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'النماذج المتاحة',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 18,
                    tablet: 20,
                    desktop: 24,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'اكتشف النماذج المجانية والمدفوعة',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getResponsiveFontSize(
                    context,
                    mobile: 12,
                    tablet: 14,
                    desktop: 16,
                  ),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        // Export Button
        IconButton(
          icon: Icon(
            Icons.download,
            size: ResponsiveHelper.getResponsiveIconSize(
              context,
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
          ),
          onPressed: () => _exportModelsList(context),
          tooltip: 'تصدير قائمة النماذج',
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            size: ResponsiveHelper.getResponsiveIconSize(
              context,
              mobile: 20,
              tablet: 24,
              desktop: 28,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  void _exportModelsList(BuildContext context) {
    final allModels = _getAllModels();
    final buffer = StringBuffer();
    
    buffer.writeln('قائمة النماذج المتاحة في Atlas AI');
    buffer.writeln('=' * 50);
    buffer.writeln('');
    
    // Group by service
    final services = ['groq', 'gptgod', 'openrouter', 'huggingface'];
    
    for (final service in services) {
      final serviceModels = allModels.where((model) => model['service'] == service).toList();
      if (serviceModels.isEmpty) continue;
      
      final serviceName = {
        'groq': 'Groq',
        'gptgod': 'GPTGod',
        'openrouter': 'OpenRouter',
        'huggingface': 'HuggingFace',
      }[service] ?? service;
      
      buffer.writeln('## $serviceName');
      buffer.writeln('');
      
      for (final model in serviceModels) {
        buffer.writeln('### ${model['name'] ?? model['id']}');
        buffer.writeln('**المعرف:** `${model['id']}`');
        buffer.writeln('**الوصف:** ${model['description'] ?? ''}');
        buffer.writeln('**السرعة:** ${model['speed'] ?? ''}');
        buffer.writeln('**الجودة:** ${model['quality'] ?? ''}');
        buffer.writeln('**السياق:** ${model['context'] ?? ''}');
        
        if (model['features'] != null) {
          buffer.writeln('**المميزات:** ${model['features'].join(', ')}');
        }
        
        if (model['requiresKey'] == true) {
          buffer.writeln('**النوع:** مدفوع (يتطلب مفتاح API)');
        } else {
          buffer.writeln('**النوع:** مجاني');
        }
        
        buffer.writeln('');
      }
      
      buffer.writeln('---');
      buffer.writeln('');
    }
    
    final modelsText = buffer.toString();
    Clipboard.setData(ClipboardData(text: modelsText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'تم تصدير قائمة النماذج إلى الحافظة',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'عرض',
          textColor: Colors.white,
          onPressed: () => _showExportedModels(context, modelsText),
        ),
      ),
    );
  }

  void _showExportedModels(BuildContext context, String modelsText) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('قائمة النماذج المصدرة'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6,
          child: SingleChildScrollView(
            child: SelectableText(
              modelsText,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              // Search Bar
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'البحث في النماذج...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: ResponsiveHelper.getResponsivePadding(
                      context,
                      mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      desktop: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              // Filter Dropdown
              DropdownButton<String>(
                value: _selectedFilter,
                items: [
                  DropdownMenuItem(value: 'all', child: Text('الكل')),
                  DropdownMenuItem(value: 'fast', child: Text('سريع')),
                  DropdownMenuItem(value: 'quality', child: Text('جودة عالية')),
                  DropdownMenuItem(value: 'free', child: Text('مجاني')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
              ),
            ],
          ),
          // Comparison Bar
          if (_selectedModelsForComparison.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.compare_arrows, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_selectedModelsForComparison.length} نموذج محدد للمقارنة',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _selectedModelsForComparison.length >= 2 
                        ? () => _showComparisonDialog(context)
                        : null,
                    child: Text('مقارنة'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedModelsForComparison.clear();
                      });
                    },
                    child: Text('مسح'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showComparisonDialog(BuildContext context) {
    final allModels = _getAllModels();
    final selectedModels = allModels.where(
      (model) => _selectedModelsForComparison.contains(model['id'])
    ).toList();
    
    if (selectedModels.length < 2) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('مقارنة النماذج'),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: _buildComparisonTable(context, selectedModels),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(BuildContext context, List<Map<String, dynamic>> models) {
    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        // Header
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[100]),
          children: [
            _buildTableHeader(context, 'المعيار'),
            ...models.map((model) => _buildTableHeader(context, model['name'] ?? model['id'])),
          ],
        ),
        // Model ID
        TableRow(
          children: [
            _buildTableCell(context, 'معرف النموذج', isHeader: true),
            ...models.map((model) => _buildTableCell(context, model['id'] ?? '')),
          ],
        ),
        // Service
        TableRow(
          children: [
            _buildTableCell(context, 'الخدمة', isHeader: true),
            ...models.map((model) => _buildTableCell(context, _getServiceName(model['service']))),
          ],
        ),
        // Speed
        TableRow(
          children: [
            _buildTableCell(context, 'السرعة', isHeader: true),
            ...models.map((model) => _buildTableCell(context, model['speed'] ?? '')),
          ],
        ),
        // Quality
        TableRow(
          children: [
            _buildTableCell(context, 'الجودة', isHeader: true),
            ...models.map((model) => _buildTableCell(context, model['quality'] ?? '')),
          ],
        ),
        // Context
        TableRow(
          children: [
            _buildTableCell(context, 'السياق', isHeader: true),
            ...models.map((model) => _buildTableCell(context, model['context'] ?? '')),
          ],
        ),
        // Type
        TableRow(
          children: [
            _buildTableCell(context, 'النوع', isHeader: true),
            ...models.map((model) => _buildTableCell(
              context, 
              _isFreeModel(model) ? 'مجاني' : 'مدفوع',
              color: _isFreeModel(model) ? Colors.green : Colors.amber,
            )),
          ],
        ),
        // Features
        TableRow(
          children: [
            _buildTableCell(context, 'المميزات', isHeader: true),
            ...models.map((model) => _buildTableCell(
              context, 
              (model['features'] as List<dynamic>?)?.join(', ') ?? '',
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 12,
            tablet: 14,
            desktop: 16,
          ),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(BuildContext context, String text, {bool isHeader = false, Color? color}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 10,
            tablet: 12,
            desktop: 14,
          ),
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getServiceName(String? service) {
    switch (service) {
      case 'groq': return 'Groq';
      case 'gptgod': return 'GPTGod';
      case 'openrouter': return 'OpenRouter';
      case 'huggingface': return 'HuggingFace';
      default: return service ?? '';
    }
  }

  bool _isFreeModel(Map<String, dynamic> model) {
    return model['requiresKey'] != true || 
           model['service'] == 'groq' || 
           model['service'] == 'gptgod';
  }

  Widget _buildStatisticsBar(BuildContext context) {
    final allModels = _getAllModels();
    final freeModels = allModels.where((model) => 
      model['requiresKey'] != true || 
      model['service'] == 'groq' || 
      model['service'] == 'gptgod'
    ).length;
    final premiumModels = allModels.where((model) => 
      model['requiresKey'] == true && 
      model['service'] != 'groq' && 
      model['service'] != 'gptgod'
    ).length;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.all(8),
        tablet: const EdgeInsets.all(12),
        desktop: const EdgeInsets.all(16),
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              'إجمالي النماذج',
              allModels.length.toString(),
              Icons.psychology,
              Colors.blue,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'النماذج المجانية',
              freeModels.toString(),
              Icons.free_breakfast,
              Colors.green,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'النماذج المدفوعة',
              premiumModels.toString(),
              Icons.star,
              Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: ResponsiveHelper.getResponsiveIconSize(
            context,
            mobile: 16,
            tablet: 18,
            desktop: 20,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(
              context,
              mobile: 10,
              tablet: 12,
              desktop: 14,
            ),
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.all_inclusive, size: 16),
                SizedBox(width: 4),
                Text('الكل'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.free_breakfast, size: 16),
                SizedBox(width: 4),
                Text('مجاني'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 16),
                SizedBox(width: 4),
                Text('مدفوع'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllModelsTab(BuildContext context) {
    return _buildModelsList(context, _getAllModels());
  }

  Widget _buildFreeModelsTab(BuildContext context) {
    return _buildModelsList(context, _getFreeModels());
  }

  Widget _buildPremiumModelsTab(BuildContext context) {
    return _buildModelsList(context, _getPremiumModels());
  }

  Widget _buildModelsList(BuildContext context, List<Map<String, dynamic>> models) {
    final filteredModels = _filterModels(models);
    
    if (filteredModels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد نماذج تطابق البحث',
              style: TextStyle(
                fontSize: ResponsiveHelper.getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Groq Models
          _buildServiceSection(context, 'Groq', 'groq', Colors.blue, filteredModels),
          SizedBox(height: 24),
          // GPTGod Models
          _buildServiceSection(context, 'GPTGod', 'gptgod', Colors.green, filteredModels),
          SizedBox(height: 24),
          // OpenRouter Models
          _buildServiceSection(context, 'OpenRouter', 'openrouter', Colors.purple, filteredModels),
          SizedBox(height: 24),
          // HuggingFace Models
          _buildServiceSection(context, 'HuggingFace', 'huggingface', Colors.orange, filteredModels),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAllModels() {
    final allModels = <Map<String, dynamic>>[];
    final services = ['groq', 'gptgod', 'openrouter', 'huggingface'];
    
    for (final service in services) {
      final models = ApiKeyManager.getFreeModels(service);
      for (final model in models) {
        allModels.add({...model, 'service': service});
      }
    }
    
    return allModels;
  }

  List<Map<String, dynamic>> _getFreeModels() {
    return _getAllModels().where((model) => 
      model['requiresKey'] != true || model['service'] == 'groq' || model['service'] == 'gptgod'
    ).toList();
  }

  List<Map<String, dynamic>> _getPremiumModels() {
    return _getAllModels().where((model) => 
      model['requiresKey'] == true && model['service'] != 'groq' && model['service'] != 'gptgod'
    ).toList();
  }

  List<Map<String, dynamic>> _filterModels(List<Map<String, dynamic>> models) {
    return models.where((model) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final name = (model['name'] ?? '').toString().toLowerCase();
        final description = (model['description'] ?? '').toString().toLowerCase();
        final features = (model['features'] ?? []).join(' ').toLowerCase();
        
        if (!name.contains(query) && 
            !description.contains(query) && 
            !features.contains(query)) {
          return false;
        }
      }
      
      // Category filter
      switch (_selectedFilter) {
        case 'fast':
          return (model['speed'] ?? '').toString().contains('سريع');
        case 'quality':
          return (model['quality'] ?? '').toString().contains('ممتاز');
        case 'free':
          return model['requiresKey'] != true || 
                 model['service'] == 'groq' || 
                 model['service'] == 'gptgod';
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildServiceSection(BuildContext context, String serviceName, String serviceKey, Color color, List<Map<String, dynamic>> allModels) {
    final serviceModels = allModels.where((model) => model['service'] == serviceKey).toList();
    
    if (serviceModels.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service Header
        Container(
          padding: ResponsiveHelper.getResponsivePadding(
            context,
            mobile: const EdgeInsets.all(12),
            tablet: const EdgeInsets.all(16),
            desktop: const EdgeInsets.all(20),
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.smart_toy,
                color: color,
                size: ResponsiveHelper.getResponsiveIconSize(
                  context,
                  mobile: 20,
                  tablet: 24,
                  desktop: 28,
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
                      serviceName,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 16,
                          tablet: 18,
                          desktop: 20,
                        ),
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      '${serviceModels.length} نموذج متاح',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 12,
                          tablet: 14,
                          desktop: 16,
                        ),
                        color: color.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (serviceKey == 'groq' || serviceKey == 'gptgod')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text(
                    'مجاني',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        mobile: 10,
                        tablet: 12,
                        desktop: 14,
                      ),
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
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

        // Models Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveHelper.getGridColumns(
              context,
              mobile: 1,
              tablet: 2,
              desktop: 3,
            ),
            crossAxisSpacing: ResponsiveHelper.getResponsiveWidth(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
            mainAxisSpacing: ResponsiveHelper.getResponsiveHeight(
              context,
              mobile: 8,
              tablet: 12,
              desktop: 16,
            ),
            childAspectRatio: ResponsiveHelper.getResponsiveAspectRatio(
              context,
              mobile: 2.5,
              tablet: 2.8,
              desktop: 3.2,
            ),
          ),
          itemCount: serviceModels.length,
          itemBuilder: (context, index) {
            return _buildModelCard(context, serviceModels[index], color);
          },
        ),
      ],
    );
  }

  Widget _buildModelCard(BuildContext context, Map<String, dynamic> model, Color color) {
    final isPremium = model['requiresKey'] == true && 
                     model['service'] != 'groq' && 
                     model['service'] != 'gptgod';
    final isSelected = _selectedModelsForComparison.contains(model['id']);
    
    return Card(
      elevation: 2,
      child: Tooltip(
        message: _buildModelTooltip(model),
        preferBelow: false,
        child: InkWell(
          onTap: () => _copyModelId(context, model),
          onLongPress: () => _toggleModelSelection(model['id']),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: ResponsiveHelper.getResponsivePadding(
              context,
              mobile: const EdgeInsets.all(8),
              tablet: const EdgeInsets.all(12),
              desktop: const EdgeInsets.all(16),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected 
                    ? Colors.blue.withOpacity(0.5)
                    : (isPremium ? Colors.amber.withOpacity(0.3) : color.withOpacity(0.2)),
                width: isSelected ? 2 : 1,
              ),
              gradient: isSelected 
                  ? LinearGradient(
                      colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : (isPremium ? LinearGradient(
                      colors: [Colors.amber.withOpacity(0.1), Colors.orange.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ) : null),
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Model Name and Premium Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          model['name'] ?? model['id'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 12,
                              tablet: 14,
                              desktop: 16,
                            ),
                            color: isSelected 
                                ? Colors.blue[700]
                                : (isPremium ? Colors.amber[700] : color),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.blue,
                        )
                      else if (isPremium)
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[600],
                        ),
                    ],
                  ),
                  
                  SizedBox(
                    height: ResponsiveHelper.getResponsiveHeight(
                      context,
                      mobile: 4,
                      tablet: 6,
                      desktop: 8,
                    ),
                  ),

                  // Description
                  Flexible(
                    child: Text(
                      model['description'] ?? '',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          mobile: 10,
                          tablet: 12,
                          desktop: 14,
                        ),
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  SizedBox(
                    height: ResponsiveHelper.getResponsiveHeight(
                      context,
                      mobile: 6,
                      tablet: 8,
                      desktop: 10,
                    ),
                  ),

                  // Info Chips
                  Row(
                    children: [
                      _buildInfoChip(context, 'سرعة', model['speed'] ?? '', color),
                      SizedBox(
                        width: ResponsiveHelper.getResponsiveWidth(
                          context,
                          mobile: 4,
                          tablet: 6,
                          desktop: 8,
                        ),
                      ),
                      _buildInfoChip(context, 'جودة', model['quality'] ?? '', color),
                    ],
                  ),

                  // Context Info
                  if (model['context'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'السياق: ${model['context']}',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(
                            context,
                            mobile: 8,
                            tablet: 10,
                            desktop: 12,
                          ),
                          color: Colors.grey[500],
                        ),
                      ),
                    ),

                  // Copy hint
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.copy,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        SizedBox(width: 4),
                        Text(
                          isSelected 
                              ? 'انقر طويلاً لإلغاء التحديد'
                              : 'انقر لنسخ المعرف، انقر طويلاً للمقارنة',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              mobile: 8,
                              tablet: 10,
                              desktop: 12,
                            ),
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _copyModelId(BuildContext context, Map<String, dynamic> model) {
    final modelId = model['id'] ?? '';
    Clipboard.setData(ClipboardData(text: modelId));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'تم نسخ معرف النموذج: $modelId',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _toggleModelSelection(String model) {
    setState(() {
      if (_selectedModelsForComparison.contains(model)) {
        _selectedModelsForComparison.remove(model);
      } else {
        _selectedModelsForComparison.add(model);
      }
    });
  }

  Widget _buildInfoChip(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: ResponsiveHelper.getResponsivePadding(
        context,
        mobile: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        tablet: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        desktop: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: ResponsiveHelper.getResponsiveFontSize(
            context,
            mobile: 8,
            tablet: 10,
            desktop: 12,
          ),
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _buildModelTooltip(Map<String, dynamic> model) {
    final buffer = StringBuffer();
    
    buffer.writeln('${model['name'] ?? model['id']}');
    buffer.writeln('');
    
    if (model['description'] != null) {
      buffer.writeln('الوصف: ${model['description']}');
      buffer.writeln('');
    }
    
    if (model['features'] != null) {
      buffer.writeln('المميزات: ${model['features']}');
      buffer.writeln('');
    }
    
    buffer.writeln('السرعة: ${model['speed'] ?? 'غير محدد'}');
    buffer.writeln('الجودة: ${model['quality'] ?? 'غير محدد'}');
    buffer.writeln('السياق: ${model['context'] ?? 'غير محدد'}');
    
    if (model['requiresKey'] == true) {
      buffer.writeln('يتطلب مفتاح API');
    } else {
      buffer.writeln('مجاني للاستخدام');
    }
    
    return buffer.toString();
  }
}
