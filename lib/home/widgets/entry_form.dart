import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/model/entry_type.dart';

/// Form used for both spending and income ([isIncome] switches the labels,
/// accent color and type names). GUI only: the submit button does nothing yet.
class EntryForm extends StatefulWidget {
  const EntryForm({super.key, required this.isIncome});

  final bool isIncome;

  @override
  State<EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<EntryForm> {
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _amount = TextEditingController();
  final _dateText = TextEditingController();

  DateTime _date = DateTime.now();
  int _type = 0;

  @override
  void initState() {
    super.initState();
    _dateText.text = formatDate(_date);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _location.dispose();
    _amount.dispose();
    _dateText.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateText.text = formatDate(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = widget.isIncome ? c.income : c.expense;

    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding =
              constraints.maxWidth < 400 ? AppSpacing.md : AppSpacing.lg;
          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Icon(
                        widget.isIncome
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 18,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Text(widget.isIncome ? 'New income' : 'New spend',
                        style: context.h4),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Fields (left) + type selector (right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildFields()),
                    const SizedBox(width: AppSpacing.md),
                    _TypeSelector(
                      selected: _type,
                      isIncome: widget.isIncome,
                      onChanged: (t) => setState(() => _type = t),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Submit (does nothing yet)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 20),
                    label: Text(widget.isIncome ? 'Add income' : 'Add spend'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFields() {
    const gap = SizedBox(height: AppSpacing.md);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: _name,
          textInputAction: TextInputAction.next,
          decoration:
              AppInputDecorations.text(label: 'Name', icon: Icons.edit_outlined),
        ),
        gap,
        TextFormField(
          controller: _description,
          textInputAction: TextInputAction.next,
          decoration: AppInputDecorations.text(
              label: 'Description', icon: Icons.notes_outlined),
        ),
        gap,
        TextFormField(
          controller: _location,
          textInputAction: TextInputAction.next,
          decoration: AppInputDecorations.text(
              label: 'Location', icon: Icons.place_outlined),
        ),
        gap,
        // Date next to amount (amount on the right). Stacks on very narrow widths.
        LayoutBuilder(
          builder: (context, constraints) {
            final date = TextFormField(
              controller: _dateText,
              readOnly: true,
              onTap: _pickDate,
              decoration: AppInputDecorations.date(label: 'Date'),
            );
            final amount = TextFormField(
              controller: _amount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: AppInputDecorations.number(label: 'Amount'),
            );

            if (constraints.maxWidth < 280) {
              return Column(children: [date, gap, amount]);
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: date),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: amount),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Type selector: 6 color buttons, exactly one selected
// ---------------------------------------------------------------------------
class _TypeSelector extends StatelessWidget {
  const _TypeSelector({
    required this.selected,
    required this.isIncome,
    required this.onChanged,
  });

  final int selected;
  final bool isIncome;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < kTypeCount; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == kTypeCount - 1 ? 0 : 6),
              child: _TypeButton(
                color: typeColor(context, i, isIncome),
                name: typeName(type: i, isIncome: isIncome),
                selected: i == selected,
                onTap: () => onChanged(i),
              ),
            ),
        ],
      );
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.color,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: name,
        child: Tooltip(
          message: name,
          child: InkResponse(
            onTap: onTap,
            customBorder: const CircleBorder(),
            radius: 24,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 38,
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      );
}
