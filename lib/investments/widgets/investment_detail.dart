import 'package:flutter/material.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/investments/widgets/investment_chart.dart';
import 'package:money_dashboard/investments/widgets/percent_pill.dart';
import 'package:money_dashboard/model/investment.dart';

/// Right side: summary, value chart (upper half), stats and news.
class InvestmentDetail extends StatelessWidget {
  const InvestmentDetail({
    super.key,
    required this.investment,
    required this.chartHeight,
  });

  final Investment? investment;
  final double chartHeight;

  static String _heldFor(DateTime since) {
    final days = DateTime.now().difference(since).inDays;
    if (days < 60) return '$days days';
    if (days < 730) return '${days ~/ 30} months';
    return '${(days / 365).toStringAsFixed(1)} years';
  }

  @override
  Widget build(BuildContext context) {
    final inv = investment;
    final c = context.colors;

    if (inv == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('No investment selected', style: context.h4),
                const SizedBox(height: AppSpacing.xs),
                Text('Add an investment to start tracking it',
                    style: context.caption),
              ],
            ),
          ),
        ),
      );
    }

    final accent = inv.isPositive ? c.income : c.expense;
    final values = inv.history.map((p) => p.value);
    final hasHistory = inv.history.isNotEmpty;
    final highest = hasHistory ? values.reduce((a, b) => a > b ? a : b) : null;
    final lowest = hasHistory ? values.reduce((a, b) => a < b ? a : b) : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inv.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.h3),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Bought ${formatDate(inv.purchaseDate)} for ${formatAmount(inv.purchaseAmount)}',
                        style: context.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatAmount(inv.currentAmount),
                        style: AppTextStyles.amountLarge
                            .copyWith(color: c.text, fontSize: 30)),
                    const SizedBox(height: AppSpacing.xs),
                    PercentPill(percent: inv.returnPercent, color: accent),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Chart
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart, size: 18, color: c.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Value over time',
                        style: context.label.copyWith(
                            color: c.primary, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('Dashed line = purchase amount',
                        style: context.caption),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: chartHeight,
                  child: InvestmentChart(
                    key: ValueKey(inv.id),
                    points: inv.history,
                    color: accent,
                    baseline: inv.purchaseAmount.toDouble(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Stats
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.md,
              children: [
                _Stat(
                  label: inv.isPositive ? 'Profit' : 'Loss',
                  value: formatSigned(inv.profit.abs(),
                      isIncome: inv.isPositive),
                  color: accent,
                ),
                _Stat(label: 'Invested', value: formatAmount(inv.purchaseAmount)),
                _Stat(label: 'Held for', value: _heldFor(inv.purchaseDate)),
                _Stat(
                    label: 'Highest',
                    value: highest == null ? '-' : formatAmount(highest.round())),
                _Stat(
                    label: 'Lowest',
                    value: lowest == null ? '-' : formatAmount(lowest.round())),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // News
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.newspaper_outlined, size: 18, color: c.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('News',
                        style: context.label.copyWith(
                            color: c.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  inv.news.isEmpty ? 'No news yet for this investment.' : inv.news,
                  style: inv.news.isEmpty
                      ? context.caption
                      : context.standard,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: context.caption),
          const SizedBox(height: 2),
          Text(value,
              style: AppTextStyles.amount
                  .copyWith(color: color ?? context.colors.text)),
        ],
      );
}