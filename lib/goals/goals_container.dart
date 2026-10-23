import 'package:flutter/material.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/goals/mock_goals.dart';
import 'package:money_dashboard/goals/widgets/goal_form.dart';
import 'package:money_dashboard/goals/widgets/goal_gauge.dart';
import 'package:money_dashboard/goals/widgets/goals_list.dart';
import 'package:money_dashboard/home/mock_data.dart';
import 'package:money_dashboard/model/goal.dart';
import 'package:money_dashboard/widgets/sidebar.dart';

class GoalsContainer extends StatefulWidget {
  const GoalsContainer({super.key});

  @override
  State<GoalsContainer> createState() => GoalsContainerState();
}

class GoalsContainerState extends State<GoalsContainer> {
  /// Content stays readable on wide windows: centered, never wider than this.
  static const double _maxContentWidth = 720;

  /// Roomier padding from this width up.
  static const double _wideBreakpoint = 600;

  late final List<Goal> _goals = List.of(kMockGoals);

  /// Only one goal can be selected at a time. The first goal is the default.
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = _goals.isEmpty ? null : _goals.first.id;
  }

  /// The selected goal; falls back to the first one (e.g. after a delete).
  Goal? get _selected {
    if (_goals.isEmpty) return null;
    return _goals.firstWhere(
      (g) => g.id == _selectedId,
      orElse: () => _goals.first,
    );
  }

  void _select(Goal goal) => setState(() => _selectedId = goal.id);

  void _add(String name, int amount) => setState(() {
        _goals.add(Goal(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: name,
          amount: amount,
        ));
      });

  void _reorder(int oldIndex, int newIndex) => setState(() {
        if (newIndex > oldIndex) newIndex -= 1;
        _goals.insert(newIndex, _goals.removeAt(oldIndex));
      });

  void _delete(Goal goal) {
    final index = _goals.indexOf(goal);
    if (index < 0) return;
    setState(() => _goals.removeAt(index));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted "${goal.name}"'),
          duration: const Duration(milliseconds: 1500),
          // A snackbar with an action stays until dismissed unless this is false.
          persist: false,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (!mounted) return;
              setState(() => _goals.insert(
                  index > _goals.length ? _goals.length : index, goal));
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      drawer: Sidebar(activeTabId: 'goals',),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gap = constraints.maxWidth >= _wideBreakpoint
                ? AppSpacing.lg
                : AppSpacing.md;
            return SingleChildScrollView(
              padding: EdgeInsets.all(gap),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GoalGauge(goal: selected, balance: kCurrentBalance),
                      SizedBox(height: gap),
                      GoalsList(
                        goals: _goals,
                        selectedId: selected?.id,
                        onSelect: _select,
                        onDelete: _delete,
                        onReorder: _reorder,
                      ),
                      SizedBox(height: gap),
                      GoalForm(onAdd: _add),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
