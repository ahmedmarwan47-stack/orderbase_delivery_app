import 'package:flutter/material.dart';
// flutter_svg is used by the example app only.
// liquid_tab_bar receives this as a normal Flutter Widget.
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';

import 'showcase_content.dart';

enum SearchIconMode {
  monochromeSvg,
  sized28Svg,
  multicolorSvg,
  materialIcon,
}

enum TabPreset {
  fullShowcase,
  sizeComparison,
}

class CustomIconsExample extends StatefulWidget {
  const CustomIconsExample({super.key});

  @override
  State<CustomIconsExample> createState() => _CustomIconsExampleState();
}

class _CustomIconsExampleState extends State<CustomIconsExample> {
  final _controller = LiquidTabBarController();
  int _selected = 0;
  String _query = '';

  TabPreset _tabPreset = TabPreset.fullShowcase;
  SearchIconMode _searchMode = SearchIconMode.monochromeSvg;
  bool _useThemeColor = true;
  bool _hasActiveIcon = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<LiquidTabItem> _buildItems() {
    if (_tabPreset == TabPreset.sizeComparison) {
      // Demo 4: Custom icon sizes
      return [
        // Standard Material icon for comparison
        const LiquidTabItem.icon(
          label: 'Standard',
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          iconSize: 23,
        ),
        // Small custom SVG icon (16px)
        LiquidTabItem.custom(
          label: 'Small',
          // flutter_svg is used by the example app only.
          // liquid_tab_bar receives this as a normal Flutter Widget.
          icon: SvgPicture.asset('assets/icons/star.svg'),
          iconSize: 16,
          useThemeColor: _useThemeColor,
        ),
        // Medium custom SVG icon (23px)
        LiquidTabItem.custom(
          label: 'Medium',
          icon: SvgPicture.asset('assets/icons/heart.svg'),
          iconSize: 23,
          useThemeColor: _useThemeColor,
        ),
        // Large custom SVG icon (28px)
        LiquidTabItem.custom(
          label: 'Large',
          icon: SvgPicture.asset('assets/icons/explore.svg'),
          iconSize: 28,
          useThemeColor: _useThemeColor,
        ),
      ];
    }

    // Demo 1, 2, 3: Mixed standard and custom tabs
    return [
      // Standard icon item
      const LiquidTabItem.icon(
        label: 'Home',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
      ),

      // Custom monochrome SVG tab (Demo 1 & 2)
      LiquidTabItem.custom(
        label: 'Explore',
        // flutter_svg is used by the example app only.
        // liquid_tab_bar receives this as a normal Flutter Widget.
        icon: SvgPicture.asset('assets/icons/explore.svg'),
        useThemeColor: _useThemeColor,
      ),

      // Custom tab with distinct activeIcon (Demo 1)
      LiquidTabItem.custom(
        label: 'Profile',
        icon: SvgPicture.asset('assets/icons/profile_outline.svg'),
        activeIcon: _hasActiveIcon ? SvgPicture.asset('assets/icons/profile_filled.svg') : null,
        useThemeColor: _useThemeColor,
      ),

      // Theme-colored custom icon (Demo 2)
      LiquidTabItem.custom(
        label: 'Favorite',
        icon: SvgPicture.asset('assets/icons/heart.svg'),
        useThemeColor: true,
      ),

      // Multi-color SVG preserving original colors (Demo 3)
      LiquidTabItem.custom(
        label: 'Brand',
        icon: SvgPicture.asset('assets/icons/brand_multicolor.svg'),
        useThemeColor: false,
      ),
    ];
  }

  LiquidTabAction _buildSearchAction() {
    switch (_searchMode) {
      case SearchIconMode.monochromeSvg:
        // Demo 5: Custom monochrome Search icon
        return LiquidTabAction.search(
          tooltip: 'Search (SVG Theme)',
          hintText: 'Search with custom SVG…',
          // flutter_svg is used by the example app only.
          // liquid_tab_bar receives this as a normal Flutter Widget.
          customIcon: SvgPicture.asset('assets/icons/search.svg'),
          useThemeColor: true,
          clearOnClose: true,
          onChanged: (q) => setState(() => _query = q),
        );

      case SearchIconMode.sized28Svg:
        // Demo 6: Custom Search icon with 28px glyph size within 64x64 button
        return LiquidTabAction.search(
          tooltip: 'Search (28px Glyph)',
          hintText: 'Search with 28px glyph…',
          customIcon: SvgPicture.asset('assets/icons/search.svg'),
          iconSize: 28.0,
          useThemeColor: true,
          clearOnClose: true,
          onChanged: (q) => setState(() => _query = q),
        );

      case SearchIconMode.multicolorSvg:
        // Demo 7: Multi-color custom Search icon preserving original colors
        return LiquidTabAction.search(
          tooltip: 'Search (Multi-color)',
          hintText: 'Search with multi-color SVG…',
          customIcon: SvgPicture.asset('assets/icons/search_multicolor.svg'),
          useThemeColor: false,
          clearOnClose: true,
          onChanged: (q) => setState(() => _query = q),
        );

      case SearchIconMode.materialIcon:
        // Fallback: standard Material IconData
        return LiquidTabAction.search(
          tooltip: 'Search (Material)',
          hintText: 'Search with Material icon…',
          icon: Icons.search_rounded,
          clearOnClose: true,
          onChanged: (q) => setState(() => _query = q),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();
    if (_selected >= items.length) {
      _selected = items.length - 1;
    }

    return LiquidTabBarScaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Custom Icons Demo'),
      ),
      body: ShowcaseContent(
        selected: _selected,
        query: _query,
        itemLabels: items.map((e) => e.label).toList(),
        controls: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls header
            Text(
              'Interactive Controls',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Tab preset selector (Demo 1-3 vs Demo 4)
            Text(
              'Tab Preset',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Mixed & Features'),
                  selected: _tabPreset == TabPreset.fullShowcase,
                  onSelected: (_) => setState(() {
                    _tabPreset = TabPreset.fullShowcase;
                    _selected = 0;
                  }),
                ),
                ChoiceChip(
                  label: const Text('Icon Sizes (16/23/28px)'),
                  selected: _tabPreset == TabPreset.sizeComparison,
                  onSelected: (_) => setState(() {
                    _tabPreset = TabPreset.sizeComparison;
                    _selected = 0;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search Icon Variant (Demo 5, 6, 7)
            Text(
              'Search Icon Variant',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                ChoiceChip(
                  label: const Text('SVG (Theme)'),
                  selected: _searchMode == SearchIconMode.monochromeSvg,
                  onSelected: (_) => setState(() {
                    _searchMode = SearchIconMode.monochromeSvg;
                  }),
                ),
                ChoiceChip(
                  label: const Text('SVG 28px Glyph'),
                  selected: _searchMode == SearchIconMode.sized28Svg,
                  onSelected: (_) => setState(() {
                    _searchMode = SearchIconMode.sized28Svg;
                  }),
                ),
                ChoiceChip(
                  label: const Text('Multi-color (Original)'),
                  selected: _searchMode == SearchIconMode.multicolorSvg,
                  onSelected: (_) => setState(() {
                    _searchMode = SearchIconMode.multicolorSvg;
                  }),
                ),
                ChoiceChip(
                  label: const Text('Material Icon'),
                  selected: _searchMode == SearchIconMode.materialIcon,
                  onSelected: (_) => setState(() {
                    _searchMode = SearchIconMode.materialIcon;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Feature toggles
            Text(
              'Toggles',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                FilterChip(
                  label: Text('Theme Tinting: ${_useThemeColor ? "ON" : "OFF"}'),
                  selected: _useThemeColor,
                  onSelected: (val) => setState(() => _useThemeColor = val),
                ),
                FilterChip(
                  label: Text('Custom Active Icon: ${_hasActiveIcon ? "ON" : "OFF"}'),
                  selected: _hasActiveIcon,
                  onSelected: (val) => setState(() => _hasActiveIcon = val),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Search & fold action buttons
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.search_rounded, size: 16),
                  label: const Text('Open Search'),
                  onPressed: _controller.openSearch,
                ),
                ActionChip(
                  avatar: const Icon(Icons.unfold_less_rounded, size: 16),
                  label: const Text('Fold Bar'),
                  onPressed: _controller.minimize,
                ),
                ActionChip(
                  avatar: const Icon(Icons.unfold_more_rounded, size: 16),
                  label: const Text('Expand Bar'),
                  onPressed: _controller.expand,
                ),
              ],
            ),
          ],
        ),
      ),
      tabBar: LiquidTabBar(
        key: ValueKey('custom-icons-bar-$_tabPreset-$_searchMode'),
        controller: _controller,
        shrinkOnScroll: true,
        selectedIndex: _selected,
        onSelected: (index) => setState(() => _selected = index),
        separateActionPlacement: LiquidTabActionPlacement.split,
        separateAction: _buildSearchAction(),
        items: items,
      ),
    );
  }
}
