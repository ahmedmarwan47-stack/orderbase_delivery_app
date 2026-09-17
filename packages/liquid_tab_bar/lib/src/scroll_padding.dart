import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'bar.dart';

/// Inherited marker registered by [LiquidScrollPadding] and [SliverLiquidScrollPadding]
/// to inform the debug safety net that bottom scroll padding is being handled.
class LiquidScrollPaddingScope extends InheritedWidget {
  const LiquidScrollPaddingScope({
    super.key,
    required this.reservedHeight,
    required super.child,
  });

  /// The reserved bottom height currently allocated for the tab bar.
  final double reservedHeight;

  /// Retrieves the nearest [LiquidScrollPaddingScope], if any.
  static LiquidScrollPaddingScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LiquidScrollPaddingScope>();
  }

  @override
  bool updateShouldNotify(LiquidScrollPaddingScope oldWidget) =>
      reservedHeight != oldWidget.reservedHeight;
}

/// A zero-friction wrapper widget that automatically reserves bottom space for
/// a [LiquidTabBar] when used with `extendBody: true`.
///
/// When wrapping a scrollable (e.g. [ListView], [GridView], or [CustomScrollView]),
/// [LiquidScrollPadding] updates the [MediaQuery] for its descendants with the
/// correct bottom padding computed via [LiquidTabBar.reservedHeight].
///
/// ### Examples
///
/// Wrapping a scrollable:
/// ```dart
/// LiquidScrollPadding(
///   child: ListView.builder(...),
/// )
/// ```
///
/// Using a spacer at the end of a [Column] or [ListView]:
/// ```dart
/// Column(
///   children: [
///     ...content,
///     LiquidScrollPadding.spacer(context),
///   ],
/// )
/// ```
class LiquidScrollPadding extends StatelessWidget {
  const LiquidScrollPadding({
    super.key,
    required this.child,
    this.additionalPadding = 0.0,
    this.updateMediaQuery = true,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// Optional extra padding in logical pixels to add beyond [LiquidTabBar.reservedHeight].
  final double additionalPadding;

  /// Whether to update [MediaQueryData.padding] for descendants. Defaults to `true`.
  final bool updateMediaQuery;

  /// Convenient spacer widget to place at the bottom of a [Column] or list.
  static Widget spacer(BuildContext context, {double additionalPadding = 0.0}) {
    final height = LiquidTabBar.reservedHeight(
      context,
      additionalPadding: additionalPadding,
    );
    return LiquidScrollPaddingScope(
      reservedHeight: height,
      child: SizedBox(height: height),
    );
  }

  /// Convenient sliver spacer widget to place as the last sliver in a [CustomScrollView].
  static Widget sliver(BuildContext context, {double additionalPadding = 0.0}) {
    return SliverLiquidScrollPadding(additionalPadding: additionalPadding);
  }

  @override
  Widget build(BuildContext context) {
    final reserved = LiquidTabBar.reservedHeight(
      context,
      additionalPadding: additionalPadding,
    );

    Widget result = child;

    if (updateMediaQuery) {
      final mq = MediaQuery.of(context);
      final currentBottom = mq.padding.bottom;
      if (currentBottom < reserved) {
        result = MediaQuery(
          data: mq.copyWith(
            padding: mq.padding.copyWith(
              bottom: math.max(currentBottom, reserved),
            ),
          ),
          child: result,
        );
      }
    }

    return LiquidScrollPaddingScope(reservedHeight: reserved, child: result);
  }
}

/// A sliver that reserves bottom space for a [LiquidTabBar] when used inside
/// a [CustomScrollView] with `Scaffold(extendBody: true)`.
///
/// Place this as the final sliver in your [CustomScrollView.slivers] list:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     const SliverAppBar(...),
///     SliverList(...),
///     const SliverLiquidScrollPadding(),
///   ],
/// )
/// ```
class SliverLiquidScrollPadding extends StatelessWidget {
  const SliverLiquidScrollPadding({super.key, this.additionalPadding = 0.0});

  /// Optional extra padding in logical pixels to add beyond [LiquidTabBar.reservedHeight].
  final double additionalPadding;

  @override
  Widget build(BuildContext context) {
    final reserved = LiquidTabBar.reservedHeight(
      context,
      additionalPadding: additionalPadding,
    );
    return LiquidScrollPaddingScope(
      reservedHeight: reserved,
      child: SliverToBoxAdapter(child: SizedBox(height: reserved)),
    );
  }
}
