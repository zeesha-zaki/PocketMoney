import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/app_controller.dart';
import '../widgets/common.dart';

class SettingsView extends StatelessWidget {
  final AppController c;
  const SettingsView(this.c, {super.key});

  @override
  Widget build(BuildContext context) {
    void snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Glass(
        padding: EdgeInsets.zero,
        child: Column(children: [
          SwitchListTile(title: const Text('Dark mode'), value: c.dark, activeColor: mint, onChanged: (_) => c.toggleDark()),
          ListTile(
            title: const Text('Weekly allowance'),
            trailing: Text(pkr(c.weekly), style: const TextStyle(color: mint, fontWeight: FontWeight.w800)),
            onTap: () {
              final t = TextEditingController(text: '${c.weekly}');
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Weekly allowance'),
                  content: TextField(controller: t, keyboardType: TextInputType.number, decoration: const InputDecoration(prefixText: 'Rs. ')),
                  actions: [FilledButton(onPressed: () { c.setWeekly(int.tryParse(t.text) ?? c.weekly); Navigator.pop(context); }, child: const Text('Save'))],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_rounded),
            title: const Text('Export backup (copy JSON)'),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: c.export()));
              snack('Backup copied to clipboard — paste it into a note or file.');
            },
          ),
          ListTile(
            leading: const Icon(Icons.download_rounded),
            title: const Text('Import backup (paste JSON)'),
            onTap: () {
              final t = TextEditingController();
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Import backup'),
                  content: TextField(controller: t, maxLines: 6, decoration: const InputDecoration(hintText: 'Paste JSON here', border: OutlineInputBorder())),
                  actions: [
                    FilledButton(
                      onPressed: () {
                        final ok = c.import(t.text);
                        Navigator.pop(context);
                        snack(ok ? 'Backup restored.' : 'Invalid backup data.');
                      },
                      child: const Text('Import'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: coral),
            title: const Text('Reset all data', style: TextStyle(color: coral)),
            onTap: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Erase everything?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  FilledButton(style: FilledButton.styleFrom(backgroundColor: coral), onPressed: () { c.reset(); Navigator.pop(context); }, child: const Text('Erase')),
                ],
              ),
            ),
          ),
        ]),
      ),
    ]);
  }
}
