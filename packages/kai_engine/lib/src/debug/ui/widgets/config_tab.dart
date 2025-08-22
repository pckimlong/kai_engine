import 'dart:convert';

import 'package:flutter/material.dart';

import '../../debug_system.dart';
import 'shared_widgets.dart';

class ConfigTab extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const ConfigTab({super.key, required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _GenerationConfigSection(debugInfo: debugInfo),
          const SizedBox(height: 16),
          _QueryProcessingSection(debugInfo: debugInfo),
          const SizedBox(height: 16),
          _MetadataSection(debugInfo: debugInfo),
          const SizedBox(height: 16),
          _TokenCostSection(),
        ],
      ),
    );
  }
}

class _GenerationConfigSection extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _GenerationConfigSection({required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    final config = debugInfo.generationConfig;
    return ExpandableSectionCard(
      title: 'Generation Configuration',
      subtitle: config != null
          ? '${config.availableTools.length} tools, ${debugInfo.usage?.tokenCount ?? "Unknown"} tokens'
          : 'Not available',
      icon: Icons.settings,
      initiallyExpanded: true,
      child: config != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (debugInfo.usage?.tokenCount != null)
                  _ConfigRow(
                    label: 'Token Count',
                    value: '${debugInfo.usage?.tokenCount}',
                  ),
                _ConfigRow(
                  label: 'Used Embedding',
                  value: config.usedEmbedding ? 'Yes' : 'No',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Available Tools:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (config.availableTools.isEmpty)
                  const Text('No tools available')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: config.availableTools
                        .map(
                          (tool) => Chip(
                            label: Text(tool),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 12),
                const Text(
                  'Configuration:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: SelectableText(
                    config.config.isEmpty
                        ? 'No configuration data'
                        : const JsonEncoder.withIndent(
                            '  ',
                          ).convert(config.config),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            )
          : const Text('Generation configuration not available'),
    );
  }
}

class _QueryProcessingSection extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _QueryProcessingSection({required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    final query = debugInfo.processedQuery;
    return ExpandableSectionCard(
      title: 'Query Processing',
      subtitle: query != null ? 'Query processed' : 'Not available',
      icon: Icons.search,
      child: query != null
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: SelectableText(
                query.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            )
          : const Text('Query processing information not available'),
    );
  }
}

class _MetadataSection extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _MetadataSection({required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    final metadata = debugInfo.metadata;
    return ExpandableSectionCard(
      title: 'Custom Metadata',
      subtitle: '${metadata.length} entries',
      icon: Icons.data_object,
      child: metadata.isEmpty
          ? const Text('No custom metadata available')
          : Column(
              children: metadata.entries
                  .map(
                    (entry) => _ConfigRow(
                      label: entry.key,
                      value: entry.value.toString(),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _ConfigRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConfigRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
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
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

class _TokenCostSection extends StatefulWidget {
  @override
  _TokenCostSectionState createState() => _TokenCostSectionState();
}

class _TokenCostSectionState extends State<_TokenCostSection> {
  late TextEditingController _inputCostController;
  late TextEditingController _outputCostController;

  @override
  void initState() {
    super.initState();
    _inputCostController = TextEditingController(
      text: KaiDebugTracker.instance
          .getInputTokenCostPerMillion()
          .toStringAsFixed(2),
    );
    _outputCostController = TextEditingController(
      text: KaiDebugTracker.instance
          .getOutputTokenCostPerMillion()
          .toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _inputCostController.dispose();
    _outputCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableSectionCard(
      title: 'Token Cost Configuration',
      subtitle: 'Set cost per million tokens',
      icon: Icons.attach_money,
      initiallyExpanded: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _inputCostController,
            decoration: const InputDecoration(
              labelText: 'Input Token Cost per Million',
              prefixText: '\$',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              if (value.isNotEmpty) {
                try {
                  final cost = double.parse(value);
                  KaiDebugTracker.instance.setInputTokenCostPerMillion(cost);
                } catch (e) {
                  // Ignore invalid input
                }
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _outputCostController,
            decoration: const InputDecoration(
              labelText: 'Output Token Cost per Million',
              prefixText: '\$',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              if (value.isNotEmpty) {
                try {
                  final cost = double.parse(value);
                  KaiDebugTracker.instance.setOutputTokenCostPerMillion(cost);
                } catch (e) {
                  // Ignore invalid input
                }
              }
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Note: These costs are used to calculate the total cost based on token usage.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
