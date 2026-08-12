import 'package:flutter/material.dart';

import '../core/session/auth_session.dart';
import '../features/auth/presentation/imports/auth_imports.dart';
import 'app_shell.dart';

/// The app's entry route ('/'): shows the login screen until [AuthSession]
/// reports a signed-in courier, then swaps to the real tabbed shell.
/// Logging out (More tab → account → "تسجيل الخروج") pops back to this page,
/// which reactively falls back to the login screen since it listens to the
/// same session.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthSession.instance,
      builder: (_, loggedIn, _) {
        return loggedIn
            ? const AppShell()
            : LoginScreen(onSubmit: AuthSession.instance.logIn);
      },
    );
  }
}
