import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../models/models.dart';
import '../widgets/common.dart';

class GoalsView extends StatelessWidget {
  final AppController c;
  const GoalsView(this.c, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        const Expanded(child: Text('Piggy Bank', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: lavender),
          onPressed: () => _newGoal(context),
          icon: const Icon(Icons.add),
          label: const Text('Goal'),
        ),
      ]),
      const SizedBox(height: 12),
      if (c.goals.isEmpty) const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Add a wish like "New Headphones – Rs. 12,000".'))),
      for (final g in c.goals)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Glass(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(g.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 10),
                Expanded(child: Text(g.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => c.deleteGoal(g.id)),
              ]),
              const SizedBox(height: 8),
              AnimatedBar(g.progress, lavender),
              const SizedBox(height: 8),
              Row(children: [
                Text('${pkr(g.saved)} / ${pkr(g.target)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Pill('${(g.progress * 100).round()}%', lavender),
              ]),
              const SizedBox(height: 6),
              Text(_eta(g), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: OutlinedButton(onPressed: () => _deposit(context, g), child: const Text('Deposit from balance'))),
            ]),
          ),
        ),
    ]);
  }

  String _eta(Goal g) {
    if (g.saved >= g.target) return '🎉 Goal reached!';
    final d = c.etaDays(g);
    return d == null ? 'Spending is above allowance — no ETA yet' : '≈ $d days left at your current pace';
  }

  void _newGoal(BuildContext context) {
    final n = TextEditingController(), t = TextEditingController(), e = TextEditingController(text: '🎧');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New goal'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: e, decoration: const InputDecoration(labelText: 'Emoji')),
          TextField(controller: n, decoration: const InputDecoration(labelText: 'Name')),
          TextField(controller: t, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Target', prefixText: 'Rs. ')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(t.text) ?? 0;
              if (n.text.trim().isEmpty || v <= 0) return;
              c.addGoal(n.text.trim(), v, e.text.trim().isEmpty ? '🎯' : e.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deposit(BuildContext context, Goal g) {
    final a = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Deposit to ${g.name}'),
        content: TextField(controller: a, keyboardType: TextInputType.number, autofocus: true, decoration: InputDecoration(prefixText: 'Rs. ', helperText: 'Available: ${pkr(c.balance)}')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              c.deposit(g, int.tryParse(a.text) ?? 0);
              Navigator.pop(context);
            },
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }
}
