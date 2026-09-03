import 'package:flutter/widgets.dart';

import '../config/res/config_imports.dart';
import 'shift_controller.dart';

/// «وضع الطريق» — the road mode. Sun on the screen at noon and winter gloves
/// on the grips are the enemies of the hero card, so the surfaces the courier
/// uses *while moving* grow one step: type one notch up the 4px scale, 64pt
/// controls, darker secondary text, a thicker outline. Lists stay as they are:
/// the Orders and settlement pages are read standing still, and a road mode
/// that grows every row is just a big app.
///
/// Phones give apps no ambient-light reading, so the mode cannot follow the
/// sun. It follows the day instead: with [auto] on it switches itself on when
/// the courier goes on route and off when they are back at the branch. The
/// switch on the Account tab is [on] itself, so what the courier sees and what
/// the switch says never disagree, and a manual flip holds until the next
/// route event.
///
/// A [ChangeNotifier] singleton like [ShiftController]; in-memory only (there
/// is no preferences plugin, and adding one would put native code back into
/// the iOS build). Both switches default to off: the courier opts in.
class RoadMode extends ChangeNotifier {
  RoadMode._() {
    _wasOnRoute = _onRoute;
    _on = _auto && _wasOnRoute;
    ShiftController.instance.addListener(_onShiftChanged);
  }
  static final RoadMode instance = RoadMode._();

  bool _on = false;
  bool _auto = false;
  bool _wasOnRoute = false;

  /// The mode is active right now — the one value the widgets read.
  bool get on => _on;

  /// Follow the route: on when the first stop becomes current, off when
  /// everything in hand is closed.
  bool get auto => _auto;

  set on(bool value) {
    if (_on == value) return;
    _on = value;
    notifyListeners();
  }

  set auto(bool value) {
    if (_auto == value) return;
    _auto = value;
    // Turning auto on mid-route applies straight away; turning it off leaves
    // the mode where it is — the courier decides from here.
    if (value && _onRoute && !_on) {
      _on = true;
    }
    notifyListeners();
  }

  bool get _onRoute => ShiftController.instance.status == CourierStatus.onRoute;

  /// Only a *transition* on or off the route moves the switch, so a manual
  /// flip mid-route is not undone by the next delivery's rebuild.
  void _onShiftChanged() {
    final onRoute = _onRoute;
    if (onRoute == _wasOnRoute) return;
    _wasOnRoute = onRoute;
    if (!_auto) return;
    if (_on != onRoute) {
      _on = onRoute;
      notifyListeners();
    }
  }
}

/// One step up the 4px type scale while the road mode is on — 12 → 14,
/// 14 → 16, 16 → 20, 20 → 24. Chain it last: `.s16.bold.road(road)`.
/// A size off that ladder is left alone.
extension RoadTextStyle on TextStyle {
  TextStyle road(bool on) {
    if (!on) return this;
    final fs = fontSize;
    if (fs == FontSizeManager.s12) return s14;
    if (fs == FontSizeManager.s14) return s16;
    if (fs == FontSizeManager.s16) return s20;
    if (fs == FontSizeManager.s20) return s24;
    return this;
  }
}
