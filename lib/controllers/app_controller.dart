import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

enum Pace { safe, balanced, fast }

class AppController extends ChangeNotifier {
  late Box _box;
  List<Txn> txns = [];
  List<Goal> goals = [];
  int monthly = 20000;
  bool dark = true;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('pocketvault');
    final raw = _box.get('data');
    if (raw != null) _apply(jsonDecode(raw));
  }

  void _apply(Map j) {
    txns = (j['txns'] as List).map((e) => Txn.fromJson(Map<String, dynamic>.from(e))).toList();
    goals = (j['goals'] as List).map((e) => Goal.fromJson(Map<String, dynamic>.from(e))).toList();
    monthly = j['monthly'] ?? (j['weekly'] != null ? j['weekly'] * 4 : 20000);
    dark = j['dark'] ?? true;
    txns.sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, dynamic> toJson() => {'txns': txns.map((e) => e.toJson()).toList(), 'goals': goals.map((e) => e.toJson()).toList(), 'monthly': monthly, 'dark': dark};
  String export() => const JsonEncoder.withIndent('  ').convert(toJson());
  bool import(String s) {
    try {
      _apply(jsonDecode(s));
      _save();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _save() {
    _box.put('data', jsonEncode(toJson()));
    notifyListeners();
  }

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  // ---- derived ----
  int get balance => txns.fold(0, (s, t) => s + (t.isIncome ? t.amount : -t.amount));
  int get savedSoFar => goals.fold(0, (s, g) => s + g.saved);
  DateTime get monthStart {
    final n = DateTime.now();
    return DateTime(n.year, n.month, 1);
  }

  int get spentThisMonth => txns.where((t) => !t.isIncome && t.category != 'Savings' && !t.date.isBefore(monthStart)).fold(0, (s, t) => s + t.amount);
  int get monthLeft => monthly - spentThisMonth;

  Map<String, int> get spendByCategory {
    final m = <String, int>{};
    for (final t in txns.where((t) => !t.isIncome)) {
      m[t.category] = (m[t.category] ?? 0) + t.amount;
    }
    return m;
  }

  Pace get pace {
    final n = DateTime.now();
    final days = DateTime(n.year, n.month + 1, 0).day;
    final elapsed = (n.day - 0.5) / days;
    final r = monthly == 0 ? 2 : spentThisMonth / (monthly * elapsed);
    return r < 0.8 ? Pace.safe : (r < 1.1 ? Pace.balanced : Pace.fast);
  }

  /// % of monthly allowance the purchase would exceed (<=0 means safe)
  double overBudgetPct(int price) => monthly == 0 ? 100 : (price - monthLeft) / monthly * 100;

  /// Estimated days to finish goal using avg daily surplus over last 28 days.
  int? etaDays(Goal g) {
    final since = DateTime.now().subtract(const Duration(days: 28));
    final spent = txns.where((t) => !t.isIncome && t.category != 'Savings' && t.date.isAfter(since)).fold(0, (s, t) => s + t.amount);
    final surplusPerDay = monthly / 30 - spent / 28;
    if (surplusPerDay <= 0) return null;
    return ((g.target - g.saved) / surplusPerDay).ceil();
  }

  // ---- actions ----
  void addTxn({required int amount, required bool income, required String category, String note = '', required DateTime date}) {
    txns.insert(0, Txn(id: _id(), amount: amount, isIncome: income, category: category, note: note, date: date));
    txns.sort((a, b) => b.date.compareTo(a.date));
    _save();
  }

  void deleteTxn(String id) {
    txns.removeWhere((t) => t.id == id);
    _save();
  }

  void addGoal(String name, int target, String emoji) {
    goals.add(Goal(id: _id(), name: name, target: target, emoji: emoji));
    _save();
  }

  void deleteGoal(String id) {
    goals.removeWhere((g) => g.id == id);
    _save();
  }

  void deposit(Goal g, int amount) {
    if (amount <= 0 || amount > balance) return;
    g.saved += amount;
    addTxn(amount: amount, income: false, category: 'Savings', note: '→ ${g.name}', date: DateTime.now());
  }

  void setMonthly(int v) {
    monthly = v;
    _save();
  }

  void toggleDark() {
    dark = !dark;
    _save();
  }

  void reset() {
    txns = [];
    goals = [];
    _save();
  }
}
