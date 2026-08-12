part of '../imports/auth_imports.dart';

/// A password's strength as the meter renders it — how many of the three
/// segments are filled, and the label key ("قوة كلمة المرور: جيدة"). Pure value
/// type derived from the raw password text.
class PasswordStrength {
  const PasswordStrength._(this.filled, this.labelKey);

  /// 0–3 filled segments.
  final int filled;

  /// LocaleKeys.* describing the level, or null when there's nothing to show.
  final String? labelKey;

  static const int minLength = 8;

  factory PasswordStrength.of(String raw) {
    if (raw.isEmpty) return const PasswordStrength._(0, null);
    var score = 0;
    if (raw.length >= minLength) score++;
    if (RegExp(r'[A-Za-z]').hasMatch(raw) && RegExp(r'\d').hasMatch(raw)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(raw) || raw.length >= 12) score++;
    final filled = score.clamp(1, 3);
    final key = switch (filled) {
      1 => LocaleKeys.authStrengthWeak,
      2 => LocaleKeys.authStrengthGood,
      _ => LocaleKeys.authStrengthStrong,
    };
    return PasswordStrength._(filled, key);
  }
}

/// New-password form state (Auth.dc.html 1d): a new password with a live
/// strength meter, and a confirm field that turns green when the two match.
class NewPasswordController {
  final TextEditingController password = TextEditingController();
  final TextEditingController confirm = TextEditingController();

  Listenable get formListenable => Listenable.merge([password, confirm]);

  PasswordStrength get strength => PasswordStrength.of(password.text);
  bool get isLongEnough => password.text.length >= PasswordStrength.minLength;
  bool get isMatching =>
      confirm.text.isNotEmpty && confirm.text == password.text;
  bool get canSave => isLongEnough && isMatching;

  void dispose() {
    password.dispose();
    confirm.dispose();
  }
}

/// Change-password form state (Auth.dc.html 1e): current password, then the new
/// + confirm pair. Update enables once the current is entered and the new pair
/// is valid and matching.
class ChangePasswordController {
  final TextEditingController current = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirm = TextEditingController();

  Listenable get formListenable =>
      Listenable.merge([current, password, confirm]);

  bool get isLongEnough => password.text.length >= PasswordStrength.minLength;
  bool get isMatching =>
      confirm.text.isNotEmpty && confirm.text == password.text;
  bool get canUpdate =>
      current.text.isNotEmpty && isLongEnough && isMatching;

  void dispose() {
    current.dispose();
    password.dispose();
    confirm.dispose();
  }
}
