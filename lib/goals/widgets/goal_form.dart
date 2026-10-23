import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_dashboard/design/theme_constants.dart';

/// Bottom card: name + target amount + submit. Adds a goal to the list.
class GoalForm extends StatefulWidget {
  const GoalForm({super.key, required this.onAdd});

  final void Function(String name, int amount) onAdd;

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  /// Side-by-side fields + button from this width up; stacked below it.
  static const double _wideBreakpoint = 480;

  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _nameFocus = FocusNode();

  String? _nameError;
  String? _amountError;

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    final amount = int.tryParse(_amount.text);

    final nameError = name.isEmpty ? 'Enter a name' : null;
    final amountError =
        (amount == null || amount <= 0) ? 'Enter an amount' : null;

    if (nameError != null || amountError != null) {
      setState(() {
        _nameError = nameError;
        _amountError = amountError;
      });
      return;
    }

    widget.onAdd(name, amount!);
    _name.clear();
    _amount.clear();
    setState(() {
      _nameError = null;
      _amountError = null;
    });
    _nameFocus.requestFocus(); // ready for the next goal
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding =
              constraints.maxWidth < 400 ? AppSpacing.md : AppSpacing.lg;
          final wide = constraints.maxWidth - padding * 2 >= _wideBreakpoint;

          final nameField = TextField(
            controller: _name,
            focusNode: _nameFocus,
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
            decoration: AppInputDecorations.text(
              label: 'Goal name',
              icon: Icons.flag_outlined,
            ).copyWith(errorText: _nameError),
          );

          final amountField = TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            onChanged: (_) {
              if (_amountError != null) setState(() => _amountError = null);
            },
            onSubmitted: (_) => _submit(),
            decoration: AppInputDecorations.number(label: 'Target amount')
                .copyWith(errorText: _amountError),
          );

          final button = ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add goal'),
          );

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (same pattern as EntryForm)
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: 0.12),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Icon(Icons.add, size: 18, color: c.primary),
                    ),
                    const SizedBox(width: AppSpacing.sm + 4),
                    Text('New goal', style: context.h4),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: nameField),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(flex: 2, child: amountField),
                      const SizedBox(width: AppSpacing.md),
                      SizedBox(height: 56, child: button),
                    ],
                  )
                else ...[
                  nameField,
                  const SizedBox(height: AppSpacing.md),
                  amountField,
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(width: double.infinity, child: button),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
