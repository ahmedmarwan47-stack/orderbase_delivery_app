import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_tab_bar/liquid_tab_bar.dart';

void main() {
  group('LiquidTabActionStyle', () {
    test('light and dark defaults preserve selected marker fills', () {
      expect(LiquidTabActionStyle.light.selectedFill, const Color(0x55FFFFFF));
      expect(LiquidTabActionStyle.dark.selectedFill, const Color(0x38FFFFFF));
    });

    test('copyWith, lerp, equality, hashCode and toString', () {
      const light = LiquidTabActionStyle.light;
      final custom = light.copyWith(selectedFill: const Color(0x33FF375F));
      expect(custom.selectedFill, const Color(0x33FF375F));
      expect(custom, isNot(equals(light)));
      expect(
        LiquidTabActionStyle.lerp(light, custom, 0.5).selectedFill,
        isNot(light.selectedFill),
      );
      expect(light.hashCode, LiquidTabActionStyle.light.hashCode);
      expect(light.toString(), contains('LiquidTabActionStyle'));
    });
  });

  group('LiquidDropletSurfaceStyle', () {
    test('canonical defaults preserve light and dark surface values', () {
      const light = LiquidDropletSurfaceStyle.light;
      expect(light.shadow.color, const Color(0x14000000));
      expect(light.shadow.blurRadius, 10);
      expect(light.shadow.offset, const Offset(0, 3));
      const dark = LiquidDropletSurfaceStyle.dark;
      expect(dark.shadow.color, const Color(0x59000000));
      expect(dark.shadow.blurRadius, 10);
      expect(dark.shadow.offset, const Offset(0, 3));
    });

    test('copyWith, lerp, equality and hashCode include BoxShadow', () {
      const a = LiquidDropletSurfaceStyle.light;
      final b = a.copyWith(
        shadow: const BoxShadow(
          color: Color(0xFF123456),
          blurRadius: 20,
          offset: Offset(2, 4),
        ),
      );
      expect(b.shadow.color, const Color(0xFF123456));
      expect(b.shadow.blurRadius, 20);
      expect(b.shadow.offset, const Offset(2, 4));
      expect(a, isNot(equals(b)));
      final halfway = LiquidDropletSurfaceStyle.lerp(a, b, 0.5);
      expect(halfway.shadow.blurRadius, 15);
      expect(a.hashCode, equals(LiquidDropletSurfaceStyle.light.hashCode));
      expect(a.toString(), contains('LiquidDropletSurfaceStyle'));
    });
  });

  group('LiquidBadgeStyle', () {
    test('defaults match specifications', () {
      const style = LiquidBadgeStyle();
      expect(style.size, 18.0);
      expect(style.dotSize, 8.0);
      expect(style.showBorder, isTrue);
      expect(style.borderWidth, 1.5);
      expect(style.color, isNull);
      expect(style.textColor, isNull);
      expect(style.borderColor, isNull);
      expect(style.textStyle, isNull);
      expect(style.offset, isNull);
      expect(style.padding, isNull);
      expect(style.borderRadius, isNull);
    });

    test('equality and hashCode', () {
      const s1 = LiquidBadgeStyle(
        color: Color(0xFF25D366),
        size: 20,
        showBorder: false,
      );
      final s2 = const LiquidBadgeStyle().copyWith(
        color: const Color(0xFF25D366),
        size: 20,
        showBorder: false,
      );
      final s3 = const LiquidBadgeStyle(
        color: Color(0xFF25D366),
        size: 20,
        showBorder: true,
      );

      expect(s1, equals(s2));
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1, isNot(equals(s3)));
    });

    test('copyWith updates all properties properly', () {
      const initial = LiquidBadgeStyle();
      final updated = initial.copyWith(
        color: const Color(0xFFFF0000),
        textColor: const Color(0xFF00FF00),
        textStyle: const TextStyle(fontSize: 12),
        size: 22,
        dotSize: 10,
        showBorder: false,
        borderColor: const Color(0xFF0000FF),
        borderWidth: 2.0,
        offset: const Offset(1, -1),
        padding: const EdgeInsets.all(4),
        borderRadius: BorderRadius.circular(6),
      );

      expect(updated.color, const Color(0xFFFF0000));
      expect(updated.textColor, const Color(0xFF00FF00));
      expect(updated.textStyle?.fontSize, 12);
      expect(updated.size, 22);
      expect(updated.dotSize, 10);
      expect(updated.showBorder, isFalse);
      expect(updated.borderColor, const Color(0xFF0000FF));
      expect(updated.borderWidth, 2.0);
      expect(updated.offset, const Offset(1, -1));
      expect(updated.padding, const EdgeInsets.all(4));
      expect(updated.borderRadius, BorderRadius.circular(6));
    });

    test('lerp interpolates correctly', () {
      const a = LiquidBadgeStyle(
        color: Color(0xFF000000),
        size: 10,
        dotSize: 4,
        showBorder: true,
        borderWidth: 1.0,
      );
      const b = LiquidBadgeStyle(
        color: Color(0xFFFFFFFF),
        size: 20,
        dotSize: 8,
        showBorder: false,
        borderWidth: 3.0,
      );

      final half = LiquidBadgeStyle.lerp(a, b, 0.5);
      expect(half, isNotNull);
      expect(half!.size, 15.0);
      expect(half.dotSize, 6.0);
      expect(half.borderWidth, 2.0);
      expect(half.showBorder, isFalse); // t >= 0.5 takes b

      expect(LiquidBadgeStyle.lerp(null, b, 0.5), equals(b));
      expect(LiquidBadgeStyle.lerp(a, null, 0.5), equals(a));
    });
  });

  group('GlassStyle', () {
    test('equality and hashCode', () {
      const style1 = GlassStyle.frosted;
      final style2 = GlassStyle.frosted.copyWith();
      final style3 = GlassStyle.frosted.copyWith(rim: 15);

      expect(style1, equals(style2));
      expect(style1.hashCode, equals(style2.hashCode));
      expect(style1, isNot(equals(style3)));
    });

    test('copyWith copies every parameter correctly', () {
      const initial = GlassStyle.frosted;
      final modified = initial.copyWith(
        rim: 20,
        curve: 1.5,
        depth: 8,
        dispersion: 0.25,
        blur: 5,
        saturation: 1.5,
        tint: const Color(0xFF00FF00),
        specular: 0.8,
        light: const Offset(0.1, 0.2),
        edgeDark: 0.1,
        shadow: 0.5,
        shadowBlur: 10,
        shadowOffset: const Offset(1, 2),
      );

      expect(modified.rim, 20);
      expect(modified.curve, 1.5);
      expect(modified.depth, 8);
      expect(modified.dispersion, 0.25);
      expect(modified.blur, 5);
      expect(modified.saturation, 1.5);
      expect(modified.tint, const Color(0xFF00FF00));
      expect(modified.specular, 0.8);
      expect(modified.light, const Offset(0.1, 0.2));
      expect(modified.edgeDark, 0.1);
      expect(modified.shadow, 0.5);
      expect(modified.shadowBlur, 10);
      expect(modified.shadowOffset, const Offset(1, 2));

      // No-op copyWith returns same instance
      expect(identical(initial, initial.copyWith()), isTrue);
    });

    test(
      'named presets have correct values and are compile-time constants',
      () {
        // frosted
        const frosted = GlassStyle.frosted;
        expect(frosted, equals(GlassStyle.frosted));
        expect(frosted.blur, 25.0);
        expect(frosted.specular, 0.32);
        expect(frosted.depth, 5.0);
        expect(frosted.dispersion, 0.08);
        expect(frosted.saturation, 1.25);
        expect(frosted.rim, 5.0);
        expect(frosted.shadow, 0.08);

        // prismaticCaustics
        const prismatic = GlassStyle.prismaticCaustics;
        expect(prismatic.blur, 15.0);
        expect(prismatic.specular, 0.65);
        expect(prismatic.depth, 8.0);
        expect(prismatic.dispersion, 0.32);
        expect(prismatic.saturation, 1.60);
        expect(prismatic.rim, 5.0);
        expect(prismatic.tint, const Color(0x75FFFFFF));
        expect(prismatic.light, const Offset(-0.55, -0.85));

        // clearCrystal
        const clear = GlassStyle.clearCrystal;
        expect(clear.blur, 0.0);
        expect(clear.specular, 0.50);
        expect(clear.depth, 6.0);
        expect(clear.dispersion, 0.15);
        expect(clear.saturation, 1.10);
        expect(clear.rim, 5.0);
        expect(clear.shadowBlur, 20.0);

        // deepRefraction
        const deep = GlassStyle.deepRefraction;
        expect(deep.blur, 40.0);
        expect(deep.specular, 0.40);
        expect(deep.depth, 14.0);
        expect(deep.dispersion, 0.20);
        expect(deep.saturation, 1.40);
        expect(deep.rim, 5.0);

        // All presets support copyWith
        expect(prismatic.copyWith(blur: 20).blur, 20.0);
        expect(clear.copyWith(specular: 0.9).specular, 0.9);
        expect(deep.copyWith(depth: 18).depth, 18.0);
      },
    );
  });

  group('LiquidTabBarTheme', () {
    test('equality and hashCode', () {
      const theme1 = LiquidTabBarTheme();
      final theme2 = const LiquidTabBarTheme().copyWith();
      final theme3 = const LiquidTabBarTheme().copyWith(
        activeColor: const Color(0xFF00FF00),
      );

      expect(theme1, equals(theme2));
      expect(theme1.hashCode, equals(theme2.hashCode));
      expect(theme1, isNot(equals(theme3)));
    });

    test('dark theme preset has appropriate dark styling', () {
      const darkTheme = LiquidTabBarTheme.dark();
      expect(darkTheme.activeColor, const Color(0xFF0A84FF));
      expect(darkTheme.barStyle.blurTint.a, lessThan(1.0));
      expect(darkTheme.barStyle.opaqueFill, const Color(0xFF1C1C1E));
    });

    testWidgets('adaptive theme selects dark preset under Brightness.dark', (
      WidgetTester tester,
    ) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );

      final theme = LiquidTabBarTheme.adaptive(capturedContext);
      expect(theme.activeColor, const Color(0xFF0A84FF));
      expect(theme.barStyle.opaqueFill, const Color(0xFF1C1C1E));
    });

    testWidgets(
      'adaptive theme follows app ThemeData brightness and primary color',
      (WidgetTester tester) async {
        late BuildContext capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF123456),
                brightness: Brightness.dark,
              ),
            ),
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox();
              },
            ),
          ),
        );

        final theme = LiquidTabBarTheme.adaptive(capturedContext);
        expect(
          theme.activeColor,
          Theme.of(capturedContext).colorScheme.primary,
        );
        expect(theme.barStyle.opaqueFill, const Color(0xFF1C1C1E));
      },
    );

    test('lerp interpolates between themes correctly', () {
      const light = LiquidTabBarTheme(activeColor: Color(0xFF000000));
      const dark = LiquidTabBarTheme(activeColor: Color(0xFFFFFFFF));

      final mid = LiquidTabBarTheme.lerp(light, dark, 0.5);
      expect(
        mid.activeColor,
        Color.lerp(light.activeColor, dark.activeColor, 0.5),
      );
    });
  });

  group('LiquidTabItem', () {
    test('supports custom iconSize and badge', () {
      final item = LiquidTabItem.icon(
        label: 'Inbox',
        icon: const IconData(0xe123, fontFamily: 'MaterialIcons'),
        badge: true,
        iconSize: 28,
      );

      expect(item.label, 'Inbox');
      expect(item.badge, isTrue);
      expect(item.hasBadge, isTrue);
    });

    test('supports badgeCount, customization, and formats large numbers', () {
      final item1 = LiquidTabItem.icon(
        label: 'Inbox',
        icon: const IconData(0xe123, fontFamily: 'MaterialIcons'),
        badge: true,
        badgeCount: 5,
        badgeStyle: const LiquidBadgeStyle(color: Color(0xFF25D366)),
      );
      expect(item1.effectiveBadgeText, '5');
      expect(item1.badgeStyle!.color, const Color(0xFF25D366));
      expect(item1.hasBadge, isTrue);

      final item2 = LiquidTabItem.icon(
        label: 'Inbox',
        icon: const IconData(0xe123, fontFamily: 'MaterialIcons'),
        badge: true,
        badgeCount: 120,
      );
      expect(item2.effectiveBadgeText, '99+');
      expect(item2.hasBadge, isTrue);

      final item3 = LiquidTabItem.icon(
        label: 'Inbox',
        icon: const IconData(0xe123, fontFamily: 'MaterialIcons'),
        badge: true,
        badgeText: 'VIP',
      );
      expect(item3.effectiveBadgeText, 'VIP');
      expect(item3.hasBadge, isTrue);
    });

    test('throws error if badge is false but badgeCount is provided', () {
      expect(
        () => LiquidTabItem.icon(
          label: 'Inbox',
          icon: const IconData(0xe123, fontFamily: 'MaterialIcons'),
          badge: false,
          badgeCount: 1,
        ),
        throwsAssertionError,
      );

      expect(
        () => LiquidTabItem.icon(
          label: 'Inbox',
          icon: const IconData(0xe123, fontFamily: 'MaterialIcons'),
          // badge omitted (defaults to false)
          badgeCount: 3,
        ),
        throwsAssertionError,
      );

      expect(
        () => LiquidTabItem.icon(
          label: 'Inbox',
          icon: Icons.inbox,
          badge: false,
          badgeCount: 5,
        ),
        throwsAssertionError,
      );
    });

    test(
      'supports compile-time const instantiation and const list literal',
      () {
        const single = LiquidTabItem.icon(
          icon: Icons.home_rounded,
          label: 'Home',
        );
        expect(single.label, 'Home');
        expect(single.icon, Icons.home_rounded);

        const items = [
          LiquidTabItem.icon(icon: Icons.home_rounded, label: 'Home'),
          LiquidTabItem.icon(icon: Icons.search_rounded, label: 'Search'),
          LiquidTabItem.icon(icon: Icons.person_rounded, label: 'Profile'),
        ];
        expect(items.length, 3);
        expect(items[0].label, 'Home');
        expect(items[1].label, 'Search');
        expect(items[2].label, 'Profile');
      },
    );

    test('default iconBuilder correctly applies icon, activeIcon, color and iconSize', () {
      const itemWithActive = LiquidTabItem.icon(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        iconSize: 26.0,
      );

      // Unselected -> inactive icon
      final unselectedWidget = itemWithActive.iconBuilder(
        const Color(0xFF8E8E93),
        false,
      );
      expect(unselectedWidget, isA<Icon>());
      final unselectedIcon = unselectedWidget as Icon;
      expect(unselectedIcon.icon, Icons.home_outlined);
      expect(unselectedIcon.color, const Color(0xFF8E8E93));
      expect(unselectedIcon.size, 26.0);

      // Selected -> activeIcon
      final selectedWidget = itemWithActive.iconBuilder(
        const Color(0xFF007AFF),
        true,
      );
      expect(selectedWidget, isA<Icon>());
      final selectedIcon = selectedWidget as Icon;
      expect(selectedIcon.icon, Icons.home);
      expect(selectedIcon.color, const Color(0xFF007AFF));
      expect(selectedIcon.size, 26.0);

      // Null activeIcon fallback -> uses icon when selected
      const itemWithoutActive = LiquidTabItem.icon(
        icon: Icons.search,
        label: 'Search',
      );
      final fallbackWidget = itemWithoutActive.iconBuilder(
        const Color(0xFF007AFF),
        true,
      );
      expect(fallbackWidget, isA<Icon>());
      final fallbackIcon = fallbackWidget as Icon;
      expect(fallbackIcon.icon, Icons.search);
      expect(fallbackIcon.color, const Color(0xFF007AFF));
      expect(fallbackIcon.size, 23.0); // default size
    });

    test('custom runtime iconBuilder overrides the default builder', () {
      final customItem = LiquidTabItem.icon(
        icon: Icons.star,
        label: 'Starred',
        iconBuilder: (color, selected) =>
            SizedBox(key: ValueKey('custom-$selected'), width: 30, height: 30),
      );

      final rendered = customItem.iconBuilder(Colors.amber, true);
      expect(rendered, isA<SizedBox>());
      expect((rendered as SizedBox).key, const ValueKey('custom-true'));
    });
  });
}
