import 'package:flutter/material.dart';

import '../core/session/auth_session.dart';
import '../features/auth/presentation/imports/auth_imports.dart';
import 'app_shell.dart';

/// The app's entry route ('/'): shows the login screen until [AuthSession]
/// reports a signed-in courier, then hands straight to the tabbed shell (Home).
///
/// The freshly dispatched branch batch is no longer a blocking gate — the shell
/// greets the courier with a *dismissible* "new batch at the branch" sheet
/// instead, so they're informed without being forced to carry it before they
/// can use the app (see [AppShell]).
///
/// Logging out (More tab → account → "تسجيل الخروج") pops back here, which
/// reactively falls back to the login screen since it listens to the same
/// session.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthSession.instance,
      builder: (_, loggedIn, _) {
        if (!loggedIn) {
          return LoginScreen(onSubmit: AuthSession.instance.logIn);
        }
        return const AppShell();
      },
    );
  }
}
