/// Notifications feature imports hub. Every presentation file below is
/// `part of` this library, so it shares this single import surface
/// (Flutter_Base convention).
library;

import 'package:flutter/material.dart';

import '../../../../config/res/config_imports.dart';
import '../../../../widgets/bottom_nav.dart';

// Models & sample data
part '../controllers/notification_models.dart';

// Views (public entry point — hosted as the Notifications tab)
part '../view/notifications_screen.dart';

// Widgets (private to the feature)
part '../widgets/notifications_header.dart';
part '../widgets/notification_tile.dart';
part '../widgets/notifications_empty.dart';
