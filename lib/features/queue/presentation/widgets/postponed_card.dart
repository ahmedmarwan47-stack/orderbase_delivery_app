part of '../imports/queue_imports.dart';

/// A single postponed order — number, pay, return time, identity, reason box,
/// and the return / call actions.
class _PostponedCard extends StatelessWidget {
  const _PostponedCard({required this.order, required this.onReturn});
  final Order order;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(order.num,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle().setMainTextColor.s16.extraBold),
                  8.szW,
                  _PayLabel(prepaid: order.prepaid),
                ],
              ),
              _ReturnBadge(time: order.returns ?? ''),
            ],
          ),
          12.szH,
          Row(
            children: [
              _MerchantThumb(size: AppSize.sH64),
              16.szW,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.name, style: const TextStyle().setMainTextColor.s18.bold),
                    4.szH,
                    Text(
                      LocaleKeys.addrArea
                          .tr(namedArgs: {'addr': order.addr, 'area': order.area}),
                      style: const TextStyle().setHintColor.s14.regular,
                    ),
                    if (order.cod != null) ...[
                      4.szH,
                      Text(
                        LocaleKeys.collectEgp
                            .tr(namedArgs: {'amount': formatThousands(order.cod!)}),
                        style: const TextStyle().setTertiaryColor.s12.bold.tabular,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          12.szH,
          _ReasonBox(order: order),
          12.szH,
          Row(
            children: [
              Expanded(child: _ReturnButton(onTap: onReturn)),
              12.szW,
              _CallButton(),
            ],
          ),
        ],
      ).paddingAll(AppPadding.pH16),
    );
  }
}

/// Amber "returns at" pill.
class _ReturnBadge extends StatelessWidget {
  const _ReturnBadge({required this.time});
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.postponedBg,
        borderRadius: BorderRadius.circular(AppCircular.r8),
        border: Border.all(color: AppColors.postponedBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconWidget(
            icon: AppAssets.svg.clock,
            color: AppColors.postponedText,
            height: AppSize.sH14,
            width: AppSize.sW14,
          ),
          4.szW,
          Text(LocaleKeys.returnsAt.tr(namedArgs: {'time': time}),
              style: const TextStyle().setColor(AppColors.postponedText).s12.bold),
        ],
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}

/// Grey reason box.
class _ReasonBox extends StatelessWidget {
  const _ReasonBox({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppCircular.r12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LocaleKeys.postponeReasonLabel.tr(),
              style: const TextStyle().setTertiaryColor.s12.bold),
          4.szH,
          Text(
            LocaleKeys.postponeReasonValue.tr(namedArgs: {
              'reason': order.reason ?? '',
              'time': order.postponedAt ?? '',
            }),
            style: const TextStyle().setSecondaryColor.s12.regular.withHeight(1.7),
          ),
        ],
      ).paddingAll(AppPadding.pH12),
    );
  }
}

/// Outlined "return to queue" button.
class _ReturnButton extends StatelessWidget {
  const _ReturnButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.sH48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r13),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconWidget(
            icon: AppAssets.svg.undo,
            color: AppColors.brand,
            height: AppSize.sH18,
            width: AppSize.sW18,
          ),
          8.szW,
          Text(LocaleKeys.returnToQueue.tr(),
              style: const TextStyle().setMainTextColor.s14.bold),
        ],
      ),
    ).onClick(onTap: onTap);
  }
}

/// Square outlined call button.
class _CallButton extends StatelessWidget {
  const _CallButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSize.sH48,
      height: AppSize.sH48,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r13),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Center(
        child: IconWidget(
          icon: AppAssets.svg.phone,
          color: AppColors.textPrimary,
          height: AppSize.sH18,
          width: AppSize.sW18,
        ),
      ),
    );
  }
}
