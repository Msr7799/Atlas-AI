import 'package:flutter/material.dart';
import '../../core/services/api_key_manager.dart';
import '../../core/utils/responsive_helper.dart';

class ModelsInfoDialog extends StatelessWidget {
  const ModelsInfoDialog({super.key});

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
                maxWidth: 900,
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
                maxWidth: 900,
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

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Groq Models
                        _buildServiceSection(context, 'Groq', 'groq', Colors.blue),
                        SizedBox(
                          height: ResponsiveHelper.getResponsiveHeight(
                            context,
                            mobile: 20,
                            tablet: 24,
                            desktop: 28,
                          ),
                        ),
                        // GPTGod Models
                        _buildServiceSection(context, 'GPTGod', 'gptgod', Colors.green),
                      ],
                    ),
                  ),
                ),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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
        Icon(
          Icons.psychology,
          color: Colors.blue,
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
        const Spacer(),
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

  Widget _buildServiceSection(BuildContext context, String serviceName, String serviceKey, Color color) {
    final models = ApiKeyManager.getFreeModels(serviceKey);
    
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
              const Spacer(),
              Text(
                '${models.length} نموذج',
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
          itemCount: models.length,
          itemBuilder: (context, index) {
            return _buildModelCard(context, models[index], color);
          },
        ),
      ],
    );
  }

  Widget _buildModelCard(BuildContext context, Map<String, dynamic> model, Color color) {
    return Card(
      elevation: 2,
      child: Tooltip(
        message: _buildModelTooltip(model),
        preferBelow: false,
        child: Container(
          padding: ResponsiveHelper.getResponsivePadding(
            context,
            mobile: const EdgeInsets.all(8),
            tablet: const EdgeInsets.all(12),
            desktop: const EdgeInsets.all(16),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Model Name
                Text(
                  model['name'] ?? model['id'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      mobile: 12,
                      tablet: 14,
                      desktop: 16,
                    ),
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              ],
            ),
          ),
        ),
      ),
    );
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
    
    return buffer.toString();
  }
}
