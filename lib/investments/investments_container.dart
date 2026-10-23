import 'package:flutter/material.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/investments/mock_investments.dart';
import 'package:money_dashboard/investments/widgets/investment_detail.dart';
import 'package:money_dashboard/investments/widgets/investment_form.dart';
import 'package:money_dashboard/investments/widgets/investments_list.dart';
import 'package:money_dashboard/model/investment.dart';
import 'package:money_dashboard/widgets/sidebar.dart';

class InvestmentsContainer extends StatefulWidget {
  const InvestmentsContainer({super.key});

  @override
  State<InvestmentsContainer> createState() => InvestmentsContainerState();
}

class InvestmentsContainerState extends State<InvestmentsContainer> {
  /// Two-column layout from this width up; stacked page below it.
  static const double _wideBreakpoint = 1100;

  /// Fixed width of the left column (list + form) in the wide layout.
  static const double _leftWidth = 540;

  late final List<Investment> _items = List.of(kMockInvestments);
  final _scroll = ScrollController(); // used by the phone layout only

  /// The first investment is selected by default.
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = _items.isEmpty ? null : _items.first.id;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Investment? get _selected {
    if (_items.isEmpty) return null;
    return _items.firstWhere(
      (i) => i.id == _selectedId,
      orElse: () => _items.first,
    );
  }

  void _select(Investment inv) {
    setState(() => _selectedId = inv.id);
    // Phone: jump back up to the chart of the chosen investment.
    if (_scroll.hasClients) {
      _scroll.animateTo(0,
          duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _add(String name, int amount, DateTime date) => setState(() {
        final id = DateTime.now().microsecondsSinceEpoch.toString();
        // GUI only: current value = purchase amount until real prices exist.
        _items.add(Investment(
          id: id,
          name: name,
          purchaseAmount: amount,
          purchaseDate: date,
          currentAmount: amount,
        ));
        _selectedId = id;
      });

  void _reorder(int oldIndex, int newIndex) => setState(() {
        if (newIndex > oldIndex) newIndex -= 1;
        _items.insert(newIndex, _items.removeAt(oldIndex));
      });

  void _delete(Investment inv) {
    final index = _items.indexOf(inv);
    if (index < 0) return;
    setState(() => _items.removeAt(index));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted "${inv.name}"'),
          duration: const Duration(milliseconds: 1500),
          persist: false,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (!mounted) return;
              setState(() => _items.insert(
                  index > _items.length ? _items.length : index, inv));
            },
          ),
        ),
      );
  }

  Widget _list({required bool shrinkWrap}) => InvestmentsList(
        investments: _items,
        selectedId: _selected?.id,
        onSelect: _select,
        onDelete: _delete,
        onReorder: _reorder,
        shrinkWrap: shrinkWrap,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Investments')),
      drawer: Sidebar(activeTabId: 'investments'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) =>
              constraints.maxWidth >= _wideBreakpoint
                  ? _buildWide(constraints)
                  : _buildNarrow(),
        ),
      ),
    );
  }

  // Desktop: list + form on the left, details on the right.
  Widget _buildWide(BoxConstraints constraints) {
    final inner = constraints.maxHeight - AppSpacing.lg * 2;
    // Chart takes roughly the upper half of the right side.
    final chartHeight = (inner * 0.42).clamp(220.0, 600.0).toDouble();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _leftWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _list(shrinkWrap: false)),
                const SizedBox(height: AppSpacing.lg),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: inner * 0.45),
                  child: SingleChildScrollView(
                    child: InvestmentForm(onAdd: _add),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: SingleChildScrollView(
              child: InvestmentDetail(
                investment: _selected,
                chartHeight: chartHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Phone: details on top, then the list, then the form.
  Widget _buildNarrow() => SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InvestmentDetail(investment: _selected, chartHeight: 240),
            const SizedBox(height: AppSpacing.md),
            _list(shrinkWrap: true),
            const SizedBox(height: AppSpacing.md),
            InvestmentForm(onAdd: _add),
          ],
        ),
      );
}