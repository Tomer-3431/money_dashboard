/// One point on an investment's value-over-time chart.
class ValuePoint {
  final DateTime date;
  final double value;
  const ValuePoint(this.date, this.value);
}

/// An investment I made: what I paid, what it is worth now, plus its history.
class Investment {
  final String id;
  final String name;
  final int purchaseAmount;
  final DateTime purchaseDate;
  final int currentAmount;
  final List<ValuePoint> history; // sorted by date
  final String news;

  const Investment({
    required this.id,
    required this.name,
    required this.purchaseAmount,
    required this.purchaseDate,
    required this.currentAmount,
    this.history = const [],
    this.news = '',
  });

  int get profit => currentAmount - purchaseAmount;
  bool get isPositive => profit >= 0;
  double get returnPercent =>
      purchaseAmount <= 0 ? 0 : profit / purchaseAmount * 100;
}