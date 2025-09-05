import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModelsInfoDialog extends StatefulWidget {
  const ModelsInfoDialog({super.key});

  @override
  State<ModelsInfoDialog> createState() => _ModelsInfoDialogState();
}

class _ModelsInfoDialogState extends State<ModelsInfoDialog> {
  String _searchQuery = '';
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final size = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.85,
        decoration: BoxDecoration(
          color: theme.dialogBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context, theme, isArabic),
            _buildSearchBar(context, theme, isArabic),
            _buildTabSelector(context, theme, isArabic),
            Expanded(
              child: _buildContent(context, theme, isArabic),
            ),
            _buildFooter(context, theme, isArabic),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isArabic ? 'نماذج الذكاء الاصطناعي' : 'AI Models',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme, bool isArabic) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: isArabic ? 'البحث في النماذج...' : 'Search models...',
          prefixIcon: Icon(Icons.search_rounded, color: theme.primaryColor, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTabSelector(BuildContext context, ThemeData theme, bool isArabic) {
    final tabs = [
      {'icon': Icons.route_rounded, 'label': 'OpenRouter', 'count': 13},
      {'icon': Icons.flash_on_rounded, 'label': 'Groq', 'count': 5},
      {'icon': Icons.more_horiz_rounded, 'label': isArabic ? 'أخرى' : 'Others', 'count': 11},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTab == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : theme.textTheme.bodyMedium?.color,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? Colors.white.withOpacity(0.2)
                            : theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${tab['count']}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : theme.primaryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, bool isArabic) {
    final models = _getModelsForTab(_selectedTab);
    final filteredModels = _filterModels(models);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildStatsRow(context, theme, isArabic, filteredModels),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: filteredModels.length,
              itemBuilder: (context, index) {
                return _buildModelCard(context, theme, isArabic, filteredModels[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, ThemeData theme, bool isArabic, List<Map<String, dynamic>> models) {
    final freeCount = models.where((m) => m['isFree'] == true).length;
    final premiumCount = models.length - freeCount;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            Icons.apps_rounded,
            models.length.toString(),
            isArabic ? 'إجمالي' : 'Total',
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            Icons.free_breakfast_rounded,
            freeCount.toString(),
            isArabic ? 'مجاني' : 'Free',
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            context,
            theme,
            Icons.star_rounded,
            premiumCount.toString(),
            isArabic ? 'مميز' : 'Premium',
            Colors.amber,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, ThemeData theme, IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelCard(BuildContext context, ThemeData theme, bool isArabic, Map<String, dynamic> model) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (model['isFree'] == true ? Colors.green : Colors.amber).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            model['isFree'] == true ? Icons.free_breakfast_rounded : Icons.star_rounded,
            color: model['isFree'] == true ? Colors.green : Colors.amber,
            size: 20,
          ),
        ),
        title: Text(
          model['name'] ?? model['id'] ?? '',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Row(
              children: [
                _buildChip(
                  theme,
                  model['service'] ?? '',
                  theme.primaryColor,
                ),
                const SizedBox(width: 8),
                _buildChip(
                  theme,
                  model['isFree'] == true 
                      ? (isArabic ? 'مجاني' : 'Free')
                      : (isArabic ? 'مميز' : 'Premium'),
                  model['isFree'] == true ? Colors.green : Colors.amber,
                ),
              ],
            ),
            if (model['description'] != null) ...[
              const SizedBox(height: 8),
              Text(
                model['description'].toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (model['parameters'] != null)
                  _buildDetailRow(theme, isArabic ? 'المعاملات' : 'Parameters', model['parameters'].toString()),
                if (model['contextLength'] != null)
                  _buildDetailRow(theme, isArabic ? 'طول السياق' : 'Context Length', model['contextLength'].toString()),
                if (model['modalities'] != null)
                  _buildDetailRow(theme, isArabic ? 'الوسائط' : 'Modalities', model['modalities'].toString()),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _copyModelId(context, model, isArabic),
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: Text(isArabic ? 'نسخ المعرف' : 'Copy ID'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (model['url'] != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openUrl(model['url']),
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: Text(isArabic ? 'فتح الرابط' : 'Open Link'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme, bool isArabic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: theme.primaryColor,
            size: 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isArabic
                  ? 'النماذج المجانية لا تحتاج مفتاح API • محدث ${DateTime.now().year}'
                  : 'Free models don\'t need API key • Updated ${DateTime.now().year}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Data Methods
  List<Map<String, dynamic>> _getModelsForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _getOpenRouterModels();
      case 1:
        return _getGroqModels();
      case 2:
        return _getOtherModels();
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> _filterModels(List<Map<String, dynamic>> models) {
    if (_searchQuery.isEmpty) return models;
    
    return models.where((model) {
      final query = _searchQuery.toLowerCase();
      final name = (model['name'] ?? '').toString().toLowerCase();
      final description = (model['description'] ?? '').toString().toLowerCase();
      final service = (model['service'] ?? '').toString().toLowerCase();
      
      return name.contains(query) || description.contains(query) || service.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> _getOpenRouterModels() {
    return [
      {
        'id': 'meta-llama/llama-4-maverick:free',
        'name': 'Llama 4 Maverick',
        'service': 'OpenRouter',
        'isFree': true,
        'parameters': '400B total, 17B active',
        'contextLength': '256K tokens',
        'modalities': 'Text + Image → Text',
        'description': 'Meta\'s advanced MoE architecture with sparse activation',
        'url': 'https://openrouter.ai/meta-llama/llama-4-maverick:free',
      },
      {
        'id': 'meta-llama/llama-4-scout:free',
        'name': 'Llama 4 Scout',
        'service': 'OpenRouter',
        'isFree': true,
        'parameters': '109B total, 17B active',
        'contextLength': '512K tokens',
        'modalities': 'Text + Image → Text',
        'description': 'Deployment-optimized variant with fewer experts',
        'url': 'https://openrouter.ai/meta-llama/llama-4-scout:free',
      },
      {
        'id': 'moonshotai/kimi-vl-a3b-thinking:free',
        'name': 'Kimi VL A3B Thinking',
        'service': 'OpenRouter',
        'isFree': true,
        'parameters': '16B total, 2.8B active',
        'contextLength': '131K tokens',
        'modalities': 'Text + Image → Text',
        'description': 'Lightweight MoE with specialized visual reasoning',
        'url': 'https://openrouter.ai/moonshotai/kimi-vl-a3b-thinking:free',
      },
      {
        'id': 'nvidia/llama-3.1-nemotron-nano-8b-v1:free',
        'name': 'Llama 3.1 Nemotron Nano',
        'service': 'OpenRouter',
        'isFree': true,
        'parameters': '8B',
        'contextLength': '8K tokens',
        'modalities': 'Text → Text',
        'description': 'NVIDIA\'s optimized Llama variant with tensor parallelism',
        'url': 'https://openrouter.ai/nvidia/llama-3.1-nemotron-nano-8b-v1:free',
      },
      {
        'id': 'google/gemini-2.5-pro-exp-03-25:free',
        'name': 'Gemini 2.5 Pro Experimental',
        'service': 'OpenRouter',
        'isFree': true,
        'parameters': 'Undisclosed (~300-500B)',
        'contextLength': '1M tokens',
        'modalities': 'Text + Image → Text',
        'description': 'Google\'s latest experimental model with enhanced reasoning',
        'url': 'https://openrouter.ai/google/gemini-2.5-pro-exp-03-25:free',
      },
      {
        'id': 'mistralai/mistral-small-3.1-24b-instruct:free',
        'name': 'Mistral Small 3.1',
        'service': 'OpenRouter',
        'isFree': true,
        'parameters': '24B',
        'contextLength': '96K tokens',
        'modalities': 'Text + Image → Text',
        'description': 'Advanced transformer with sliding window attention',
        'url': 'https://openrouter.ai/mistralai/mistral-small-3.1-24b-instruct:free',
      },
      {
        'id': 'deepseek/deepseek-v3-base:free',
        'name': 'DeepSeek V3 Base',
        'service': 'OpenRouter',
        'isFree': true,
        'parameters': 'Undisclosed',
        'contextLength': 'Variable',
        'modalities': 'Text → Text',
        'description': 'Technical domain optimized foundation model',
        'url': 'https://openrouter.ai/deepseek/deepseek-v3-base:free',
      },
      {
        'id': 'qwen/qwen2.5-vl-3b-instruct:free',
        'name': 'Qwen 2.5 VL 3B',
        'service': 'OpenRouter',
        'isFree': true,
        'parameters': '3B',
        'contextLength': 'Variable',
        'modalities': 'Text + Image → Text',
        'description': 'Efficient multimodal model for visual understanding',
        'url': 'https://openrouter.ai/qwen/qwen2.5-vl-3b-instruct:free',
      },
      {
        'id': 'deepseek/deepseek-chat-v3-0324:free',
        'name': 'DeepSeek Chat V3',
        'service': 'OpenRouter',
        'isFree': true,
        'parameters': 'Undisclosed',
        'contextLength': 'Variable',
        'modalities': 'Text → Text',
        'description': 'Dialogue-optimized transformer for conversations',
        'url': 'https://openrouter.ai/deepseek/deepseek-chat-v3-0324:free',
      },
      {
        'id': 'deepseek/deepseek-r1-zero:free',
        'name': 'DeepSeek R1 Zero',
        'service': 'OpenRouter',
        'isFree': true,
        'parameters': 'Undisclosed',
        'contextLength': 'Variable',
        'modalities': 'Text → Text',
        'description': 'Research-oriented model for scientific reasoning',
        'url': 'https://openrouter.ai/deepseek/deepseek-r1-zero:free',
      },
      {
        'id': 'nousresearch/deephermes-3-llama-3-8b-preview:free',
        'name': 'DeepHermes 3 Llama 3 8B',
        'service': 'OpenRouter',
        'isFree': true,
        'parameters': '8B',
        'contextLength': 'Variable',
        'modalities': 'Text → Text',
        'description': 'Nous Research\'s optimized Llama 3 variant',
        'url': 'https://openrouter.ai/nousresearch/deephermes-3-llama-3-8b-preview:free',
      },
      {
        'id': 'openrouter/optimus-alpha',
        'name': 'Optimus Alpha',
        'service': 'OpenRouter',
        'isFree': true,
        'parameters': 'Undisclosed',
        'contextLength': 'Variable',
        'modalities': 'Text → Text',
        'description': 'OpenRouter\'s in-house general-purpose assistant',
        'url': 'https://openrouter.ai/openrouter/optimus-alpha',
      },
      {
        'id': 'openrouter/quasar-alpha',
        'name': 'Quasar Alpha',
        'service': 'OpenRouter',
        'isFree': true,
        'parameters': 'Undisclosed',
        'contextLength': 'Variable',
        'modalities': 'Text → Text',
        'description': 'Knowledge-enhanced reasoning model',
        'url': 'https://openrouter.ai/openrouter/quasar-alpha',
      },
    ];
  }

  List<Map<String, dynamic>> _getGroqModels() {
    return [
      {
        'id': 'llama-3.1-70b-versatile',
        'name': 'Llama 3.1 70B Versatile',
        'service': 'Groq',
        'isFree': true,
        'parameters': '70B',
        'contextLength': '128K tokens',
        'modalities': 'Text → Text',
        'description': 'High-performance general-purpose model with versatile capabilities',
      },
      {
        'id': 'llama-3.1-8b-instant',
        'name': 'Llama 3.1 8B Instant',
        'service': 'Groq',
        'isFree': true,
        'parameters': '8B',
        'contextLength': '128K tokens',
        'modalities': 'Text → Text',
        'description': 'Fast and efficient model for quick responses',
      },
      {
        'id': 'mixtral-8x7b-32768',
        'name': 'Mixtral 8x7B',
        'service': 'Groq',
        'isFree': true,
        'parameters': '8x7B MoE',
        'contextLength': '32K tokens',
        'modalities': 'Text → Text',
        'description': 'Mixture of experts model for diverse tasks',
      },
      {
        'id': 'gemma2-9b-it',
        'name': 'Gemma 2 9B IT',
        'service': 'Groq',
        'isFree': true,
        'parameters': '9B',
        'contextLength': '8K tokens',
        'modalities': 'Text → Text',
        'description': 'Google\'s efficient instruction-tuned model',
      },
      {
        'id': 'llama-guard-3-8b',
        'name': 'Llama Guard 3 8B',
        'service': 'Groq',
        'isFree': true,
        'parameters': '8B',
        'contextLength': '8K tokens',
        'modalities': 'Text → Text',
        'description': 'Safety-focused content moderation model',
      },
    ];
  }

  List<Map<String, dynamic>> _getOtherModels() {
    return [
      // GPT-GOD Models (Updated)
      {
        'id': 'gpt-3.5-turbo',
        'name': 'GPT-3.5 Turbo',
        'service': 'GPTGod',
        'isFree': true,
        'parameters': '1.8B',
        'contextLength': '16K tokens',
        'modalities': 'Text → Text',
        'description': 'نموذج OpenAI السريع والموثوق للاستخدام العام',
      },
      {
        'id': 'gpt-4o-mini',
        'name': 'GPT-4o Mini',
        'service': 'GPTGod',
        'isFree': true,
        'parameters': '3B',
        'contextLength': '128K tokens',
        'modalities': 'Text + Image → Text',
        'description': 'نموذج OpenAI مصغر ومجاني مع قدرات متقدمة',
      },
      {
        'id': 'gpt-4o',
        'name': 'GPT-4o',
        'service': 'GPTGod',
        'isFree': true,
        'parameters': '6B',
        'contextLength': '128K tokens',
        'modalities': 'Text + Vision + Audio',
        'description': 'النموذج الأكثر تطوراً في GPT-4 مع دعم متعدد الوسائط',
      },
      {
        'id': 'gpt-4o-vision',
        'name': 'GPT-4o Vision',
        'service': 'GPTGod',
        'isFree': false,
        'parameters': '6B',
        'contextLength': '128K tokens',
        'modalities': 'Text + Vision',
        'description': 'نموذج متخصص في معالجة الصور والرسوم المتحركة - محدود',
      },
      {
        'id': 'chatgpt-free',
        'name': 'ChatGPT (نسخة مجانية)',
        'service': 'GPTGod',
        'isFree': true,
        'parameters': '3B (based on GPT-4o Mini)',
        'contextLength': '128K tokens',
        'modalities': 'Text → Text',
        'description': 'واجهة ChatGPT المجانية المستندة إلى GPT-4o Mini',
      },
      {
        'id': 'claude-3-haiku',
        'name': 'Claude 3 Haiku',
        'service': 'Anthropic',
        'isFree': false,
        'parameters': 'Undisclosed',
        'contextLength': '200K tokens',
        'modalities': 'Text + Image → Text',
        'description': 'Fast and efficient model from Anthropic',
      },
      {
        'id': 'gpt-4-turbo',
        'name': 'GPT-4 Turbo',
        'service': 'OpenAI',
        'isFree': false,
        'parameters': 'Undisclosed',
        'contextLength': '128K tokens',
        'modalities': 'Text + Image → Text',
        'description': 'Advanced multimodal model with enhanced capabilities',
      },
      {
        'id': 'claude-3.5-sonnet',
        'name': 'Claude 3.5 Sonnet',
        'service': 'Anthropic',
        'isFree': false,
        'parameters': 'Undisclosed',
        'contextLength': '200K tokens',
        'modalities': 'Text + Image → Text',
        'description': 'Anthropic\'s most capable model for complex tasks',
      },
      {
        'id': 'gemini-pro',
        'name': 'Gemini Pro',
        'service': 'Google',
        'isFree': false,
        'parameters': 'Undisclosed',
        'contextLength': '32K tokens',
        'modalities': 'Text + Image → Text',
        'description': 'Google\'s advanced multimodal model',
      },
      {
        'id': 'command-r-plus',
        'name': 'Command R+',
        'service': 'Cohere',
        'isFree': false,
        'parameters': '104B',
        'contextLength': '128K tokens',
        'modalities': 'Text → Text',
        'description': 'Cohere\'s flagship model for enterprise applications',
      },
      {
        'id': 'qwen-max',
        'name': 'Qwen Max',
        'service': 'Alibaba',
        'isFree': false,
        'parameters': 'Undisclosed',
        'contextLength': '32K tokens',
        'modalities': 'Text → Text',
        'description': 'Alibaba\'s most advanced language model',
      },
    ];
  }

  void _copyModelId(BuildContext context, Map<String, dynamic> model, bool isArabic) {
    final modelId = model['id'] ?? '';
    Clipboard.setData(ClipboardData(text: modelId));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic ? 'تم نسخ معرف النموذج' : 'Model ID copied',
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openUrl(String url) {
    // Implement URL opening logic
  }
}
