/// Failure States feature imports hub. Every presentation file below is
/// `part of` this library, so they share a single import surface
/// (Flutter_Base convention).
///
/// Ported from **Failure States.dc.html** — the section
/// «ما يحدث بعد اختيار سبب عدم التسليم» (what happens after the courier picks a
/// not-delivered reason). One interactive mockup drives 7 states:
///   1a Reason step · 1b Not present · 1c Wrong address · 1d Product mismatch ·
///   1e Return to branch · 1f Logged with undo · 1g Returns list.
///
/// 1a–1f are bottom sheets shown over the order-detail context; 1g is a full
/// screen (the active orders list with a "returns to branch" banner on top).
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../config/res/config_imports.dart';
import '../../../../widgets/app_sheet.dart';

// Models & sample data (pure — no Flutter logic)
part '../controllers/failure_states_models.dart';

// Controllers (ephemeral UI state — ValueNotifier / Timer, never setState)
part '../controllers/reason_step_controller.dart';
part '../controllers/wrong_address_controller.dart';
part '../controllers/undo_controller.dart';

// Public entry points
part '../widgets/failure_flow.dart';
part '../widgets/failure_states_host.dart';
part '../view/returns_list_screen.dart';

// Sheets (1a–1f) — private to the feature
part '../widgets/reason_sheet.dart';
part '../widgets/not_present_sheet.dart';
part '../widgets/wrong_address_sheet.dart';
part '../widgets/product_mismatch_sheet.dart';
part '../widgets/return_to_branch_sheet.dart';
part '../widgets/logged_sheet.dart';

// Shared private widgets (buttons, note field, order-context background, …)
part '../widgets/failure_shared.dart';

// 1g body
part '../widgets/returns_list_body.dart';
