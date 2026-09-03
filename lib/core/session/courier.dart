/// The signed-in courier's identity.
///
/// One source for the few facts several screens show about the person using the
/// app — the profile tab, the change-password screen's account card, the
/// unified header's merchant line. They used to be literals sitting in each
/// widget, which is exactly how a name ends up spelled two ways. Real values
/// arrive with the backend; today it mirrors what the login screen signs in with.
abstract final class Courier {
  static const String name = 'Mahmoud Ezzat';
  static const String username = 'mahmoud.ezzat';

  /// The merchant (branch) code entered at sign-in.
  static const String merchant = '10248';

  /// The merchant the courier rides for. Which of its branches they are
  /// assigned to today comes from the shift ([ShiftController.branchName]).
  static const String merchantName = 'Sale Sucre';

  /// Shown in the avatar until there is a real photo to show.
  static const String initials = 'م ع';
}
