part of '../imports/auth_imports.dart';

/// The Orderbase brand wordmark for the auth screens (Auth.dc.html 1a). Renders
/// the shipped `orderbase` wordmark SVG (its own black + red brand colors) sized
/// to ~160px wide, height following its ~155×27 aspect ratio, centered on the
/// warm-paper ground.
class _AuthBrandLockup extends StatelessWidget {
  const _AuthBrandLockup();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        'assets/images/orderbase_wordmark.svg',
        width: 160.w,
        fit: BoxFit.contain,
      ),
    );
  }
}
