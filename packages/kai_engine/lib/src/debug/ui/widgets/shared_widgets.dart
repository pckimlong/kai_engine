import 'package:flutter/material.dart';

/// Small informational chip widget for displaying debug data
class InfoChip extends StatelessWidget {
  final String label;
  final String? value;
  final Color? color;
  final IconData? icon;

  const InfoChip({
    super.key,
    required this.label,
    this.value,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Colors.blue;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: chipColor),
            const SizedBox(width: 4),
          ],
          Text(
            value != null ? '$label: $value' : label,
            style: TextStyle(
              fontSize: 11,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to get phase colors
Color getPhaseColor(String phaseName) {
  switch (phaseName.toLowerCase()) {
    case 'query-processing':
      return Colors.blue;
    case 'context-building':
      return Colors.orange;
    case 'ai-generation':
      return Colors.green;
    case 'post-response-processing':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}