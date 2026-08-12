part of '../imports/auth_imports.dart';

/// Auth 1e — Change password (opened from the profile). A header bar, an account
/// card, the current password (with a "نسيتها؟" link), then the new + confirm
/// pair, a note, and the ink primary "تحديث كلمة المرور" (disabled until valid).
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final ChangePasswordController _vc = ChangePasswordController();

  @override
  void dispose() {
    _vc.dispose();
    super.dispose();
  }

  void _update() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const AuthSuccessScreen()),
      );

  void _openForgot() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
      );

  @override
  Widget build(BuildContext context) {
    return _AuthScaffold(
      header: _AuthHeaderBar(
        title: LocaleKeys.authChangeTitle.tr(),
        back: LocaleKeys.authAccount.tr(),
        onBack: () => Navigator.of(context).maybePop(),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          8.szH,
          _AuthProfileCard(
            initials: 'م ع',
            name: 'Mahmoud Ezzat',
            username: 'mahmoud.ezzat',
            merchant: '10248',
          ),
          20.szH,
          _AuthField(
            label: LocaleKeys.authCurrentPassword.tr(),
            controller: _vc.current,
            icon: _kLockIcon,
            obscure: true,
            showToggle: true,
            labelTrailing: _AuthLink(
                label: LocaleKeys.authForgotItLink.tr(), onTap: _openForgot),
          ),
          16.szH,
          Container(height: 1, color: AppColors.borderHeader),
          16.szH,
          _AuthField(
            label: LocaleKeys.authNewPassword.tr(),
            controller: _vc.password,
            icon: _kLockIcon,
            obscure: true,
            showToggle: true,
            hint: LocaleKeys.authRuleLength.tr(),
          ),
          16.szH,
          _AuthField(
            label: LocaleKeys.authConfirmPassword.tr(),
            controller: _vc.confirm,
            icon: _kLockIcon,
            obscure: true,
            showToggle: true,
            hint: LocaleKeys.authConfirmHint.tr(),
          ),
          16.szH,
          Text(LocaleKeys.authChangeNote.tr(),
              style: const TextStyle().setSecondaryColor.s12.regular.withHeight(1.5)),
        ],
      ),
      footer: AnimatedBuilder(
        animation: _vc.formListenable,
        builder: (context, _) => _AuthPrimaryButton(
          label: LocaleKeys.authUpdatePassword.tr(),
          enabled: _vc.canUpdate,
          onTap: _update,
        ),
      ),
    );
  }
}
