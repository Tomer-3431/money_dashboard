import 'package:money_dashboard/model/goal.dart';

/// Constants for the GUI-only phase. Replace with Firestore later.
/// The first goal in the list is the one selected by default.
final List<Goal> kMockGoals = [
  const Goal(id: 'g1', name: 'Emergency fund', amount: 5000000),
  const Goal(id: 'g2', name: 'Apartment deposit', amount: 10000000),
  const Goal(id: 'g3', name: 'Wedding', amount: 15000000),
  const Goal(id: 'g4', name: 'Retirement', amount: 50000000),
];
