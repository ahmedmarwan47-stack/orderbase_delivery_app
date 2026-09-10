import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_module.dart';
import 'core/live_activity/live_activity_bridge.dart';
import 'theme/colors.dart';
import 'theme/typography.dart';
import 'widgets/header_blur.dart';
import 'widgets/nav_bar_controller.dart';
import 'widgets/nav_glass.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // Mirrors the shift onto the iOS Dynamic Island / Lock Screen where the
  // device supports it. A no-op everywhere else — see [LiveActivityService].
  LiveActivityBridge.instance.attach();
  // The tab bar's glass shader — loaded before the first frame so the bar
  // never flashes from its blur fallback to glass.
  await NavGlass.load();
  // The header's scroll-edge fade rides the same engine path as the bar.
  await HeaderBlur.load();
  NavBarController.instance.armGovernor();
  runApp(
    ModularApp(
      module: AppModule(),
      child: EasyLocalization(
        supportedLocales: const [Locale('ar'), Locale('en')],
        path: 'assets/translations',
        startLocale: const Locale('ar'),
        fallbackLocale: const Locale('ar'),
        child: const OrderbaseCourierApp(),
      ),
    ),
  );
}

class OrderbaseCourierApp extends StatelessWidget {
  const OrderbaseCourierApp({super.key});

  /// The mockup phone frame; screenutil scales every token from it.
  static const Size _design = Size(368, 812);

  /// Wider than this and the viewport is a desktop browser, not a phone.
  static const double _phoneMaxWidth = 600;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const _ScaledApp();
    return MediaQuery.fromView(
      view: View.of(context),
      child: Builder(
        builder: (context) {
          final mq = MediaQuery.of(context);
          if (mq.size.width <= _phoneMaxWidth) {
            // A phone's browser. Safari's chrome takes the viewport down to
            // ~660pt on an iPhone 15, so screenutil's height scale lands
            // ~15% under its width scale and every 44×44 tile squashes into
            // a slab. Scale both axes from the width: the page simply runs a
            // little longer under the browser bar instead of shrinking.
            final w = mq.size.width;
            ScreenUtil.configure(
              data: mq.copyWith(
                size: Size(w, w * _design.height / _design.width),
              ),
              designSize: _design,
              minTextAdapt: true,
              splitScreenMode: false,
              fontSizeResolver: FontSizeResolvers.width,
            );
            return const _CourierMaterialApp();
          }
          // A desktop browser (GitHub Pages on a laptop): screenutil would
          // scale widths by the window's width and heights by its height —
          // 3.5× wide and 0.9× tall on a 1280×720 window, which squashes
          // every 44×44 tile into a slab and clips the large title. Instead
          // the app renders at exactly the design frame and the frame is
          // scaled as one, so a laptop shows the phone the mockups show.
          final framed = mq.copyWith(
            size: _design,
            padding: EdgeInsets.zero,
            viewPadding: EdgeInsets.zero,
            viewInsets: EdgeInsets.zero,
          );
          ScreenUtil.configure(
            data: framed,
            designSize: _design,
            minTextAdapt: true,
            splitScreenMode: false,
            fontSizeResolver: FontSizeResolvers.width,
          );
          return MediaQuery(
            data: framed,
            child: ColoredBox(
              color: AppColors.inkFill,
              child: Center(
                child: FittedBox(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: SizedBox.fromSize(
                      size: _design,
                      child: const _CourierMaterialApp(),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The app scaled by screenutil from the real screen — every native phone.
/// (The web takes the manual [ScreenUtil.configure] paths above: a browser's
/// viewport is never the phone's own aspect.)
class _ScaledApp extends StatelessWidget {
  const _ScaledApp();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: OrderbaseCourierApp._design,
      minTextAdapt: true,
      builder: (context, _) => const _CourierMaterialApp(),
    );
  }
}

class _CourierMaterialApp extends StatelessWidget {
  const _CourierMaterialApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Orderbase Courier',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: AppTypography.size16.fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          primary: AppColors.brand,
          surface: AppColors.surface,
        ),
      ),
      // Deliberately light-only: the "warm paper" identity has no dark variant.
      // Pinning ThemeMode.light keeps the app consistent under system dark mode
      // instead of a mechanically inverted look.
      themeMode: ThemeMode.light,
      // Honor the OS text-size setting, but cap it so large accessibility
      // sizes don't clip the fixed-height chrome (pills, deliver bar, etc.).
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3),
          ),
          child: child!,
        );
      },
      routerConfig: Modular.routerConfig,
    );
  }
}
