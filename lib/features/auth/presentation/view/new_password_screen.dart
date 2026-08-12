part of '../imports/auth_imports.dart';

/// Auth 1d — New password. A new password with a live 3-segment strength meter,
/// a confirm field that shows a green check when it matches, a rules card, and
/// the ink primary "حفظ كلمة المرور" (enabled once valid).
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final NewPasswordController _vc = NewPasswordController();

  @override
  void dispose() {
    _vc.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const AuthSuccessScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      body: AnimatedBuilder(
        animation: _vc.formListenable,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AuthBackLink(onTap: () => Navigator.of(context).maybePop()),
            20.szH,
            Text(LocaleKeys.authNewTitle.tr(),
                style: const TextStyle().setMainTextColor.s24.extraBold),
            8.szH,
            Text(LocaleKeys.authNewSubtitle.tr(),
                style: const TextStyle().setSecondaryColor.s14.regular),
            24.szH,
            _AuthField(
              label: LocaleKeys.authNewPassword.tr(),
              controller: _vc.password,
              icon: _kLockIcon,
              obscure: true,
              showToggle: true,
            ),
            _AuthStrengthMeter(strength: _vc.strength),
            16.szH,
            _AuthField(
              label: LocaleKeys.authConfirmPassword.tr(),
              controller: _vc.confirm,
              icon: _kLockIcon,
              obscure: true,
              showToggle: !_vc.isMatching,
              trailing: _vc.isMatching
                  ? IconWidget(
                      icon: AppAssets.svg.check,
                      color: AppColors.deliveredText,
                      height: AppSize.sH20,
                      width: AppSize.sW20,
                    )
                  : null,
            ),
            20.szH,
            _AuthRulesCard(
                lengthOk: _vc.isLongEnough, matchOk: _vc.isMatching),
          ],
        ),
      ),
      footer: AnimatedBuilder(
        animation: _vc.formListenable,
        builder: (context, _) => _AuthPrimaryButton(
          label: LocaleKeys.authSavePassword.tr(),
          enabled: _vc.canSave,
          onTap: _save,
        ),
      ),
    );
  }
}
