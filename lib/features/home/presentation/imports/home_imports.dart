/// Home feature imports hub. Every presentation file below is `part of` this
/// library, so it shares this single import surface (Flutter_Base convention).
library;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../config/res/config_imports.dart';
import '../../../../features/queue/presentation/imports/queue_imports.dart';
import '../../../../theme/shadows.dart';
import '../../../../widgets/bottom_nav.dart';
import '../../../../widgets/map_view.dart';

// Views (public route entry points)
part '../view/home_screen.dart';
part '../view/home_glance_screen.dart';
part '../view/home_compact_screen.dart';
part '../view/home_flat_screen.dart';

// Widgets (private to the feature)
part '../widgets/home_merchant_header.dart';
part '../widgets/home_square_icon_button.dart';
part '../widgets/home_next_stop_card.dart';
part '../widgets/home_progress_seg.dart';
part '../widgets/home_today_stats.dart';
part '../widgets/home_stat_card.dart';

// Shared home-variant widgets (1b / 1c / 2a)
part '../widgets/home_progress_bar.dart';
part '../widgets/home_remaining_stop_row.dart';

// Glance (1b) widgets
part '../widgets/home_online_bar.dart';
part '../widgets/home_collection_banner.dart';
part '../widgets/home_stat_strip.dart';
part '../widgets/home_next_stop_compact_card.dart';

// Compact (1c) widgets
part '../widgets/home_compact_header.dart';
part '../widgets/home_compact_stat_row.dart';
part '../widgets/home_route_card.dart';

// Flat (2a) widgets
part '../widgets/home_flat_header.dart';
part '../widgets/home_flat_next_stop.dart';
part '../widgets/home_overview_card.dart';
