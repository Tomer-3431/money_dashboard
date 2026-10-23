import 'package:flutter/material.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/model/goal.dart';

/// Middle card: the goals, in the user's order. Tap a row to select it.
/// On hover (always visible on phones) each row shows a grab handle on the
/// left for reordering and a recycle bin on the right for deleting.
class GoalsList extends StatelessWidget {
  const GoalsList({
    super.key,
    required this.goals,
    required this.selectedId,
    required this.onSelect,
    required this.onDelete,
    required this.onReorder,
  });

  final List<Goal> goals;
  final String? selectedId;
  final ValueChanged<Goal> onSelect;
  final ValueChanged<Goal> onDelete;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md - 2,
            ),
            child: Row(
              children: [
                Text('Goals', style: context.h4),
                const Spacer(),
                Text('Tap a goal to track it', style: context.caption),
              ],
            ),
          ),
          const Divider(),
          if (goals.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: Text('No goals yet', style: context.caption),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: goals.length,
              onReorder: onReorder,
              proxyDecorator: (child, _, _) => Material(
                color: c.surface,
                surfaceTintColor: Colors.transparent,
                elevation: 4,
                borderRadius: AppRadius.smAll,
                child: child,
              ),
              itemBuilder: (_, i) {
                final goal = goals[i];
                return _GoalTile(
                  key: ValueKey(goal.id),
                  goal: goal,
                  index: i,
                  selected: goal.id == selectedId,
                  showDivider: i != goals.length - 1,
                  onTap: () => onSelect(goal),
                  onDelete: () => onDelete(goal),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatefulWidget {
  const _GoalTile({
    super.key,
    required this.goal,
    required this.index,
    required this.selected,
    required this.showDivider,
    required this.onTap,
    required this.onDelete,
  });

  final Goal goal;
  final int index;
  final bool selected;
  final bool showDivider;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_GoalTile> createState() => _GoalTileState();
}

class _GoalTileState extends State<_GoalTile> {
  bool _hover = false;

  /// Phones have no hover, so the icons stay visible there.
  bool get _touch {
    final p = Theme.of(context).platform;
    return p == TargetPlatform.android || p == TargetPlatform.iOS;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final show = _hover || _touch;
    final selected = widget.selected;

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
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    // Grab handle (left): drag to reorder.
                    IgnorePointer(
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
                              child: Icon(Icons.drag_indicator,
                                  size: 20, color: c.textDisabled),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        widget.goal.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.standard.copyWith(
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      formatAmount(widget.goal.amount),
                      style: AppTextStyles.amount.copyWith(
                        color: selected ? c.primary : c.text,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    // Recycle bin (right): delete.
                    IgnorePointer(
                      ignoring: !show,
                      child: AnimatedOpacity(
                        opacity: show ? 1 : 0,
                        duration: const Duration(milliseconds: 120),
                        child: IconButton(
                          tooltip: 'Delete goal',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: widget.onDelete,
                          style: ButtonStyle(
                            foregroundColor:
                                WidgetStateProperty.resolveWith((states) =>
                                    states.contains(WidgetState.hovered)
                                        ? c.expense
                                        : c.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (widget.showDivider) const Divider(),
        ],
      ),
    );
  }
}
