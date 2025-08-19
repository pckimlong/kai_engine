import 'package:flutter/material.dart';



class InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const InfoChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color.withAlpha((255 * 0.2).round()),
        child: Text(
          label[0],
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      label: Text('$label: $value'),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class ExpandableSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final bool initiallyExpanded;

  const ExpandableSectionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          )
        ],
      ),
    );
  }
}

Color getPhaseColor(String phaseName) {
  final lowerName = phaseName.toLowerCase();

  switch (lowerName) {
    case 'query-processing':
      return Colors.blue;
    case 'context-building':
    case 'context-engine-processing':
      return Colors.orange;
    case 'ai-generation':
      return Colors.green;
    case 'post-response-processing':
      return Colors.red;
    default:
      // Context builder specific colors
      if (lowerName.startsWith('parallel-') || lowerName.startsWith('par-')) {
        return Colors.teal;
      }
      if (lowerName.startsWith('sequential-') || lowerName.startsWith('seq-')) {
        return Colors.indigo;
      }
      // Post-response engine specific colors
      if (lowerName.startsWith('post-response-')) {
        return Colors.pink;
      }
      return Colors.purple;
  }
}
