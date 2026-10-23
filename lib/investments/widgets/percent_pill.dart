import 'package:flutter/material.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';

/// Tinted pill with the return percentage (green / red).
class PercentPill extends StatelessWidget {
  const PercentPill({super.key, required this.percent, required this.color});

  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.smAll,
        ),
        child: Text(
          formatPercent(percent),
          style: AppTextStyles.amount.copyWith(color: color, fontSize: 12),
        ),
      );
}