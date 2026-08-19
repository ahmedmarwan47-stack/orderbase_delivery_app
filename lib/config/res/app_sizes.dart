import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Flutter_Base sizing tokens. Values are responsive via `flutter_screenutil`
/// (`.h`/`.w`/`.sp`/`.r`) against the design size declared in `main.dart`
/// (the mockup phone frame, 368×812). Use these everywhere — never raw numbers.
///
/// `AppSize.sHxx` = heights, `.sWxx` = widths.
abstract final class AppSize {
  static double get sH1 => 1.h;
  static double get sH2 => 2.h;
  static double get sH4 => 4.h;
  static double get sH6 => 6.h;
  static double get sH8 => 8.h;
  static double get sH10 => 10.h;
  static double get sH12 => 12.h;
  static double get sH14 => 14.h;
  static double get sH16 => 16.h;
  static double get sH18 => 18.h;
  static double get sH20 => 20.h;
  static double get sH22 => 22.h;
  static double get sH24 => 24.h;
  static double get sH28 => 28.h;
  static double get sH32 => 32.h;
  static double get sH36 => 36.h;
  static double get sH40 => 40.h;
  static double get sH44 => 44.h;
  static double get sH48 => 48.h;
  static double get sH52 => 52.h;
  static double get sH56 => 56.h;
  static double get sH60 => 60.h;
  static double get sH64 => 64.h;
  static double get sH72 => 72.h;
  static double get sH88 => 88.h;
  static double get sH96 => 96.h;
  static double get sH120 => 120.h; // Home hero map strip
  static double get sH180 => 180.h; // Order-detail map preview

  static double get sW4 => 4.w;
  static double get sW6 => 6.w;
  static double get sW8 => 8.w;
  static double get sW10 => 10.w;
  static double get sW12 => 12.w;
  static double get sW14 => 14.w;
  static double get sW16 => 16.w;
  static double get sW18 => 18.w;
  static double get sW20 => 20.w;
  static double get sW22 => 22.w;
  static double get sW24 => 24.w;
  static double get sW28 => 28.w;
  static double get sW40 => 40.w;
  static double get sW44 => 44.w;
  static double get sW48 => 48.w;
  static double get sW56 => 56.w;
  static double get sW64 => 64.w;
  static double get sW88 => 88.w;
}

/// Padding tokens. `pH` = vertical (height-based), `pW` = horizontal (width-based).
abstract final class AppPadding {
  static double get pH2 => 2.h;
  static double get pH4 => 4.h;
  static double get pH6 => 6.h;
  static double get pH8 => 8.h;
  static double get pH10 => 10.h;
  static double get pH12 => 12.h;
  static double get pH14 => 14.h;
  static double get pH16 => 16.h;
  static double get pH18 => 18.h;
  static double get pH20 => 20.h;
  static double get pH24 => 24.h;
  static double get pH32 => 32.h;
  static double get pH56 => 56.h;
  static double get pH64 => 64.h;

  static double get pW4 => 4.w;
  static double get pW8 => 8.w;
  static double get pW12 => 12.w;
  static double get pW16 => 16.w;
  static double get pW20 => 20.w;
  static double get pW24 => 24.w;
  static double get pW32 => 32.w;
}

/// Margin tokens. `mH` = vertical, `mW` = horizontal.
abstract final class AppMargin {
  static double get mH4 => 4.h;
  static double get mH8 => 8.h;
  static double get mH12 => 12.h;
  static double get mH16 => 16.h;
  static double get mH20 => 20.h;
  static double get mW4 => 4.w;
  static double get mW8 => 8.w;
  static double get mW12 => 12.w;
  static double get mW16 => 16.w;
  static double get mW20 => 20.w;
}

/// Corner radii. Mockups use 8/12/13/14/16/20/22/24 (radii are exempt from the
/// 4px rule). `.r` keeps them proportional under screenutil.
abstract final class AppCircular {
  static double get r3 => 3.r; // grabber / progress pills
  static double get r7 => 7.r; // pay pill
  static double get r8 => 8.r;
  static double get r9 => 9.r;
  static double get r10 => 10.r;
  static double get r11 => 11.r;
  static double get r12 => 12.r;
  static double get r13 => 13.r;
  static double get r14 => 14.r;
  static double get r15 => 15.r; // primary buttons
  static double get r16 => 16.r;
  static double get r18 => 18.r; // money / large cards
  static double get r20 => 20.r;
  static double get r22 => 22.r;
  static double get r24 => 24.r;
  static double get r26 => 26.r; // bottom-sheet top corners
  static double get infinity => 999.r;
}

/// Font sizes (`.sp`). The mockups use a 4-multiple scale plus 14/18.
abstract final class FontSizeManager {
  // Floor is 14sp; 12sp only for dense meta/counts. Nothing smaller.
  static double get s10 => 10.sp; // off the 4px scale — status-pill label only
  static double get s12 => 12.sp;
  static double get s14 => 14.sp;
  static double get s16 => 16.sp;
  static double get s18 => 18.sp;
  static double get s20 => 20.sp;
  static double get s24 => 24.sp;
  static double get s28 => 28.sp; // auth screen titles
  static double get s36 => 36.sp; // COD amount entry — the cash figure
}

/// Font weights. Mockup headings go up to w800, so `extraBold` is included.
abstract final class FontWeightManager {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}
