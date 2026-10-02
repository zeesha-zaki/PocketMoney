import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const mint = Color(0xFF00E6A1);
const coral = Color(0xFFFF5370);
const lavender = Color(0xFF8A70D6);

final _f = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 0, locale: 'en_PK');
String pkr(num v) => _f.format(v);

class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;
  const Glass({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.gradient});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (dark ? const Color(0xFF1E202E) : Colors.white) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: dark ? const Color(0xFF2A2D3D) : const Color(0xFFE4E6EB)),
      ),
      child: child,
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  const Pill(this.text, this.color, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(99)),
        child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      );
}

class AnimatedBar extends StatelessWidget {
  final double value;
  final Color color;
  const AnimatedBar(this.value, this.color, {super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(99),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 10, color: color, backgroundColor: color.withOpacity(.15)),
        ),
      );
}
