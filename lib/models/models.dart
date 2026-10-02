const incomeCategory = 'Allowance';
const categories = <String, String>{
  'Snacks/Chai': '🍵',
  'Gaming': '🎮',
  'Hangouts': '🍕',
  'Transport/Fuel': '⛽',
  'Subscriptions': '📺',
  'Shopping': '🛍️',
  'Savings': '🐷',
};

class Txn {
  final String id;
  final int amount;
  final bool isIncome;
  final String category;
  final String note;
  final DateTime date;
  Txn({required this.id, required this.amount, required this.isIncome, required this.category, this.note = '', required this.date});

  Map<String, dynamic> toJson() => {'id': id, 'amount': amount, 'isIncome': isIncome, 'category': category, 'note': note, 'date': date.toIso8601String()};
  factory Txn.fromJson(Map<String, dynamic> j) => Txn(
      id: j['id'], amount: j['amount'], isIncome: j['isIncome'], category: j['category'], note: j['note'] ?? '', date: DateTime.parse(j['date']));
}

class Goal {
  final String id;
  final String name;
  final String emoji;
  final int target;
  int saved;
  Goal({required this.id, required this.name, this.emoji = '🎯', required this.target, this.saved = 0});

  double get progress => target == 0 ? 0 : (saved / target).clamp(0.0, 1.0);
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'emoji': emoji, 'target': target, 'saved': saved};
  factory Goal.fromJson(Map<String, dynamic> j) => Goal(id: j['id'], name: j['name'], emoji: j['emoji'] ?? '🎯', target: j['target'], saved: j['saved']);
}
