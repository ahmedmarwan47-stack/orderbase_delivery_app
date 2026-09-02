import 'package:flutter/widgets.dart';

/// Padding via extensions — `widget.paddingAll(AppPadding.pH16)` instead of a
/// `Padding(...)` wrapper. Directional variants are RTL-safe.
extension PaddingExtension on Widget {
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    ),
    child: this,
  );

  Widget paddingOnlyDirectional({
    double start = 0,
    double top = 0,
    double end = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsetsDirectional.only(
      start: start,
      top: top,
      end: end,
      bottom: bottom,
    ),
    child: this,
  );

  Widget paddingStart(double value) => Padding(
    padding: EdgeInsetsDirectional.only(start: value),
    child: this,
  );

  Widget paddingEnd(double value) => Padding(
    padding: EdgeInsetsDirectional.only(end: value),
    child: this,
  );
}
