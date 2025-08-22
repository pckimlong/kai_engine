import 'package:flutter/material.dart';

import '../../debug_system.dart';
import 'shared_widgets.dart';

class MetricsTab extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const MetricsTab({super.key, required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    final inputCost = KaiDebugTracker.instance.getInputTokenCostPerMillion();
    final outputCost = KaiDebugTracker.instance.getOutputTokenCostPerMillion();
    final showCostBreakdown = inputCost > 0 || outputCost > 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _PerformanceMetrics(debugInfo: debugInfo),
          const SizedBox(height: 16),
          _PhaseBreakdown(debugInfo: debugInfo),
          const SizedBox(height: 16),
          _TokenBreakdown(debugInfo: debugInfo),
          const SizedBox(height: 16),
          if (showCostBreakdown) ...[
            _CostBreakdown(debugInfo: debugInfo),
            const SizedBox(height: 16),
          ],
          _ErrorSection(debugInfo: debugInfo),
        ],
      ),
    );
  }
}

class _PerformanceMetrics extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _PerformanceMetrics({required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Metrics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Duration',
                    value: debugInfo.totalDuration != null
                        ? '${debugInfo.totalDuration!.inMilliseconds}ms'
                        : 'In Progress...',
                    icon: Icons.timer,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Streaming Events',
                    value: '${debugInfo.streaming.eventCount}',
                    icon: Icons.stream,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Token Count',
                    value: debugInfo.usage?.tokenCount != null
                        ? '${debugInfo.usage?.tokenCount}'
                        : 'Unknown',
                    icon: Icons.token,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Phases',
                    value: '${debugInfo.phases.length}',
                    icon: Icons.timeline,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha((255 * 0.1).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PhaseBreakdown extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _PhaseBreakdown({required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    final phases = debugInfo.phases.values.toList();
    phases.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phase Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (phases.isEmpty)
              const Text('No phase information available')
            else
              ...phases.map((phase) => _PhaseMetricRow(phase: phase)),
          ],
        ),
      ),
    );
  }
}

class _PhaseMetricRow extends StatelessWidget {
  final DebugPhase phase;

  const _PhaseMetricRow({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: getPhaseColor(phase.name),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              phase.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            phase.duration != null
                ? '${phase.duration!.inMilliseconds}ms'
                : 'In Progress...',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenBreakdown extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _TokenBreakdown({required this.debugInfo});

  void _showTokenCostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _TokenCostDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usage = debugInfo.usage;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Token Breakdown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    _showTokenCostDialog(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _TokenMetricRow(
              label: 'Total Input Tokens',
              value: usage?.inputToken?.toString() ?? "Unknown",
              icon: Icons.input,
            ),
            _TokenMetricRow(
              label: 'Total Output Tokens',
              value: usage?.outputToken?.toString() ?? "Unknown",
              icon: Icons.output,
            ),
            _TokenMetricRow(
              label: 'Total API Calls',
              value: usage?.apiCallCount?.toString() ?? "Unknown",
              icon: Icons.api,
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenCostDialog extends StatefulWidget {
  @override
  _TokenCostDialogState createState() => _TokenCostDialogState();
}

class _TokenCostDialogState extends State<_TokenCostDialog> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  late double _inputCost;
  late double _outputCost;

  @override
  void initState() {
    super.initState();
    _inputCost = KaiDebugTracker.instance.getInputTokenCostPerMillion();
    _outputCost = KaiDebugTracker.instance.getOutputTokenCostPerMillion();
    _inputController.text = _inputCost.toString();
    _outputController.text = _outputCost.toString();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Token Costs'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _inputController,
            decoration: const InputDecoration(
              labelText: 'Input Token Cost per Million',
              prefixText: '\$',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _outputController,
            decoration: const InputDecoration(
              labelText: 'Output Token Cost per Million',
              prefixText: '\$',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final inputCost = double.tryParse(_inputController.text) ?? 0.0;
            final outputCost = double.tryParse(_outputController.text) ?? 0.0;
            KaiDebugTracker.instance.setInputTokenCostPerMillion(inputCost);
            KaiDebugTracker.instance.setOutputTokenCostPerMillion(outputCost);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _CostBreakdown extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _CostBreakdown({required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    final totalCost = KaiDebugTracker.instance.calculateTotalCost(
      debugInfo.usage,
    );
    final inputTokens = debugInfo.usage?.inputToken ?? 0;
    final outputTokens = debugInfo.usage?.outputToken ?? 0;
    final inputCost = KaiDebugTracker.instance.getInputTokenCostPerMillion();
    final outputCost = KaiDebugTracker.instance.getOutputTokenCostPerMillion();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cost Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _TokenMetricRow(
              label: 'Input Token Cost',
              value: '\$${inputCost.toStringAsFixed(2)} per million',
              icon: Icons.input,
            ),
            _TokenMetricRow(
              label: 'Output Token Cost',
              value: '\$${outputCost.toStringAsFixed(2)} per million',
              icon: Icons.output,
            ),
            const SizedBox(height: 16),
            _TokenMetricRow(
              label: 'Total Input Tokens',
              value: inputTokens.toString(),
              icon: Icons.input,
            ),
            _TokenMetricRow(
              label: 'Total Output Tokens',
              value: outputTokens.toString(),
              icon: Icons.output,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha((255 * 0.1).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Cost:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '\$${totalCost.toStringAsFixed(4)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TokenMetricRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TokenMetricRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final MessageDebugInfo debugInfo;

  const _ErrorSection({required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    if (!debugInfo.hasError) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Text(
                'No Errors',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.green),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 12),
                Text(
                  'Error Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 120,
                    child: Text(
                      'Error Phase:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Expanded(
                    child: SelectableText(debugInfo.errorPhase ?? 'Unknown'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Error Details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: SelectableText(
                debugInfo.error?.toString() ?? 'No error details available',
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
