import 'package:flutter/material.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlass.load();
  LiquidTabBarController.shared.armGovernor();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'liquid_tab_bar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F5F3),
      ),
      home: const Shell(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _tab = 0;
  final _nav = LiquidTabBarController.shared;

  static const _titles = ['Home', 'Orders', 'Wallet', 'Me'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: _nav.handleScroll,
        child: IndexedStack(
          index: _tab,
          children: [
            for (var i = 0; i < _titles.length; i++)
              DemoPage(title: _titles[i], seed: i, controller: _nav),
          ],
        ),
      ),
      bottomNavigationBar: LiquidTabBar(
        items: [
          LiquidTabItem.icon(
            label: 'Home',
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),
          LiquidTabItem.icon(
            label: 'Orders',
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long,
            badge: true,
          ),
          LiquidTabItem.icon(
            label: 'Wallet',
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet,
          ),
          LiquidTabItem.icon(
            label: 'Me',
            icon: Icons.person_outline,
            activeIcon: Icons.person,
          ),
        ],
        selectedIndex: _tab,
        onSelected: (i) {
          _nav.expand();
          setState(() => _tab = i);
        },
        theme: const LiquidTabBarTheme(activeColor: Color(0xFFC81E1C)),
      ),
    );
  }
}

/// Colour bands, dark cards and rows — the kinds of page the glass has to
/// read over — plus a material picker.
class DemoPage extends StatelessWidget {
  const DemoPage({
    super.key,
    required this.title,
    required this.seed,
    required this.controller,
  });

  final String title;
  final int seed;
  final LiquidTabBarController controller;

  @override
  Widget build(BuildContext context) {
    final hues = [seed * 90.0, seed * 90.0 + 40, seed * 90.0 + 200];
    return ListView(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 16,
        20,
        LiquidTabBar.reservedHeight(context),
      ),
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        _MaterialPicker(controller: controller),
        const SizedBox(height: 16),
        for (final h in hues) ...[
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [
                  HSLColor.fromAHSL(1, h % 360, 0.7, 0.55).toColor(),
                  HSLColor.fromAHSL(1, (h + 30) % 360, 0.7, 0.45).toColor(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1919),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(20),
          child: const Text(
            'A dark card — the rim light and the frost read against this.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < 20; i++)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: HSLColor.fromAHSL(
                1,
                (i * 37) % 360,
                0.6,
                0.6,
              ).toColor(),
            ),
            title: Text('Row ${i + 1}'),
            subtitle:
                const Text('Scroll to fold the bar; scroll up to open it.'),
          ),
      ],
    );
  }
}

class _MaterialPicker extends StatelessWidget {
  const _MaterialPicker({required this.controller});

  final LiquidTabBarController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => SegmentedButton<LiquidTabBarMaterial>(
        segments: [
          for (final m in LiquidTabBarMaterial.values)
            ButtonSegment(value: m, label: Text(m.name)),
        ],
        selected: {controller.material},
        onSelectionChanged: (s) => controller.material = s.first,
      ),
    );
  }
}
