import 'dart:math' as math;

import 'package:money_dashboard/model/investment.dart';

/// Constants for the GUI-only phase. Replace with Firestore later.
/// The first investment is the one selected by default.
final List<Investment> kMockInvestments = _build();

List<ValuePoint> _walk({
  required DateTime start,
  required int from,
  required int to,
  required int seed,
  double volatility = 0.05,
}) {
  final rnd = math.Random(seed);
  final now = DateTime.now();
  final total = now.difference(start);
  final n = (total.inDays / 7).round().clamp(8, 60);
  final points = <ValuePoint>[];
  for (var i = 0; i <= n; i++) {
    final t = i / n;
    final date = i == n
        ? now
        : start.add(Duration(milliseconds: (total.inMilliseconds * t).round()));
    var v = from + (to - from) * t;
    if (i != 0 && i != n) {
      v += (rnd.nextDouble() - 0.5) * 2 * volatility * from * math.sin(math.pi * t);
    }
    if (i == n) v = to.toDouble();
    points.add(ValuePoint(date, math.max(1, v)));
  }
  return points;
}

List<Investment> _build() {
  final now = DateTime.now();
  DateTime ago(int days) => now.subtract(Duration(days: days));

  Investment make(String id, String name, int bought, int current, int days,
      int seed, double vol, String news) {
    final start = ago(days);
    return Investment(
      id: id,
      name: name,
      purchaseAmount: bought,
      purchaseDate: start,
      currentAmount: current,
      history: _walk(
          start: start, from: bought, to: current, seed: seed, volatility: vol),
      news: news,
    );
  }

  return [
    make('v1', 'S&P 500 ETF', 20000, 23450, 300, 1, 0.04,
        'Broad US equities keep trending upward, led by large-cap tech. '
            'Analysts are watching the next rate decision, which could add short-term volatility. '
            '(Placeholder text - connect a news source later.)'),
    make('v2', 'Apple (AAPL)', 8000, 9120, 200, 2, 0.07,
        'Strong services revenue is offsetting slower hardware growth. '
            '(Placeholder text - connect a news source later.)'),
    make('v3', 'Tel Aviv 35 Index', 12000, 11340, 150, 3, 0.05,
        'The local market is under pressure from regional uncertainty, '
            'while banks continue to report solid earnings. '
            '(Placeholder text - connect a news source later.)'),
    make('v4', 'Bitcoin', 5000, 3890, 90, 4, 0.15,
        'Crypto remains highly volatile; regulation headlines are driving most of the moves. '
            '(Placeholder text - connect a news source later.)'),
    make('v5', 'Government bonds', 10000, 10420, 400, 5, 0.01,
        'Yields are stable. Bonds continue to act as the low-risk part of the portfolio. '
            '(Placeholder text - connect a news source later.)'),
  ];
}