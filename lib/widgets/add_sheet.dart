import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../models/models.dart';
import 'common.dart';

class AddSheet extends StatefulWidget {
  final AppController c;
  const AddSheet(this.c, {super.key});
  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  bool income = false;
  String cat = categories.keys.first;
  DateTime date = DateTime.now();
  final amt = TextEditingController();
  final note = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final accent = income ? mint : coral;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          SegmentedButton<bool>(
            segments: const [ButtonSegment(value: false, label: Text('Expense')), ButtonSegment(value: true, label: Text('Allowance / Income'))],
            selected: {income},
            onSelectionChanged: (s) => setState(() => income = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: amt,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: accent),
            decoration: const InputDecoration(prefixText: 'Rs. ', border: InputBorder.none, hintText: '0'),
          ),
          if (!income)
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final e in categories.entries)
                ChoiceChip(label: Text('${e.value} ${e.key}'), selected: cat == e.key, selectedColor: coral.withOpacity(.25), onSelected: (_) => setState(() => cat = e.key)),
            ]),
          const SizedBox(height: 12),
          TextField(controller: note, decoration: const InputDecoration(hintText: 'Note or emoji (optional)', border: OutlineInputBorder())),
          const SizedBox(height: 8),
          Row(children: [
            TextButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text('${date.day}/${date.month}/${date.year}'),
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)));
                if (d != null) setState(() => date = d);
              },
            ),
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.black),
              onPressed: () {
                final v = int.tryParse(amt.text.trim()) ?? 0;
                if (v <= 0) return;
                widget.c.addTxn(amount: v, income: income, category: income ? incomeCategory : cat, note: note.text.trim(), date: date);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ]),
        ]),
      ),
    );
  }
}
