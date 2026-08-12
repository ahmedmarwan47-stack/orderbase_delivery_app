import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_module.dart';
import 'theme/colors.dart';
import 'theme/typography.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
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
        routerConfig: Modular.routerConfig,
      ),
    );
  }
}
