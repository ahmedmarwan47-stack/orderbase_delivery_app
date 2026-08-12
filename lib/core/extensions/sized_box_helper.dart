import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Spacing helper — `12.szH` / `8.szW` instead of raw `SizedBox`.
/// Values are screenutil-scaled (`.h` / `.w`).
extension SizedBoxHelper on num {
  Widget get szH => SizedBox(height: toDouble().h);
  Widget get szW => SizedBox(width: toDouble().w);
}
