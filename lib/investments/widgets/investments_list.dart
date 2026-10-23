import 'package:flutter/material.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/investments/widgets/percent_pill.dart';
import 'package:money_dashboard/model/investment.dart';

/// Left card: all investments. Tap to select. On hover (always visible on
/// phones) each row shows a drag handle (left) and a bin (right).
class InvestmentsList extends StatelessWidget {
  const InvestmentsList({
    super.key,
    required this.investments,
    required this.selectedId,
    required this.onSelect,
    required this.onDelete,
    required this.onReorder,
    this.shrinkWrap = false,
  });

  final List<Investment> investments;
  final String? selectedId;
  final ValueChanged<Investment> onSelect;
  final ValueChanged<Investment> onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;

  /// true = size to content (phone page that scrolls as a whole).
  final bool shrinkWrap;

  static const double _compactBreakpoint = 520;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final invested =
        investments.fold<int>(0, (s, e) => s + e.purchaseAmount);
    final value = investments.fold<int>(0, (s, e) => s + e.currentAmount);
    final pct = invested <= 0 ? 0.0 : (value - invested) / invested * 100;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < _compactBreakpoint;

          final Widget list = investments.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Center(
                    child: Text('No investments yet', style: context.caption),
                  ),
                )
              : ReorderableListView.builder(
                  shrinkWrap: shrinkWrap,
                  physics:
                      shrinkWrap ? const NeverScrollableScrollPhysics() : null,
                  buildDefaultDragHandles: false,
                  itemCount: investments.length,
                  onReorder: onReorder,
                  proxyDecorator: (child, _, _) => Material(
                    color: c.surface,
                    surfaceTintColor: Colors.transparent,
                    elevation: 4,
                    borderRadius: AppRadius.smAll,
                    child: child,
                  ),
                  itemBuilder: (_, i) {
                    final inv = investments[i];
                    return _InvestmentTile(
                      key: ValueKey(inv.id),
                      investment: inv,
                      index: i,
                      compact: compact,
                      selected: inv.id == selectedId,
                      showDivider: i != investments.length - 1,
                      onTap: () => onSelect(inv),
                      onDelete: () => onDelete(inv),
                    );
                  },
                );

          return Column(
            mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(invested: invested, value: value, percent: pct),
              const Divider(),
              if (!compact && investments.isNotEmpty) ...const [
                _ColumnHeader(),
                Divider(),
              ],
              if (shrinkWrap) list else Expanded(child: list),
            ],
          );
        },
      ),
    );
  }
}

// Fixed column widths (wide layout).
class _Cols {
  _Cols._();
  static const double handle = 40; // 36 icon area + 4 gap
  static const double bought = 84;
  static const double now = 90;
  static const double ret = 76;
  static const double bin = 48;
}

class _Header extends StatelessWidget {
  const _Header(
      {required this.invested, required this.value, required this.percent});

  final int invested;
  final int value;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = percent >= 0 ? c.income : c.expense;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md - 2,
      ),
      child: Row(
        children: [
          Text('Investments', style: context.h4),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatAmount(value), style: AppTextStyles.amount),
              Text(
                '${formatPercent(percent)} of ${formatAmount(invested)}',
                style: context.caption.copyWith(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader();

  @override
  Widget build(BuildContext context) {
    final style = context.label.copyWith(fontWeight: FontWeight.w600);
    return ColoredBox(
      color: context.colors.surfaceAlt,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm + 3, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
        child: Row(
          children: [
            const SizedBox(width: _Cols.handle),
            Expanded(child: Text('Name', style: style)),
            SizedBox(
                width: _Cols.bought,
                child: Text('Bought', textAlign: TextAlign.right, style: style)),
            SizedBox(
                width: _Cols.now,
                child: Text('Now', textAlign: TextAlign.right, style: style)),
            SizedBox(
                width: _Cols.ret,
                child: Text('Return', textAlign: TextAlign.right, style: style)),
            const SizedBox(width: _Cols.bin),
          ],
        ),
      ),
    );
  }
}

class _InvestmentTile extends StatefulWidget {
  const _InvestmentTile({
    super.key,
    required this.investment,
    required this.index,
    required this.compact,
    required this.selected,
    required this.showDivider,
    required this.onTap,
    required this.onDelete,
  });

  final Investment investment;
  final int index;
  final bool compact;
  final bool selected;
  final bool showDivider;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_InvestmentTile> createState() => _InvestmentTileState();
}

class _InvestmentTileState extends State<_InvestmentTile> {
  bool _hover = false;

  /// Phones have no hover, so the icons stay visible there.
  bool get _touch {
    final p = Theme.of(context).platform;
    return p == TargetPlatform.android || p == TargetPlatform.iOS;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final inv = widget.investment;
    final show = _hover || _touch;
    final selected = widget.selected;
    final accent = inv.isPositive ? c.income : c.expense;

    final handle = IgnorePointer(
      ignoring: !show,
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: const Duration(milliseconds: 120),
        child: ReorderableDragStartListener(
          index: widget.index,
          child: MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Icon(Icons.drag_indicator, size: 20, color: c.textDisabled),
            ),
          ),
        ),
      ),
    );

    final bin = IgnorePointer(
      ignoring: !show,
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: const Duration(milliseconds: 120),
        child: IconButton(
          tooltip: 'Delete investment',
          icon: const Icon(Icons.delete_outline),
          onPressed: widget.onDelete,
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.hovered)
                    ? c.expense
                    : c.textSecondary),
          ),
        ),
      ),
    );

    final nameBlock = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            inv.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.standard.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
          Text(formatDate(inv.purchaseDate), style: context.caption),
        ],
      ),
    );

    final nowStyle = AppTextStyles.amount
        .copyWith(color: selected ? c.primary : c.text);

    final row = widget.compact
        ? Row(
            children: [
              handle,
              const SizedBox(width: AppSpacing.xs),
              nameBlock,
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatAmount(inv.currentAmount), style: nowStyle),
                  const SizedBox(height: 2),
                  PercentPill(percent: inv.returnPercent, color: accent),
                ],
              ),
              bin,
            ],
          )
        : Row(
            children: [
              handle,
              const SizedBox(width: AppSpacing.xs),
              nameBlock,
              SizedBox(
                width: _Cols.bought,
                child: Text(
                  formatAmount(inv.purchaseAmount),
                  textAlign: TextAlign.right,
                  style: context.standard.copyWith(color: c.textSecondary),
                ),
              ),
              SizedBox(
                width: _Cols.now,
                child: Text(formatAmount(inv.currentAmount),
                    textAlign: TextAlign.right, style: nowStyle),
              ),
              SizedBox(
                width: _Cols.ret,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: PercentPill(percent: inv.returnPercent, color: accent),
                ),
              ),
              bin,
            ],
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: selected ? c.primaryLight : Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: selected ? c.primary : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: row,
              ),
            ),
          ),
          if (widget.showDivider) const Divider(),
        ],
      ),
    );
  }
}