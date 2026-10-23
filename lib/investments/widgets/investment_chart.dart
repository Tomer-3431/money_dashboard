import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:money_dashboard/design/formatters.dart';
import 'package:money_dashboard/design/theme_constants.dart';
import 'package:money_dashboard/model/investment.dart';

/// Line chart of an investment's value. Hover (mouse) or tap/drag (phone)
/// to read a value. The dashed line marks the purchase amount (break-even).
class InvestmentChart extends StatefulWidget {
  const InvestmentChart({
    super.key,
    required this.points,
    required this.color,
    required this.baseline,
  });

  final List<ValuePoint> points;
  final Color color;
  final double baseline;

  @override
  State<InvestmentChart> createState() => _InvestmentChartState();
}

class _InvestmentChartState extends State<InvestmentChart> {
  int? _hover;

  @override
  Widget build(BuildContext context) {
    if (widget.points.length < 2) {
      return Center(
        child: Text('Not enough data to draw a chart yet',
            style: context.caption),
      );
    }
    final c = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final geo = _Geo(constraints.biggest, widget.points);

        void update(Offset p) =>
            setState(() => _hover = geo.nearest(p.dx));

        return MouseRegion(
          onHover: (e) => update(e.localPosition),
          onExit: (_) => setState(() => _hover = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => update(d.localPosition),
            onHorizontalDragUpdate: (d) => update(d.localPosition),
            child: CustomPaint(
              size: constraints.biggest,
              painter: _ChartPainter(
                geo: geo,
                colors: c,
                color: widget.color,
                baseline: widget.baseline,
                hover: _hover,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Geo {
  _Geo(this.size, this.pts) {
    final values = pts.map((p) => p.value);
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = maxV - minV;
    final pad = range == 0 ? math.max(1.0, maxV * 0.05) : range * 0.1;
    lo = minV - pad;
    hi = maxV + pad;
    t0 = pts.first.date.millisecondsSinceEpoch;
    t1 = pts.last.date.millisecondsSinceEpoch;
  }

  final Size size;
  final List<ValuePoint> pts;
  late final double lo, hi;
  late final int t0, t1;

  static const double left = 60, right = 12, top = 12, bottom = 28;

  Rect get plot =>
      Rect.fromLTRB(left, top, size.width - right, size.height - bottom);

  double x(ValuePoint p) {
    final span = t1 - t0;
    if (span == 0) return plot.left;
    return plot.left +
        plot.width * (p.date.millisecondsSinceEpoch - t0) / span;
  }

  double y(double v) => plot.bottom - plot.height * (v - lo) / (hi - lo);

  int nearest(double dx) {
    var best = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < pts.length; i++) {
      final d = (x(pts[i]) - dx).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }
}

String _short(double v) {
  final a = v.abs();
  if (a >= 1e6) return '$kCurrency${(v / 1e6).toStringAsFixed(1)}M';
  if (a >= 1e4) return '$kCurrency${(v / 1e3).toStringAsFixed(0)}K';
  return formatAmount(v.round());
}

TextPainter _text(String s, TextStyle style) => TextPainter(
      text: TextSpan(text: s, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.geo,
    required this.colors,
    required this.color,
    required this.baseline,
    required this.hover,
  });

  final _Geo geo;
  final AppColors colors;
  final Color color;
  final double baseline;
  final int? hover;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = geo.plot;
    final axisStyle = TextStyle(fontSize: 11, color: colors.textSecondary);

    // Grid + y labels
    final grid = Paint()
      ..color = colors.divider
      ..strokeWidth = 1;
    for (var i = 0; i < 4; i++) {
      final v = geo.lo + (geo.hi - geo.lo) * i / 3;
      final y = geo.y(v);
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      final tp = _text(_short(v), axisStyle);
      tp.paint(canvas, Offset(plot.left - 8 - tp.width, y - tp.height / 2));
    }

    // x labels (first / last date)
    final first = _text(formatDate(geo.pts.first.date), axisStyle);
    final last = _text(formatDate(geo.pts.last.date), axisStyle);
    final ly = size.height - _Geo.bottom + 8;
    first.paint(canvas, Offset(plot.left, ly));
    last.paint(canvas, Offset(plot.right - last.width, ly));

    // Break-even (purchase amount) dashed line
    if (baseline > geo.lo && baseline < geo.hi) {
      final y = geo.y(baseline);
      final dash = Paint()
        ..color = colors.textDisabled
        ..strokeWidth = 1;
      for (var x = plot.left; x < plot.right; x += 10) {
        canvas.drawLine(
            Offset(x, y), Offset(math.min(x + 5, plot.right), y), dash);
      }
    }

    // Line + gradient fill
    final line = Path();
    for (var i = 0; i < geo.pts.length; i++) {
      final o = Offset(geo.x(geo.pts[i]), geo.y(geo.pts[i].value));
      i == 0 ? line.moveTo(o.dx, o.dy) : line.lineTo(o.dx, o.dy);
    }
    final fill = Path.from(line)
      ..lineTo(geo.x(geo.pts.last), plot.bottom)
      ..lineTo(geo.x(geo.pts.first), plot.bottom)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0)],
        ).createShader(plot),
    );
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = color,
    );

    // Hover marker + tooltip
    final h = hover;
    if (h == null) return;
    final p = geo.pts[h];
    final px = geo.x(p);
    final py = geo.y(p.value);
    canvas.drawLine(
      Offset(px, plot.top),
      Offset(px, plot.bottom),
      Paint()
        ..color = colors.textDisabled
        ..strokeWidth = 1,
    );
    canvas.drawCircle(Offset(px, py), 6, Paint()..color = colors.surface);
    canvas.drawCircle(Offset(px, py), 4.5, Paint()..color = color);

    final tp = _text(
      '${formatDate(p.date)}   ${formatAmount(p.value.round())}',
      TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.text),
    );
    const padX = 10.0, padY = 6.0;
    final w = tp.width + padX * 2;
    final hgt = tp.height + padY * 2;
    final double bx = (px - w / 2).clamp(plot.left, math.max(plot.left, plot.right - w));
    var by = py - hgt - 12;
    if (by < plot.top) by = py + 12;
    final box = RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, w, hgt), const Radius.circular(8));
    canvas.drawRRect(box, Paint()..color = colors.surface);
    canvas.drawRRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = colors.border,
    );
    tp.paint(canvas, Offset(bx + padX, by + padY));
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.hover != hover ||
      old.color != color ||
      old.baseline != baseline ||
      old.colors != colors ||
      !identical(old.geo.pts, geo.pts) ||
      old.geo.size != geo.size;
}