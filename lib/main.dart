import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      // Placeholder home — replaced as soon as the first screen is ported.
      home: const _PendingFirstScreen(),
    );
  }
}

class _PendingFirstScreen extends StatelessWidget {
  const _PendingFirstScreen();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Text(
            'لسه معملناش أول شاشة',
            style: AppTypography.size18,
          ),
        ),
      ),
    );
  }
}
