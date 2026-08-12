part of '../imports/auth_imports.dart';

/// Forgot-password form state (Auth.dc.html 1b). Merchant number + username;
/// submitting sends the WhatsApp verification code (→ 1c code entry).
class ForgotController {
  final TextEditingController merchant = TextEditingController();
  final TextEditingController username = TextEditingController();

  Listenable get formListenable => Listenable.merge([merchant, username]);

  bool get canSubmit =>
      merchant.text.trim().isNotEmpty && username.text.trim().isNotEmpty;

  void dispose() {
    merchant.dispose();
    username.dispose();
  }
}
