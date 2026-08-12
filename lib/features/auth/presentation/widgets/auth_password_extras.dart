part of '../imports/auth_imports.dart';

/// The 3-segment password-strength meter (Auth.dc.html 1d): green filled
/// segments over border-default empties, plus the level label
/// ("قوة كلمة المرور: جيدة"). Rendered only when the field is non-empty.
class _AuthStrengthMeter extends StatelessWidget {
  const _AuthStrengthMeter({required this.strength});
  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    if (strength.labelKey == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        8.szH,
        Row(
          children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0) 6.szW,
              Expanded(
                child: Container(
                  height: AppSize.sH4,
                  decoration: BoxDecoration(
                    color: i < strength.filled
                        ? AppColors.deliveredText
                        : AppColors.borderDefault,
                    borderRadius: BorderRadius.circular(AppCircular.r3),
                  ),
                ),
              ),
            ],
          ],
        ),
        8.szH,
        Text(
          LocaleKeys.authStrengthLabel
              .tr(namedArgs: {'level': strength.labelKey!.tr()}),
          style: const TextStyle().setColor(AppColors.deliveredText).s12.bold,
        ),
      ],
    );
  }
}

/// The password-rules card (Auth.dc.html 1d): a paper-toned card listing each
/// requirement with a green check when met, greyed otherwise.
class _AuthRulesCard extends StatelessWidget {
  const _AuthRulesCard({required this.lengthOk, required this.matchOk});
  final bool lengthOk;
  final bool matchOk;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppCircular.r14),
        border: Border.all(color: AppColors.borderDefault),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: AppPadding.pW16, vertical: AppPadding.pH12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AuthRuleRow(label: LocaleKeys.authRuleLength.tr(), ok: lengthOk),
          8.szH,
          _AuthRuleRow(label: LocaleKeys.authRuleMatch.tr(), ok: matchOk),
        ],
      ),
    );
  }
}

class _AuthRuleRow extends StatelessWidget {
  const _AuthRuleRow({required this.label, required this.ok});
  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconWidget(
          icon: AppAssets.svg.check,
          color: ok ? AppColors.deliveredText : AppColors.chipCountMuted,
          height: AppSize.sH16,
          width: AppSize.sW16,
        ),
        8.szW,
        Expanded(
          child: Text(
            label,
            style: const TextStyle()
                .setColor(ok ? AppColors.textBody : AppColors.textSecondary)
                .s14
                .regular,
          ),
        ),
      ],
    );
  }
}
