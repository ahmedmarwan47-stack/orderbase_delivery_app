import 'package:flutter/services.dart';

/// Hands a URL to the OS.
///
/// Rides the channel the Live Activity already registers rather than pulling in
/// url_launcher: that plugin would put native code back into the iOS build, and
/// this app is deliberately CocoaPods-free.
///
/// Every call is best-effort — on Android, on the web build, or on an iOS build
/// made before the channel existed the platform simply has no handler, which is
/// swallowed here so a dead link can never take a screen down with it.
class ExternalLinks {
  const ExternalLinks._();

  static const MethodChannel _channel = MethodChannel('orderbase/live_activity');

  static Future<void> open(String url) async {
    try {
      await _channel.invokeMethod<void>('openUrl', {'url': url});
    } on MissingPluginException {
      // No native side (Android / web / pre-channel build) — nothing to do.
    } on PlatformException {
      // The OS refused the URL; not worth interrupting the courier for.
    }
  }

  /// Open a destination in Google Maps, falling back to the browser build of
  /// Maps when the app is not installed — the universal /maps/search URL does
  /// that hand-off by itself.
  static Future<void> openInGoogleMaps({
    required double lat,
    required double lng,
    String? label,
  }) {
    final query = label == null || label.isEmpty
        ? '$lat,$lng'
        : Uri.encodeComponent(label);
    return open(
      'https://www.google.com/maps/search/?api=1&query=$query'
      '&center=$lat,$lng',
    );
  }
}
