import 'package:flutter/material.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/goals/goals_container.dart';
import 'package:money_dashboard/home/mock_data.dart';
import 'package:money_dashboard/home/widgets/balance_card.dart';
import 'package:money_dashboard/home/widgets/entry_form.dart';
import 'package:money_dashboard/home/widgets/transactions_panel.dart';

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

  void _openGoals() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const GoalsContainer()),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Money Dashboard'),
          actions: [
            IconButton(
              tooltip: 'Goals',
              icon: const Icon(Icons.flag_outlined),
              onPressed: _openGoals,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) =>
                constraints.maxWidth >= _wideBreakpoint
                    ? _buildWide()
                    : _buildNarrow(),
          ),
        ),
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
                  const BalanceCard(balance: kCurrentBalance),
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
            const BalanceCard(balance: kCurrentBalance),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 460,
              child: TransactionsPanel(entries: kMockEntries),
            ),
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
