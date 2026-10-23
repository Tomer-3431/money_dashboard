import 'package:money_dashboard/model/income.dart';
import 'package:money_dashboard/model/ledger_entry.dart';
import 'package:money_dashboard/model/spend.dart';

/// Constants for the GUI-only phase. Replace with Firestore later.
const int kCurrentBalance = 7654321;

final List<LedgerEntry> kMockEntries = _buildMockEntries();

List<LedgerEntry> _buildMockEntries() {
  final now = DateTime.now();

  DateTime ago(int days, int hour, int minute) {
    final d = now.subtract(Duration(days: days));
    return DateTime(d.year, d.month, d.day, hour, minute);
  }

  LedgerEntry income(String id, String name, int amount, int type,
          String location, String description, int days, int h, int m) =>
      LedgerEntry.fromIncome(Income(
        id: id,
        name: name,
        description: description,
        amount: amount,
        type: type,
        location: location,
        dateTime: ago(days, h, m),
        reportDate: ago(days, h, m + 5),
      ));

  LedgerEntry spend(String id, String name, int amount, int type,
          String location, String description, int days, int h, int m) =>
      LedgerEntry.fromSpend(Spend(
        id: id,
        name: name,
        description: description,
        amount: amount,
        type: type,
        location: location,
        dateTime: ago(days, h, m),
        reportDate: ago(days, h, m + 5),
      ));

  final entries = <LedgerEntry>[
    income('i1', 'Monthly salary', 18500, 0, 'Acme Ltd.', 'October salary', 1, 9, 0),
    spend('s1', 'Supermarket', 412, 0, 'Shufersal', 'Weekly groceries', 1, 18, 42),
    spend('s2', 'Rent', 4800, 1, 'Landlord transfer', 'Monthly rent', 3, 8, 15),
    income('i2', 'Logo design', 1200, 1, 'Online', 'Freelance project for a client', 4, 14, 30),
    spend('s3', 'Train ticket', 38, 2, 'Israel Railways', '', 5, 7, 50),
    spend('s4', 'Cinema', 96, 3, 'Cinema City', 'Two tickets', 6, 21, 10),
    spend('s5', 'Pharmacy', 74, 4, 'Super-Pharm', 'Vitamins', 8, 12, 5),
    income('i3', 'Dividends', 640, 2, 'Brokerage', 'Quarterly dividends', 9, 10, 0),
    spend('s6', 'Coffee', 18, 0, 'Aroma', '', 10, 9, 20),
    spend('s7', 'Gift for Dana', 220, 5, 'Mall', 'Birthday present', 12, 17, 0),
    income('i4', 'Refund', 150, 4, 'Online store', 'Returned headphones', 14, 11, 45),
    spend('s8', 'Electricity bill', 530, 1, 'Israel Electric Corp.', 'Bi-monthly bill', 16, 8, 0),
    spend('s9', 'Fuel', 310, 2, 'Paz', '', 19, 19, 25),
    spend('s10', 'Restaurant', 245, 0, 'Tel Aviv', 'Dinner with friends', 22, 20, 40),
    // Older entries, so the month arrows have something to show.
    income('i5', 'Monthly salary', 18500, 0, 'Acme Ltd.', 'Previous month salary', 31, 9, 0),
    spend('s11', 'Rent', 4800, 1, 'Landlord transfer', 'Monthly rent', 33, 8, 15),
    spend('s12', 'Gym', 180, 4, 'Holmes Place', 'Monthly membership', 36, 7, 0),
    spend('s13', 'Concert', 350, 3, 'Live Park', 'Two tickets', 41, 22, 0),
    income('i6', 'Website project', 2400, 1, 'Online', 'Freelance project', 44, 15, 10),
    spend('s14', 'Supermarket', 388, 0, 'Rami Levy', '', 47, 18, 5),
  ];

  entries.sort((a, b) => b.dateTime.compareTo(a.dateTime));
  return entries;
}
