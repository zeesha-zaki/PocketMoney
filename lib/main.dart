import 'package:flutter/material.dart';
import 'controllers/app_controller.dart';
import 'views/shell.dart';
import 'widgets/common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final c = AppController();
  await c.init();
  runApp(PocketVaultApp(c));
}

class PocketVaultApp extends StatelessWidget {
  final AppController c;
  const PocketVaultApp(this.c, {super.key});

  ThemeData _theme(bool dark) => ThemeData(
        useMaterial3: true,
        brightness: dark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: dark ? const Color(0xFF12131C) : const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(seedColor: mint, brightness: dark ? Brightness.dark : Brightness.light, primary: mint),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
        bottomSheetTheme: BottomSheetThemeData(backgroundColor: dark ? const Color(0xFF1E202E) : Colors.white),
        navigationBarTheme: NavigationBarThemeData(backgroundColor: dark ? const Color(0xFF1E202E) : Colors.white, indicatorColor: mint.withOpacity(.2)),
      );

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: c,
        builder: (_, __) => MaterialApp(
          title: 'PocketVault',
          debugShowCheckedModeBanner: false,
          theme: _theme(false),
          darkTheme: _theme(true),
          themeMode: c.dark ? ThemeMode.dark : ThemeMode.light,
          home: Shell(c),
        ),
      );
}
