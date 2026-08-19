part of '../imports/queue_imports.dart';

/// Outcome pill for a closed order — colour + icon + label per [OrderStatus].
/// Shown in place of the pay label once an order is done, so a dimmed card
/// says *why* it's dimmed: delivered (green = success), failed (red = could
/// not deliver), or postponed (amber).
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
          text: LocaleKeys.statusTransit.tr(),
        ),
      OrderStatus.postponed => _pill(
          bg: AppColors.postponedBg,
          fg: AppColors.postponedText,
          border: AppColors.postponedBorder,
          leading: AppAssets.svg.clock,
          text: LocaleKeys.statusPostponedReturns
              .tr(namedArgs: {'time': returns ?? ''}),
        ),
      OrderStatus.delivered => _pill(
          bg: AppColors.deliveredBg,
          fg: AppColors.deliveredText,
          border: AppColors.deliveredBorder,
          leading: AppAssets.svg.check,
          text: LocaleKeys.statusDelivered.tr(),
        ),
      OrderStatus.failed => _pill(
          bg: AppColors.failedBg,
          fg: AppColors.failedText,
          border: AppColors.failedBorder,
          leading: AppAssets.svg.fail,
          text: LocaleKeys.statusFailed.tr(),
        ),
    };
  }

  Widget _pill({
    required Color bg,
    required Color fg,
    Color? border,
    String? leading,
    required String text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100), // full pill (radii 4px-exempt)
        border: border != null ? Border.all(color: border) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            IconWidget(
              icon: leading,
              color: fg,
              height: AppSize.sH10,
              width: AppSize.sW10,
            ),
            4.szW,
          ],
          Text(text, style: const TextStyle().setColor(fg).s10.semiBold),
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
          .semiBold,
    );
  }
}
