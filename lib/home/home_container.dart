import 'package:flutter/material.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/goals/mock_goals.dart';
import 'package:money_dashboard/home/mock_data.dart';
import 'package:money_dashboard/home/widgets/balance_card.dart';
import 'package:money_dashboard/home/widgets/entry_form.dart';
import 'package:money_dashboard/home/widgets/transactions_panel.dart';
import 'package:money_dashboard/investments/mock_investments.dart';
import 'package:money_dashboard/model/goal.dart';
import 'package:money_dashboard/widgets/sidebar.dart';

class HomeContainer extends StatefulWidget {
  const HomeContainer({super.key});

  @override
  State<HomeContainer> createState() => HomeContainerState();
}

class HomeContainerState extends State<HomeContainer> {
  /// Desktop / tablet layout from this width up; phone layout below it.
  static const double _wideBreakpoint = 960;

  /// Fixed width of the forms column in the wide layout.
  static const double _formsWidth = 440;

  /// The first goal in the goals list is the "top goal".
  Goal? get _topGoal => kMockGoals.isEmpty ? null : kMockGoals.first;

  /// Current value of all investments together.
  int get _investmentsTotal =>
      kMockInvestments.fold<int>(0, (sum, i) => sum + i.currentAmount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Dashboard')),
      drawer: Sidebar(activeTabId: 'home'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) =>
              constraints.maxWidth >= _wideBreakpoint
              ? _buildWide()
              : _buildNarrow(),
        ),
      ),
    );
  }

  Widget _balanceCard() => BalanceCard(
    balance: kCurrentBalance,
    topGoal: _topGoal,
    investmentsTotal: _investmentsTotal,
  );

  // Windows / tablet: balance + list on the left, forms on the right.
  Widget _buildWide() => Padding(
    padding: const EdgeInsets.all(AppSpacing.lg),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _balanceCard(),
              const SizedBox(height: AppSpacing.lg),
              Expanded(child: TransactionsPanel(entries: kMockEntries)),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        SizedBox(
          width: _formsWidth,
          child: SingleChildScrollView(child: _buildForms()),
        ),
      ],
    ),
  );

  // Phone: everything stacked in one scrolling page.
  Widget _buildNarrow() => SingleChildScrollView(
    padding: const EdgeInsets.all(AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _balanceCard(),
        const SizedBox(height: AppSpacing.md),
        SizedBox(height: 460, child: TransactionsPanel(entries: kMockEntries)),
        const SizedBox(height: AppSpacing.md),
        _buildForms(),
      ],
    ),
  );

  // Spend form, divider, income form.
  Widget _buildForms() => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      EntryForm(isIncome: false),
      Divider(height: AppSpacing.xl),
      EntryForm(isIncome: true),
    ],
  );
}
