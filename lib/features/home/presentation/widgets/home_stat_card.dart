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
  });

  final String icon;
  final Color iconColor;
  final Color tile;
  final String value;
  final String labelKey;
  final String? suffixKey;
  final Color valueColor;
  final double? valueSize;

  @override
  Widget build(BuildContext context) {
    final valueStyle = const TextStyle()
        .setColor(valueColor)
        .extraBold
        .tabular
        .withHeight(1)
        .copyWith(fontSize: valueSize ?? 28.sp); // 28px is on the 4px grid, no token

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18.r), // radii exempt from 4px rule
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.card,
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
                        style: const TextStyle().s14.bold,
                      ),
                    ],
            ),
          ),
          4.szH,
          Text(
            labelKey.tr(),
            style: const TextStyle().setSecondaryColor.s12.regular,
          ),
        ],
      ).paddingAll(AppPadding.pH16),
    );
  }
}
