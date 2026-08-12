/// Auth feature imports hub. Every presentation file below is `part of` this
/// library, so it shares this single import surface (Flutter_Base convention).
///
/// Ported from Auth.dc.html — ONE interactive screen driving six states, each
/// built here as its own Flutter screen/route:
///   1a Login · 1b Forgot password · 1c Code entry · 1d New password ·
///   1e Change password (from profile) · 1f Success.
/// RTL, Arabic-first, the warm-paper / ink-black "Courier's Manifest" world of
/// DESIGN.md. Controllers are ValueNotifier/Listenable-driven — no `setState`.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/res/config_imports.dart';
import '../../../../widgets/home_indicator.dart';

// Controllers (ephemeral per-screen form state)
part '../controllers/login_controller.dart';
part '../controllers/forgot_controller.dart';
part '../controllers/code_controller.dart';
part '../controllers/password_controllers.dart';

// Views (public route entry points — one per Auth.dc.html state)
part '../view/login_screen.dart';
part '../view/forgot_password_screen.dart';
part '../view/code_entry_screen.dart';
part '../view/new_password_screen.dart';
part '../view/change_password_screen.dart';
part '../view/auth_success_screen.dart';

// Widgets (private to the feature)
part '../widgets/auth_scaffold.dart';
part '../widgets/auth_field.dart';
part '../widgets/auth_buttons.dart';
part '../widgets/auth_code_boxes.dart';
part '../widgets/auth_password_extras.dart';
part '../widgets/auth_info_card.dart';
part '../widgets/auth_profile_card.dart';
part '../widgets/auth_brand_lockup.dart';
