part of '../../imports/order_flow_imports.dart';

/// Handoff sheet (Order Flow.dc.html, `showHandoff`): capture the proof-of-
/// delivery photo, then confirm. Cash is no longer collected here — for a COD
/// order the caller runs the COD 2a flow after this; a prepaid order has no
/// cash step at all. Returns `true` when the photo step is confirmed.
Future<bool?> showHandoffSheet(
  BuildContext context, {
  bool cod = true,
  String orderNum = '#89289',
  String customerName = 'محمد حمدي',
}) {
  return showAppSheet<bool>(
    context,
    child: _HandoffSheet(
      cod: cod,
      orderNum: orderNum,
      customerName: customerName,
    ),
  );
}

/// StatefulWidget only to own the [HandoffSheetController] lifecycle — no
/// `setState`; reactive parts rebuild via [ValueListenableBuilder].
class _HandoffSheet extends StatefulWidget {
  const _HandoffSheet({
    required this.cod,
    required this.orderNum,
    required this.customerName,
  });

  /// COD order → the primary button leads on to cash collection (COD 2a);
  /// prepaid → it confirms delivery directly.
  final bool cod;

  /// The order number (with '#') and customer name shown in the header line.
  final String orderNum;
  final String customerName;

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
                  text: widget.orderNum,
                  style: const TextStyle().setTertiaryColor.semiBold,
                ),
                // i18n: " — " separator between order number and customer name.
                TextSpan(text: ' — ${widget.customerName}'),
              ],
            ),
          ),
          16.szH,
          Text.rich(
            TextSpan(
              text: LocaleKeys.handoffPhotoLabel.tr(),
              style: const TextStyle().setMainTextColor.s14.semiBold,
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
          20.szH,
          // The proof photo is required (red *): the confirm button stays
          // disabled (muted fill + text, no tap) until a photo is captured.
          ValueListenableBuilder<bool>(
            valueListenable: _controller.photo,
            builder: (_, captured, _) {
              final fg = captured
                  ? AppColors.surface
                  : AppColors.chipCountMuted;
              return Container(
                height: AppSize.sH56,
                decoration: BoxDecoration(
                  color: captured ? AppColors.inkFill : AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(
                    AppCircular.r15,
                  ), // mockup radius
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconWidget(
                      icon: widget.cod
                          ? AppAssets.svg.cash
                          : AppAssets.svg.check,
                      color: fg,
                      height: AppSize.sH20,
                      width: AppSize.sW20,
                    ),
                    8.szW,
                    Text(
                      widget.cod
                          ? LocaleKeys.handoffCollectNext.tr()
                          : LocaleKeys.handoffTitle.tr(),
                      style: const TextStyle().setColor(fg).s14.semiBold,
                    ),
                  ],
                ),
              ).onClick(
                onTap: captured ? () => Navigator.of(context).pop(true) : null,
              );
            },
          ),
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
              borderRadius: BorderRadius.circular(
                AppCircular.r14,
              ), // mockup radius
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
            style: const TextStyle().setMainTextColor.s14.semiBold,
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
              top: 10.h, // 10px overlay inset (mockup) — off the 4px grid
              start: 10.w,
              // Confirm beat: the "captured" check settles in with a small
              // scale + fade the instant the photo lands. Instant under
              // Reduce Motion. This subtree is rebuilt only when the photo is
              // taken, so the one-shot tween plays exactly once.
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: MediaQuery.of(context).disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                builder: (_, t, child) => Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: Transform.scale(scale: 0.7 + 0.3 * t, child: child),
                ),
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
            ),
            PositionedDirectional(
              bottom: 10.h, // 10px overlay inset (mockup) — off the 4px grid
              end: 10.w,
              child: Container(
                height: 32.h,
                decoration: BoxDecoration(
                  color: AppColors.scrim,
                  borderRadius: BorderRadius.circular(
                    AppCircular.r9,
                  ), // mockup radius
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
}
