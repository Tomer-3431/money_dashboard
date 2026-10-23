import 'package:flutter/material.dart';
import 'package:money_dashboard/design/colors_constants.dart';
import 'package:money_dashboard/design/theme_constants.dart';

/// A type is just an index 0..5. Its color comes from the theme's chart
/// palette (first six colors), so it follows light / dark automatically.
const int kTypeCount = 6;

const List<(String, Color)> kSpendTypes = [
  ('Medical / Mendatory', red),
  ('Food', orange),
  ('Cheap', yellow),
  ('Transportation', green),
  ('Subscription', lime),
  ('Other', teal),
];

const List<(String, Color)> kIncomeTypes = [
  ('Job / IDF', cyan),
  ('Freelance', blue),
  ('Gifts', navy),
  ('Investments', indigo),
  ('Refunds', purple),
  ('Other', pink),
];

String typeName({required int type, required bool isIncome}) {
  if (type < 0 || type >= kTypeCount) return 'Uncategorized';
  return (isIncome ? kIncomeTypes : kSpendTypes)[type].$1;
}

Color typeColor(BuildContext context, int type, bool isIncome) {
  if (type < 0 || type >= kTypeCount) return context.colors.textDisabled;
  return (isIncome ? kIncomeTypes : kSpendTypes)[type].$2;
}
