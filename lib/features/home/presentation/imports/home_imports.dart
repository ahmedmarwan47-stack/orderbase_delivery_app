/// Home feature imports hub. Every presentation file below is `part of` this
/// library, so it shares this single import surface (Flutter_Base convention).
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../config/res/config_imports.dart';
import '../../../../theme/shadows.dart';
import '../../../../widgets/bottom_nav.dart';
import '../../../../widgets/map_view.dart';

// Views (public route entry point)
part '../view/home_screen.dart';

// Widgets (private to the feature)
part '../widgets/home_merchant_header.dart';
part '../widgets/home_square_icon_button.dart';
part '../widgets/home_next_stop_card.dart';
part '../widgets/home_progress_seg.dart';
part '../widgets/home_today_stats.dart';
part '../widgets/home_stat_card.dart';
