import 'package:flutter/material.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';

/// Top-left card: the money currently in the bank.
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key, required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Card(
      color: c.primaryLight,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          ],
        ),
      ),
    );
  }
}
