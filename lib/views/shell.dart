import 'package:flutter/material.dart';
import '../controllers/app_controller.dart';
import '../widgets/add_sheet.dart';
import 'home_view.dart';
import 'goals_view.dart';
import 'insights_view.dart';
import 'settings_view.dart';

class Shell extends StatefulWidget {
  final AppController c;
  const Shell(this.c, {super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [HomeView(widget.c), GoalsView(widget.c), InsightsView(widget.c), SettingsView(widget.c)];
    return Scaffold(
      body: SafeArea(child: AnimatedSwitcher(duration: const Duration(milliseconds: 250), child: KeyedSubtree(key: ValueKey(i), child: pages[i]))),
      floatingActionButton: i == 0 || i == 2
          ? FloatingActionButton.extended(
              onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, builder: (_) => AddSheet(widget.c)),
              icon: const Icon(Icons.add),
              label: const Text('Log'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.savings_rounded), label: 'Piggy Bank'),
          NavigationDestination(icon: Icon(Icons.donut_large_rounded), label: 'Insights'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}
