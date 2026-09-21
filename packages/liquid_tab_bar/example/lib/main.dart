import 'package:flutter/material.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';

import 'examples/actions_example.dart';
import 'examples/advanced_example.dart';
import 'examples/basic_example.dart';
import 'examples/custom_icons_example.dart';
import 'examples/styling_example.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlass.load();
  LiquidTabBarController.shared.armGovernor();
  runApp(const LiquidTabBarExampleApp());
}

class LiquidTabBarExampleApp extends StatefulWidget {
  const LiquidTabBarExampleApp({super.key});

  @override
  State<LiquidTabBarExampleApp> createState() => _LiquidTabBarExampleAppState();
}

class _LiquidTabBarExampleAppState extends State<LiquidTabBarExampleApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeMode == ThemeMode.dark;
    return MaterialApp(
      title: 'liquid_tab_bar Showcase',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0D11),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A84FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
      ),
      home: LauncherScreen(onToggleTheme: _toggleTheme, isDark: isDark),
    );
  }
}

class LauncherScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final bool isDark;

  const LauncherScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LiquidTabBar Examples'),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.navigation_rounded),
            title: const Text('Basic'),
            subtitle: const Text(
              'Standard bottom navigation with fluid droplet',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const BasicExample())),
          ),
          ListTile(
            leading: const Icon(Icons.palette_rounded),
            title: const Text('Styling'),
            subtitle: const Text(
              'Tints, blur, glass materials, and refraction',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const StylingExample())),
          ),
          ListTile(
            leading: const Icon(Icons.touch_app_rounded),
            title: const Text('Actions'),
            subtitle: const Text(
              'Together and Split separate action button modes',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ActionsExample())),
          ),
          ListTile(
            leading: const Icon(Icons.search_rounded),
            title: const Text('Advanced'),
            subtitle: const Text(
              'Search morphing, folding shapes, and RTL layout',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AdvancedExample())),
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome_rounded),
            title: const Text('Custom Icons Demo'),
            subtitle: const Text(
              'Custom SVG tabs, activeIcon, theme tinting, and search glyphs',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CustomIconsExample()),
            ),
          ),
        ],
      ),
    );
  }
}
