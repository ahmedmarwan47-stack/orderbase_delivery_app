import 'package:flutter/widgets.dart';

/// Margin via extensions — `widget.marginAll(AppMargin.mH8)`. Directional
/// variants are RTL-safe.
extension MarginExtension on Widget {
  Widget marginAll(double value) =>
      Container(margin: EdgeInsets.all(value), child: this);

  Widget marginSymmetric({double horizontal = 0, double vertical = 0}) => Container(
        margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
        child: this,
      );

  Widget marginOnlyDirectional({
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) =>
      Container(
        margin: EdgeInsetsDirectional.only(start: start, top: top, end: end, bottom: bottom),
        child: this,
      );

  Widget marginStart(double value) =>
      Container(margin: EdgeInsetsDirectional.only(start: value), child: this);

  Widget marginEnd(double value) =>
      Container(margin: EdgeInsetsDirectional.only(end: value), child: this);
}
