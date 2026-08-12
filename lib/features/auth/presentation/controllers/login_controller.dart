part of '../imports/auth_imports.dart';

/// Login form state (Auth.dc.html 1a). Holds the three fields — merchant number,
/// username, password — prefilled to match the mockup. The password's obscure
/// toggle lives locally in the field; the button listens to [formListenable].
class LoginController {
  final TextEditingController merchant = TextEditingController(text: '10248');
  final TextEditingController username =
      TextEditingController(text: 'mahmoud.ezzat');
  final TextEditingController password = TextEditingController();

  /// Rebuilds the submit button whenever any field changes.
  Listenable get formListenable =>
      Listenable.merge([merchant, username, password]);

  bool get canSubmit =>
      merchant.text.trim().isNotEmpty &&
      username.text.trim().isNotEmpty &&
      password.text.isNotEmpty;

  void dispose() {
    merchant.dispose();
    username.dispose();
    password.dispose();
  }
}
