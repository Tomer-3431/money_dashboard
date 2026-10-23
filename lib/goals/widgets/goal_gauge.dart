import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/model/goal.dart';

/// Top card: a 180° progress arc (left → right) for the selected goal.
/// Progress = current balance / goal amount, capped at 100%.
class GoalGauge extends StatelessWidget {
  const GoalGauge({super.key, required this.goal, required this.balance});

  final Goal? goal;
  final int balance;

  static const double _maxGaugeWidth = 360;

  double get _progress {
    final g = goal;
    if (g == null || g.amount <= 0) return 0;
    return (balance / g.amount).clamp(0.0, 1.0).toDouble();
  }

  Color _getProgressColor(double value, AppColors c) {
    if (value == 1) return c.success;
    if (value <= 0.3) return c.error;
    if (value <= 0.5) return c.warning;
    return c.primary;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final g = goal;
    final reached = g != null && g.amount > 0 && balance >= g.amount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.flag_outlined, size: 18, color: c.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Goal progress',
                    style: context.label.copyWith(
                      color: c.primary,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = math.min(constraints.maxWidth, _maxGaugeWidth);
                  final stroke = (width * 0.075).clamp(14.0, 30.0).toDouble();
                  final height = width / 2 + stroke / 2;

                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(end: _progress),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      final done = value >= 1;
                      // Two decimals; never show 100.00% before it is reached.
                      final percent = done
                          ? 100.0
                          : math.min(99.99, (value * 10000).round() / 100);
                      final percentText = percent.toStringAsFixed(2);
                      return Semantics(
                        label: 'Goal progress $percentText percent',
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: Stack(
                            children: [
                              CustomPaint(
                                size: Size(width, height),
                                painter: _GaugePainter(
                                  progress: value,
                                  trackColor: c.border,
                                  progressColor: _getProgressColor(value, c),
                                  strokeWidth: stroke,
                                ),
                              ),
                              Positioned(
                                left: stroke * 1.5,
                                right: stroke * 1.5,
                                bottom: stroke / 2,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$percentText%',
                                    style: AppTextStyles.amountLarge.copyWith(
                                      color: c.text,
                                      fontSize: width * 0.13,
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
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (g == null) ...[
              Text('No goal selected',
                  textAlign: TextAlign.center, style: context.h4),
              const SizedBox(height: AppSpacing.xs),
              Text('Add a goal below to start tracking it',
                  textAlign: TextAlign.center, style: context.caption),
            ] else ...[
              Text(g.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.h4),
              const SizedBox(height: AppSpacing.xs),
              Text('${formatAmount(balance)} of ${formatAmount(g.amount)}',
                  textAlign: TextAlign.center, style: context.caption),
              Text(
                reached
                    ? 'Goal reached'
                    : '${formatAmount(g.amount - balance)} to go',
                textAlign: TextAlign.center,
                style: context.caption.copyWith(
                  color: reached ? c.success : c.textSecondary,
                  fontWeight: reached ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress; // 0..1
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  Paint _paint(Color color) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    // The arc's flat edge sits half a stroke above the bottom so the round
    // caps are not clipped.
    final center = Offset(size.width / 2, size.height - strokeWidth / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Angle π = 9 o'clock; sweeping clockwise goes over the top to 3 o'clock.
    canvas.drawArc(rect, math.pi, math.pi, false, _paint(trackColor));
    if (progress > 0) {
      canvas.drawArc(
          rect, math.pi, math.pi * progress, false, _paint(progressColor));
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress ||
      old.trackColor != trackColor ||
      old.progressColor != progressColor ||
      old.strokeWidth != strokeWidth;
}
