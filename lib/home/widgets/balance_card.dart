import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/model/goal.dart';

/// Top-left card. The current bank balance is the hero; the top goal's
/// progress and the investments total sit underneath as quieter stats.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.topGoal,
    required this.investmentsTotal,
  });

  final int balance;

  /// The first goal in the goals list (null when there are no goals).
  final Goal? topGoal;

  /// Sum of the current value of every investment.
  final int investmentsTotal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final divider = c.primary.withValues(alpha: 0.18);

    return Card(
      color: c.primaryLight,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero: current balance
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    size: 18, color: c.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('Current balance',
                    style: context.label.copyWith(
                      color: c.primary,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formatAmount(balance),
                style: AppTextStyles.amountLarge.copyWith(
                  color: c.text,
                  fontSize: 44,
                ),
              ),
            ),

            // Secondary stats
            Divider(height: AppSpacing.lg * 2, color: divider),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _GoalStat(goal: topGoal, balance: balance),
                ),
                Container(
                  width: 1,
                  height: 56,
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  color: divider,
                ),
                Expanded(
                  child: _InvestmentsStat(total: investmentsTotal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared look of the small stat titles (icon + caption).
class _StatTitle extends StatelessWidget {
  const _StatTitle({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Icon(icon, size: 16, color: c.textSecondary),
        const SizedBox(width: AppSpacing.xs + 2),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.caption,
          ),
        ),
      ],
    );
  }
}

TextStyle _statValueStyle(BuildContext context, {Color? color}) =>
    AppTextStyles.amount.copyWith(
      color: color ?? context.colors.text,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    );

// ---------------------------------------------------------------------------
// Top goal: percentage + thin progress bar (same math as the goal gauge)
// ---------------------------------------------------------------------------
class _GoalStat extends StatelessWidget {
  const _GoalStat({required this.goal, required this.balance});

  final Goal? goal;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final g = goal;

    if (g == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StatTitle(icon: Icons.flag_outlined, text: 'Top goal'),
          const SizedBox(height: AppSpacing.xs),
          Text('No goal yet', style: _statValueStyle(context, color: c.textSecondary)),
        ],
      );
    }

    final progress = g.amount <= 0
        ? 0.0
        : (balance / g.amount).clamp(0.0, 1.0).toDouble();
    final reached = progress >= 1;
    // Two decimals; never show 100% before the goal is actually reached.
    final percent =
        reached ? 100.0 : math.min(99.99, (progress * 10000).round() / 100);
    final percentText = reached ? '100%' : '${percent.toStringAsFixed(2)}%';
    final barColor = reached ? c.success : c.primary;

    return Semantics(
      label: '${g.name} progress $percentText',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatTitle(icon: Icons.flag_outlined, text: g.name),
          const SizedBox(height: AppSpacing.xs),
          Text(percentText,
              style: _statValueStyle(context,
                  color: reached ? c.success : c.text)),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              color: barColor,
              backgroundColor: c.primary.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Investments: current value of everything invested
// ---------------------------------------------------------------------------
class _InvestmentsStat extends StatelessWidget {
  const _InvestmentsStat({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StatTitle(icon: Icons.show_chart, text: 'Investments'),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(formatAmount(total), style: _statValueStyle(context)),
          ),
        ],
      );
}