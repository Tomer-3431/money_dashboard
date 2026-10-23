import 'package:money_dashboard/model/income.dart';
import 'package:money_dashboard/model/spend.dart';

/// One row in the transactions list: either an [Income] or a [Spend].
/// [amount] is always positive; use [isIncome] / [signedAmount] for direction.
class LedgerEntry {
  final String id;
  final bool isIncome;
  final String name;
  final String description;
  final String location;
  final int type;
  final int amount;
  final DateTime dateTime;
  final DateTime reportDate;

  const LedgerEntry({
    required this.id,
    required this.isIncome,
    required this.name,
    required this.description,
    required this.location,
    required this.type,
    required this.amount,
    required this.dateTime,
    required this.reportDate,
  });

  factory LedgerEntry.fromIncome(Income i) => LedgerEntry(
        id: i.id,
        isIncome: true,
        name: i.name,
        description: i.description,
        location: i.location,
        type: i.type,
        amount: i.amount,
        dateTime: i.dateTime,
        reportDate: i.reportDate,
      );

  factory LedgerEntry.fromSpend(Spend s) => LedgerEntry(
        id: s.id,
        isIncome: false,
        name: s.name,
        description: s.description,
        location: s.location,
        type: s.type,
        amount: s.amount,
        dateTime: s.dateTime,
        reportDate: s.reportDate,
      );

  int get signedAmount => isIncome ? amount : -amount;
}
