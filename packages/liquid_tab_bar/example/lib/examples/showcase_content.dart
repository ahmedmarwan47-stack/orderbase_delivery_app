import 'package:flutter/material.dart';
import 'package:liquid_tab_bar/droplet.dart';

List<LiquidTabItem> showcaseItems({bool rtl = false}) => [
      LiquidTabItem.icon(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: rtl ? 'الرئيسية' : 'Home',
      ),
      LiquidTabItem.icon(
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        label: rtl ? 'استكشاف' : 'Explore',
      ),
      LiquidTabItem.icon(
        icon: Icons.bookmark_outline_rounded,
        label: rtl ? 'المحفوظات' : 'Saved',
        badge: true,
        badgeCount: 4,
      ),
      LiquidTabItem.icon(
        icon: Icons.person_outline_rounded,
        label: rtl ? 'الحساب' : 'Profile',
      ),
    ];

/// Shared scrolling content provides text and edges behind the glass.
class ShowcaseContent extends StatelessWidget {
  const ShowcaseContent({
    super.key,
    this.selected = 0,
    this.rtl = false,
    this.query = '',
    this.controls,
  });
  final int selected;
  final bool rtl;
  final String query;
  final Widget? controls;

  @override
  Widget build(BuildContext context) {
    final titles = rtl
        ? ['ملاحظات', 'مستندات', 'صور', 'روابط']
        : ['Notes', 'Documents', 'Photos', 'Links'];
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showcaseItems(rtl: rtl)[selected].label,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  rtl
                      ? 'تنقّل بين علامات التبويب أو اسحب المؤشر.'
                      : 'Tap a destination or drag across the navigation.',
                ),
                if (controls != null) ...[
                  const SizedBox(height: 20),
                  controls!,
                ],
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: 24,
          itemBuilder: (context, index) {
            final title = titles[index % titles.length];
            if (query.isNotEmpty &&
                !title.toLowerCase().contains(query.toLowerCase())) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    leading: Icon(
                      [
                        Icons.description_outlined,
                        Icons.folder_outlined,
                        Icons.photo_outlined,
                        Icons.link,
                      ][index % 4],
                      color: [
                        const Color(0xFF526D59),
                        const Color(0xFF987256),
                        const Color(0xFF647887),
                        const Color(0xFF84738A),
                      ][index % 4],
                    ),
                    title: Text(title),
                    subtitle: Text(
                      rtl ? 'عنصر ${index + 1}' : 'Item ${index + 1}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 18),
                  ),
                  const Divider(height: 1),
                ],
              ),
            );
          },
        ),
        const SliverLiquidScrollPadding(),
      ],
    );
  }
}
