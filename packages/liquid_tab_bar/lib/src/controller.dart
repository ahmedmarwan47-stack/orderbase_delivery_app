import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'glass.dart';
import 'test_overrides.dart';

/// How the bar's surface is drawn. [auto] picks the richest tier the device
/// can carry; the others pin one.
enum LiquidTabBarMaterial { auto, glass, blur, opaque }

/// Configuration for [LiquidTabBarController]'s performance frame governor.
///
/// If a device running the glass tier drops frames (raster time exceeds [rasterThresholdMs]),
/// the governor automatically downgrades to blur to maintain fluid scrolling.
class LiquidGovernorConfig {
  const LiquidGovernorConfig({
    this.warmupFrames = 90,
    this.windowFrames = 60,
    this.rasterThresholdMs = 24,
    this.maxSlowFrames = 12,
  });

  /// Number of initial frames ignored to allow GPU pipeline and asset warm-up.
  final int warmupFrames;

  /// Window of evaluated frames over which [maxSlowFrames] is measured.
  final int windowFrames;

  /// Raster duration in milliseconds after which a frame is considered slow.
  final int rasterThresholdMs;

  /// Maximum slow frames within [windowFrames] before stepping down to blur.
  final int maxSlowFrames;

  /// Duration representation of [rasterThresholdMs].
  Duration get rasterThreshold => Duration(milliseconds: rasterThresholdMs);
}

/// The bar's shared state: whether it is folded, and which material tier it
/// renders. Give one to every [LiquidTabBar] that should move together, and
/// feed it the pages' scroll notifications through [handleScroll].
///
/// **Fold follows the scroll**, the way iOS 26's bar does: scrolling down
/// through content folds the bar into a pill holding only the selected tab;
/// scrolling back up, reaching the top, or switching tabs opens it again. A
/// page too short to scroll under the bar never folds it.
///
/// **The tier is automatic**: glass (the refraction shader) wherever Impeller
/// runs it, blur where it does not, and — outside debug builds — a frame
/// governor that steps a struggling device down to blur for the session: a
/// full-width backdrop shader every scrolled frame is exactly what an old GPU
/// drops frames on, and a bar that stutters is worse than one that is flat.
class LiquidTabBarController extends ChangeNotifier {
  LiquidTabBarController({
    LiquidTabBarMaterial material = LiquidTabBarMaterial.auto,
    this.shrinkOnScroll = true,
    this.governorConfig = const LiquidGovernorConfig(),
  }) : _material = material;

  /// Configuration thresholds for the frame governor.
  final LiquidGovernorConfig governorConfig;

  /// The controller a [LiquidTabBar] uses when given none — one per app, so
  /// every bar folds and unfolds as one.
  static final LiquidTabBarController shared = LiquidTabBarController()
    .._registerTestDisarm();

  void _registerTestDisarm() {
    assert(() {
      LiquidControllerTestOverrides.disarmShared = () {
        _governorArmed = false;
        _unwatchFrames();
      };
      return true;
    }());
  }

  /// Whether [handleScroll] allows folding/shrinking the bar when scrolling down.
  ///
  /// Defaults to `true`. When set to `false`, scrolling down will not shrink the bar.
  bool shrinkOnScroll;

  bool _minimized = false;
  bool get minimized => _minimized;

  LiquidTabBarMaterial _material = LiquidTabBarMaterial.auto;
  LiquidTabBarMaterial get material => _material;
  set material(LiquidTabBarMaterial value) {
    if (_material == value) return;
    _material = value;
    if (_governorArmed) {
      _checkGovernor();
    } else {
      _unwatchFrames();
    }
    if (!_disposed) notifyListeners();
  }

  bool _degraded = false;

  /// Whether the governor stepped down the material tier due to frame drops.
  bool get isDegraded => _degraded;

  bool _disposed = false;

  /// Whether [dispose] has been called on this controller.
  bool get isDisposed => _disposed;

  /// The tier actually drawn — [LiquidTabBarMaterial.auto] resolved.
  LiquidTabBarMaterial get effectiveMaterial {
    if (_material == LiquidTabBarMaterial.glass) {
      return LiquidGlass.supported
          ? LiquidTabBarMaterial.glass
          : LiquidTabBarMaterial.blur;
    }
    if (_material != LiquidTabBarMaterial.auto) return _material;
    if (_degraded || !LiquidGlass.supported) return LiquidTabBarMaterial.blur;
    return LiquidTabBarMaterial.glass;
  }

  @override
  void dispose() {
    _disposed = true;
    _governorArmed = false;
    _lastHandledNotification = null;
    _unwatchFrames();
    super.dispose();
  }

  // ---- Scroll → fold --------------------------------------------------------

  /// How far the page must travel in one direction before the bar reacts —
  /// enough to ignore a thumb settling on the screen, little enough that the
  /// bar answers the first real scroll.
  static const double _threshold = 12;

  /// Pages that cannot scroll at least this far are left alone: folding the
  /// bar to reveal nothing is a twitch, not a behaviour.
  static const double _minScrollable = 120;

  double _travel = 0;
  bool? _down;
  ScrollNotification? _lastHandledNotification;

  /// Feed a page's scroll notifications here (a `NotificationListener` above
  /// the pages is the usual place). Always returns false so the notification
  /// keeps bubbling.
  ///
  /// By default, [allowNested] is false so only the primary scrollable
  /// (`n.depth == 0`) controls the bar. Set [allowNested] to true if an inner
  /// scrollable should also fold/expand the bar.
  bool handleScroll(ScrollNotification n, {bool allowNested = false}) {
    if (identical(n, _lastHandledNotification)) return false;
    _lastHandledNotification = n;
    if (!allowNested && n.depth != 0) return false;
    if (n.metrics.axis != Axis.vertical) return false;
    if (n is ScrollEndNotification) {
      _lastHandledNotification = null;
      return false;
    }
    if (n is ScrollUpdateNotification) {
      final m = n.metrics;
      if (m.pixels <= 0) {
        _travel = 0;
        expand();
        return false;
      }
      if (m.maxScrollExtent < _minScrollable) return false;
      final d = n.scrollDelta ?? 0;
      if (d == 0) return false;
      final down = d > 0;
      if (down != _down) {
        _down = down;
        _travel = 0;
      }
      _travel += d.abs();
      if (_travel < _threshold) return false;
      if (down) {
        if (shrinkOnScroll) minimize();
      } else {
        expand();
      }
    }
    return false;
  }

  void minimize() {
    if (_disposed || _minimized) return;
    _minimized = true;
    notifyListeners();
  }

  void expand() {
    _travel = 0;
    _down = null;
    if (_disposed || !_minimized) return;
    _minimized = false;
    notifyListeners();
  }

  // ---- Search morph ---------------------------------------------------------

  bool _searching = false;
  bool _clearTextOnClose = false;

  /// Whether the tab bar is currently morphed into an active search input field.
  ///
  /// This property reflects both user-driven search transitions (tapping the
  /// search action button on the bar) and programmatic transitions via
  /// [openSearch] and [closeSearch].
  bool get isSearching => _searching;

  /// Whether the most recent call to [closeSearch] requested clearing the search field.
  bool get clearTextOnClose => _clearTextOnClose;

  /// Morphs the bar into search input mode if a search action is present.
  ///
  /// If the bar is already in search mode or has been disposed, calling this
  /// method is an idempotent no-op.
  void openSearch() {
    if (_disposed || _searching) return;
    _searching = true;
    notifyListeners();
  }

  /// Closes the search morph and returns the bar to regular tab mode.
  ///
  /// If [clearText] is `true`, any query text currently entered in the search
  /// input field is cleared. Defaults to `false`, preserving the existing query
  /// text.
  ///
  /// If the bar is not in search mode or has been disposed, calling this method
  /// is an idempotent no-op.
  void closeSearch({bool clearText = false}) {
    if (_disposed || !_searching) return;
    _clearTextOnClose = clearText;
    _searching = false;
    notifyListeners();
  }

  // ---- Frame governor -------------------------------------------------------

  bool _governorArmed = false;

  /// Whether [armGovernor] has been called on this controller.
  bool get isGovernorArmed => _governorArmed;

  bool _watching = false;
  int _warm = 0;
  int _seen = 0;
  int _slow = 0;

  /// Start watching frame times if the glass tier is on. Idle frames are not
  /// reported, so the window only ever measures real rendering.
  void _watchFrames() {
    if (_disposed ||
        kDebugMode ||
        _watching ||
        effectiveMaterial != LiquidTabBarMaterial.glass) {
      return;
    }
    _watching = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  void _unwatchFrames() {
    if (!_watching) return;
    _watching = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
  }

  void _checkGovernor() {
    if (_disposed || !_governorArmed || _degraded) return;
    if (effectiveMaterial == LiquidTabBarMaterial.glass) {
      _watchFrames();
    } else if (!LiquidGlass.ready) {
      LiquidGlass.load()
          .then((_) {
            if (!_disposed && _governorArmed && !_degraded) {
              if (effectiveMaterial == LiquidTabBarMaterial.glass) {
                _watchFrames();
              } else {
                _unwatchFrames();
              }
            }
          })
          .catchError((_) {});
    } else {
      _unwatchFrames();
    }
  }

  /// Re-checks governor status and arms frame timing monitoring if conditions are met.
  void checkGovernor() => _checkGovernor();

  void _onTimings(List<FrameTiming> timings) {
    if (_disposed || effectiveMaterial != LiquidTabBarMaterial.glass) {
      if (_watching) _unwatchFrames();
      return;
    }
    final cfg = governorConfig;
    for (final f in timings) {
      // The first frames pay for pipeline warm-up; they are not the verdict.
      if (_warm < cfg.warmupFrames) {
        _warm++;
        continue;
      }
      _seen++;
      if (f.rasterDuration > cfg.rasterThreshold) _slow++;
      if (_slow >= cfg.maxSlowFrames) {
        _degraded = true;
        _unwatchFrames();
        _seen = 0;
        _slow = 0;
        if (!_disposed) notifyListeners();
        return;
      }
      if (_seen < cfg.windowFrames) continue;
      _seen = 0;
      _slow = 0;
    }
  }

  /// Manually feeds frame timings to the governor for testing slow-frame degradation.
  @visibleForTesting
  void onTimings(List<FrameTiming> timings) => _onTimings(timings);

  /// Arms the frame governor (monitors frame timings while the glass tier is on).
  ///
  /// Can be called at any time (including before [LiquidGlass.load] completes);
  /// it will automatically start monitoring once the glass shader is ready.
  void armGovernor() {
    if (_disposed) return;
    _governorArmed = true;
    _checkGovernor();
  }

  /// Reset the degraded status if the frame governor had stepped the tier down.
  void resetGovernor() {
    if (!_degraded) return;
    _degraded = false;
    _warm = 0;
    _seen = 0;
    _slow = 0;
    if (_governorArmed) _checkGovernor();
    if (!_disposed) notifyListeners();
  }
}
