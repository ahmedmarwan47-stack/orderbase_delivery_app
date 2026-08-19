part of '../imports/home_imports.dart';

/// A single stat tile — icon chip, big value (optional currency suffix), label.
class _HomeStatCard extends StatelessWidget {
  const _HomeStatCard({
    required this.icon,
    required this.iconColor,
    required this.tile,
    required this.value,
    required this.labelKey,
    this.suffixKey,
    this.valueColor = AppColors.textPrimary,
    this.valueSize,
    this.onTap,
    this.dark = false,
  });

  final String icon;
  final Color iconColor;
  final Color tile;
  final String value;
  final String labelKey;
  final String? suffixKey;
  final Color valueColor;
  final double? valueSize;

  /// Opens the page this KPI summarises (Orders slice / settlement).
  final VoidCallback? onTap;

  /// Slate "cash" treatment (matching the settlement cash card) — used for the
  /// money KPI so it reads as cash, not the green delivered-success state.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final valueStyle = const TextStyle()
        .setColor(valueColor)
        .bold
        .tabular
        .withHeight(1)
        .copyWith(
          fontSize: valueSize ?? 24.sp,
        ); // was 28px — big-font trim sweep

    return Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.paymentCardBg : AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppCircular.r18,
        ), // radii exempt from 4px rule
        border: dark ? null : Border.all(color: AppColors.borderCardFaint),
        boxShadow: dark ? null : AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AppSize.sH40,
            height: AppSize.sH40,
            decoration: BoxDecoration(
              color: tile,
              borderRadius: BorderRadius.circular(AppCircular.r12),
            ),
            child: Center(
              child: IconWidget(
                icon: icon,
                color: iconColor,
                height: AppSize.sH22,
                width: 22.w, // no sW22 token; mockup glyph 22px
              ),
            ),
          ),
          12.szH,
          Text.rich(
            TextSpan(
              text: value,
              style: valueStyle,
              children: suffixKey == null
                  ? null
                  : [
                      TextSpan(
                        text: ' ${suffixKey!.tr()}',
                        style: const TextStyle()
                            .setColor(
                              dark ? AppColors.paymentSuffix : valueColor,
                            )
                            .s14
                            .semiBold,
                      ),
                    ],
            ),
          ),
          4.szH,
          Text(
            labelKey.tr(),
            style: const TextStyle()
                .setColor(
                  dark ? AppColors.paymentLabel : AppColors.textSecondary,
                )
                .s12
                .regular,
          ),
        ],
      ).paddingAll(AppPadding.pH16),
    ).onClick(onTap: onTap);
  }
}
