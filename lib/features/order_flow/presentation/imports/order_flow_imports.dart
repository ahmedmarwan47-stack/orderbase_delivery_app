/// Order Flow feature imports hub. Every presentation file below is `part of`
/// this library, so it shares this single import surface (Flutter_Base
/// convention). Ported from Order Flow.dc.html (`isOrder` / `isResult` +
/// the `showHandoff` / `showFail` / `showPostpone` sheets).
library;

import 'package:flutter/material.dart';

import '../../../../app/road_mode.dart';
import '../../../../app/shift_controller.dart';
import '../../../../config/res/config_imports.dart';
import '../../../../core/live_activity/live_activity_bridge.dart';
import '../../../../core/live_activity/live_activity_service.dart';
import '../../../../data/flow_order.dart';
import '../../../../data/order.dart' show formatThousands;
import '../../../cod/presentation/imports/cod_imports.dart';
import '../../../failure_states/presentation/imports/failure_states_imports.dart';
import '../../../../widgets/app_sheet.dart';
import '../../../../widgets/bottom_nav.dart';
import '../../../../widgets/header_back_button.dart';
import '../../../../widgets/home_indicator.dart';
import '../../../../widgets/map_view.dart';

// Controllers (flow orchestration + ephemeral sheet state)
part '../controllers/order_flow_controller.dart';
part '../controllers/handoff_sheet_controller.dart';
part '../controllers/postpone_sheet_controller.dart';

// Views (public route entry points)
part '../view/order_detail_screen.dart';
part '../view/result_screen.dart';

// Widgets (private to the feature)
part '../widgets/order_detail_header.dart';
part '../widgets/order_detail_customer_section.dart';
part '../widgets/order_detail_address_section.dart';
part '../widgets/order_detail_items_section.dart';
part '../widgets/order_detail_notes_card.dart';
part '../widgets/order_detail_payment_card.dart';
part '../widgets/order_detail_fail_button.dart';
part '../widgets/order_detail_timeline.dart';
part '../widgets/order_detail_deliver_bar.dart';
part '../widgets/order_detail_shared.dart';
part '../widgets/result_summary_card.dart';
part '../widgets/result_actions.dart';

// Sheets (Order Flow overlays)
part '../widgets/sheets/handoff_sheet.dart';
part '../widgets/sheets/postpone_sheet.dart';
