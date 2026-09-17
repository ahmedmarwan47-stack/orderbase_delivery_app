/// Test-only renderer and controller overrides. This library is intentionally not exported
/// from `liquid_tab_bar.dart` and is not part of the supported API.
class LiquidGlassTestOverrides {
  static bool forceSupported = false;
}

/// Test-only hook to reset shared governor state between tests without polluting
/// the public [LiquidTabBarController] API with test cleanup methods.
class LiquidControllerTestOverrides {
  static void Function()? disarmShared;
  static void resetSharedGovernor() => disarmShared?.call();
}
