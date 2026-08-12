/// Pickup feature imports hub. Every presentation file below is `part of` this
/// library, so it shares this single import surface (Flutter_Base convention).
library;

import 'package:flutter/material.dart';

import '../../../../config/res/config_imports.dart';
import '../../../../data/flow_order.dart';
import '../../../../theme/shadows.dart';
import '../../../../widgets/home_indicator.dart';

// Views (public route entry point)
part '../view/pickup_screen.dart';

// Widgets (private to the feature)
part '../widgets/pickup_header.dart';
part '../widgets/pickup_card.dart';
part '../widgets/pickup_confirm_bar.dart';
