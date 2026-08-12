import 'package:flutter/material.dart';

/// Tap handling via extension — `widget.onClick(onTap: fn)` instead of a bare
/// `GestureDetector`. Pass `ripple: true` (with a `borderRadius`) for an
/// `InkWell` material ripple instead of an opaque gesture.
extension OnClick on Widget {
  Widget onClick({
    required VoidCallback? onTap,
    bool ripple = false,
    BorderRadius? borderRadius,
  }) {
    if (ripple) {
      return InkWell(onTap: onTap, borderRadius: borderRadius, child: this);
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: this,
    );
  }
}
