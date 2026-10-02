import 'dart:math';
import 'package:flutter/material.dart';

const donutColors = [Color(0xFFFF5370), Color(0xFF8A70D6), Color(0xFFFFB84D), Color(0xFF4DB8FF), Color(0xFF00E6A1), Color(0xFFFF8A65), Color(0xFFB0BEC5)];

class DonutChart extends StatelessWidget {
  final List<double> values;
  final int? selected;
  final Widget center;
  const DonutChart({super.key, required this.values, this.selected, required this.center});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (_, t, __) => SizedBox(
          height: 220,
          width: 220,
          child: CustomPaint(painter: _P(values, t, selected), child: Center(child: center)),
        ),
      );
}

class _P extends CustomPainter {
  final List<double> v;
  final double t;
  final int? sel;
  _P(this.v, this.t, this.sel);

  @override
  void paint(Canvas c, Size s) {
    final total = v.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    final rect = Rect.fromCircle(center: s.center(Offset.zero), radius: s.width / 2 - 16);
    double start = -pi / 2;
    for (var i = 0; i < v.length; i++) {
      final sweep = v[i] / total * 2 * pi * t;
      final p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = sel == i ? 30 : 22
        ..color = donutColors[i % donutColors.length];
      c.drawArc(rect, start, max(sweep - 0.03, 0.001), false, p);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_P o) => o.t != t || o.sel != sel || o.v != v;
}
