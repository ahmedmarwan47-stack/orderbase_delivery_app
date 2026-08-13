/// Orders-list feature imports hub. Every presentation file below is `part of`
/// this library, so it shares this single import surface (Flutter_Base
/// convention). Ported from Order Flow.dc.html (`isOrders`).
library;

import 'package:flutter/material.dart';

import '../../../../config/res/config_imports.dart';
import '../../../../data/flow_order.dart';
import '../../../../features/queue/presentation/imports/queue_imports.dart';
import '../../../../theme/shadows.dart';
import '../../../../widgets/bottom_nav.dart';

// Controllers (ephemeral UI state)
part '../controllers/orders_view_controller.dart';

// Views (public route entry point)
part '../view/orders_list_screen.dart';

// Widgets (private to the feature)
part '../widgets/orders_body.dart';
part '../widgets/orders_header.dart';
part '../widgets/orders_filter_chips.dart';
part '../widgets/orders_card.dart';
