part of '../imports/auth_imports.dart';

/// Auth 1f — Success. A centered green check badge, a title + body, then the ink
/// primary "دخول بكلمة المرور الجديدة" and an outlined secondary
/// "الرجوع للطلبات". Fully static — no controller.
class AuthSuccessScreen extends StatelessWidget {
  const AuthSuccessScreen({super.key, this.onSignIn, this.onBackToOrders});

  /// Sign in with the new password (route → app entry).
  final VoidCallback? onSignIn;

  /// Return to the orders queue.
  final VoidCallback? onBackToOrders;

  void _pop(BuildContext context, VoidCallback? cb) {
    if (cb != null) {
      cb();
    } else {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          64.szH,
          Center(
            child: Container(
              height: AppSize.sH88,
              width: AppSize.sW88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.deliveredBg,
                borderRadius: BorderRadius.circular(AppCircular.r26),
              ),
              child: IconWidget(
                icon: AppAssets.svg.check,
                color: AppColors.deliveredText,
                height: AppSize.sH36,
                width: AppSize.sH36,
              ),
            ),
          ),
          24.szH,
          Text(LocaleKeys.authSuccessTitle.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle().setMainTextColor.s20.extraBold),
          8.szH,
          Text(LocaleKeys.authSuccessBody.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle().setSecondaryColor.s14.regular.withHeight(1.5)),
        ],
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AuthPrimaryButton(
            label: LocaleKeys.authSuccessSignIn.tr(),
            enabled: true,
            onTap: () => _pop(context, onSignIn),
          ),
          12.szH,
          _AuthOutlinedButton(
            label: LocaleKeys.authSuccessBackToOrders.tr(),
            onTap: () => _pop(context, onBackToOrders),
          ),
        ],
      ),
    );
  }
}
