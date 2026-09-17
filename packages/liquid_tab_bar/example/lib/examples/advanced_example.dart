import 'package:flutter/material.dart';
import 'package:liquid_tab_bar/droplet.dart';

import 'showcase_content.dart';

class AdvancedExample extends StatefulWidget {
  const AdvancedExample({super.key});
  @override
  State<AdvancedExample> createState() => _AdvancedExampleState();
}

class _AdvancedExampleState extends State<AdvancedExample> {
  final _controller = LiquidTabBarController();
  int _selected = 0;
  bool _rtl = false;
  String _query = '';
  LiquidFoldedShape _shape = LiquidFoldedShape.circle;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Directionality(
        // A deliberately small RTL showcase, not a localized application.
        textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
        child: LiquidTabBarScaffold(
          resizeToAvoidBottomInset: true,
          appBar:
              AppBar(title: Text(_rtl ? 'البحث والطي' : 'Search & Folding')),
          body: ShowcaseContent(
            selected: _selected,
            rtl: _rtl,
            query: _query,
            controls: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: _controller.openSearch,
                      child: const Text('Search'),
                    ),
                    TextButton(
                      onPressed: _controller.minimize,
                      child: const Text('Fold'),
                    ),
                    TextButton(
                      onPressed: _controller.expand,
                      child: const Text('Expand'),
                    ),
                    FilterChip(
                      label: const Text('RTL / العربية'),
                      selected: _rtl,
                      onSelected: (value) => setState(() => _rtl = value),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final shape in LiquidFoldedShape.values)
                      ChoiceChip(
                        label: Text(
                          shape == LiquidFoldedShape.circle ? 'Circle' : 'Oval',
                        ),
                        selected: shape == _shape,
                        onSelected: (_) => setState(() => _shape = shape),
                      ),
                  ],
                ),
              ],
            ),
          ),
          tabBar: LiquidTabBar(
            key: const ValueKey('advanced-bar'),
            controller: _controller,
            shrinkOnScroll: true,
            selectedIndex: _selected,
            onSelected: (index) => setState(() => _selected = index),
            foldedShape: _shape,
            separateActionPlacement: LiquidTabActionPlacement.split,
            separateAction: LiquidTabAction.search(
              hintText: _rtl ? 'ابحث في المحتوى…' : 'Search content…',
              clearOnClose: true,
              onChanged: (query) => setState(() => _query = query),
              onSubmitted: (query) =>
                  ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(query.isEmpty ? 'Search' : query)),
              ),
            ),
            items: showcaseItems(rtl: _rtl),
          ),
        ),
      );
}
