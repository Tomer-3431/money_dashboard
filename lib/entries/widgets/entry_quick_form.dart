import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/model/entry_type.dart';

typedef NewEntryCallback = void Function({
  required String name,
  required String description,
  required String location,
  required int type,
  required int amount,
  required DateTime dateTime,
});

/// Compact add form for the bottom of the table screen.
///
/// Row 1: the six type color buttons.
/// Row 2: name, description, location, date & time, amount, add button.
/// Stacks the fields on narrow windows.
class EntryQuickForm extends StatefulWidget {
  const EntryQuickForm({
    super.key,
    required this.isIncome,
    required this.onAdd,
  });

  final bool isIncome;
  final NewEntryCallback onAdd;

  @override
  State<EntryQuickForm> createState() => _EntryQuickFormState();
}

class _EntryQuickFormState extends State<EntryQuickForm> {
  /// Single-row layout from this width up.
  static const double _wideBreakpoint = 1000;

  final _name = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();
  final _amount = TextEditingController();
  final _dateText = TextEditingController();
  final _nameFocus = FocusNode();

  DateTime _dateTime = DateTime.now();
  int _type = 0;
  String? _nameError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _dateText.text = formatDateTime(_dateTime);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _location.dispose();
    _amount.dispose();
    _dateText.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (!mounted) return;
    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? _dateTime.hour,
      time?.minute ?? _dateTime.minute,
    );
    setState(() {
      _dateTime = picked;
      _dateText.text = formatDateTime(picked);
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

    widget.onAdd(
      name: name,
      description: _description.text.trim(),
      location: _location.text.trim(),
      type: _type,
      amount: amount!,
      dateTime: _dateTime,
    );

    _name.clear();
    _description.clear();
    _location.clear();
    _amount.clear();
    setState(() {
      _nameError = null;
      _amountError = null;
      _dateTime = DateTime.now();
      _dateText.text = formatDateTime(_dateTime);
    });
    _nameFocus.requestFocus(); // ready for the next one
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = widget.isIncome ? c.income : c.expense;

    final nameField = TextField(
      controller: _name,
      focusNode: _nameFocus,
      textInputAction: TextInputAction.next,
      onChanged: (_) {
        if (_nameError != null) setState(() => _nameError = null);
      },
      decoration: AppInputDecorations.text(label: 'Name')
          .copyWith(errorText: _nameError),
    );

    final descriptionField = TextField(
      controller: _description,
      textInputAction: TextInputAction.next,
      decoration: AppInputDecorations.text(label: 'Description'),
    );

    final locationField = TextField(
      controller: _location,
      textInputAction: TextInputAction.next,
      decoration: AppInputDecorations.text(label: 'Location'),
    );

    final dateField = TextField(
      controller: _dateText,
      readOnly: true,
      onTap: _pickDateTime,
      decoration: AppInputDecorations.date(label: 'Date & time', hint: ''),
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
      decoration: AppInputDecorations.number(label: 'Amount')
          .copyWith(errorText: _amountError),
    );

    final button = ElevatedButton.icon(
      onPressed: _submit,
      icon: const Icon(Icons.add, size: 20),
      label: Text(widget.isIncome ? 'Add income' : 'Add spend'),
    );

    const gap = SizedBox(width: AppSpacing.md);
    const vGap = SizedBox(height: AppSpacing.md);

    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= _wideBreakpoint;

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: type color buttons
                Row(
                  children: [
                    Icon(
                      widget.isIncome
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      size: 18,
                      color: accent,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(widget.isIncome ? 'New income' : 'New spend',
                        style: context.h4),
                    const SizedBox(width: AppSpacing.lg),
                    Flexible(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (var i = 0; i < kTypeCount; i++)
                            _TypeButton(
                              color: typeColor(context, i, widget.isIncome),
                              name: typeName(type: i, isIncome: widget.isIncome),
                              selected: i == _type,
                              onTap: () => setState(() => _type = i),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm),
                            child: Text(
                              typeName(type: _type, isIncome: widget.isIncome),
                              style: context.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                vGap,
                // Row 2: fields + button
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: nameField),
                      gap,
                      Expanded(flex: 3, child: descriptionField),
                      gap,
                      Expanded(flex: 2, child: locationField),
                      gap,
                      SizedBox(width: 200, child: dateField),
                      gap,
                      SizedBox(width: 140, child: amountField),
                      gap,
                      SizedBox(height: 56, child: button),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      nameField,
                      vGap,
                      descriptionField,
                      vGap,
                      locationField,
                      vGap,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: dateField),
                          gap,
                          Expanded(child: amountField),
                        ],
                      ),
                      vGap,
                      button,
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
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
            radius: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 32,
              height: 32,
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
