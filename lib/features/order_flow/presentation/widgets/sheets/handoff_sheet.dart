part of '../../imports/order_flow_imports.dart';

/// Handoff sheet (Order Flow.dc.html, `showHandoff`): capture a delivery photo,
/// confirm the collected cash, optionally move the change to the wallet, then
/// confirm. Returns `true` when delivery is confirmed.
Future<bool?> showHandoffSheet(BuildContext context) {
  return showAppSheet<bool>(context, child: const _HandoffSheet());
}

/// StatefulWidget only to own the [HandoffSheetController] lifecycle — no
/// `setState`; reactive parts rebuild via [ValueListenableBuilder].
class _HandoffSheet extends StatefulWidget {
  const _HandoffSheet();

  @override
  State<_HandoffSheet> createState() => _HandoffSheetState();
}

class _HandoffSheetState extends State<_HandoffSheet> {
  final HandoffSheetController _controller = HandoffSheetController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetShell(
      title: LocaleKeys.handoffTitle.tr(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              text: LocaleKeys.handoffOrderPrefix.tr(),
              style: const TextStyle().setSecondaryColor.s14.regular,
              children: [
                TextSpan(
                  text: '#89289',
                  style: const TextStyle().setTertiaryColor.bold,
                ),
                TextSpan(text: LocaleKeys.handoffOrderCustomer.tr()),
              ],
            ),
          ),
          16.szH,
          Text.rich(
            TextSpan(
              text: LocaleKeys.handoffPhotoLabel.tr(),
              style: const TextStyle().setMainTextColor.s14.bold,
              children: [
                TextSpan(
                  text: '*',
                  style: const TextStyle().setColor(AppColors.dangerAccent),
                ),
              ],
            ),
          ),
          8.szH,
          ValueListenableBuilder<bool>(
            valueListenable: _controller.photo,
            builder: (_, captured, _) =>
                captured ? _capturedPhoto() : _capturePrompt(),
          ),
          16.szH,
          _codCard(),
          16.szH,
          Container(
            height: AppSize.sH56,
            decoration: BoxDecoration(
              color: AppColors.inkFill,
              borderRadius: BorderRadius.circular(15.r), // mockup radius
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconWidget(
                  icon: AppAssets.svg.check,
                  color: AppColors.surface,
                  height: AppSize.sH20,
                  width: AppSize.sW20,
                ),
                8.szW,
                Text(
                  LocaleKeys.handoffTitle.tr(),
                  style: const TextStyle().setWhite.s16.bold,
                ),
              ],
            ),
          ).onClick(onTap: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
  }

  Widget _capturePrompt() {
    return Container(
      height: 141.h, // fixed capture-area height from the mockup
      decoration: BoxDecoration(
        color: AppColors.photoDashBg,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.dashedBorder, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52.w, // camera icon tile
            height: 52.h,
            decoration: BoxDecoration(
              color: AppColors.photoTile,
              borderRadius: BorderRadius.circular(14.r), // mockup radius
            ),
            child: Center(
              child: IconWidget(
                icon: AppAssets.svg.cam,
                color: AppColors.textTertiary,
                height: 26.h,
                width: 26.w,
              ),
            ),
          ),
          4.szH,
          Text(
            LocaleKeys.handoffCaptureTitle.tr(),
            style: const TextStyle().setMainTextColor.s14.bold,
          ),
          Text(
            LocaleKeys.handoffCaptureSub.tr(),
            style: const TextStyle().setSecondaryColor.s12.regular,
          ),
        ],
      ),
    ).onClick(onTap: _controller.capture);
  }

  Widget _capturedPhoto() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppCircular.r16),
      child: SizedBox(
        height: 130.h, // fixed captured-photo height from the mockup
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppAssets.img.fudgeCake, fit: BoxFit.cover),
            const ColoredBox(color: AppColors.photoGreenWash),
            PositionedDirectional(
              top: 10.h,
              start: 10.w,
              child: Container(
                width: 30.w,
                height: 30.h,
                decoration: const BoxDecoration(
                  color: AppColors.greenAccent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: IconWidget(
                    icon: AppAssets.svg.check,
                    color: AppColors.surface,
                    height: 17.h,
                    width: 17.w,
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              bottom: 10.h,
              end: 10.w,
              child: Container(
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.scrim,
                  borderRadius: BorderRadius.circular(9.r), // mockup radius
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconWidget(
                      icon: AppAssets.svg.cam,
                      color: AppColors.surface,
                      height: AppSize.sH14,
                      width: AppSize.sW14,
                    ),
                    8.szW,
                    Text(
                      LocaleKeys.handoffRecapture.tr(),
                      style: const TextStyle().setWhite.s12.semiBold,
                    ),
                  ],
                ).paddingSymmetric(horizontal: AppPadding.pW12),
              ).onClick(onTap: _controller.capture),
            ),
          ],
        ),
      ),
    );
  }

  Widget _codCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderHeader),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.handoffCodRequired.tr(),
                style: const TextStyle().setSecondaryColor.s14.regular,
              ),
              Text(
                LocaleKeys.handoffCodAmount.tr(),
                style: const TextStyle().setMainTextColor.s16.extraBold.tabular,
              ),
            ],
          ),
          16.szH,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.handoffCollectedLabel.tr(),
                style: const TextStyle().setMainTextColor.s14.bold,
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(11.r), // mockup radius
                  border: Border.all(color: AppColors.inkFill, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '1,250',
                      style: const TextStyle().setMainTextColor.s18.extraBold.tabular,
                    ),
                    8.szW,
                    Text(
                      LocaleKeys.handoffEgpSuffix.tr(),
                      style: const TextStyle().setSecondaryColor.s12.regular,
                    ),
                  ],
                ).paddingSymmetric(
                  horizontal: AppPadding.pW12,
                  vertical: AppPadding.pH8,
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: AppMargin.mH16),
            padding: EdgeInsets.only(top: AppPadding.pH12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.summaryDivider)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      IconWidget(
                        icon: AppAssets.svg.wallet,
                        color: AppColors.postponedText,
                        height: AppSize.sH18,
                        width: AppSize.sW18,
                      ),
                      8.szW,
                      Flexible(
                        child: Text(
                          LocaleKeys.handoffWalletToggle.tr(),
                          style: const TextStyle()
                              .setColor(AppColors.textBody)
                              .s14
                              .semiBold,
                        ),
                      ),
                    ],
                  ),
                ),
                8.szW,
                ValueListenableBuilder<bool>(
                  valueListenable: _controller.wallet,
                  builder: (_, on, _) => _WalletToggle(on: on),
                ),
              ],
            ).onClick(onTap: _controller.toggleWallet),
          ),
        ],
      ).paddingAll(AppPadding.pH16),
    );
  }
}

/// The wallet on/off switch — knob sits at the RTL end when on.
class _WalletToggle extends StatelessWidget {
  const _WalletToggle({required this.on});
  final bool on;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46.w, // fixed track width from the mockup
      decoration: BoxDecoration(
        color: on ? AppColors.greenAccent : AppColors.dashedBorder,
        borderRadius: BorderRadius.circular(15.r), // mockup radius
      ),
      child: Row(
        // flex-end (mockup "on") maps to the end of the RTL row.
        mainAxisAlignment: on ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            width: 21.w,
            height: 21.h,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ).paddingAll(AppPadding.pH4),
    );
  }
}
