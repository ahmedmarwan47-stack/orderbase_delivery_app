/// COD collection feature imports hub. Every presentation file below is
/// `part of` this library (Flutter_Base convention). Ported from
/// COD Collection.dc.html — direction **2a** ("SIMPLE ENTRY"): the courier
/// types the collected amount on an on-screen keypad, any excess over the
/// order value is auto-added to the customer's wallet, and a confirmation
/// screen spells out the settlement math.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/res/config_imports.dart';
import '../../../../data/order.dart' show formatThousands;
import '../../../../widgets/app_sheet.dart';

// Controller (ephemeral keypad-buffer state)
part '../controllers/cod_entry_controller.dart';

// Public entry point (orchestrates entry → confirm)
part '../widgets/cod_collection_flow.dart';

// Sheets
part '../widgets/cod_entry_sheet.dart';
part '../widgets/cod_confirm_sheet.dart';
