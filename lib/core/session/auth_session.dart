import 'package:flutter/foundation.dart';

/// Minimal in-memory auth session — no persistence, no backend. Login/logout
/// just flip this flag; [AuthGate] (`lib/app/auth_gate.dart`) listens and
/// swaps the app root between the login screen and the tabbed shell.
class AuthSession extends ValueNotifier<bool> {
  AuthSession._() : super(false);

  static final AuthSession instance = AuthSession._();

  bool get isLoggedIn => value;

  void logIn() => value = true;
  void logOut() => value = false;
}
