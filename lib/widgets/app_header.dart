import 'package:flutter/material.dart';

import '../app/shift_controller.dart';
import '../config/res/config_imports.dart';
import '../core/session/courier.dart';
import '../data/order.dart';

/// The unified app header — a solid white bar with a hairline bottom, shared
/// by every tab page so the app reads the same wherever the courier is.
///
/// It answers the questions a courier asks *between* screens, not the ones the
/// page beneath answers: who am I riding for today (the merchant and the
/// branch), how much is left, and how much cash am I carrying. Three signals
/// join the second line only while they are true — a batch waiting at the
/// branch, returns in custody, and the cash figure going red past the limit —
/// so on an ordinary day the line stays quiet.
///
/// Rebuilds with [ShiftController] so the numbers stay current as stops close.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.onSearch,
    this.onOpenNotifications,
    this.onOpenPendingBatch,
    this.notificationsBadge = true,
    this.notificationsActive = false,
  });

  /// Opens search for this page (inline on Orders, a pushed search elsewhere).
  final VoidCallback? onSearch;

  /// Opens (or, when [notificationsActive], closes) the notifications page.
  final VoidCallback? onOpenNotifications;

  /// The amber «دفعة في الفرع» chip — jumps to the waiting batch.
  final VoidCallback? onOpenPendingBatch;

  /// Shows the red dot on the bell.
  final bool notificationsBadge;

  /// The notifications page is what is on screen: the bell tile inverts to ink
  /// so the courier can see they are "in" it, and tapping it goes back.
  final bool notificationsActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ShiftController.instance,
      builder: (context, _) {
        final shift = ShiftController.instance;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(color: AppColors.borderHeader),
                ),
              ),
              child:
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // The merchant mark — a multi-colour brand asset, so it
                      // is drawn as-is rather than recoloured like an icon.
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppCircular.r10),
                        child: IconWidget(
                          icon: AppAssets.img.saleSucre,
                          height: AppSize.sH36,
                          width: 36.w,
                        ),
                      ),
                      8.szW,
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${Courier.merchantName} · ${shift.branchName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle()
                                  .setMainTextColor
                                  .s14
                                  .semiBold,
                            ),
                            4.szH,
                            _StatusLine(
                              shift: shift,
                              onOpenPendingBatch: onOpenPendingBatch,
                            ),
                          ],
                        ),
                      ),
                      8.szW,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (onOpenNotifications != null) ...[
                            _HeaderAction(
                              icon: AppAssets.svg.bell,
                              label: notificationsActive
                                  ? LocaleKeys.a11yBack.tr()
                                  : LocaleKeys.navNotifications.tr(),
                              badge: notificationsBadge && !notificationsActive,
                              active: notificationsActive,
                              onTap: onOpenNotifications!,
                            ),
                            8.szW,
                          ],
                          if (onSearch != null)
                            _HeaderAction(
                              icon: AppAssets.svg.search,
                              label: LocaleKeys.a11ySearch.tr(),
                              onTap: onSearch!,
                            ),
                        ],
                      ),
                    ],
                  ).paddingOnly(
                    left: AppPadding.pW20,
                    top: AppPadding.pH12,
                    right: AppPadding.pW20,
                    bottom: AppPadding.pH12,
                  ),
            ),
            // Breathing room between the header bar and the page content.
            SizedBox(height: AppPadding.pH8),
          ],
        );
      },
    );
  }
}

/// The header's second line, composed from the courier's status: what is
/// left, the cash in hand (red past the limit), and the amber chip while a
/// batch waits at the branch. Returns in custody are deliberately *not* here —
/// they did not fit beside the chip at 12px, and Home's returning card and the
/// settlement both carry them.
class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.shift, this.onOpenPendingBatch});

  final ShiftController shift;
  final VoidCallback? onOpenPendingBatch;

  @override
  Widget build(BuildContext context) {
    final quiet = const TextStyle().setSecondaryColor.s12.regular;
    final strong = const TextStyle().setMainTextColor.s12.semiBold.tabular;
    final over = shift.overCashLimit;
    final cashStyle = over
        ? const TextStyle().setColor(AppColors.failedText).s12.semiBold.tabular
        : strong;

    final String lead = switch (shift.status) {
      CourierStatus.idle => LocaleKeys.headerNoBatch.tr(),
      CourierStatus.onRoute => LocaleKeys.headerRemaining.tr(
        namedArgs: {'count': arabicDigits(shift.inProgress)},
      ),
      CourierStatus.returning => LocaleKeys.headerExpectedAtBranch.tr(
        namedArgs: {'time': shift.returnEtaLabel ?? ''},
      ),
      CourierStatus.settled => LocaleKeys.headerSettled.tr(),
    };
    final cash = LocaleKeys.headerCashInHand.tr(
      namedArgs: {'amount': formatThousands(shift.cashInHand)},
    );

    return Row(
      children: [
        Flexible(
          child: Text.rich(
            TextSpan(
              style: quiet,
              children: [
                TextSpan(text: lead),
                const TextSpan(text: ' · '),
                if (over)
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: IconWidget(
                      icon: AppAssets.svg.alert,
                      color: AppColors.failedText,
                      height: AppSize.sH14,
                      width: AppSize.sW14,
                    ).paddingOnlyDirectional(end: AppPadding.pW4),
                  ),
                TextSpan(text: cash, style: cashStyle),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (shift.hasPendingBatch) ...[
          6.szW,
          _PendingBatchChip(onTap: onOpenPendingBatch),
        ],
      ],
    );
  }
}

/// Amber «دفعة» with a parcel glyph — the one thing left behind after the
/// mid-flight sheet is dismissed, so a waiting batch is never silently
/// forgotten. Kept to one word so the cash figure beside it still fits.
class _PendingBatchChip extends StatelessWidget {
  const _PendingBatchChip({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.heroCodPillBg,
          borderRadius: BorderRadius.circular(AppCircular.r7),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.pW8,
          vertical: AppPadding.pH2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconWidget(
              icon: AppAssets.svg.box,
              color: AppColors.postponedText,
              height: AppSize.sH12,
              width: AppSize.sW12,
            ),
            4.szW,
            Text(
              LocaleKeys.headerPendingBatch.tr(),
              style: const TextStyle()
                  .setColor(AppColors.postponedText)
                  .s10
                  .semiBold,
            ),
          ],
        ),
      ).onClick(onTap: onTap),
    );
  }
}

/// A 40pt white icon tile (hairline border, ink glyph) with an optional red
/// notification dot — the shared header action look. [active] inverts it to
/// ink-on-white → white-on-ink.
class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.onTap,
    this.label,
    this.badge = false,
    this.active = false,
  });

  final String icon;
  final VoidCallback onTap;
  final String? label;
  final bool badge;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Widget tile = AnimatedContainer(
      duration: AppMotion.stamp,
      curve: AppMotion.ease,
      width: AppSize.sH40,
      height: AppSize.sH40,
      decoration: BoxDecoration(
        color: active ? AppColors.inkFill : AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r12),
        border: Border.all(
          color: active ? AppColors.inkFill : AppColors.iconButtonBorder,
        ),
      ),
      child: Center(
        child: IconWidget(
          icon: icon,
          color: active ? AppColors.surface : AppColors.textPrimary,
          height: AppSize.sH20,
          width: AppSize.sW20,
        ),
      ),
    );
    return Semantics(
      button: true,
      label: label,
      selected: active,
      child:
          (badge
                  ? Stack(
                      clipBehavior: Clip.none,
                      children: [
                        tile,
                        Positioned(
                          top: 2.h,
                          right: 2.w,
                          child: Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: AppColors.brand,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : tile)
              .onClick(onTap: onTap),
    );
  }
}
