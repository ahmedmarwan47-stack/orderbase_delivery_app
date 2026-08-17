/// Settlement feature imports hub. Every presentation file below is `part of`
/// this library, so it shares this single import surface (Flutter_Base
/// convention). Ported from Settlement.dc.html — ONE screen with two states
/// driven by a `startScreen` prop (`open` | `settled`): the courier reviews the
/// cash they're holding against today's cash orders (OPEN), then hands it to the
/// cashier and the queue closes (SETTLED). The `reset` action loops SETTLED back
/// to OPEN.
library;

import 'package:flutter/material.dart';

import '../../../../app/shift_controller.dart';
import '../../../../config/res/config_imports.dart';
import '../../../../data/order.dart' show formatThousands, OrderStatus;
import '../../../../theme/shadows.dart';
import '../../../../widgets/bottom_nav.dart';
import '../../../../widgets/home_indicator.dart';

// Models + in-feature sample data (mirrors the mockup's DCLogic `state`).
part '../models/settlement_models.dart';

// Controller (ephemeral open/settled stage — no setState).
part '../controllers/settlement_controller.dart';

// View (public route entry point).
part '../view/settlement_screen.dart';

// Widgets (private to the feature).
part '../widgets/settlement_open_view.dart';
part '../widgets/settlement_cash_card.dart';
part '../widgets/settlement_collections_section.dart';
part '../widgets/settlement_locked_note.dart';
part '../widgets/settlement_settled_view.dart';
