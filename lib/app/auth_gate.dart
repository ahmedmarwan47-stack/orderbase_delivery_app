import 'package:flutter/material.dart';

import '../core/session/auth_session.dart';
import '../features/auth/presentation/imports/auth_imports.dart';
import '../features/pickup/presentation/imports/pickup_imports.dart';
import 'app_shell.dart';
import 'shift_controller.dart';

/// The app's entry route ('/'): shows the login screen until [AuthSession]
/// reports a signed-in courier. Once signed in, the courier first lands on the
/// "collect from branch" pickup screen for the freshly dispatched batch;
/// confirming the pickup ([ShiftController.acceptBatch]) reveals the real
/// tabbed shell with the first stop ready on Home.
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
        return AnimatedBuilder(
          animation: ShiftController.instance,
          builder: (_, _) => ShiftController.instance.accepted
              ? const AppShell()
              : PickupScreen(onConfirm: ShiftController.instance.acceptBatch),
        );
      },
    );
  }
}
