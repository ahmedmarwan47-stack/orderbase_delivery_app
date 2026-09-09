import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'nav_glass.dart';

/// How the tab bar's surface is drawn. [auto] picks the richest tier the
/// device can carry; the others pin one (the Account tab's dev row).
enum NavMaterial { auto, glass, blur, opaque }

/// The tab bar's shared state: whether it is minimized, and which material
/// tier it renders. One instance — every screen's bar reads it, and the app
/// shell feeds it the pages' scroll notifications.
///
/// **Minimize follows the scroll**, the way iOS 26's bar does: scrolling down
/// through content folds the bar into a pill holding only the selected tab;
/// scrolling back up, reaching the top, or switching tabs opens it again. A
/// page too short to scroll under the bar never folds it.
///
/// **The tier is automatic**: glass (the refraction shader) wherever Impeller
/// runs it, blur where it does not, and — outside debug builds — a frame
/// governor that steps a struggling device down to blur for the session: a
/// full-width backdrop shader every scrolled frame is exactly what an old GPU
/// drops frames on, and a bar that stutters is worse than one that is flat.
class NavBarController extends ChangeNotifier {
  NavBarController._();

  static final NavBarController instance = NavBarController._();

  bool _minimized = false;
  bool get minimized => _minimized;

  NavMaterial _material = NavMaterial.auto;
  NavMaterial get material => _material;
  set material(NavMaterial value) {
    if (_material == value) return;
    _material = value;
    _watchFrames();
    notifyListeners();
  }

  bool _degraded = false;

  /// The tier actually drawn — [NavMaterial.auto] resolved.
  NavMaterial get effectiveMaterial {
    if (_material == NavMaterial.glass) {
      return NavGlass.supported ? NavMaterial.glass : NavMaterial.blur;
    }
    if (_material != NavMaterial.auto) return _material;
    if (_degraded || !NavGlass.supported) return NavMaterial.blur;
    return NavMaterial.glass;
  }

  // ---- Scroll → minimize --------------------------------------------------

  /// How far the page must travel in one direction before the bar reacts —
  /// enough to ignore a thumb settling on the screen, little enough that the
  /// bar answers the first real scroll.
  static const double _threshold = 12;

  /// Pages that cannot scroll at least this far are left alone: folding the
  /// bar to reveal nothing is a twitch, not a behaviour.
  static const double _minScrollable = 120;

  double _travel = 0;
  bool? _down;

  /// Feed a page's scroll notifications here. Always returns false so the
  /// notification keeps bubbling.
  bool handleScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
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
        minimize();
      } else {
        expand();
      }
    }
    return false;
  }

  void minimize() {
    if (_minimized) return;
    _minimized = true;
    notifyListeners();
  }

  void expand() {
    _travel = 0;
    _down = null;
    if (!_minimized) return;
    _minimized = false;
    notifyListeners();
  }

  // ---- Frame governor -----------------------------------------------------

  bool _watching = false;
  int _warm = 0;
  int _seen = 0;
  int _slow = 0;

  /// Start watching frame times if the glass tier is on. Idle frames are not
  /// reported, so the window only ever measures real rendering.
  void _watchFrames() {
    if (kDebugMode || _watching || effectiveMaterial != NavMaterial.glass) {
      return;
    }
    _watching = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  void _onTimings(List<FrameTiming> timings) {
    if (effectiveMaterial != NavMaterial.glass) return;
    for (final f in timings) {
      // The first frames pay for pipeline warm-up; they are not the verdict.
      if (_warm < 90) {
        _warm++;
        continue;
      }
      _seen++;
      if (f.rasterDuration > const Duration(milliseconds: 24)) _slow++;
      if (_seen < 60) continue;
      if (_slow >= 12) {
        _degraded = true;
        _watching = false;
        SchedulerBinding.instance.removeTimingsCallback(_onTimings);
        notifyListeners();
        return;
      }
      _seen = 0;
      _slow = 0;
    }
  }

  /// Called once the shader has loaded so the governor can arm itself.
  void armGovernor() => _watchFrames();
}
