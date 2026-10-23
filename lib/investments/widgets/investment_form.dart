import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';

/// Bottom-left card: name + amount + purchase date. Adds an investment.
class InvestmentForm extends StatefulWidget {
  const InvestmentForm({super.key, required this.onAdd});

  final void Function(String name, int amount, DateTime date) onAdd;

  @override
  State<InvestmentForm> createState() => _InvestmentFormState();
}

class _InvestmentFormState extends State<InvestmentForm> {
  static const double _wideBreakpoint = 440;

  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _dateText = TextEditingController();
  final _nameFocus = FocusNode();

  DateTime _date = DateTime.now();
  String? _nameError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _dateText.text = formatDate(_date);
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _dateText.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateText.text = formatDate(picked);
    });
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

    widget.onAdd(name, amount!, _date);
    _name.clear();
    _amount.clear();
    setState(() {
      _nameError = null;
      _amountError = null;
      _date = DateTime.now();
      _dateText.text = formatDate(_date);
    });
    _nameFocus.requestFocus();
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
              label: 'Investment name',
              icon: Icons.trending_up_outlined,
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
            decoration: AppInputDecorations.number(label: 'Amount invested')
                .copyWith(errorText: _amountError),
          );

          final dateField = TextField(
            controller: _dateText,
            readOnly: true,
            onTap: _pickDate,
            decoration: AppInputDecorations.date(label: 'Purchase date'),
          );

          final button = ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Add investment'),
          );

          const gap = SizedBox(width: AppSpacing.md);
          const vGap = SizedBox(height: AppSpacing.md);

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    Text('New investment', style: context.h4),
                  ],
                ),
                vGap,
                if (wide) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: nameField),
                      gap,
                      Expanded(flex: 2, child: amountField),
                    ],
                  ),
                  vGap,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: dateField),
                      gap,
                      SizedBox(height: 56, child: button),
                    ],
                  ),
                ] else ...[
                  nameField,
                  vGap,
                  amountField,
                  vGap,
                  dateField,
                  vGap,
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