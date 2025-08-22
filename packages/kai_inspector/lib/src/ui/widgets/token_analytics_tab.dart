import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kai_engine/src/inspector/models/timeline_session.dart';

import '../session_metrics_calculator.dart';
import 'shared_widgets.dart';

/// Detailed token usage analytics and cost analysis
class TokenAnalyticsTab extends StatelessWidget {
  final TimelineSession session;
  final SessionMetrics sessionMetrics;
  final bool isSmallScreen;

  const TokenAnalyticsTab({
    super.key,
    required this.session,
    required this.sessionMetrics,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokenUsageTrend =
        SessionMetricsCalculator.calculateTokenUsageTrend(session);
    final phaseComparison =
        SessionMetricsCalculator.calculatePhasePerformanceComparison(session);
    final costAnalysis = SessionMetricsCalculator.calculateCostAnalysis(session,
        costPerToken: 0.0001);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withAlpha(13),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withAlpha(26),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.analytics,
                  size: 28,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Token Analytics',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).primaryColor,
                                ),
                      ),
                      Text(
                        'Detailed token usage and cost analysis',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _TokenOverviewCards(
            sessionMetrics: sessionMetrics,
            isSmallScreen: isSmallScreen,
          ),
          const SizedBox(height: 20),
          if (isSmallScreen) ...[
            // Stack vertically on small screens
            Container(
              width: double.infinity,
              child: _TokenUsageTrendChart(tokenUsageTrend: tokenUsageTrend),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              child: _TokenEfficiencyInsights(
                sessionMetrics: sessionMetrics,
                phaseComparison: phaseComparison,
              ),
            ),
          ] else ...[
            // Use Row layout on larger screens
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:
                      _TokenUsageTrendChart(tokenUsageTrend: tokenUsageTrend),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _TokenEfficiencyInsights(
                    sessionMetrics: sessionMetrics,
                    phaseComparison: phaseComparison,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: _PhaseTokenAnalysis(phaseComparison: phaseComparison),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            child: _CostAnalysisSection(
              costAnalysis: costAnalysis,
              isSmallScreen: isSmallScreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _TokenOverviewCards extends StatelessWidget {
  final SessionMetrics sessionMetrics;
  final bool isSmallScreen;

  const _TokenOverviewCards({
    required this.sessionMetrics,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = sessionMetrics.tokenEconomics;
    final performance = sessionMetrics.performanceMetrics;

    if (isSmallScreen) {
      // Stack vertically on small screens
      return Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.token, color: Colors.green, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Token Usage',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTokenStat('Total Tokens',
                      '${_formatNumber(tokens.totalTokensUsed)}', Colors.green),
                  _buildTokenStat('Avg/Message',
                      '${tokens.averageTokensPerMessage}', Colors.blue),
                  _buildTokenStat(
                      'Min/Max',
                      '${tokens.minTokensPerMessage}/${tokens.maxTokensPerMessage}',
                      Colors.purple),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed, color: Colors.orange, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Performance',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTokenStat(
                      'Tokens/Min', '${tokens.tokensPerMinute}', Colors.orange),
                  _buildTokenStat('Efficiency',
                      '${tokens.efficiency.toStringAsFixed(3)}/ms', Colors.red),
                  _buildTokenStat('Avg Response',
                      '${performance.averageResponseTimeMs}ms', Colors.blue),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      // Use Row layout on larger screens
      return Row(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.token, color: Colors.green, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Token Usage',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTokenStat(
                        'Total Tokens',
                        '${_formatNumber(tokens.totalTokensUsed)}',
                        Colors.green),
                    _buildTokenStat('Avg/Message',
                        '${tokens.averageTokensPerMessage}', Colors.blue),
                    _buildTokenStat(
                        'Min/Max',
                        '${tokens.minTokensPerMessage}/${tokens.maxTokensPerMessage}',
                        Colors.purple),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.speed, color: Colors.orange, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Performance',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTokenStat('Tokens/Min', '${tokens.tokensPerMinute}',
                        Colors.orange),
                    _buildTokenStat(
                        'Efficiency',
                        '${tokens.efficiency.toStringAsFixed(3)}/ms',
                        Colors.red),
                    _buildTokenStat('Avg Response',
                        '${performance.averageResponseTimeMs}ms', Colors.blue),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildTokenStat(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _TokenUsageTrendChart extends StatelessWidget {
  final List<TokenUsagePoint> tokenUsageTrend;

  const _TokenUsageTrendChart({required this.tokenUsageTrend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(51)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart,
                  size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Token Usage Trend',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (tokenUsageTrend.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.data_usage, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No token usage data available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: _TokenTrendChart(points: tokenUsageTrend),
            ),
        ],
      ),
    );
  }
}

class _TokenTrendChart extends StatelessWidget {
  final List<TokenUsagePoint> points;

  const _TokenTrendChart({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox();

    final maxTokens = points.map((p) => p.cumulativeTokens).reduce(max);
    final maxTimelineTokens = points.map((p) => p.timelineTokens).reduce(max);

    return CustomPaint(
      size: Size.infinite,
      painter: _TokenTrendPainter(points, maxTokens, maxTimelineTokens),
    );
  }
}

class _TokenTrendPainter extends CustomPainter {
  final List<TokenUsagePoint> points;
  final int maxTokens;
  final int maxTimelineTokens;

  _TokenTrendPainter(this.points, this.maxTokens, this.maxTimelineTokens);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    // Draw cumulative line
    paint.color = Colors.blue;
    final cumulativePath = Path();
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height -
          ((points[i].cumulativeTokens / maxTokens) * size.height);
      if (i == 0) {
        cumulativePath.moveTo(x, y);
      } else {
        cumulativePath.lineTo(x, y);
      }
    }
    canvas.drawPath(cumulativePath, paint);

    // Draw individual message bars
    fillPaint.color = Colors.green.withAlpha(128);
    final barWidth = size.width / points.length * 0.6;

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width - barWidth / 2;
      final barHeight =
          (points[i].timelineTokens / maxTimelineTokens) * size.height * 0.3;
      final y = size.height - barHeight;

      canvas.drawRect(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        fillPaint,
      );
    }

    // Draw data points
    fillPaint.color = Colors.blue;
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height -
          ((points[i].cumulativeTokens / maxTokens) * size.height);
      canvas.drawCircle(Offset(x, y), 3, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TokenEfficiencyInsights extends StatelessWidget {
  final SessionMetrics sessionMetrics;
  final List<PhasePerformanceComparison> phaseComparison;

  const _TokenEfficiencyInsights({
    required this.sessionMetrics,
    required this.phaseComparison,
  });

  @override
  Widget build(BuildContext context) {
    final insights = _generateEfficiencyInsights();

    return Container(
      constraints: const BoxConstraints(
          maxHeight: 200), // Match the height of the trend chart
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(51)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb,
                  size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Efficiency Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...insights.map((insight) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: _EfficiencyInsightItem(insight: insight),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<EfficiencyInsight> _generateEfficiencyInsights() {
    final insights = <EfficiencyInsight>[];
    final tokens = sessionMetrics.tokenEconomics;

    // Token efficiency
    if (tokens.efficiency > 1.0) {
      insights.add(EfficiencyInsight(
        icon: Icons.flash_on,
        title: 'High Token Throughput',
        description: '${tokens.efficiency.toStringAsFixed(2)} tokens/ms',
        color: Colors.green,
        isPositive: true,
      ));
    } else if (tokens.efficiency < 0.1) {
      insights.add(EfficiencyInsight(
        icon: Icons.hourglass_empty,
        title: 'Low Token Throughput',
        description: '${tokens.efficiency.toStringAsFixed(3)} tokens/ms',
        color: Colors.orange,
        isPositive: false,
      ));
    }

    // Token variance
    final tokenRange = tokens.maxTokensPerMessage - tokens.minTokensPerMessage;
    if (tokenRange > tokens.averageTokensPerMessage) {
      insights.add(EfficiencyInsight(
        icon: Icons.trending_up,
        title: 'High Token Variance',
        description:
            'Range: ${tokens.minTokensPerMessage}-${tokens.maxTokensPerMessage}',
        color: Colors.blue,
        isPositive: false,
      ));
    }

    // Phase efficiency
    final mostExpensivePhase =
        phaseComparison.isNotEmpty ? phaseComparison.first : null;

    if (mostExpensivePhase != null && mostExpensivePhase.totalTokenUsage > 0) {
      insights.add(EfficiencyInsight(
        icon: Icons.analytics,
        title: 'Top Token Consumer',
        description:
            '${mostExpensivePhase.phaseName}: ${mostExpensivePhase.totalTokenUsage}',
        color: Colors.purple,
        isPositive: false,
      ));
    }

    // Rate insights
    if (tokens.tokensPerMinute > 10000) {
      insights.add(EfficiencyInsight(
        icon: Icons.speed,
        title: 'High Usage Rate',
        description: '${tokens.tokensPerMinute} tokens/minute',
        color: Colors.red,
        isPositive: false,
      ));
    }

    if (insights.isEmpty) {
      insights.add(EfficiencyInsight(
        icon: Icons.check_circle,
        title: 'Optimal Usage',
        description: 'Token usage patterns look healthy',
        color: Colors.green,
        isPositive: true,
      ));
    }

    return insights;
  }
}

class _EfficiencyInsightItem extends StatelessWidget {
  final EfficiencyInsight insight;

  const _EfficiencyInsightItem({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: insight.color.withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Icon(
            insight.icon,
            size: 16,
            color: insight.color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                insight.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                insight.description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhaseTokenAnalysis extends StatelessWidget {
  final List<PhasePerformanceComparison> phaseComparison;

  const _PhaseTokenAnalysis({required this.phaseComparison});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pie_chart,
                size: 24, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Token Usage by Phase',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  Text(
                    'Detailed breakdown of token consumption across processing phases',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (phaseComparison.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.data_usage, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No phase token data available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: phaseComparison
                .map((phase) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PhaseTokenItem(
                        phase: phase,
                        maxValue: phaseComparison.isNotEmpty
                            ? phaseComparison.first.totalTokenUsage
                            : phase.totalTokenUsage,
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }
}

class _PhaseTokenItem extends StatelessWidget {
  final PhasePerformanceComparison phase;
  final int maxValue;

  const _PhaseTokenItem({required this.phase, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final phaseName = phase.phaseName
        .split('-')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.withAlpha(51)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  phaseName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(51),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withAlpha(77)),
                ),
                child: Text(
                  '${phase.totalTokenUsage} total',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _PhaseTokenBar(
                      value: phase.totalTokenUsage,
                      maxValue: maxValue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '${phase.averageTokenUsage} avg',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  InfoChip(
                    label: 'Executions',
                    value: '${phase.executionCount}',
                    color: Colors.blue,
                  ),
                  InfoChip(
                    label: 'Avg Duration',
                    value: '${phase.averageDurationMs}ms',
                    color: Colors.purple,
                  ),
                  if (phase.errorRate > 0)
                    InfoChip(
                      label: 'Error Rate',
                      value: '${(phase.errorRate * 100).toStringAsFixed(1)}%',
                      color: Colors.red,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhaseTokenBar extends StatelessWidget {
  final int value;
  final int maxValue;

  const _PhaseTokenBar({
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = maxValue > 0 ? value / maxValue : 0.0;

    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

class _CostAnalysisSection extends StatelessWidget {
  final CostAnalysis costAnalysis;
  final bool isSmallScreen;

  const _CostAnalysisSection({
    required this.costAnalysis,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(51)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money,
                  color: Theme.of(context).primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Cost Analysis',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withAlpha(51)),
                ),
                child: Text(
                  'Rate: \$${costAnalysis.costPerToken.toStringAsFixed(4)}/token',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isSmallScreen) ...[
            // Stack vertically on small screens
            Column(
              children: [
                Center(
                  child: _CostMetricCard(
                    title: 'Total Cost',
                    value: '\$${costAnalysis.totalCost.toStringAsFixed(4)}',
                    icon: Icons.monetization_on,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: _CostMetricCard(
                    title: 'Avg/Message',
                    value:
                        '\$${costAnalysis.averageCostPerMessage.toStringAsFixed(4)}',
                    icon: Icons.message,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: _CostMetricCard(
                    title: 'Total Tokens',
                    value: '${costAnalysis.totalTokens}',
                    icon: Icons.token,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ] else ...[
            // Use Row layout on larger screens
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _CostMetricCard(
                    title: 'Total Cost',
                    value: '\$${costAnalysis.totalCost.toStringAsFixed(4)}',
                    icon: Icons.monetization_on,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CostMetricCard(
                    title: 'Avg/Message',
                    value:
                        '\$${costAnalysis.averageCostPerMessage.toStringAsFixed(4)}',
                    icon: Icons.message,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CostMetricCard(
                    title: 'Total Tokens',
                    value: '${costAnalysis.totalTokens}',
                    icon: Icons.token,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
          if (costAnalysis.phaseCostBreakdown.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Cost Breakdown by Phase',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ...costAnalysis.phaseCostBreakdown
                .take(5)
                .map((phase) => _PhaseCostItem(phase: phase)),
          ],
        ],
      ),
    );
  }
}

class _CostMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _CostMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(
        minWidth: 100,
        maxWidth: 200,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PhaseCostItem extends StatelessWidget {
  final PhaseCostData phase;

  const _PhaseCostItem({required this.phase});

  @override
  Widget build(BuildContext context) {
    final phaseName = phase.phaseName
        .split('-')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              phaseName,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: phase.percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '\$${phase.totalCost.toStringAsFixed(4)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 40,
            child: Text(
              '${phase.percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class EfficiencyInsight {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isPositive;

  const EfficiencyInsight({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isPositive,
  });
}
