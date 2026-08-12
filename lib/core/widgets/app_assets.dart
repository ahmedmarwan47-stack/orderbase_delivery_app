/// Asset paths, mirroring Flutter_Base's `AppAssets.svg.<name>` / `AppAssets.img.<name>` access.
///
/// Deviation from the skill's "icons are pre-colored, never pass `color:`" rule:
/// this project's icon set is monochrome stroke artwork (`stroke=currentColor`),
/// recolored at render time — so [IconWidget] here accepts a `color`.
abstract final class AppAssets {
  static const svg = _AppSvgs();
  static const img = _AppImages();
}

class _AppSvgs {
  const _AppSvgs();

  String _icon(String name) => 'assets/icons/$name.svg';

  String get bag => _icon('bag');
  String get bell => _icon('bell');
  String get bike => _icon('bike');
  String get cam => _icon('cam');
  String get cash => _icon('cash');
  String get chat => _icon('chat');
  String get check => _icon('check');
  String get chevronLeft => _icon('chevron_left');
  String get chevronRight => _icon('chevron_right');
  String get clock => _icon('clock');
  String get fail => _icon('fail');
  String get home => _icon('home');
  String get more => _icon('more');
  String get nav => _icon('nav');
  String get note => _icon('note');
  String get orders => _icon('orders');
  String get phone => _icon('phone');
  String get pin => _icon('pin');
  String get search => _icon('search');
  String get undo => _icon('undo');
  String get user => _icon('user');
  String get wallet => _icon('wallet');
  String get x => _icon('x');

  // Auth glyphs (from Auth.dc.html) — added for the auth flow.
  String get store => _icon('store');
  String get lock => _icon('lock');
  String get eye => _icon('eye');
  String get eyeOff => _icon('eye_off');

  // Failure States glyphs (from Failure States.dc.html) — the failure flow.
  String get tick => _icon('tick'); // i-tick (bare check, radio/checkbox)
  String get alert => _icon('alert'); // i-alert (!-in-circle)
  String get box => _icon('box'); // i-box (package / returns)
  String get wa => _icon('wa'); // i-wa (whatsapp)

  // Filled (solid) variants — used only for the bottom-nav ACTIVE tab.
  String get homeFilled => _icon('home_filled');
  String get ordersFilled => _icon('orders_filled');
  String get bellFilled => _icon('bell_filled');
  String get moreFilled => _icon('more_filled');
}

class _AppImages {
  const _AppImages();
  String get fudgeCake => 'assets/merchant/fudge-cake.jpg';
  String get saleSucre => 'assets/images/sale_sucre.svg';
  String get mapStrip => 'assets/images/map_strip.svg';
  String get resultSuccess => 'assets/images/result/success.png';
  String get resultFailure => 'assets/images/result/failure.png';
}
