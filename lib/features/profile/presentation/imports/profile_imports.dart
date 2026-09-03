/// Profile feature imports hub. Every presentation file below is `part of` this
/// library, so it shares this single import surface (Flutter_Base convention).
///
/// This tab used to be «المزيد» — a drawer of links that happened to include
/// the courier's account. A tab bar names sections, and the section here is the
/// person: their identity leads, and the account actions hang off it.
library;

import 'package:flutter/material.dart';

import '../../../../app/road_mode.dart';
import '../../../../app/shift_controller.dart';
import '../../../../config/res/config_imports.dart';
import '../../../../core/session/auth_session.dart';
import '../../../../core/session/courier.dart';
import '../../../../dev/dev_gallery.dart';
import '../../../auth/presentation/imports/auth_imports.dart';
import '../../../../widgets/app_header.dart';
import '../../../../widgets/bottom_nav.dart';

// View (public route entry point)
part '../view/profile_screen.dart';

// Widgets (private to the feature)
part '../widgets/profile_identity.dart';
part '../widgets/profile_row.dart';
part '../widgets/profile_switch_row.dart';
