import 'package:flutter/material.dart';
import 'package:liquid_tab_bar/droplet.dart';

import 'showcase_content.dart';

class StylingExample extends StatefulWidget {
  const StylingExample({super.key});
  @override
  State<StylingExample> createState() => _StylingExampleState();
}

class _StylingExampleState extends State<StylingExample> {
  int _selected = 0;
  bool _custom = false;
  int _preset = 2;
  @override
  Widget build(BuildContext context) => Scaffold(
        extendBody: true,
        appBar: AppBar(title: const Text('Styling & Refraction')),
        body: ShowcaseContent(
          selected: _selected,
          controls: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final custom in [false, true])
                    ChoiceChip(
                      label: Text(custom ? 'Custom' : 'Default'),
                      selected: _custom == custom,
                      onSelected: (_) => setState(() => _custom = custom),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (var i = 0; i < 4; i++)
                    ChoiceChip(
                      label: Text(['None', 'Subtle', 'Medium', 'Strong'][i]),
                      selected: _preset == i,
                      onSelected: (_) => setState(() => _preset = i),
                    ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: LiquidTabBar(
          shrinkOnScroll: false,
          selectedIndex: _selected,
          onSelected: (index) => setState(() => _selected = index),
          items: showcaseItems(),
          dropletRefraction: [
            const DropletRefractionStyle.none(),
            const DropletRefractionStyle.subtle(),
            const DropletRefractionStyle.medium(),
            const DropletRefractionStyle.strong(),
          ][_preset],
          theme: _custom
              ? LiquidTabBarTheme.adaptive(context).copyWith(
                  activeColor: const Color(0xFF9D572D),
                  barStyle: LiquidBarStyle.light.copyWith(
                    glass: GlassStyle.prismaticCaustics,
                    blurTint: const Color(0x45F4E4CA),
                  ),
                  dropletSurfaceStyle: LiquidDropletSurfaceStyle.light.copyWith(
                    borderColor: const Color(0x88C89D6C),
                    borderWidth: 1.0,
                  ),
                )
              : null,
        ),
      );
}
