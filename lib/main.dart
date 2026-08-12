import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'dev/dev_gallery.dart';
import 'theme/colors.dart';
import 'theme/typography.dart';

void main() {
  runApp(const OrderbaseCourierApp());
}

class OrderbaseCourierApp extends StatelessWidget {
  const OrderbaseCourierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orderbase Courier',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
      home: const DevGallery(),
    );
  }
}
