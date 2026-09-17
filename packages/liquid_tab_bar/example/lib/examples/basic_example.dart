import 'package:flutter/material.dart';
import 'package:liquid_tab_bar/droplet.dart';

import 'showcase_content.dart';

class BasicExample extends StatefulWidget {
  const BasicExample({super.key});
  @override
  State<BasicExample> createState() => _BasicExampleState();
}

class _BasicExampleState extends State<BasicExample> {
  int _selected = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
        extendBody: true,
        appBar: AppBar(title: const Text('Basic')),
        body: ShowcaseContent(selected: _selected),
        bottomNavigationBar: LiquidTabBar(
          key: const ValueKey('basic-bar'),
          shrinkOnScroll: false,
          selectedIndex: _selected,
          onSelected: (index) => setState(() => _selected = index),
          items: showcaseItems(),
        ),
      );
}
