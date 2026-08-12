part of '../imports/auth_imports.dart';

/// Auth 1b — Forgot password. Merchant number + username, a green WhatsApp info
/// card, and the ink primary "إرسال الكود على واتساب" (cash-bright chat glyph),
/// which sends the code and moves to the code-entry step.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotController _vc = ForgotController();

  @override
  void dispose() {
    _vc.dispose();
    super.dispose();
  }

  void _send() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const CodeEntryScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AuthBackLink(onTap: () => Navigator.of(context).maybePop()),
          20.szH,
          Text(LocaleKeys.authForgotTitle.tr(),
              style: const TextStyle().setMainTextColor.s24.extraBold),
          8.szH,
          Text(LocaleKeys.authForgotSubtitle.tr(),
              style: const TextStyle().setSecondaryColor.s14.regular.withHeight(1.5)),
          24.szH,
          _AuthField(
            label: LocaleKeys.authMerchant.tr(),
            controller: _vc.merchant,
            icon: _kStoreIcon,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ltr: true,
            tabular: true,
          ),
          16.szH,
          _AuthField(
            label: LocaleKeys.authUsername.tr(),
            controller: _vc.username,
            icon: AppAssets.svg.user,
            ltr: true,
          ),
          20.szH,
          _AuthInfoCard(
            title: LocaleKeys.authWhatsappTitle.tr(),
            body: LocaleKeys.authWhatsappBody.tr(),
          ),
        ],
      ),
      footer: AnimatedBuilder(
        animation: _vc.formListenable,
        builder: (context, _) => _AuthPrimaryButton(
          label: LocaleKeys.authSendCode.tr(),
          enabled: _vc.canSubmit,
          onTap: _send,
          icon: AppAssets.svg.chat,
          // Green only while enabled — a grey disabled button keeps a grey glyph.
          iconColor: _vc.canSubmit ? AppColors.cashBright : null,
        ),
      ),
    );
  }
}
