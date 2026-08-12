part of '../imports/order_flow_imports.dart';

/// The three outcomes of a delivery attempt, shown on the result screen.
enum ResultKind { delivered, failed, postponed }

/// Result — Order Flow terminal step (Order Flow.dc.html, `isResult`).
/// A centered outcome screen with a tinted badge, a summary card whose last
/// row is variant-specific, and two follow-up actions. Defaults match the
/// mockup's sample data for order #89289 (Arabic defaults resolve through
/// [LocaleKeys] when not supplied).
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    this.kind = ResultKind.delivered,
    this.orderNum = '#89289',
    this.customer = 'Mohmaed Hamdy',
    this.codAmount,
    this.showWalletChange = true,
    this.walletChange,
    this.reasonLabel,
    this.postponeDisplay,
    this.onContinue,
    this.onHome,
  });

  final ResultKind kind;
  final String orderNum;
  final String customer;
  final String? codAmount;
  final bool showWalletChange;
  final String? walletChange;
  final String? reasonLabel;
  final String? postponeDisplay;
  final VoidCallback? onContinue;
  final VoidCallback? onHome;

  Color get _tint => switch (kind) {
        ResultKind.delivered => AppColors.greenAccent,
        ResultKind.postponed => AppColors.postponedText,
        ResultKind.failed => AppColors.brand,
      };

  Color get _tintBg => switch (kind) {
        ResultKind.delivered => AppColors.deliveredBg,
        ResultKind.postponed => AppColors.heroCodPillBg,
        ResultKind.failed => AppColors.failedBg,
      };

  String get _icon => switch (kind) {
        ResultKind.delivered => AppAssets.svg.check,
        ResultKind.postponed => AppAssets.svg.clock,
        ResultKind.failed => AppAssets.svg.fail,
      };

  String get _title => switch (kind) {
        ResultKind.delivered => LocaleKeys.resultDeliveredTitle,
        ResultKind.postponed => LocaleKeys.resultPostponedTitle,
        ResultKind.failed => LocaleKeys.resultFailedTitle,
      }
          .tr();

  String get _sub => switch (kind) {
        ResultKind.delivered => LocaleKeys.resultDeliveredSub,
        ResultKind.postponed => LocaleKeys.resultPostponedSub,
        ResultKind.failed => LocaleKeys.resultFailedSub,
      }
          .tr();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: AppSize.sW88 + AppSize.sW8, // 96 badge
                        height: AppSize.sH88 + AppSize.sH8,
                        decoration: BoxDecoration(color: _tintBg, shape: BoxShape.circle),
                        child: Center(
                          child: IconWidget(
                            icon: _icon,
                            color: _tint,
                            height: 52.h, // large badge glyph
                            width: 52.w,
                          ),
                        ),
                      ),
                    ),
                    20.szH,
                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: const TextStyle().setMainTextColor.s24.extraBold,
                    ),
                    8.szH,
                    Text(
                      _sub,
                      textAlign: TextAlign.center,
                      style: const TextStyle()
                          .setSecondaryColor
                          .s14
                          .regular
                          .withHeight(1.6),
                    ),
                    20.szH,
                    _ResultSummaryCard(
                      kind: kind,
                      orderNum: orderNum,
                      customer: customer,
                      codAmount: codAmount ?? LocaleKeys.resultDefaultCod.tr(),
                      showWalletChange: showWalletChange,
                      walletChange: walletChange ?? LocaleKeys.resultDefaultWallet.tr(),
                      reasonLabel: reasonLabel ?? LocaleKeys.resultDefaultReason.tr(),
                      postponeDisplay:
                          postponeDisplay ?? LocaleKeys.resultDefaultPostpone.tr(),
                    ),
                  ],
                ).paddingSymmetric(horizontal: 36.w), // wide mockup gutter
              ),
              _ResultActions(onContinue: onContinue, onHome: onHome),
              const HomeIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
