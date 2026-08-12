part of '../imports/order_flow_imports.dart';

/// Outlined "not delivered" button — opens the fail sheet.
class _FailButton extends StatelessWidget {
  const _FailButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.sH52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r15), // mockup radius
        border: Border.all(color: AppColors.failedBorder, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        LocaleKeys.orderDetailNotDelivered.tr(),
        style: const TextStyle().setColor(AppColors.dangerAccent).s14.bold,
      ),
    ).onClick(onTap: onTap);
  }
}
