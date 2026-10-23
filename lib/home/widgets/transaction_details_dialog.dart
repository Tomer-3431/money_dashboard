import 'package:flutter/material.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/home/widgets/type_dot.dart';
import 'package:money_dashboard/model/entry_type.dart';
import 'package:money_dashboard/model/ledger_entry.dart';

Future<void> showTransactionDetails(BuildContext context, LedgerEntry entry) =>
    showDialog<void>(
      context: context,
      builder: (_) => TransactionDetailsDialog(entry: entry),
    );

/// Pop-up with every field of a spend / income.
class TransactionDetailsDialog extends StatelessWidget {
  const TransactionDetailsDialog({super.key, required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = entry.isIncome ? c.income : c.expense;

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(entry.name, style: context.h3),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: AppRadius.smAll,
                ),
                child: Text(
                  entry.isIncome ? 'Income' : 'Spend',
                  style: context.label.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              _DetailRow(
                label: 'Description',
                child: Text(
                  entry.description.isEmpty ? '-' : entry.description,
                  style: context.standard,
                ),
              ),
              _DetailRow(
                label: 'Location',
                child: Text(
                  entry.location.isEmpty ? '-' : entry.location,
                  style: context.standard,
                ),
              ),
              _DetailRow(
                label: 'Type',
                child: Row(
                  children: [
                    TypeDot(type: entry.type, isIncome: entry.isIncome),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      typeName(type: entry.type, isIncome: entry.isIncome),
                      style: context.standard,
                    ),
                  ],
                ),
              ),
              _DetailRow(
                label: 'Amount',
                child: Text(
                  formatSigned(entry.amount, isIncome: entry.isIncome),
                  style: AppTextStyles.amount.copyWith(color: accent),
                ),
              ),
              _DetailRow(
                label: 'Date and time',
                child: Text(formatDateTime(entry.dateTime),
                    style: context.standard),
              ),
              _DetailRow(
                label: 'Reported on',
                child: Text(formatDateTime(entry.reportDate),
                    style: context.standard),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 112, child: Text(label, style: context.label)),
            Expanded(child: child),
          ],
        ),
      );
}
