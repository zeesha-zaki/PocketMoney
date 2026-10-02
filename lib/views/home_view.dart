import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class HomeView extends StatelessWidget {
  final AppController c;
  const HomeView(this.c, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), children: [
      const Text('PocketVault', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Glass(
        padding: const EdgeInsets.all(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: c.balance >= 0 ? [const Color(0xFF00E6A1).withOpacity(.85), const Color(0xFF0B8F8F)] : [coral, const Color(0xFF8E2B3F)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Total Balance', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(end: c.balance.toDouble()),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (_, v, __) => Text(pkr(v), style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.black)),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      Row(children: [
        _stat('Spent This Week', pkr(c.spentThisWeek), coral),
        const SizedBox(width: 8),
        _stat('Weekly Allowance', pkr(c.weekly), mint),
        const SizedBox(width: 8),
        _stat('Saved So Far', pkr(c.savedSoFar), lavender),
      ]),
      const SizedBox(height: 12),
      AffordWidget(c),
      const SizedBox(height: 20),
      const Text('Recent', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      if (c.txns.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Nothing yet — tap Log to add your first entry.'))),
      for (final t in c.txns.take(25))
        Dismissible(
          key: ValueKey(t.id),
          background: Container(color: coral.withOpacity(.3)),
          onDismissed: (_) => c.deleteTxn(t.id),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(backgroundColor: (t.isIncome ? mint : coral).withOpacity(.15), child: Text(t.isIncome ? '💰' : categories[t.category] ?? '💸')),
            title: Text(t.category, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(t.note.isEmpty ? '${t.date.day}/${t.date.month}' : '${t.note} · ${t.date.day}/${t.date.month}'),
            trailing: Text('${t.isIncome ? '+' : '-'}${pkr(t.amount)}', style: TextStyle(color: t.isIncome ? mint : coral, fontWeight: FontWeight.w800)),
          ),
        ),
    ]);
  }

  Widget _stat(String label, String value, Color color) => Expanded(
        child: Glass(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 6),
            FittedBox(child: Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color))),
          ]),
        ),
      );
}

class AffordWidget extends StatefulWidget {
  final AppController c;
  const AffordWidget(this.c, {super.key});
  @override
  State<AffordWidget> createState() => _AffordWidgetState();
}

class _AffordWidgetState extends State<AffordWidget> {
  final ctrl = TextEditingController();
  int price = 0;

  @override
  Widget build(BuildContext context) {
    final over = widget.c.overBudgetPct(price);
    final safe = over <= 0 && price <= widget.c.balance;
    final color = safe ? mint : coral;
    return Glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Can I afford this?', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(() => price = int.tryParse(v) ?? 0),
          decoration: const InputDecoration(prefixText: 'Rs. ', hintText: '4500', border: OutlineInputBorder(), isDense: true),
        ),
        if (price > 0) ...[
          const SizedBox(height: 12),
          AnimatedBar(price / (widget.c.weekLeft <= 0 ? 1 : widget.c.weekLeft), color),
          const SizedBox(height: 8),
          Pill(
              price > widget.c.balance
                  ? 'More than your balance'
                  : safe
                      ? '✅ Safe to Buy'
                      : '⚠️ Pushes budget by ${over.toStringAsFixed(0)}%',
              color),
        ],
      ]),
    );
  }
}
