import 'package:flutter/material.dart';
import 'package:money_dashboard/design/theme_constants.dart';

/// A type is just an index 0..5. Its color comes from the theme's chart
/// palette (first six colors), so it follows light / dark automatically.
const int kTypeCount = 6;

const List<String> kSpendTypeNames = [
  'Food',
  'Housing',
  'Transport',
  'Leisure',
  'Health',
  'Other',
];

const List<String> kIncomeTypeNames = [
  'Salary',
  'Freelance',
  'Investments',
  'Gifts',
  'Refunds',
  'Other',
];

String typeName({required int type, required bool isIncome}) {
  if (type < 0 || type >= kTypeCount) return 'Uncategorized';
  return (isIncome ? kIncomeTypeNames : kSpendTypeNames)[type];
}

Color typeColor(BuildContext context, int type) {
  if (type < 0 || type >= kTypeCount) return context.colors.textDisabled;
  return context.colors.chart[type];
}
