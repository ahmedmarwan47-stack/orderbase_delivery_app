import 'package:flutter_modular/flutter_modular.dart';

import 'app/auth_gate.dart';
import 'core/session/auth_session.dart';
import 'features/auth/presentation/imports/auth_imports.dart';
import 'features/failure_states/presentation/imports/failure_states_imports.dart';
import 'features/order_flow/presentation/imports/order_flow_imports.dart';
import 'features/pickup/presentation/imports/pickup_imports.dart';
import 'features/queue/presentation/imports/queue_imports.dart';
import 'features/settlement/presentation/imports/settlement_imports.dart';

/// Root Modular module — DI binds + the app's named routes.
///
/// Every screen is now migrated to the Flutter_Base feature structure. `/` is
/// the auth gate (login until [AuthSession] says otherwise, then the tabbed
/// shell); pushed screens (order detail, pickup) get named routes.
class AppModule extends Module {
  @override
  void binds(Injector i) {}

  @override
  void routes(RouteManager r) {
    r.child('/', child: (_) => const AuthGate());
    r.child('/auth',
        child: (_) => LoginScreen(
              onSubmit: () {
                AuthSession.instance.logIn();
                Modular.to.navigate('/');
              },
            ));
    r.child('/queue', child: (_) => const QueueScreen());
    r.child('/queue/postponed', child: (_) => const PostponedScreen());
    r.child('/order-detail', child: (_) => const OrderDetailScreen());
    r.child('/pickup', child: (_) => const PickupScreen());
    r.child('/settlement', child: (_) => const SettlementScreen());
    r.child('/failure-states',
        child: (_) => const FailureStatesHost(runFlow: true));
    r.child('/returns', child: (_) => const ReturnsListScreen());
  }
}
