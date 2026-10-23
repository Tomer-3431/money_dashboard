import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/entries/widgets/entry_quick_form.dart';
import 'package:money_dashboard/home/widgets/transaction_details_dialog.dart';
import 'package:money_dashboard/home/widgets/type_dot.dart';
import 'package:money_dashboard/model/entry_type.dart';
import 'package:money_dashboard/model/ledger_entry.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

enum _SortColumn { name, description, location, date, amount }

/// Full-screen table of one month of either income or spend.
///
/// [isIncome] decides which one. [entries] may contain both kinds; only the
/// matching ones are shown. Navigate to it however you like, e.g.:
///   EntriesTableScreen(isIncome: true, entries: kMockEntries)
class EntriesTableScreen extends StatefulWidget {
  const EntriesTableScreen({
    super.key,
    required this.isIncome,
    required this.entries,
  });

  final bool isIncome;
  final List<LedgerEntry> entries;

  @override
  State<EntriesTableScreen> createState() => _EntriesTableScreenState();
}

class _EntriesTableScreenState extends State<EntriesTableScreen> {
  /// Below this width the table scrolls horizontally instead of squeezing.
  static const double _minTableWidth = 900;

  late final List<LedgerEntry> _all = widget.entries
      .where((e) => e.isIncome == widget.isIncome)
      .toList();

  late DateTime _month;
  _SortColumn _sortColumn = _SortColumn.date;
  bool _ascending = false;
  final Set<int> _typeFilter = {}; // empty = show every type

  final _hScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    _hScroll.dispose();
    super.dispose();
  }

  bool get _canGoNext {
    final now = DateTime.now();
    return _month.isBefore(DateTime(now.year, now.month));
  }

  void _shiftMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  void _changeMonth(DateTime month) => setState(() => _month = month);

  void _sortBy(_SortColumn column) => setState(() {
    if (_sortColumn == column) {
      _ascending = !_ascending;
    } else {
      _sortColumn = column;
      _ascending = true;
    }
  });

  void _toggleType(int type) => setState(() {
    if (!_typeFilter.remove(type)) _typeFilter.add(type);
  });

  void _addEntry({
    required String name,
    required String description,
    required String location,
    required int type,
    required int amount,
    required DateTime dateTime,
  }) {
    // GUI only for now: replace with a Firestore write later.
    setState(() {
      _all.add(
        LedgerEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          isIncome: widget.isIncome,
          name: name,
          description: description,
          location: location,
          type: type,
          amount: amount,
          dateTime: dateTime,
          reportDate: DateTime.now(),
        ),
      );
      // Jump to the month of the new entry so it is visible right away.
      _month = DateTime(dateTime.year, dateTime.month);
    });
  }

  int _compare(LedgerEntry a, LedgerEntry b) {
    int result;
    switch (_sortColumn) {
      case _SortColumn.name:
        result = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case _SortColumn.description:
        result = a.description.toLowerCase().compareTo(
          b.description.toLowerCase(),
        );
      case _SortColumn.location:
        result = a.location.toLowerCase().compareTo(b.location.toLowerCase());
      case _SortColumn.date:
        result = a.dateTime.compareTo(b.dateTime);
      case _SortColumn.amount:
        result = a.amount.compareTo(b.amount);
    }
    return _ascending ? result : -result;
  }

  List<LedgerEntry> get _visible =>
      _all
          .where(
            (e) =>
                e.dateTime.year == _month.year &&
                e.dateTime.month == _month.month &&
                (_typeFilter.isEmpty || _typeFilter.contains(e.type)),
          )
          .toList()
        ..sort(_compare);

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final total = visible.fold<int>(0, (s, e) => s + e.amount);

    return Scaffold(
      appBar: AppBar(title: Text(widget.isIncome ? 'Income' : 'Spend')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pad = constraints.maxWidth >= 600
                ? AppSpacing.lg
                : AppSpacing.md;
            return Padding(
              padding: EdgeInsets.all(pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildTableCard(visible, total)),
                  SizedBox(height: pad),
                  // Keep the form from eating the whole screen on phones.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.55,
                    ),
                    child: SingleChildScrollView(
                      child: EntryQuickForm(
                        isIncome: widget.isIncome,
                        onAdd: _addEntry,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Table card: month header + scrollable table
  // -------------------------------------------------------------------------
  Widget _buildTableCard(List<LedgerEntry> visible, int total) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MonthHeader(
          month: _month,
          canGoNext: _canGoNext,
          onPrevious: () => _shiftMonth(-1),
          onNext: () => _shiftMonth(1),
          onSelect: (m) => _changeMonth(m),
          isIncome: widget.isIncome,
          total: total,
          count: visible.length,
        ),
        const Divider(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = constraints.maxWidth < _minTableWidth
                  ? _minTableWidth
                  : constraints.maxWidth;
              return ScrollConfiguration(
                // Let a mouse drag the table too (Windows).
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(dragDevices: PointerDeviceKind.values.toSet()),
                child: Scrollbar(
                  controller: _hScroll,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _hScroll,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: tableWidth,
                      height: constraints.maxHeight,
                      child: Column(
                        children: [
                          _buildColumnHeader(),
                          const Divider(),
                          Expanded(
                            child: visible.isEmpty
                                ? Center(
                                    child: Text(
                                      _typeFilter.isEmpty
                                          ? 'No transactions this month'
                                          : 'No transactions match the filter',
                                      style: context.caption,
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: visible.length,
                                    separatorBuilder: (_, _) => const Divider(),
                                    itemBuilder: (_, i) =>
                                        _EntryRow(entry: visible[i]),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );

  Widget _buildColumnHeader() {
    Widget sortable(String label, _SortColumn col, {bool right = false}) =>
        _SortHeader(
          label: label,
          active: _sortColumn == col,
          ascending: _ascending,
          alignRight: right,
          onTap: () => _sortBy(col),
        );

    return ColoredBox(
      color: context.colors.surfaceAlt,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              flex: _Cols.nameFlex,
              child: sortable('Name', _SortColumn.name),
            ),
            Expanded(
              flex: _Cols.descriptionFlex,
              child: sortable('Description', _SortColumn.description),
            ),
            Expanded(
              flex: _Cols.locationFlex,
              child: sortable('Location', _SortColumn.location),
            ),
            SizedBox(
              width: _Cols.type,
              child: _TypeFilterHeader(
                isIncome: widget.isIncome,
                selected: _typeFilter,
                onToggle: _toggleType,
                onClear: () => setState(_typeFilter.clear),
              ),
            ),
            SizedBox(
              width: _Cols.date,
              child: sortable('Date', _SortColumn.date),
            ),
            SizedBox(
              width: _Cols.amount,
              child: sortable('Amount', _SortColumn.amount, right: true),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Columns
// ---------------------------------------------------------------------------
class _Cols {
  _Cols._();
  static const int nameFlex = 3;
  static const int descriptionFlex = 3;
  static const int locationFlex = 2;
  static const double type = 100;
  static const double date = 150;
  static const double amount = 120;
}

// ---------------------------------------------------------------------------
// Month header: arrows + month + total
// ---------------------------------------------------------------------------
class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
    required this.onSelect,
    required this.isIncome,
    required this.total,
    required this.count,
  });

  final DateTime month;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final void Function(DateTime month) onSelect;
  final bool isIncome;
  final int total;
  final int count;

  void _selectMonth(BuildContext context) async {
    final date = await showMonthPicker(
      context: context,
      initialDate: month,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null) return;

    onSelect(date);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = isIncome ? c.income : c.expense;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: AppSpacing.xs,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Previous month',
                icon: const Icon(Icons.chevron_left),
                onPressed: onPrevious,
              ),
              SizedBox(
                width: 150,
                child: IconButton(
                  onPressed: () {
                    _selectMonth(context);
                  },
                  icon: Text(
                    formatMonth(month),
                    textAlign: TextAlign.center,
                    style: context.h4,
                  ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isIncome ? 'Income' : 'Spent', style: context.caption),
                    Text(
                      formatSigned(total, isIncome: isIncome),
                      style: AppTextStyles.amount.copyWith(color: color),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.lg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Entries', style: context.caption),
                    Text('$count', style: AppTextStyles.amount),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header cells
// ---------------------------------------------------------------------------
class _SortHeader extends StatelessWidget {
  const _SortHeader({
    required this.label,
    required this.active,
    required this.ascending,
    required this.onTap,
    this.alignRight = false,
  });

  final String label;
  final bool active;
  final bool ascending;
  final bool alignRight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final style = context.label.copyWith(
      fontWeight: FontWeight.w600,
      color: active ? c.primary : c.textSecondary,
    );
    final icon = Icon(
      active
          ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
          : Icons.unfold_more,
      size: 14,
      color: active ? c.primary : c.textDisabled,
    );

    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm + 2,
            horizontal: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: style),
              const SizedBox(width: 2),
              icon,
            ],
          ),
        ),
      ),
    );
  }
}

/// "Type" header: not sortable, has a filter menu instead.
class _TypeFilterHeader extends StatelessWidget {
  const _TypeFilterHeader({
    required this.isIncome,
    required this.selected,
    required this.onToggle,
    required this.onClear,
  });

  final bool isIncome;
  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final active = selected.isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Type',
          style: context.label.copyWith(
            fontWeight: FontWeight.w600,
            color: active ? c.primary : c.textSecondary,
          ),
        ),
        MenuAnchor(
          menuChildren: [
            for (var i = 0; i < kTypeCount; i++)
              CheckboxMenuButton(
                closeOnActivate: false, // pick several without reopening
                value: selected.contains(i),
                onChanged: (_) => onToggle(i),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TypeDot(type: i, isIncome: isIncome, size: 12),
                    const SizedBox(width: AppSpacing.sm),
                    Text(typeName(type: i, isIncome: isIncome)),
                  ],
                ),
              ),
            const Divider(height: AppSpacing.sm),
            MenuItemButton(
              onPressed: active ? onClear : null,
              leadingIcon: const Icon(Icons.filter_alt_off_outlined, size: 18),
              closeOnActivate: false,
              child: const Text('Clear filter'),
            ),
          ],
          builder: (context, controller, _) => IconButton(
            tooltip: 'Filter by type',
            iconSize: 18,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            icon: Icon(
              active ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: active ? c.primary : c.textDisabled,
            ),
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Row
// ---------------------------------------------------------------------------
class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final amountColor = entry.isIncome ? c.income : c.expense;
    final secondary = context.standard.copyWith(color: c.textSecondary);

    return InkWell(
      onTap: () => showTransactionDetails(context, entry),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        child: Row(
          children: [
            Expanded(
              flex: _Cols.nameFlex,
              child: Text(
                entry.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.standard.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              flex: _Cols.descriptionFlex,
              child: Text(
                entry.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: secondary,
              ),
            ),
            Expanded(
              flex: _Cols.locationFlex,
              child: Text(
                entry.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: secondary,
              ),
            ),
            SizedBox(
              width: _Cols.type,
              child: Center(
                child: TypeDot(type: entry.type, isIncome: entry.isIncome),
              ),
            ),
            SizedBox(
              width: _Cols.date,
              child: Text(formatDateTime(entry.dateTime), style: secondary),
            ),
            SizedBox(
              width: _Cols.amount,
              child: Text(
                formatSigned(entry.amount, isIncome: entry.isIncome),
                textAlign: TextAlign.right,
                style: AppTextStyles.amount.copyWith(color: amountColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
