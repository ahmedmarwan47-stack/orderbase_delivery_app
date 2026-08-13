part of '../imports/queue_imports.dart';

/// Status pill — colour + icon + label per [OrderStatus].
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, this.returns});
  final OrderStatus status;
  final String? returns;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      OrderStatus.transit => _pill(
          bg: AppColors.transitBg,
          fg: AppColors.transitText,
          leading: Container(
            width: AppSize.sW8,
            height: AppSize.sH8,
            decoration: const BoxDecoration(
                color: AppColors.transitText, shape: BoxShape.circle),
          ),
          text: LocaleKeys.statusTransit.tr(),
        ),
      OrderStatus.postponed => _pill(
          bg: AppColors.postponedBg,
          fg: AppColors.postponedText,
          border: AppColors.postponedBorder,
          leading: IconWidget(
            icon: AppAssets.svg.clock,
            color: AppColors.postponedText,
            height: AppSize.sH14,
            width: AppSize.sW14,
          ),
          text: LocaleKeys.statusPostponedReturns
              .tr(namedArgs: {'time': returns ?? ''}),
        ),
      OrderStatus.delivered => _pill(
          bg: AppColors.deliveredBg,
          fg: AppColors.deliveredText,
          border: AppColors.deliveredBorder,
          leading: IconWidget(
            icon: AppAssets.svg.check,
            color: AppColors.deliveredText,
            height: AppSize.sH14,
            width: AppSize.sW14,
          ),
          text: LocaleKeys.statusDelivered.tr(),
        ),
      OrderStatus.failed => _pill(
          bg: AppColors.failedBg,
          fg: AppColors.failedText,
          border: AppColors.failedBorder,
          leading: IconWidget(
            icon: AppAssets.svg.fail,
            color: AppColors.failedText,
            height: AppSize.sH14,
            width: AppSize.sW14,
          ),
          text: LocaleKeys.statusFailed.tr(),
        ),
    };
  }

  Widget _pill({
    required Color bg,
    required Color fg,
    Color? border,
    required Widget leading,
    required String text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppCircular.r8),
        border: border != null ? Border.all(color: border) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          8.szW,
          Text(text, style: const TextStyle().setColor(fg).s12.bold),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}

/// Pay label — COD (amber, the COD semaphore) vs prepaid (green). Amber keeps
/// red reserved as a locator (The One Red Rule) and matches the home hero pill.
class _PayLabel extends StatelessWidget {
  const _PayLabel({required this.prepaid});
  final bool prepaid;

  @override
  Widget build(BuildContext context) {
    return Text(
      (prepaid ? LocaleKeys.payPrepaid : LocaleKeys.payCod).tr(),
      style: const TextStyle()
          .setColor(prepaid ? AppColors.deliveredText : AppColors.postponedText)
          .s12
          .bold,
    );
  }
}
