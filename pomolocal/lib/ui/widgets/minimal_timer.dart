import 'package:flutter/material.dart';

/// Minimal görünüm — sadece büyük yazı
class MinimalTimer extends StatelessWidget {
  final double progress;
  final String timeText;
  final String label;
  final Color color;

  const MinimalTimer({
    super.key,
    required this.progress,
    required this.timeText,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: color,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          timeText,
          style: TextStyle(
            fontSize: 112,
            fontWeight: FontWeight.w100,
            color: theme.colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
            height: 1,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }
}
