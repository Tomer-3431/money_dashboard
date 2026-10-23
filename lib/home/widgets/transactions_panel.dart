import 'package:flutter/material.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/home/widgets/transaction_details_dialog.dart';
import 'package:money_dashboard/home/widgets/type_dot.dart';
import 'package:money_dashboard/model/ledger_entry.dart';

/// Left-side list: one month of income (green) and spend (red), newest first.
/// The arrows move between months. Tapping a row opens its details.
class TransactionsPanel extends StatefulWidget {
  const TransactionsPanel({super.key, required this.entries});

  final List<LedgerEntry> entries;

  @override
  State<TransactionsPanel> createState() => _TransactionsPanelState();
}

class _TransactionsPanelState extends State<TransactionsPanel> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  void _shiftMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  List<LedgerEntry> get _visible => widget.entries
      .where((e) =>
          e.dateTime.year == _month.year && e.dateTime.month == _month.month)
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final incomeTotal =
        visible.where((e) => e.isIncome).fold<int>(0, (s, e) => s + e.amount);
    final spendTotal =
        visible.where((e) => !e.isIncome).fold<int>(0, (s, e) => s + e.amount);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          return Column(
            children: [
              _Header(
                month: _month,
                canGoNext: !_isCurrentMonth,
                onPrevious: () => _shiftMonth(-1),
                onNext: () => _shiftMonth(1),
                incomeTotal: incomeTotal,
                spendTotal: spendTotal,
              ),
              const Divider(),
              if (!compact) ...const [_ColumnHeader(), Divider()],
              Expanded(
                child: visible.isEmpty
                    ? Center(
                        child: Text('No transactions this month',
                            style: context.caption),
                      )
                    : ListView.separated(
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (_, i) =>
                            _EntryRow(entry: visible[i], compact: compact),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: month arrows + month totals
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header({
    required this.month,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.incomeTotal,
    required this.spendTotal,
  });

  final DateTime month;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final int incomeTotal;
  final int spendTotal;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        runSpacing: AppSpacing.xs,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Previous month',
                icon: const Icon(Icons.chevron_left),
                onPressed: onPrevious,
              ),
              SizedBox(
                width: 150,
                child: Text(
                  formatMonth(month),
                  textAlign: TextAlign.center,
                  style: context.h4,
                ),
              ),
              IconButton(
                tooltip: 'Next month',
                icon: const Icon(Icons.chevron_right),
                onPressed: canGoNext ? onNext : null,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Total(
                  label: 'Income',
                  value: formatSigned(incomeTotal, isIncome: true),
                  color: c.income,
                ),
                const SizedBox(width: AppSpacing.lg),
                _Total(
                  label: 'Spent',
                  value: formatSigned(spendTotal, isIncome: false),
                  color: c.expense,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.caption),
          Text(value, style: AppTextStyles.amount.copyWith(color: color)),
        ],
      );
}

// ---------------------------------------------------------------------------
// Columns (wide layout)
// ---------------------------------------------------------------------------
class _Cols {
  _Cols._();
  static const int nameFlex = 3;
  static const int locationFlex = 2;
  static const double type = 56;
  static const double date = 150;
  static const double amount = 110;
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader();

  @override
  Widget build(BuildContext context) {
    final style = context.label.copyWith(fontWeight: FontWeight.w600);
    return ColoredBox(
      color: context.colors.surfaceAlt,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(flex: _Cols.nameFlex, child: Text('Name', style: style)),
            Expanded(
                flex: _Cols.locationFlex,
                child: Text('Location', style: style)),
            SizedBox(
              width: _Cols.type,
              child: Text('Type', textAlign: TextAlign.center, style: style),
            ),
            SizedBox(width: _Cols.date, child: Text('Date', style: style)),
            SizedBox(
              width: _Cols.amount,
              child: Text('Amount', textAlign: TextAlign.right, style: style),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Row
// ---------------------------------------------------------------------------
class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.compact});

  final LedgerEntry entry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final amountColor = entry.isIncome ? c.income : c.expense;
    final amountText = formatSigned(entry.amount, isIncome: entry.isIncome);
    final amountStyle = AppTextStyles.amount.copyWith(color: amountColor);
    final nameStyle = context.standard.copyWith(fontWeight: FontWeight.w600);

    return InkWell(
      onTap: () => showTransactionDetails(context, entry),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: compact ? 12 : 14,
        ),
        child: compact
            ? Row(
                children: [
                  TypeDot(type: entry.type, isIncome: entry.isIncome, size: 12),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: nameStyle),
                        if (entry.location.isNotEmpty)
                          Text(entry.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.caption),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(amountText, style: amountStyle),
                      Text(formatShortDateTime(entry.dateTime),
                          style: context.caption),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    flex: _Cols.nameFlex,
                    child: Text(entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: nameStyle),
                  ),
                  Expanded(
                    flex: _Cols.locationFlex,
                    child: Text(entry.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.standard
                            .copyWith(color: c.textSecondary)),
                  ),
                  SizedBox(
                    width: _Cols.type,
                    child: Center(
                      child: TypeDot(type: entry.type, isIncome: entry.isIncome),
                    ),
                  ),
                  SizedBox(
                    width: _Cols.date,
                    child: Text(formatDateTime(entry.dateTime),
                        style: context.standard
                            .copyWith(color: c.textSecondary)),
                  ),
                  SizedBox(
                    width: _Cols.amount,
                    child: Text(amountText,
                        textAlign: TextAlign.right, style: amountStyle),
                  ),
                ],
              ),
      ),
    );
  }
}
