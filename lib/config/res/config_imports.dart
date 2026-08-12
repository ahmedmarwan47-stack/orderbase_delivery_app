/// Single import that exposes the whole Flutter_Base foundation — tokens,
/// colors, extensions, core widgets, localization, and the responsive/i18n
/// packages. Presentation files reach these through their feature imports hub.
library;

// `hide TextDirection` — easy_localization re-exports intl, whose TextDirection
// would otherwise clash with dart:ui's (the one Flutter widgets expect).
export 'package:easy_localization/easy_localization.dart' hide TextDirection;
export 'package:flutter_screenutil/flutter_screenutil.dart';

export 'app_sizes.dart';
export '../../theme/colors.dart';
export '../../core/extensions/sized_box_helper.dart';
export '../../core/extensions/padding_extension.dart';
export '../../core/extensions/margin_extension.dart';
export '../../core/extensions/widget_extension.dart';
export '../../core/extensions/text_style_extensions.dart';
export '../../core/widgets/icon_widget.dart';
export '../../core/widgets/app_assets.dart';
export '../../core/localization/locale_keys.dart';
