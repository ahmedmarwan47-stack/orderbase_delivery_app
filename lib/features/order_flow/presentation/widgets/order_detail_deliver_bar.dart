part of '../imports/order_flow_imports.dart';

/// Sticky bottom bar — the primary "order delivered" action that opens the
/// handoff sheet.
class _DeliverBar extends StatelessWidget {
  const _DeliverBar({this.onDeliver});
  final VoidCallback? onDeliver;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppPadding.pW20,
        right: AppPadding.pW20,
        top: AppPadding.pH12,
        bottom: AppPadding.pH8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderHeader)),
      ),
      child: Container(
        height: AppSize.sH56,
        decoration: BoxDecoration(
          color: AppColors.inkFill,
          borderRadius: BorderRadius.circular(AppCircular.r15), // mockup radius
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconWidget(
              icon: AppAssets.svg.check,
              color: AppColors.surface,
              height: AppSize.sH18,
              width: AppSize.sW18,
            ),
            8.szW,
            Text(
              LocaleKeys.orderDetailDeliver.tr(),
              style: const TextStyle().setWhite.s14.bold,
            ),
          ],
        ),
      ).onClick(onTap: onDeliver),
    );
  }
}
