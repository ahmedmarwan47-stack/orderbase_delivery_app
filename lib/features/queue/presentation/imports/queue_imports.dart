/// Queue feature imports hub. Every presentation file below is `part of` this
/// library, so it shares this single import surface (Flutter_Base convention).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../app/shift_controller.dart';
import '../../../../config/res/config_imports.dart';
import '../../../../data/order.dart';
import '../../../../data/flow_order.dart';
import '../../../order_flow/presentation/imports/order_flow_imports.dart'
    show OrderDetailScreen;
import '../../../../widgets/bottom_nav.dart';
import '../../../../widgets/home_indicator.dart';

// Controllers (ephemeral UI state)
part '../controllers/queue_view_controller.dart';

// Views (public route entry points)
part '../view/queue_screen.dart';
part '../view/postponed_screen.dart';

// Widgets (private to the feature)
part '../widgets/queue_body.dart';
part '../widgets/queue_browse_header.dart';
part '../widgets/queue_search_header.dart';
part '../widgets/queue_filter_chips.dart';
part '../widgets/queue_cards.dart';
part '../widgets/queue_badges.dart';
part '../widgets/queue_empty_states.dart';
part '../widgets/postponed_body.dart';
part '../widgets/postponed_card.dart';
