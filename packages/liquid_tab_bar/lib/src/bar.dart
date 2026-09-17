import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'controller.dart';
import 'glass.dart';
import 'scroll_padding.dart';
import 'theme.dart';

const _defaultBadgeColor = Color(0xFFE72B29);
const _defaultBadgeBorder = Color(0xFFFFFFFF);

// Renderer calibration retained from the former public droplet glass presets.
// These values are intentionally fixed so removing the inactive public style
// path does not alter the default light or dark output.
const _lightDropletGlass = GlassStyle(
  rim: 13,
  curve: 1.2,
  depth: 5,
  dispersion: 0,
  blur: 0,
  saturation: 1.15,
  tint: Color(0x55FFFFFF),
  specular: 0.28,
  light: Offset(-0.55, -0.85),
  edgeDark: 0.02,
);

const _darkDropletGlass = GlassStyle(
  rim: 13,
  curve: 1.2,
  depth: 4,
  dispersion: 0,
  blur: 0,
  saturation: 1.15,
  tint: Color(0x38FFFFFF),
  specular: 0.26,
  light: Offset(-0.55, -0.85),
  edgeDark: 0.02,
);

/// The floating tab bar — built to iOS 26's own numbers and manners, so an
/// app's bar and the system apps beside it behave as one.
///
/// **Geometry** was measured off the real iOS 26 bar (Files on an iPhone 17
/// Pro): 62pt tall and 21pt off the screen edge (64 and 20 here, on a 4px
/// grid), `n × 86 + 16` wide and capped at the screen less 2 × 20, the
/// selection lens a slot + 8 wide and the bar − 8 tall. Everything is in
/// absolute logical pixels — iOS does not scale its bar with the screen, so
/// neither does this.
///
/// **Material** comes in three tiers, picked by [LiquidTabBarController]:
/// *glass* (the refraction shader — lensing at the rim, a top-left light,
/// dispersion, frost, its own shadow), *blur* (backdrop blur + saturation
/// under the same tint, with the shader's rim light painted on, for devices
/// without Impeller or that the frame governor stepped down), and *opaque* —
/// a solid pill, no backdrop at all — which `MediaQuery.highContrast` forces
/// automatically or can be selected via [material].
///
/// **Manners**: scrolling down folds the bar into a pill holding only the
/// selected tab, scrolling up opens it; the lens slides between tabs on a
/// spring and stretches with its own speed; a finger can press and scrub
/// along the bar, the lens glued to it with a tick at every tab, and release
/// to choose. While it moves the lens disperses light like a soap bubble —
/// the glyphs and labels its rim crosses split into a warm copy and a cool
/// one, and a thin-film band lies along its edge. All of it jumps straight to
/// the end state under Reduce Motion.
///
/// **It only works because the page passes underneath it.** Put it in
/// `Scaffold(extendBody: true)`'s `bottomNavigationBar` slot and give the
/// scrollable [reservedHeight] of bottom padding. Prefer ONE bar over every
/// tab page (a shell with an `IndexedStack`), so [selectedIndex] changes on
/// this widget and the lens slides from the old tab to the new one.
///
/// [selectedIndex] is null on pages that are not a tab: nothing is
/// highlighted and there is nothing to fold into.
class LiquidTabBar extends StatefulWidget {
  const LiquidTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    this.onSelected,
    this.controller,
    this.theme,
    this.material,
    this.shrinkOnScroll = true,
    this.initiallyMinimized = false,
    this.foldedShape,
    this.haptic = HapticFeedback.selectionClick,
    this.separateAction,
    this.separateActionPlacement = LiquidTabActionPlacement.together,
    this.maxWidth,
    this.dropletRefraction,
    this.warnOnMissingExtendBodyPadding = true,
  }) : assert(items.length > 0, 'LiquidTabBar requires at least one tab item.'),
       assert(
         selectedIndex == null ||
             (selectedIndex >= 0 && selectedIndex < items.length),
         'selectedIndex must be null or within 0 and items.length - 1.',
       );

  final List<LiquidTabItem> items;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;

  /// Whether to warn in debug mode if [LiquidTabBar] is hosted in a [Scaffold] with
  /// `extendBody: true` and the scrollable content does not reserve bottom padding.
  ///
  /// Defaults to `true`. Has zero effect in release mode.
  final bool warnOnMissingExtendBodyPadding;

  /// Globally disable the debug-mode warning for `extendBody: true` without scroll padding.
  static bool disableExtendBodyWarning = false;

  /// Test hook to observe extendBody warning emissions.
  @visibleForTesting
  static void Function(String message)? onExtendBodyWarningForTesting;

  /// Fold state and material; [LiquidTabBarController.shared] when null.
  final LiquidTabBarController? controller;

  /// Theme styling; [LiquidTabBarTheme.adaptive] when null.
  final LiquidTabBarTheme? theme;

  /// Direct material tier selection without needing a controller.
  final LiquidTabBarMaterial? material;

  /// Whether the tab bar folds/shrinks into a pill when the user scrolls down.
  ///
  /// Defaults to `true`. When set to `false`, the bar always stays expanded.
  final bool shrinkOnScroll;

  /// Whether the bar starts folded into a pill. Defaults to `false`.
  final bool initiallyMinimized;

  /// The shape of the tab bar capsule when folded on scroll or minimized.
  ///
  /// When null (the default), the shape is inherited from [LiquidTabBarTheme.foldedShape]
  /// (which defaults to [LiquidFoldedShape.circle]).
  ///
  /// Set explicitly to [LiquidFoldedShape.circle] for an equilateral true circle,
  /// or [LiquidFoldedShape.oval] for an elongated stadium pill shape.
  final LiquidFoldedShape? foldedShape;

  /// Fired every time a scrubbing finger crosses into another tab. Null for
  /// silence.
  final VoidCallback? haptic;

  /// A separate circular action button (such as a search, filter, or create button)
  /// displayed alongside the tab bar capsule.
  final LiquidTabAction? separateAction;

  /// Placement of the separate action button: [LiquidTabActionPlacement.together] (default)
  /// or [LiquidTabActionPlacement.split].
  final LiquidTabActionPlacement separateActionPlacement;

  /// Optional maximum width of the expanded capsule. When null, the
  /// tab-count-based cap is used. The folded capsule keeps its fixed size.
  final double? maxWidth;

  /// Optional optical refraction configuration for the moving selection droplet.
  ///
  /// When null, defaults to [LiquidTabBarTheme.dropletRefraction].
  final DropletRefractionStyle? dropletRefraction;

  /// @internal
  /// @nodoc
  /// Internal helper used by [LiquidTabBarScaffold] to bind a scoped controller.
  @internal
  LiquidTabBar withController(LiquidTabBarController controller) {
    if (this.controller != null) return this;
    return LiquidTabBar(
      key: key,
      items: items,
      selectedIndex: selectedIndex,
      onSelected: onSelected,
      controller: controller,
      theme: theme,
      material: material,
      shrinkOnScroll: shrinkOnScroll,
      initiallyMinimized: initiallyMinimized,
      foldedShape: foldedShape,
      haptic: haptic,
      separateAction: separateAction,
      separateActionPlacement: separateActionPlacement,
      maxWidth: maxWidth,
      dropletRefraction: dropletRefraction,
      warnOnMissingExtendBodyPadding: warnOnMissingExtendBodyPadding,
    );
  }

  /// Feed a page's scroll notifications directly here (via a [NotificationListener])
  /// without needing to instantiate or manage a controller.
  ///
  /// ```dart
  /// NotificationListener<ScrollNotification>(
  ///   onNotification: LiquidTabBar.handleScroll,
  ///   child: ListView(...),
  /// )
  /// ```
  static bool handleScroll(
    ScrollNotification notification, {
    bool allowNested = false,
  }) => LiquidTabBarController.shared.handleScroll(
    notification,
    allowNested: allowNested,
  );

  /// Expand the tab bar open.
  static void expand() => LiquidTabBarController.shared.expand();

  /// Minimize / fold the tab bar into a pill.
  static void minimize() => LiquidTabBarController.shared.minimize();

  /// Whether the default shared tab bar is currently minimized/folded.
  static bool get isMinimized => LiquidTabBarController.shared.minimized;

  /// Opens search input mode programmatically on the default shared controller.
  ///
  /// Safe to call if search mode is already open.
  static void openSearch() => LiquidTabBarController.shared.openSearch();

  /// Closes search input mode programmatically on the default shared controller.
  ///
  /// If [clearText] is `true`, any text entered in the search field is cleared.
  /// Defaults to `false`, preserving the existing search query. Safe to call
  /// if search mode is already closed.
  static void closeSearch({bool clearText = false}) =>
      LiquidTabBarController.shared.closeSearch(clearText: clearText);

  /// Whether the default shared tab bar is currently morphed into search mode.
  static bool get isSearching => LiquidTabBarController.shared.isSearching;

  /// The bar's height when open (iOS: 62).
  static const double barHeight = 64;

  static const double _slotWidth = 86;
  static const double _barPadding = 8;
  static const double _sideMargin = 20; // iOS: 21
  static const double _gapNotch = 20; // iOS: 21 above the screen edge
  static const double _gapFlat = 12;
  static const double _lensOverhang = 8;
  static const double _lensInset = 4;
  static const double _pillSize = barHeight;
  static const double _pillOvalWidth = 84;
  static const double _glassPad = 24; // room for the shadow and rim sampling
  static const double _iconSize = 23;
  static const double _labelHeight = 17;
  static const double _iconLabelGap = 4;

  /// The speed at which the moving lens reaches its full visual motion state.
  static const double _fringeFullSpeed = 3;
  static const int _defaultFoldedDensityLevel = 2;

  /// How far a finger travels along the bar before a press is a scrub.
  static const double _scrubSlop = 6;

  /// @nodoc
  /// Computes the effective [GlassStyle] for the folded/expanded state.
  /// Scales blur down to fit compact capsule bounds and enhances contrast/shadow.
  @visibleForTesting
  static GlassStyle computeEffectiveGlassStyle({
    required LiquidTabBarTheme theme,
    required double foldProgress,
    int? densityLevel,
  }) {
    final fp = foldProgress.clamp(0.0, 1.0);
    if (fp <= 0.001) {
      return theme.barStyle.glass;
    }

    final isDark =
        theme.barStyle.blurTint.computeLuminance() < 0.2 ||
        theme.barStyle.opaqueFill.computeLuminance() < 0.5;
    final level = densityLevel ?? _defaultFoldedDensityLevel;

    final double targetShaderAlpha;
    final double glassShadowAlpha;
    final double blurScale;

    switch (level) {
      case 1: // Subtle
        targetShaderAlpha = isDark ? 0.30 : 0.55;
        glassShadowAlpha = isDark ? 0.30 : 0.10;
        blurScale = 0.75;
        break;
      case 3: // Dense
        targetShaderAlpha = isDark ? 0.55 : 0.75;
        glassShadowAlpha = isDark ? 0.60 : 0.22;
        blurScale = 0.55;
        break;
      case 2: // Balanced (default)
      default:
        targetShaderAlpha = isDark ? 0.42 : 0.65;
        glassShadowAlpha = isDark ? 0.45 : 0.15;
        blurScale = 0.65;
        break;
    }

    final effectiveBlur = ui.lerpDouble(
      theme.barStyle.glass.blur,
      theme.barStyle.glass.blur * blurScale,
      fp,
    )!;

    return theme.barStyle.glass.copyWith(
      tint: Color.lerp(
        theme.barStyle.glass.tint,
        theme.barStyle.glass.tint.withValues(
          alpha: math.max(theme.barStyle.glass.tint.a, targetShaderAlpha),
        ),
        fp,
      )!,
      blur: effectiveBlur,
      shadow: ui.lerpDouble(theme.barStyle.glass.shadow, glassShadowAlpha, fp)!,
    );
  }

  /// Where the glyph's centre sits when the bar is open.
  static const double _iconCenterY =
      (barHeight - (_iconSize + _iconLabelGap + _labelHeight)) / 2 +
      _iconSize / 2;

  /// Total bottom space in logical pixels to reserve for the tab bar.
  ///
  /// Accounts for [barHeight] (64), the floating gap ([_bottomGap]),
  /// 12pt of top breathing room, dynamic text scaling, and system bottom insets.
  ///
  /// Use this when padding your scrollable content manually, or prefer using
  /// [reservedPadding] or the zero-friction [LiquidScrollPadding] /
  /// [SliverLiquidScrollPadding] widgets.
  static double reservedHeight(
    BuildContext context, {
    double additionalPadding = 0.0,
  }) {
    final textScaler = MediaQuery.textScalerOf(context);
    final extraTextHeight = (textScaler.scale(12.0) - 12.0).clamp(0.0, 16.0);
    final base =
        barHeight +
        _bottomGap(context) +
        12.0 +
        extraTextHeight +
        additionalPadding;
    return math.max(base, MediaQuery.paddingOf(context).bottom);
  }

  /// Convenience helper returning an [EdgeInsets] with [reservedHeight] as bottom padding.
  ///
  /// ```dart
  /// ListView(
  ///   padding: LiquidTabBar.reservedPadding(context),
  ///   children: [...],
  /// )
  /// ```
  static EdgeInsets reservedPadding(
    BuildContext context, {
    double additionalPadding = 0.0,
  }) {
    return EdgeInsets.only(
      bottom: reservedHeight(context, additionalPadding: additionalPadding),
    );
  }

  /// How far the pill floats above the screen edge: iOS puts it 21pt up on a
  /// home-indicator phone — below the safe area, not above it.
  static double _bottomGap(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).bottom > 0 ? _gapNotch : _gapFlat;

  @override
  State<LiquidTabBar> createState() => _LiquidTabBarState();
}

class _LiquidTabBarState extends State<LiquidTabBar>
    with TickerProviderStateMixin {
  LiquidTabBarController get _nav =>
      widget.controller ?? LiquidTabBarController.shared;
  LiquidTabBarController? _listening;

  /// 0 = open, 1 = folded into the pill. Unbounded so the spring may
  /// overshoot a hair either side.
  late final AnimationController _fold = AnimationController.unbounded(
    vsync: this,
    value:
        (_nav.minimized || (widget.initiallyMinimized && widget.shrinkOnScroll))
        ? 1
        : 0,
  );

  /// The lens's position in visual slots (0 = the leftmost slot).
  late final AnimationController _lens = AnimationController.unbounded(
    vsync: this,
    value: 0,
  );

  bool _initializedLens = false;

  bool _pressed = false;
  bool _scrubbing = false;

  /// The active pointer ID currently controlling touch/scrub gestures.
  int? _activePointer;

  /// Where the finger landed; null once it has lifted.
  Offset? _down;

  /// The finger's speed along the bar while scrubbing, in slots per second,
  /// and the short relaxation that lets the stretch it drives ease off once
  /// the finger stops — a lens that stays stretched under a still finger
  /// reads as stuck.
  double _fingerVelocity = 0;
  Duration? _fingerAt;
  late final AnimationController _relax = AnimationController(
    vsync: this,
    duration: widget.theme?.relax ?? const Duration(milliseconds: 120),
    value: 1,
  );

  /// The visual slot under the finger while scrubbing — a tick every time it
  /// changes.
  int? _hover;

  Duration get _searchDuration =>
      _effectiveSearch?.animationDuration ?? const Duration(milliseconds: 350);

  late final AnimationController _searchAnim = AnimationController(
    vsync: this,
    duration: _searchDuration,
    value: 0.0,
  );
  late final TextEditingController _internalSearchController =
      TextEditingController();
  late final FocusNode _internalSearchFocusNode = FocusNode();
  final LayerLink _searchLayerLink = LayerLink();
  final OverlayPortalController _searchOverlayController =
      OverlayPortalController(debugLabel: 'liquid-tab-bar-search');
  bool _isSearching = false;
  bool _searchCloseRequested = false;
  AnimationStatusListener? _searchFocusListener;
  final ChromaticShaderCache _lensChromaticCache = ChromaticShaderCache();
  int _springGeneration = 0;

  LiquidTabBarSearch? get _effectiveSearch => _effectiveAction?.search;
  TextEditingController get _searchController =>
      _effectiveSearch?.controller ?? _internalSearchController;
  FocusNode get _searchFocusNode =>
      _effectiveSearch?.focusNode ?? _internalSearchFocusNode;

  void _prewarmSearchText() {
    try {
      final s = _effectiveSearch;
      final th = widget.theme ?? const LiquidTabBarTheme();
      final text = s?.hintText ?? 'Search';
      final baseStyle =
          s?.style ??
          TextStyle(
            color: th.activeColor,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          );
      final tp = TextPainter(
        text: TextSpan(text: text, style: baseStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.dispose();
    } catch (_) {}
  }

  void _setSearchMode(bool active, {bool clearText = false}) {
    if (_isSearching == active &&
        ((active && (_searchAnim.value - 1.0).abs() < 0.01) ||
            (!active && _searchAnim.value.abs() < 0.01))) {
      return;
    }
    setState(() => _isSearching = active);
    if (active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_searchOverlayController.isShowing) {
          _searchOverlayController.show();
        }
      });
    }
    if (!active) {
      _searchCloseRequested = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _searchOverlayController.isShowing) {
          _searchOverlayController.hide();
        }
      });
    }
    if (_nav.isSearching != active) {
      if (active) {
        _nav.openSearch();
      } else {
        _nav.closeSearch(clearText: clearText);
      }
    }
    _spring(_searchAnim, active ? 1.0 : 0.0);
    if (active) {
      if (_searchFocusListener != null) {
        _searchAnim.removeStatusListener(_searchFocusListener!);
        _searchFocusListener = null;
      }
      if (_effectiveSearch?.autofocus ?? true) {
        if (_reduced || _searchAnim.isCompleted || _searchAnim.value >= 0.95) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _isSearching) _searchFocusNode.requestFocus();
          });
        } else {
          _searchFocusListener = (status) {
            if (status == AnimationStatus.completed) {
              if (_searchFocusListener != null) {
                _searchAnim.removeStatusListener(_searchFocusListener!);
                _searchFocusListener = null;
              }
              if (mounted && _isSearching) {
                _searchFocusNode.requestFocus();
              }
            }
          };
          _searchAnim.addStatusListener(_searchFocusListener!);
        }
      }
    } else {
      if (_searchFocusListener != null) {
        _searchAnim.removeStatusListener(_searchFocusListener!);
        _searchFocusListener = null;
      }
      _searchFocusNode.unfocus();
      final shouldClear =
          clearText || (_effectiveSearch?.clearOnClose ?? false);
      if (shouldClear && _searchController.text.isNotEmpty) {
        _searchController.clear();
        _effectiveSearch?.onChanged?.call('');
      }
      _effectiveSearch?.onClose?.call();
    }
  }

  void _requestSearchClose() {
    if (!_isSearching) return;
    if (MediaQuery.viewInsetsOf(context).bottom > 1.0) {
      _searchCloseRequested = true;
      _searchFocusNode.unfocus();
      return;
    }
    _setSearchMode(false);
  }

  late Listenable _mergedListenable;

  void _updateListenable() {
    _mergedListenable = Listenable.merge([
      _nav,
      _fold,
      _lens,
      _relax,
      _searchAnim,
    ]);
  }

  @override
  void initState() {
    super.initState();
    _updateListenable();
    _listen();
    _prewarmSearchText();
    _nav.shrinkOnScroll = widget.shrinkOnScroll;
    if (widget.initiallyMinimized && widget.shrinkOnScroll && !_nav.minimized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _nav.minimize();
      });
    } else if (!widget.shrinkOnScroll && _nav.minimized) {
      _nav.expand();
    }
    if (!LiquidGlass.ready) {
      LiquidGlass.load()
          .then((_) {
            if (mounted) {
              _nav.checkGovernor();
              setState(() {});
            }
          })
          .catchError((_) {
            // Blur tier is used when shaders are unsupported or fail to load.
          });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedLens) {
      _initializedLens = true;
      final inner = _innerIndexFromOriginal(widget.selectedIndex);
      final v = _visualSlot(inner);
      if (v != null) {
        _lens.value = v.toDouble();
      }
    }
    if (kDebugMode &&
        !LiquidTabBar.disableExtendBodyWarning &&
        widget.warnOnMissingExtendBodyPadding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _checkExtendBodyPadding();
      });
    }
  }

  static final Set<int> _warnedRoutes = {};

  void _checkExtendBodyPadding() {
    if (!kDebugMode ||
        LiquidTabBar.disableExtendBodyWarning ||
        !widget.warnOnMissingExtendBodyPadding) {
      return;
    }

    final scaffold = context.findAncestorStateOfType<ScaffoldState>();
    if (scaffold == null || !scaffold.mounted || !scaffold.widget.extendBody) {
      return;
    }

    final routeKey = ModalRoute.of(context)?.hashCode ?? scaffold.hashCode;
    if (_warnedRoutes.contains(routeKey)) return;

    final reserved = LiquidTabBar.reservedHeight(context);
    bool hasScope = false;
    bool hasScrollable = false;
    bool hasSufficientPadding = false;

    final textDir = Directionality.maybeOf(context) ?? TextDirection.ltr;

    void inspectElement(Element el) {
      if (hasScope || hasSufficientPadding) return;

      if (el.widget is LiquidScrollPaddingScope) {
        hasScope = true;
        return;
      }

      if (el.widget is Scrollable) {
        hasScrollable = true;
      }

      final ro = el.renderObject;
      if (ro is RenderViewportBase) {
        hasScrollable = true;
        RenderSliver? sliver = ro.firstChild;
        while (sliver != null) {
          if (sliver is RenderSliverPadding) {
            if (sliver.padding.resolve(textDir).bottom >= reserved - 2.0) {
              hasSufficientPadding = true;
              return;
            }
          }
          final next = ro.childAfter(sliver);
          if (next == null) {
            if (sliver is RenderSliverSingleBoxAdapter) {
              final child = sliver.child;
              if (child != null &&
                  child.hasSize &&
                  child.size.height >= reserved - 2.0) {
                hasSufficientPadding = true;
                return;
              }
            }
          }
          sliver = next;
        }
      } else if (ro is RenderPadding) {
        if (ro.padding.resolve(textDir).bottom >= reserved - 2.0) {
          hasSufficientPadding = true;
          return;
        }
      }

      el.visitChildren(inspectElement);
    }

    if (scaffold.context is Element) {
      (scaffold.context as Element).visitChildren(inspectElement);
    }

    if (hasScope || !hasScrollable || hasSufficientPadding) return;

    _warnedRoutes.add(routeKey);

    final message =
        '\n'
        '================================================================================\n'
        '⚠️  [LiquidTabBar] extendBody: true detected without bottom scroll padding\n'
        '--------------------------------------------------------------------------------\n'
        'Your Scaffold has `extendBody: true`, allowing the scrollable body to extend\n'
        'behind the floating LiquidTabBar.\n'
        '\n'
        'However, the scrollable content does not appear to reserve bottom padding for\n'
        'the bar\'s resting position (${reserved.toStringAsFixed(1)}pt required).\n'
        '\n'
        'Why this matters:\n'
        '  LiquidTabBar uses real-time glass refraction and backdrop sampling. Content\n'
        '  resting directly behind the capsule will show through the frosted glass,\n'
        '  which can look like an accidental visual patch or seam.\n'
        '\n'
        'How to fix (choose one):\n'
        '  1. CustomScrollView: Add `const SliverLiquidScrollPadding()` as the last sliver.\n'
        '  2. ListView / Box:   Add `padding: LiquidTabBar.reservedPadding(context)`.\n'
        '  3. Drop-in wrapper:  Wrap your scroll view in `LiquidScrollPadding(child: ...)`. \n'
        '  4. Scaffold wrapper: Use `LiquidTabBarScaffold` instead of `Scaffold`.\n'
        '\n'
        'To silence this warning:\n'
        '  Set `warnOnMissingExtendBodyPadding: false` on LiquidTabBar or set\n'
        '  `LiquidTabBar.disableExtendBodyWarning = true`.\n'
        '================================================================================\n';

    LiquidTabBar.onExtendBodyWarningForTesting?.call(message);
    debugPrint(message);
  }

  void _listen() {
    final c = _nav;
    if (identical(c, _listening)) return;
    _listening?.removeListener(_onNav);
    c.addListener(_onNav);
    _listening = c;
    _updateListenable();
  }

  LiquidTabBarTheme get _theme =>
      widget.theme ?? LiquidTabBarTheme.adaptive(context);

  @override
  void didUpdateWidget(LiquidTabBar old) {
    super.didUpdateWidget(old);
    _listen();
    _relax.duration = _theme.relax;
    _searchAnim.duration = _searchDuration;
    _nav.shrinkOnScroll = widget.shrinkOnScroll;
    if (!widget.shrinkOnScroll && _nav.minimized) {
      _nav.expand();
    }
    if (old.selectedIndex != widget.selectedIndex && !_scrubbing) {
      final inner = _innerIndexFromOriginal(widget.selectedIndex);
      final v = _visualSlot(inner);
      if (v != null) _spring(_lens, v.toDouble());
    }
  }

  @override
  void dispose() {
    _listening?.removeListener(_onNav);
    if (_searchFocusListener != null) {
      _searchAnim.removeStatusListener(_searchFocusListener!);
      _searchFocusListener = null;
    }
    _fold.dispose();
    _lens.dispose();
    _relax.dispose();
    _searchAnim.dispose();
    _internalSearchController.dispose();
    _internalSearchFocusNode.dispose();
    super.dispose();
  }

  void _onNav() {
    _spring(_fold, _nav.minimized ? 1 : 0);
    if (_effectiveAction?.isSearch == true || _effectiveSearch != null) {
      if (_nav.isSearching != _isSearching) {
        _setSearchMode(_nav.isSearching, clearText: _nav.clearTextOnClose);
      }
    }
  }

  bool get _reduced => MediaQuery.disableAnimationsOf(context);

  /// Drive [c] to [target] on the theme's spring, carrying whatever velocity
  /// it has — an interrupted fold reverses mid-air instead of snapping.
  void _spring(AnimationController c, double target, {double? velocity}) {
    if (!mounted) return;
    if (_reduced) {
      c.value = target;
      return;
    }
    if (!c.isAnimating && (c.value - target).abs() < 0.0005) {
      c.value = target;
      return;
    }
    final generation = ++_springGeneration;
    c
        .animateWith(
          SpringSimulation(
            _theme.spring,
            c.value,
            target,
            velocity ?? c.velocity,
          ),
        )
        .then((_) {
          if (mounted && generation == _springGeneration) {
            c.value = target;
            setState(() {});
          }
        })
        .catchError((_) {});
  }

  List<LiquidTabItem> get _innerItems => widget.items;

  int? _innerIndexFromOriginal(int? original) {
    if (original == null) return null;
    if (original < 0 || original >= widget.items.length) return null;
    return original;
  }

  int _originalIndexFromInner(int inner) => inner;

  LiquidTabAction? get _effectiveAction => widget.separateAction;

  bool get _rtl => Directionality.of(context) == TextDirection.rtl;
  int get _n => _innerItems.length;

  /// A tab's slot counted from the left, whatever the reading direction.
  int? _visualSlot(int? i) {
    if (i == null || _n == 0) return null;
    final clamped = i.clamp(0, _n - 1);
    return _rtl ? _n - 1 - clamped : clamped;
  }

  int _indexAtVisual(int v) => _rtl ? _n - 1 - v : v;

  _Geometry _geometry(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final action = _effectiveAction;
    final hasAction = action != null;
    final defaultActionSize = LiquidTabBar.barHeight;
    final actionSize = action?.size ?? defaultActionSize;
    const actionGap = 12.0;

    if (_n == 0) {
      if (hasAction) {
        final actionX = _rtl
            ? LiquidTabBar._sideMargin
            : w - LiquidTabBar._sideMargin - actionSize;
        final actionY = (LiquidTabBar.barHeight - actionSize) / 2;
        return _Geometry(
          expanded: Rect.zero,
          pill: Rect.zero,
          slotW: 0,
          actionRect: Rect.fromLTWH(actionX, actionY, actionSize, actionSize),
        );
      }
      return const _Geometry(expanded: Rect.zero, pill: Rect.zero, slotW: 0);
    }

    // Adaptive horizontal layout:
    // Ensures that 4 tabs + 1 action button fit comfortably on any screen width
    // (from compact 360/375 screens to 390/440 Pro Max screens) without overflowing,
    // clipping, or hiding the separate action icon.
    final minSideMargin = hasAction ? 12.0 : LiquidTabBar._sideMargin;
    final maxUsableW = math.max(0.0, w - 2 * minSideMargin);

    final double availableForBar;
    if (hasAction) {
      availableForBar = math.max(0.0, maxUsableW - actionSize - actionGap);
    } else {
      availableForBar = maxUsableW;
    }

    // Proportional slot widths: 86 for 1-3 tabs, or adaptively scaled for 4+ tabs
    final idealMaxSlotW = (hasAction && _n >= 4)
        ? 76.0
        : LiquidTabBar._slotWidth;
    final maxBarW = _n * idealMaxSlotW + 2 * LiquidTabBar._barPadding;
    final configuredMaxW = widget.maxWidth ?? _theme.maxWidth;
    final widthLimit = configuredMaxW ?? maxBarW;
    final barW = math.min(widthLimit, availableForBar);
    final slotW = _n > 0 ? (barW - 2 * LiquidTabBar._barPadding) / _n : 0.0;

    double barLeft;
    Rect? actionRect;
    Rect? searchCollapsedTabRect;
    Rect? searchExpandedRect;

    if (hasAction) {
      final actionY = (LiquidTabBar.barHeight - actionSize) / 2;
      final totalGroupW = barW + actionGap + actionSize;

      final isTogether =
          widget.separateActionPlacement == LiquidTabActionPlacement.together;

      if (isTogether) {
        // Together placement: Tab bar capsule and separate circle are adjacent
        // and centered together symmetrically, matching the Apple Music design.
        final startX = math.max(minSideMargin, (w - totalGroupW) / 2);
        if (_rtl) {
          final actionLeft = startX;
          barLeft = startX + actionSize + actionGap;
          actionRect = Rect.fromLTWH(
            actionLeft,
            actionY,
            actionSize,
            actionSize,
          );
          searchCollapsedTabRect = Rect.fromLTWH(
            startX + totalGroupW - actionSize,
            actionY,
            actionSize,
            actionSize,
          );
          searchExpandedRect = Rect.fromLTWH(startX, actionY, barW, actionSize);
        } else {
          barLeft = startX;
          final actionLeft = startX + barW + actionGap;
          actionRect = Rect.fromLTWH(
            actionLeft,
            actionY,
            actionSize,
            actionSize,
          );
          searchCollapsedTabRect = Rect.fromLTWH(
            startX,
            actionY,
            actionSize,
            actionSize,
          );
          searchExpandedRect = Rect.fromLTWH(
            startX + actionSize + actionGap,
            actionY,
            barW,
            actionSize,
          );
        }
      } else {
        // Split placement: tab bar pinned to leading edge, action to trailing edge
        final sideMargin = (totalGroupW + 2 * LiquidTabBar._sideMargin <= w)
            ? LiquidTabBar._sideMargin
            : minSideMargin;
        final searchW = math.max(
          0.0,
          w - 2 * sideMargin - actionSize - actionGap,
        );
        if (_rtl) {
          barLeft = w - sideMargin - barW;
          final actionLeft = sideMargin;
          actionRect = Rect.fromLTWH(
            actionLeft,
            actionY,
            actionSize,
            actionSize,
          );
          searchCollapsedTabRect = Rect.fromLTWH(
            w - sideMargin - actionSize,
            actionY,
            actionSize,
            actionSize,
          );
          searchExpandedRect = Rect.fromLTWH(
            sideMargin,
            actionY,
            searchW,
            actionSize,
          );
        } else {
          barLeft = sideMargin;
          final actionLeft = w - sideMargin - actionSize;
          actionRect = Rect.fromLTWH(
            actionLeft,
            actionY,
            actionSize,
            actionSize,
          );
          searchCollapsedTabRect = Rect.fromLTWH(
            sideMargin,
            actionY,
            actionSize,
            actionSize,
          );
          searchExpandedRect = Rect.fromLTWH(
            sideMargin + actionSize + actionGap,
            actionY,
            searchW,
            actionSize,
          );
        }
      }
    } else {
      barLeft = (w - barW) / 2;
    }

    final expanded = Rect.fromLTWH(barLeft, 0, barW, LiquidTabBar.barHeight);
    final resolvedShape = widget.foldedShape ?? _theme.foldedShape;
    final pillW = resolvedShape == LiquidFoldedShape.oval
        ? LiquidTabBar._pillOvalWidth
        : LiquidTabBar._pillSize;
    final pillH = LiquidTabBar.barHeight;
    final pillLeft = _rtl ? expanded.right - pillW : expanded.left;
    final pill = Rect.fromLTWH(pillLeft, 0, pillW, pillH);
    return _Geometry(
      expanded: expanded,
      pill: pill,
      slotW: slotW,
      actionRect: actionRect,
      searchExpandedRect: searchExpandedRect,
      searchCollapsedTabRect: searchCollapsedTabRect,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_isSearching) {
          _setSearchMode(false);
        }
      },
      child: AnimatedBuilder(
        animation: _mergedListenable,
        builder: (context, _) => _bar(context),
      ),
    );
  }

  Widget _bar(BuildContext context) {
    final th = _theme;
    final g = _geometry(context);
    final gap = LiquidTabBar._bottomGap(context);
    final LiquidTabBarMaterial resolvedMaterial;
    if (MediaQuery.highContrastOf(context)) {
      resolvedMaterial = LiquidTabBarMaterial.opaque;
    } else if (widget.material != null) {
      resolvedMaterial = widget.material == LiquidTabBarMaterial.auto
          ? _nav.effectiveMaterial
          : widget.material!;
    } else {
      resolvedMaterial = _nav.effectiveMaterial;
    }
    final material =
        (resolvedMaterial == LiquidTabBarMaterial.glass &&
            !LiquidGlass.supported)
        ? LiquidTabBarMaterial.blur
        : resolvedMaterial;

    final s = _searchAnim.value.clamp(0.0, 1.0);
    final inner = _innerIndexFromOriginal(widget.selectedIndex);
    // A page with no tab selected or when shrinkOnScroll is false has nothing to fold into.
    // The spring is unbounded so it can carry velocity, but layout and paint
    // geometry must remain between the expanded and folded frames.
    final t = (inner == null || !widget.shrinkOnScroll)
        ? 0.0
        : _fold.value.clamp(0.0, 1.0);
    final tt = t.clamp(0.0, 1.0);
    final baseRect = Rect.lerp(g.expanded, g.pill, t)!;
    final rect = (g.searchCollapsedTabRect != null && s > 0)
        ? Rect.lerp(baseRect, g.searchCollapsedTabRect!, s)!
        : baseRect;
    final radius = rect.height / 2;
    final pad = material == LiquidTabBarMaterial.glass
        ? LiquidTabBar._glassPad
        : 0.0;

    final action = _effectiveAction;
    final effectiveSearchRect =
        (g.searchExpandedRect != null && g.actionRect != null && s > 0)
        ? Rect.lerp(g.actionRect!, g.searchExpandedRect!, s)!
        : g.actionRect;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    if (_searchCloseRequested && keyboardInset <= 1.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            _searchCloseRequested &&
            MediaQuery.viewInsetsOf(context).bottom <= 1.0) {
          _setSearchMode(false);
        }
      });
    }
    final overlayActive = _isSearching;
    final totalHeight = LiquidTabBar.barHeight + gap;
    final renderSearchInBar = !overlayActive;

    final bar = RepaintBoundary(
      child: SizedBox(
        height: totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (_n > 0) ...[
              // The surface and its shadow — free to paint past the box.
              Positioned(
                left: rect.left - pad,
                top: rect.top - pad,
                width: rect.width + 2 * pad,
                height: rect.height + 2 * pad,
                child: IgnorePointer(
                  child: _surface(
                    material,
                    rect.size,
                    radius,
                    pad,
                    th,
                    foldProgress: tt,
                  ),
                ),
              ),
              // What sits on the glass.
              Positioned.fromRect(
                rect: rect,
                child: IgnorePointer(
                  child: _content(g, rect, t, s, material, th),
                ),
              ),
              Positioned.fromRect(
                rect: rect,
                child: s > 0.5
                    ? GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          widget.haptic?.call();
                          _requestSearchClose();
                          _nav.expand();
                        },
                        child: overlayActive
                            ? const SizedBox.expand()
                            : Semantics(
                                button: true,
                                label: 'Close search and show tabs',
                                child: const SizedBox.expand(),
                              ),
                      )
                    : _touch(g, rect, t),
              ),
            ],
            if (renderSearchInBar &&
                effectiveSearchRect != null &&
                action != null) ...[
              Positioned.fromRect(
                rect: effectiveSearchRect,
                child: _SeparateActionButton(
                  action: action,
                  material: material,
                  theme: th,
                  haptic: widget.haptic,
                  searchAnim: s,
                  search: _effectiveSearch,
                  searchController: _searchController,
                  searchFocusNode: _searchFocusNode,
                  onSearchOpen: () => _setSearchMode(true),
                  onSearchClose: _requestSearchClose,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final overlayGap = keyboardInset > 0 ? LiquidTabBar._gapFlat : gap;
    final keyboardShift = gap - overlayGap - keyboardInset;

    return OverlayPortal(
      controller: _searchOverlayController,
      overlayChildBuilder: (overlayContext) {
        if (effectiveSearchRect == null || action == null) {
          return const SizedBox.shrink();
        }
        final inset = MediaQuery.viewInsetsOf(overlayContext).bottom;
        final effectiveOverlayGap = inset > 0 ? LiquidTabBar._gapFlat : gap;
        final dy = gap - effectiveOverlayGap - inset;
        return CompositedTransformFollower(
          link: _searchLayerLink,
          showWhenUnlinked: false,
          offset: Offset(0, dy),
          child: SizedBox(
            width: MediaQuery.sizeOf(overlayContext).width,
            height: LiquidTabBar.barHeight + effectiveOverlayGap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fromRect(
                  rect: effectiveSearchRect,
                  child: _SeparateActionButton(
                    action: action,
                    material: material,
                    theme: th,
                    haptic: widget.haptic,
                    searchAnim: s,
                    search: _effectiveSearch,
                    searchController: _searchController,
                    searchFocusNode: _searchFocusNode,
                    onSearchOpen: () => _setSearchMode(true),
                    onSearchClose: _requestSearchClose,
                  ),
                ),
                // Keep the lens close target interactive while the expanded
                // search surface is composited above the stable bar.
                Positioned.fromRect(
                  rect: rect,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.haptic?.call();
                      _requestSearchClose();
                      _nav.expand();
                    },
                    child: Semantics(
                      button: true,
                      label: 'Close search and show tabs',
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: _searchLayerLink,
        child: keyboardInset > 0
            ? Transform.translate(offset: Offset(0, keyboardShift), child: bar)
            : bar,
      ),
    );
  }

  static Widget _surface(
    LiquidTabBarMaterial m,
    Size size,
    double radius,
    double pad,
    LiquidTabBarTheme th, {
    double foldProgress = 0.0,
  }) {
    final r = BorderRadius.circular(radius);
    final fp = foldProgress.clamp(0.0, 1.0);
    final isDark =
        th.barStyle.blurTint.computeLuminance() < 0.2 ||
        th.barStyle.opaqueFill.computeLuminance() < 0.5;

    // Density parameters based on foldedDensityLevel (1: Subtle, 2: Balanced, 3: Dense)
    final double targetTintAlpha;
    final double contactShadowAlpha;
    final double contactShadowBlur;
    final double contactShadowDy;
    final double targetEdgeAlpha;

    switch (LiquidTabBar._defaultFoldedDensityLevel) {
      case 1: // Subtle
        targetTintAlpha = isDark ? 0.32 : 0.45;
        contactShadowAlpha = isDark ? 0.22 : 0.08;
        contactShadowBlur = 6.0;
        contactShadowDy = 2.0;
        targetEdgeAlpha = isDark ? 0.24 : 0.33;
        break;
      case 3: // Dense
        targetTintAlpha = isDark ? 0.58 : 0.72;
        contactShadowAlpha = isDark ? 0.45 : 0.18;
        contactShadowBlur = 10.0;
        contactShadowDy = 3.0;
        targetEdgeAlpha = isDark ? 0.38 : 0.50;
        break;
      case 2: // Balanced (default)
      default:
        targetTintAlpha = isDark ? 0.45 : 0.58;
        contactShadowAlpha = isDark ? 0.32 : 0.12;
        contactShadowBlur = 8.0;
        contactShadowDy = 2.5;
        targetEdgeAlpha = isDark ? 0.30 : 0.42;
        break;
    }

    final effectiveStyle = LiquidTabBar.computeEffectiveGlassStyle(
      theme: th,
      foldProgress: fp,
    );

    switch (m) {
      case LiquidTabBarMaterial.glass:
        if (!LiquidGlass.supported) {
          return _surface(
            LiquidTabBarMaterial.blur,
            size,
            radius,
            pad,
            th,
            foldProgress: foldProgress,
          );
        }
        return GlassSurface(
          size: size,
          radius: radius,
          pad: pad,
          style: effectiveStyle,
        );
      case LiquidTabBarMaterial.blur:
      case LiquidTabBarMaterial.auto:
        final effectiveTint = fp > 0.001
            ? Color.lerp(
                th.barStyle.blurTint,
                th.barStyle.blurTint.withValues(
                  alpha: math.max(th.barStyle.blurTint.a, targetTintAlpha),
                ),
                fp,
              )!
            : th.barStyle.blurTint;

        final effectiveEdge = fp > 0.001
            ? Color.lerp(
                th.barStyle.blurEdge,
                th.barStyle.blurEdge.withValues(
                  alpha: math.max(th.barStyle.blurEdge.a, targetEdgeAlpha),
                ),
                fp,
              )!
            : th.barStyle.blurEdge;

        final effectiveShadow = <BoxShadow>[
          ...th.barStyle.shadow,
          if (fp > 0.001)
            BoxShadow(
              color: Colors.black.withValues(alpha: contactShadowAlpha * fp),
              blurRadius: contactShadowBlur * fp,
              offset: Offset(0, contactShadowDy * fp),
            ),
        ];

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: r,
            boxShadow: effectiveShadow,
          ),
          child: ClipRRect(
            borderRadius: r,
            child: BackdropFilter(
              filter: _frostFilter(effectiveStyle),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: effectiveTint,
                  borderRadius: r,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        th.barStyle.blurSheenTop,
                        th.barStyle.blurSheenBottom,
                      ],
                    ),
                    borderRadius: r,
                    border: Border.all(color: effectiveEdge),
                  ),
                  child: CustomPaint(
                    painter: GlassLightPainter(
                      style: effectiveStyle,
                      radius: radius,
                      isDark: isDark,
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        );
      case LiquidTabBarMaterial.opaque:
        return DecoratedBox(
          decoration: BoxDecoration(
            color: th.barStyle.opaqueFill,
            borderRadius: r,
            border: Border.all(color: th.barStyle.opaqueEdge),
            boxShadow: th.barStyle.shadow,
          ),
          child: const SizedBox.expand(),
        );
    }
  }

  /// Saturation matrix about the Rec. 709 luminance axis.
  static List<double> _saturationMatrix(double s) {
    final inv = 1.0 - s;
    final r = inv * 0.2126;
    final g = inv * 0.7152;
    final b = inv * 0.0722;
    return <double>[
      r + s, g, b, 0, 0, //
      r, g + s, b, 0, 0, //
      r, g, b + s, 0, 0, //
      0, 0, 0, 1, 0, //
    ];
  }

  static final Map<_FrostKey, ui.ImageFilter> _frostCache = {};

  /// The blur tier's material: blur, then saturate — Apple's own order — at
  /// the frost and saturation the [GlassStyle] uses. [ui.TileMode.clamp] matters:
  /// without it the blur samples transparent black past the clip and the
  /// pill's edges bleed dark.
  static ui.ImageFilter _frostFilter(GlassStyle style) {
    // Quantize to avoid fractional float noise from live slider tuning
    final qBlur = (style.blur * 10.0).round() / 10.0;
    final qSat = (style.saturation * 100.0).round() / 100.0;
    final key = _FrostKey(qBlur, qSat);
    // LRU access promotion: remove and re-insert so key becomes most-recently-used
    final cached = _frostCache.remove(key);
    if (cached != null) {
      _frostCache[key] = cached;
      return cached;
    }

    final sigma = qBlur > 0 ? (qBlur * (25.0 / 24.0)) : 0.0;
    final filter = ui.ImageFilter.compose(
      outer: ColorFilter.matrix(_saturationMatrix(qSat)),
      inner: ui.ImageFilter.blur(
        sigmaX: sigma,
        sigmaY: sigma,
        tileMode: ui.TileMode.clamp,
      ),
    );
    // Bounded cache with LRU eviction (removes least-recently-used when cap reached)
    if (_frostCache.length >= 24) {
      _frostCache.remove(_frostCache.keys.first);
    }
    _frostCache[key] = filter;
    return filter;
  }

  /// The glyphs, the labels and the lens, laid out in the capsule's own
  /// coordinates. As the bar folds ([t] → 1) everything slides so the selected
  /// glyph lands in the pill's centre while the rest fades and shrinks away.
  Widget _content(
    _Geometry g,
    Rect rect,
    double t,
    double s,
    LiquidTabBarMaterial m,
    LiquidTabBarTheme th,
  ) {
    final tt = t.clamp(0.0, 1.0);
    final fade = (1 - tt) * (1 - tt) * (1 - s);
    final inner = _innerIndexFromOriginal(widget.selectedIndex);
    final activeV = _visualSlot(inner);
    final shift = activeV == null
        ? 0.0
        : t * (g.pill.center.dx - g.slotCenterX(activeV.toDouble()));
    final iconCy =
        ui.lerpDouble(LiquidTabBar._iconCenterY, g.pill.center.dy, t)! -
        rect.top;
    final labelTop =
        LiquidTabBar._iconCenterY +
        LiquidTabBar._iconSize / 2 +
        LiquidTabBar._iconLabelGap -
        rect.top;
    final children = <Widget>[];

    // The lens rides behind the glyphs as an elegant backdrop pill,
    // ensuring the active glyph and label remain 100% vibrant, crisp, and legible.
    final lensFade = fade * (1 - s);
    // Lens center X (in capsule-local coords) — used for icon magnification.
    double? lensCxLocal;
    double lensMotion = 0;
    double dropletMotionStrength = 0;
    double lensW = 0;
    double lensH = 0;
    double lensCy = 0;
    GlassStyle? lensStyle;
    if (activeV != null && lensFade > 0) {
      final v = _lens.value;
      final speed = _lensVelocity.abs();
      final stretch = (speed * 0.055).clamp(0.0, 0.45);
      final press = _pressed ? 1.06 : 1.0;
      final distFromSlot = (v - v.round()).abs();
      final scrubBetween = _scrubbing
          ? (distFromSlot * 2.0).clamp(0.0, 1.0)
          : 0.0;
      final motion = math.max(
        scrubBetween * 0.85,
        (speed / (LiquidTabBar._fringeFullSpeed * 0.5)).clamp(0.0, 1.0),
      );
      lensMotion = motion;

      // Optical content refraction is strictly MOTION-ONLY:
      // When resting on the selected tab (speed ~ 0 and distToTarget ~ 0),
      // dropletMotionStrength fades to 0.0 so the selected icon and label are 100% normal.
      // While moving across tabs, dropletMotionStrength smoothly rises to 1.0, bending content.
      // During the final part of the spring, it fades slightly earlier to prevent any
      // visible "late refraction" after the droplet looks stationary.
      final distToTarget = (v - activeV.toDouble()).abs();
      final vFactor = _smoothstep(0.18, 2.00, speed);
      final dFactor = _smoothstep(0.08, 0.45, distToTarget);
      final scrubFactor = _scrubbing
          ? math.max(
              _smoothstep(0.10, 1.20, speed),
              (distFromSlot * 2.0).clamp(0.0, 1.0),
            )
          : 0.0;
      dropletMotionStrength = math
          .max(scrubFactor, vFactor * dFactor)
          .clamp(0.0, 1.0);

      final isDark = th.barStyle.blurTint.computeLuminance() < 0.2;
      final style = isDark ? _darkDropletGlass : _lightDropletGlass;
      lensStyle = style;
      // Authentic droplet geometry: a sleek pill neatly contained inside the bar capsule.
      // At rest, height is (barHeight - 2 * _lensInset) = 56pt with 4pt margin top/bottom.
      // During motion, it stretches horizontally with velocity without ballooning outside the bar.
      final restingH = (LiquidTabBar.barHeight - 2 * LiquidTabBar._lensInset);
      final restingW = (g.slotW + LiquidTabBar._lensOverhang);
      final lh = restingH * (1 - stretch * 0.15) * press;
      final lw = restingW * (1 + stretch) * press;
      lensW = lw;
      lensH = lh;
      final normalCx = g.slotCenterX(v) - rect.left + shift;
      final cx = ui.lerpDouble(normalCx, rect.width / 2, s)!;
      lensCxLocal = cx;
      final cy = LiquidTabBar.barHeight / 2 - rect.top;
      lensCy = cy;
      final lensPad = m == LiquidTabBarMaterial.glass ? 6.0 : 0.0;
      children.add(
        Positioned(
          left: cx - lw / 2 - lensPad,
          top: cy - lh / 2 - lensPad,
          width: lw + 2 * lensPad,
          height: lh + 2 * lensPad,
          child: _lensSurface(
            m,
            Size(lw, lh),
            lensPad,
            style,
            lensFade,
            motion,
            _lensVelocity,
            th,
          ),
        ),
      );
    }

    final badgeSlots = <Widget>[];
    for (var i = 0; i < _n; i++) {
      final item = _innerItems[i];
      final originalIndex = _originalIndexFromInner(i);
      final v = _visualSlot(i)!;
      final selected = originalIndex == widget.selectedIndex;
      final normalCx = g.slotCenterX(v.toDouble()) - rect.left + shift;
      final cx = ui.lerpDouble(normalCx, rect.width / 2, s)!;
      final cy = ui.lerpDouble(iconCy, rect.height / 2, s)!;

      // Continuous liquid coverage: derives the tab's active visual state directly
      // from the liquid indicator's continuous position, speed, and geometry.
      final double coverage;
      if (activeV == null || lensFade <= 0) {
        coverage = 0.0;
      } else {
        final slotDist = (_lens.value - v).abs();
        if (slotDist >= 1.0) {
          coverage = 0.0;
        } else {
          final tSlot = (1.0 - slotDist).clamp(0.0, 1.0);
          final smoothT = 0.5 - 0.5 * math.cos(math.pi * tSlot);
          coverage = (smoothT * lensFade).clamp(0.0, 1.0);
        }
      }

      // Smooth color transition from inactiveColor to activeColor as the liquid
      // blob approaches, covers, and departs each tab.
      // When folded (tt > 0), the active tab's icon represents the selected
      // destination and must remain in activeColor rather than decaying to inactive grey.
      final effectiveCoverage = selected
          ? math.max(coverage, tt * (1 - s)).clamp(0.0, 1.0)
          : coverage;
      final color = Color.lerp(
        th.inactiveColor,
        th.activeColor,
        effectiveCoverage,
      )!;
      final isIconSelected = effectiveCoverage >= 0.5;

      final iconOnly = SizedBox(
        width: LiquidTabBar._iconSize,
        height: LiquidTabBar._iconSize,
        child: item.iconBuilder(color, isIconSelected),
      );
      Widget glyph = iconOnly;
      final badgeText = item.effectiveBadgeText;
      if (item.hasBadge) {
        final bs = item.badgeStyle ?? th.badgeStyle;
        final Widget badgeWidget;
        if (item.badgeWidget != null) {
          badgeWidget = item.badgeWidget!;
        } else if (badgeText != null && badgeText.isNotEmpty) {
          final isSingleDigit = badgeText.length == 1;
          final badgeSize = bs.size;
          final showBorder = bs.showBorder;
          final badgeBgColor = bs.color ?? _defaultBadgeColor;
          final badgeBorderCol = bs.borderColor ?? _defaultBadgeBorder;
          final badgeTextCol =
              bs.textColor ?? bs.textStyle?.color ?? Colors.white;
          final border = showBorder
              ? Border.all(color: badgeBorderCol, width: bs.borderWidth)
              : null;

          badgeWidget = Container(
            padding:
                bs.padding ??
                EdgeInsets.symmetric(
                  horizontal: isSingleDigit ? 0 : 5,
                  vertical: isSingleDigit ? 0 : 1,
                ),
            constraints: BoxConstraints(
              minWidth: badgeSize,
              minHeight: badgeSize,
            ),
            decoration: BoxDecoration(
              color: badgeBgColor,
              shape: isSingleDigit && bs.borderRadius == null
                  ? BoxShape.circle
                  : BoxShape.rectangle,
              borderRadius: isSingleDigit && bs.borderRadius == null
                  ? null
                  : (bs.borderRadius ?? BorderRadius.circular(badgeSize / 2)),
              border: border,
            ),
            alignment: Alignment.center,
            child: Text(
              badgeText,
              style:
                  (bs.textStyle ??
                          TextStyle(
                            fontSize: badgeSize * (10.5 / 18.0),
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ))
                      .copyWith(color: badgeTextCol),
            ),
          );
        } else {
          final dotSize = bs.dotSize;
          final showBorder = bs.showBorder;
          final badgeBgColor = bs.color ?? _defaultBadgeColor;
          final badgeBorderCol = bs.borderColor ?? _defaultBadgeBorder;
          final border = showBorder
              ? Border.all(color: badgeBorderCol, width: bs.borderWidth)
              : null;

          badgeWidget = Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: badgeBgColor,
              shape: BoxShape.circle,
              border: border,
            ),
          );
        }

        final defaultTop = badgeText != null ? -5.0 : -2.0;
        final defaultRight = badgeText != null ? -7.0 : -2.0;
        final posTop = bs.offset != null
            ? defaultTop + bs.offset!.dy
            : defaultTop;
        final posRight = bs.offset != null
            ? defaultRight - bs.offset!.dx
            : defaultRight;

        Widget badgeSlot = Positioned(
          top: posTop,
          right: posRight,
          child: badgeWidget,
        );
        Widget badgeStack = Stack(
          clipBehavior: Clip.none,
          children: [badgeSlot],
        );
        if (!selected && (fade < 1 || s > 0)) {
          final slotOpacity = (fade * (1 - s)).clamp(0.0, 1.0);
          badgeStack = Opacity(
            opacity: slotOpacity,
            child: Transform.scale(
              scale: (1 - 0.15 * tt) * (1 - 0.2 * s),
              child: badgeStack,
            ),
          );
        }
        badgeSlots.add(
          Positioned(
            left: cx - LiquidTabBar._iconSize / 2,
            top: cy - LiquidTabBar._iconSize / 2,
            width: LiquidTabBar._iconSize,
            height: LiquidTabBar._iconSize,
            child: IgnorePointer(child: badgeStack),
          ),
        );
      }
      Widget text = Text(
        item.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: th.labelStyle.copyWith(
          fontSize: th.labelStyle.fontSize ?? 12,
          fontWeight: isIconSelected ? FontWeight.w600 : FontWeight.w400,
          color: color,
        ),
      );
      // The selected glyph is the one thing that survives the fold and search collapse;
      // its label and every other tab go with the bar.
      if (fade < 1) text = Opacity(opacity: fade, child: text);

      Widget slot = Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: g.slotW / 2 - LiquidTabBar._iconSize / 2,
            top: cy - LiquidTabBar._iconSize / 2,
            width: LiquidTabBar._iconSize,
            height: LiquidTabBar._iconSize,
            child: glyph,
          ),
          Positioned(
            left: 0,
            top: labelTop,
            width: g.slotW,
            height: LiquidTabBar._labelHeight,
            child: Center(child: text),
          ),
        ],
      );
      if (!selected && (fade < 1 || s > 0)) {
        final slotOpacity = (fade * (1 - s)).clamp(0.0, 1.0);
        slot = Opacity(
          opacity: slotOpacity,
          child: Transform.scale(
            scale: (1 - 0.15 * tt) * (1 - 0.2 * s),
            child: slot,
          ),
        );
      }
      children.add(
        Positioned(
          left: cx - g.slotW / 2,
          top: 0,
          width: g.slotW,
          height: LiquidTabBar.barHeight,
          child: ExcludeSemantics(
            excluding: (!selected && fade < 0.05) || s > 0.5,
            child: Semantics(
              button: true,
              selected: selected,
              label: item.hasBadge
                  ? (badgeText != null
                        ? '${item.label}, $badgeText notifications'
                        : '${item.label}, unread notification')
                  : item.label,
              onTap: () {
                _nav.expand();
                widget.onSelected?.call(originalIndex);
              },
              child: ExcludeSemantics(child: slot),
            ),
          ),
        ),
      );
    }

    // Badges are tab content, so they must be painted before the optical lens
    // can sample them. Their construction and geometry remain unchanged.
    if (badgeSlots.isNotEmpty) {
      children.addAll(badgeSlots);
    }

    // --- Layer 2: Optical Droplet Glass Lens ---
    // Runs directly above the stable, stationary icons and labels.
    // The droplet shader samples the rendered icons and labels from the backdrop
    // and refracts them via Snell's law based on the curved glass lens normal.
    if (activeV != null &&
        lensFade > 0 &&
        lensCxLocal != null &&
        lensStyle != null &&
        m == LiquidTabBarMaterial.glass &&
        LiquidGlass.dropletSupported) {
      final effectiveRefraction =
          widget.dropletRefraction ?? th.dropletRefraction;
      children.add(
        Positioned(
          left: lensCxLocal - lensW / 2,
          top: lensCy - lensH / 2,
          width: lensW,
          height: lensH,
          child: IgnorePointer(
            child: DropletGlassSurface(
              size: Size(lensW, lensH),
              radius: lensH / 2,
              style: lensStyle,
              refractionStyle: effectiveRefraction,
              motionStrength: dropletMotionStrength,
            ),
          ),
        ),
      );
    }

    // The chromatic lens overlay rides in front of the glyphs as the glass top surface,
    // projecting the crisp diamond-cut specular rim, curved top/bottom meniscus highlights,
    // and electric-cyan / azure dispersion caustics over the magnified icons.
    if (activeV != null &&
        lensFade > 0 &&
        lensCxLocal != null &&
        lensStyle != null &&
        (m != LiquidTabBarMaterial.opaque || lensMotion > 0.01)) {
      final isDark = th.barStyle.blurTint.computeLuminance() < 0.2;
      children.add(
        Positioned(
          left: lensCxLocal - lensW / 2,
          top: lensCy - lensH / 2,
          width: lensW,
          height: lensH,
          child: IgnorePointer(
            child: CustomPaint(
              painter: LiquidDropletChromaticPainter(
                radius: lensH / 2,
                motion: lensMotion,
                velocity: _lensVelocity,
                isDark: isDark,
                fade: lensFade,
                cache: _lensChromaticCache,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
    }

    return Stack(clipBehavior: Clip.none, children: children);
  }

  Widget _lensSurface(
    LiquidTabBarMaterial m,
    Size size,
    double pad,
    GlassStyle style,
    double fade,
    double motion,
    double velocity,
    LiquidTabBarTheme th,
  ) {
    final r = BorderRadius.circular(size.height / 2);
    final surface = th.dropletSurfaceStyle;

    final BoxDecoration decoration;
    if (m == LiquidTabBarMaterial.opaque) {
      // Always render flat neutral gray pill so it tracks position in visual
      // lockstep with the icon/label color change (no lag from motion settlement).
      decoration = BoxDecoration(
        color: surface.opaqueFill.withValues(
          alpha: surface.opaqueFill.a * fade,
        ),
        borderRadius: r,
      );
    } else {
      decoration = BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: surface.shadow.color.withValues(
              alpha: surface.shadow.color.a * fade,
            ),
            blurRadius: surface.shadow.blurRadius,
            offset: surface.shadow.offset,
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            surface.gradientTop.withValues(alpha: surface.gradientTop.a * fade),
            surface.gradientBottom.withValues(
              alpha: surface.gradientBottom.a * fade,
            ),
          ],
        ),
        border: Border.all(
          color: surface.borderColor.withValues(
            alpha: surface.borderColor.a * fade,
          ),
          width: surface.borderWidth,
        ),
      );
    }

    final dropletBody = Positioned(
      left: pad,
      top: pad,
      width: size.width,
      height: size.height,
      child: DecoratedBox(
        decoration: decoration,
        child: const SizedBox.expand(),
      ),
    );

    return Stack(clipBehavior: Clip.none, children: [dropletBody]);
  }

  /// Touch, over the whole capsule — raw pointer events, not a gesture
  /// recognizer: a recognizer waits out the touch slop (18pt of travel)
  /// before it calls a drag a drag, and that wait is a beat where the lens
  /// sits still under a finger already moving. The bar sits in the
  /// Scaffold's own slot, never inside a scrollable, so there is no arena to
  /// be polite in.
  ///
  /// A press is a **tap** until the finger has travelled [_scrubSlop]: down
  /// swells the lens, up chooses the tab under it and the lens springs there
  /// from wherever it is. Past the slop it is a **scrub**: the lens glues to
  /// the finger from that point on, and release chooses the tab under it
  /// carrying the finger's speed. The slop is a third of a recognizer's — a
  /// real scrub crosses it inside a frame — but it is there: without it the
  /// pixel of wobble in a tap (every mouse click has one) teleports the lens
  /// to the pointer and parks it there until release. A finger that wanders
  /// far off the bar is a cancel; folded, up opens the bar.
  Widget _touch(_Geometry g, Rect rect, double t) {
    final folded = t > 0.5;
    final listener = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (e) {
        if (_activePointer != null) return;
        _activePointer = e.pointer;
        if (folded) return;
        _down = e.localPosition;
        _scrubbing = false;
        _fingerVelocity = 0;
        _fingerAt = null;
        _hover = _visualAt(g, rect, e.localPosition.dx);
        setState(() => _pressed = true);
      },
      onPointerMove: (e) {
        if (folded || _down == null || e.pointer != _activePointer) return;
        if (!_scrubbing) {
          if ((e.localPosition.dx - _down!.dx).abs() <
              LiquidTabBar._scrubSlop) {
            return;
          }
          _scrubbing = true;
          _fingerAt = e.timeStamp;
        }
        _follow(g, rect, e.localPosition.dx, e.timeStamp);
      },
      onPointerUp: (e) {
        if (e.pointer != _activePointer) return;
        _activePointer = null;
        if (folded) {
          _nav.expand();
          return;
        }
        if (_down == null) return;
        _down = null;
        final dy = e.localPosition.dy;
        if (dy < -rect.height || dy > 2 * rect.height) {
          _scrubbing = false;
          _cancel();
          return;
        }
        if (_scrubbing) {
          final carried = _lensVelocity;
          _scrubbing = false;
          _choose(
            _hover ?? _visualAt(g, rect, e.localPosition.dx),
            velocity: carried,
          );
        } else {
          _choose(_visualAt(g, rect, e.localPosition.dx));
        }
        _release();
      },
      onPointerCancel: (e) {
        if (e.pointer != _activePointer) return;
        _activePointer = null;
        if (_down == null) return;
        _down = null;
        _scrubbing = false;
        _cancel();
      },
    );

    if (folded) {
      return Semantics(
        button: true,
        label: 'Expand navigation bar',
        onTap: () => _nav.expand(),
        child: listener,
      );
    }

    return listener;
  }

  /// The finger left without choosing: the lens goes home.
  void _cancel() {
    _activePointer = null;
    final v = _visualSlot(widget.selectedIndex);
    if (v != null) _spring(_lens, v.toDouble());
    _release();
  }

  double _slotsFrom(_Geometry g, Rect rect, double localX) {
    if (g.slotW <= 0) return 0;
    return (localX + rect.left - g.expanded.left - LiquidTabBar._barPadding) /
        g.slotW;
  }

  int _visualAt(_Geometry g, Rect rect, double localX) {
    if (_n <= 0) return 0;
    return _slotsFrom(g, rect, localX).floor().clamp(0, _n - 1);
  }

  /// The lens under a scrubbing finger is glued to it — no spring, however
  /// stiff: a spring restarted on every pointer event trails the finger by
  /// its own settle time, and that trail reads as lag. The liquid feel comes
  /// from the stretch instead, driven by the finger's measured speed and
  /// relaxed over the theme's [LiquidTabBarTheme.relax] once it stops; the
  /// release carries that speed into the settling spring so a flick lands
  /// like a flick.
  void _follow(_Geometry g, Rect rect, double localX, Duration timeStamp) {
    final v = _visualAt(g, rect, localX);
    if (v != _hover) {
      _hover = v;
      widget.haptic?.call();
    }
    final target = (_slotsFrom(g, rect, localX) - 0.5).clamp(-0.15, _n - 0.85);
    final at = _fingerAt;
    if (at != null) {
      final dtMicros = (timeStamp - at).inMicroseconds;
      if (dtMicros >= 4000) {
        final dt = dtMicros / 1e6;
        final sample = (target - _lens.value) / dt;
        _fingerVelocity = _fingerVelocity * 0.4 + sample * 0.6;
        _fingerAt = timeStamp;
      }
    } else {
      _fingerAt = timeStamp;
    }
    _lens.stop();
    _lens.value = target;
    if (_reduced) {
      _relax.value = 1;
    } else {
      _relax.forward(from: 0);
    }
  }

  /// What the stretch and the release spring read: the finger's speed while
  /// scrubbing (fading as [_relax] runs), the lens's own otherwise.
  double get _lensVelocity =>
      _scrubbing ? _fingerVelocity * (1 - _relax.value) : _lens.velocity;

  void _choose(int v, {double? velocity}) {
    _nav.expand();
    _spring(_lens, v.toDouble(), velocity: velocity);
    final originalIndex = _originalIndexFromInner(_indexAtVisual(v));
    widget.onSelected?.call(originalIndex);
  }

  void _release() {
    _activePointer = null;
    _hover = null;
    if (_pressed && mounted) setState(() => _pressed = false);
  }
}

/// Standard Hermite smoothstep interpolation: 0 below min, 1 above max, smooth S-curve between.
double _smoothstep(double min, double max, double x) {
  if (x <= min) return 0.0;
  if (x >= max) return 1.0;
  final t = (x - min) / (max - min);
  return t * t * (3.0 - 2.0 * t);
}

/// The bar's frame for one screen width: the open capsule, the folded pill,
/// the slot pitch between them, and search morph rects.
class _Geometry {
  const _Geometry({
    required this.expanded,
    required this.pill,
    required this.slotW,
    this.actionRect,
    this.searchExpandedRect,
    this.searchCollapsedTabRect,
  });

  final Rect expanded;
  final Rect pill;
  final double slotW;
  final Rect? actionRect;
  final Rect? searchExpandedRect;
  final Rect? searchCollapsedTabRect;

  /// Centre of visual slot [v] (fractional while the lens is in flight).
  double slotCenterX(double v) =>
      expanded.left + LiquidTabBar._barPadding + (v + 0.5) * slotW;
}

class _SeparateActionButton extends StatefulWidget {
  const _SeparateActionButton({
    required this.action,
    required this.material,
    required this.theme,
    required this.haptic,
    this.searchAnim = 0.0,
    this.search,
    this.searchController,
    this.searchFocusNode,
    this.onSearchOpen,
    this.onSearchClose,
  });

  final LiquidTabAction action;
  final LiquidTabBarMaterial material;
  final LiquidTabBarTheme theme;
  final VoidCallback? haptic;
  final double searchAnim;
  final LiquidTabBarSearch? search;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final VoidCallback? onSearchOpen;
  final VoidCallback? onSearchClose;

  @override
  State<_SeparateActionButton> createState() => _SeparateActionButtonState();
}

class _SeparateActionButtonState extends State<_SeparateActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final act = widget.action;
    final th = widget.theme;
    final searchAnim = widget.searchAnim;
    final isSearching = searchAnim > 0.01;

    return LayoutBuilder(
      builder: (context, constraints) {
        final currentWidth = constraints.maxWidth;
        final currentHeight = constraints.maxHeight;
        final size = Size(currentWidth, currentHeight);
        final radius = currentHeight / 2;
        final pad = widget.material == LiquidTabBarMaterial.glass
            ? LiquidTabBar._glassPad
            : 0.0;
        final color = act.selected
            ? (act.activeColor ?? th.activeColor)
            : (act.color ?? th.inactiveColor);

        Widget content;
        if (searchAnim < 0.15) {
          // Circular button with icon
          Widget glyph = SizedBox(
            width: LiquidTabBar._iconSize,
            height: LiquidTabBar._iconSize,
            child: Center(
              child: IconTheme.merge(
                data: IconThemeData(color: color, size: LiquidTabBar._iconSize),
                child: act.icon,
              ),
            ),
          );

          if (act.badge ||
              (act.badgeText != null && act.badgeText!.isNotEmpty)) {
            final actBs = act.badgeStyle ?? th.badgeStyle;
            final badgeText = act.badgeText;
            Widget badgeWidget;
            if (badgeText != null && badgeText.isNotEmpty) {
              final isSingleDigit = badgeText.length == 1;
              final badgeSize = actBs.size;
              final showBorder = actBs.showBorder;
              final badgeBgColor = actBs.color ?? _defaultBadgeColor;
              final badgeBorderCol = actBs.borderColor ?? _defaultBadgeBorder;
              final badgeTextCol =
                  actBs.textColor ??
                  actBs.textStyle?.color ??
                  const Color(0xFFFFFFFF);
              final border = showBorder
                  ? Border.all(color: badgeBorderCol, width: actBs.borderWidth)
                  : null;

              badgeWidget = Container(
                padding:
                    actBs.padding ??
                    EdgeInsets.symmetric(
                      horizontal: isSingleDigit ? 0 : 4,
                      vertical: isSingleDigit ? 0 : 1,
                    ),
                constraints: BoxConstraints(
                  minWidth: badgeSize,
                  minHeight: badgeSize,
                ),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  shape: isSingleDigit && actBs.borderRadius == null
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  borderRadius: isSingleDigit && actBs.borderRadius == null
                      ? null
                      : (actBs.borderRadius ??
                            BorderRadius.circular(badgeSize / 2)),
                  border: border,
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeText,
                  style:
                      (actBs.textStyle ??
                              TextStyle(
                                fontSize: badgeSize * (10.5 / 18.0),
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ))
                          .copyWith(color: badgeTextCol),
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              final dotSize = actBs.dotSize;
              final showBorder = actBs.showBorder;
              final badgeBgColor = actBs.color ?? _defaultBadgeColor;
              final badgeBorderCol = actBs.borderColor ?? _defaultBadgeBorder;
              final border = showBorder
                  ? Border.all(color: badgeBorderCol, width: actBs.borderWidth)
                  : null;

              badgeWidget = Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  shape: BoxShape.circle,
                  border: border,
                ),
              );
            }
            final defaultTop = -2.0;
            final defaultRight = badgeText != null && badgeText.isNotEmpty
                ? -8.0
                : -2.0;
            final posTop = actBs.offset != null
                ? defaultTop + actBs.offset!.dy
                : defaultTop;
            final posRight = actBs.offset != null
                ? defaultRight - actBs.offset!.dx
                : defaultRight;

            glyph = Stack(
              clipBehavior: Clip.none,
              children: [
                glyph,
                Positioned(top: posTop, right: posRight, child: badgeWidget),
              ],
            );
          }

          content = Center(child: glyph);

          if (act.selected) {
            content = Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(LiquidTabBar._lensInset),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: th.actionStyle.selectedFill,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                content,
              ],
            );
          }
        } else {
          // Expanded search input field
          final searchOpacity = ((searchAnim - 0.15) / 0.85).clamp(0.0, 1.0);
          content = TextFieldTapRegion(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: th.inactiveColor.withValues(alpha: searchOpacity),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widget.searchController,
                      focusNode: widget.searchFocusNode,
                      textInputAction:
                          widget.search?.textInputAction ??
                          TextInputAction.search,
                      onTapOutside: (event) {
                        widget.search?.onTapOutside?.call(event);
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      onChanged: (val) {
                        setState(() {});
                        widget.search?.onChanged?.call(val);
                      },
                      onSubmitted: widget.search?.onSubmitted,
                      style:
                          (widget.search?.style ??
                                  TextStyle(
                                    color: th.activeColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ))
                              .copyWith(
                                color:
                                    (widget.search?.style?.color ??
                                            th.activeColor)
                                        .withValues(alpha: searchOpacity),
                              ),
                      decoration: InputDecoration(
                        hintText: widget.search?.hintText,
                        hintStyle:
                            (widget.search?.hintStyle ??
                                    TextStyle(
                                      color: th.inactiveColor.withValues(
                                        alpha: 0.65,
                                      ),
                                      fontSize: 15,
                                    ))
                                .copyWith(
                                  color:
                                      (widget.search?.hintStyle?.color ??
                                              th.inactiveColor.withValues(
                                                alpha: 0.65,
                                              ))
                                          .withValues(alpha: searchOpacity),
                                ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      cursorColor: th.activeColor.withValues(
                        alpha: searchOpacity,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.haptic?.call();
                      widget.onSearchClose?.call();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        color: th.inactiveColor.withValues(
                          alpha: 0.6 * searchOpacity,
                        ),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        Widget buttonBody = Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -pad,
              top: -pad,
              width: size.width + 2 * pad,
              height: size.height + 2 * pad,
              child: IgnorePointer(
                child: _LiquidTabBarState._surface(
                  widget.material,
                  size,
                  radius,
                  pad,
                  th,
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: content,
              ),
            ),
          ],
        );

        if (!isSearching) {
          buttonBody = Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => setState(() => _pressed = true),
            onPointerUp: (_) {
              if (_pressed) {
                setState(() => _pressed = false);
                widget.haptic?.call();
                if (act.isSearch || widget.search != null) {
                  widget.onSearchOpen?.call();
                }
                act.onTap?.call();
              }
            },
            onPointerCancel: (_) {
              if (_pressed) setState(() => _pressed = false);
            },
            child: AnimatedScale(
              scale: _pressed ? 0.92 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              child: buttonBody,
            ),
          );
        }

        return Semantics(
          button: !isSearching,
          selected: act.selected,
          label: isSearching
              ? (widget.search?.hintText ?? 'Search field')
              : (act.tooltip ?? 'Action'),
          onTap: !isSearching
              ? () {
                  if (act.isSearch || widget.search != null) {
                    widget.onSearchOpen?.call();
                  }
                  act.onTap?.call();
                }
              : null,
          child: buttonBody,
        );
      },
    );
  }
}

class _FrostKey {
  const _FrostKey(this.blur, this.saturation);
  final double blur;
  final double saturation;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FrostKey &&
          other.blur == blur &&
          other.saturation == saturation;

  @override
  int get hashCode => Object.hash(blur, saturation);
}
