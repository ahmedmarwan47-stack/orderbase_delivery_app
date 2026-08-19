part of '../imports/queue_imports.dart';

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
