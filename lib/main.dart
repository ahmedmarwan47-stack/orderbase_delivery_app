import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_module.dart';
import 'core/live_activity/live_activity_bridge.dart';
import 'theme/colors.dart';
import 'theme/typography.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // Mirrors the shift onto the iOS Dynamic Island / Lock Screen where the
  // device supports it. A no-op everywhere else — see [LiveActivityService].
  LiveActivityBridge.instance.attach();
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

  @override
  Widget build(BuildContext context) {
    // Design size = the mockup phone frame; screenutil scales tokens from it.
    return ScreenUtilInit(
      designSize: const Size(368, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp.router(
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
      ),
    );
  }
}
