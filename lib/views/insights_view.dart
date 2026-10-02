import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../models/models.dart';
import '../widgets/common.dart';
import '../widgets/donut.dart';

class InsightsView extends StatefulWidget {
  final AppController c;
  const InsightsView(this.c, {super.key});
  @override
  State<InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<InsightsView> {
  int? sel;

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    final data = c.spendByCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final total = data.fold(0, (s, e) => s + e.value);
    final pace = c.pace;
    final pc = {Pace.safe: mint, Pace.balanced: const Color(0xFFFFB84D), Pace.fast: coral}[pace]!;
    final label = {Pace.safe: 'Safe', Pace.balanced: 'Balanced', Pace.fast: 'Fast Burn 🔥'}[pace]!;
    final pv = {Pace.safe: .25, Pace.balanced: .6, Pace.fast: .95}[pace]!;

    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), children: [
      const Text('Insights', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Glass(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Text('Spending pace', style: TextStyle(fontWeight: FontWeight.w700)), const Spacer(), Pill(label, pc)]),
          const SizedBox(height: 10),
          AnimatedBar(pv, pc),
        ]),
      ),
      const SizedBox(height: 12),
      Glass(
        child: data.isEmpty
            ? const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Log some expenses to see your breakdown.')))
            : Column(children: [
                DonutChart(
                  values: data.map((e) => e.value.toDouble()).toList(),
                  selected: sel,
                  center: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(sel == null ? 'Total' : data[sel!].key, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(pkr(sel == null ? total : data[sel!].value), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  ]),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < data.length; i++)
                  InkWell(
                    onTap: () => setState(() => sel = sel == i ? null : i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(children: [
                        Container(width: 12, height: 12, decoration: BoxDecoration(color: donutColors[i % donutColors.length], shape: BoxShape.circle)),
                        const SizedBox(width: 10),
                        Text('${categories[data[i].key] ?? ''} ${data[i].key}'),
                        const Spacer(),
                        Text(pkr(data[i].value), style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Text('${(data[i].value / total * 100).round()}%', style: const TextStyle(color: Colors.grey)),
                      ]),
                    ),
                  ),
              ]),
      ),
    ]);
  }
}
