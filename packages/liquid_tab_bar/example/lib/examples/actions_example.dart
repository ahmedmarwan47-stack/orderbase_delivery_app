import 'package:flutter/material.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';

import 'showcase_content.dart';

class ActionsExample extends StatefulWidget {
  const ActionsExample({super.key});
  @override
  State<ActionsExample> createState() => _ActionsExampleState();
}

class _ActionsExampleState extends State<ActionsExample> {
  int _selected = 0;
  bool _actionSelected = false;
  LiquidTabActionPlacement _placement = LiquidTabActionPlacement.together;
  @override
  Widget build(BuildContext context) => Scaffold(
        extendBody: true,
        appBar: AppBar(title: const Text('Actions')),
        body: ShowcaseContent(
          selected: _selected,
          controls: Wrap(
            spacing: 8,
            children: [
              for (final placement in LiquidTabActionPlacement.values)
                ChoiceChip(
                  label: Text(
                    placement == LiquidTabActionPlacement.together
                        ? 'Together'
                        : 'Split',
                  ),
                  selected: _placement == placement,
                  onSelected: (_) => setState(() => _placement = placement),
                ),
            ],
          ),
        ),
        bottomNavigationBar: LiquidTabBar(
          key: const ValueKey('actions-bar'),
          shrinkOnScroll: false,
          selectedIndex: _selected,
          onSelected: (index) => setState(() => _selected = index),
          items: showcaseItems(),
          separateActionPlacement: _placement,
          separateAction: LiquidTabAction.icon(
            icon: Icons.add_rounded,
            activeIcon: Icons.check_rounded,
            tooltip: 'Create',
            selected: _actionSelected,
            badge: true,
            badgeText: '1',
            onTap: () => setState(() => _actionSelected = !_actionSelected),
          ),
        ),
      );
}
