part of '../imports/auth_imports.dart';

/// Auth 1a — Login. Merchant number + username (prefilled) + password with the
/// active 2px-ink border and eye toggle, a danger-red "forgot password" link,
/// and the ink primary "دخول". The Screen owns the [LoginController] lifecycle.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onSubmit});

  /// Called on a successful sign-in — the route wires this to enter the app.
  final VoidCallback? onSubmit;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController _vc = LoginController();

  @override
  void dispose() {
    _vc.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.onSubmit != null) {
      widget.onSubmit!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _openForgot() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          24.szH,
          const _AuthBrandLockup(),
          24.szH,
          Text(LocaleKeys.authLoginTitle.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle().setMainTextColor.s20.extraBold),
          8.szH,
          Text(LocaleKeys.authLoginSubtitle.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle().setSecondaryColor.s14.regular),
          32.szH,
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
          16.szH,
          _AuthField(
            label: LocaleKeys.authPassword.tr(),
            controller: _vc.password,
            icon: _kLockIcon,
            obscure: true,
            showToggle: true,
          ),
          12.szH,
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: _AuthLink(
                label: LocaleKeys.authForgotLink.tr(), onTap: _openForgot),
          ),
        ],
      ),
      footer: AnimatedBuilder(
        animation: _vc.formListenable,
        builder: (context, _) => _AuthPrimaryButton(
          label: LocaleKeys.authLoginSubmit.tr(),
          enabled: _vc.canSubmit,
          onTap: _submit,
        ),
      ),
    );
  }
}
