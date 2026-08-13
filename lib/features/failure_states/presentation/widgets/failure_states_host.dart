part of '../imports/failure_states_imports.dart';

/// Hosts the failure flow over a faithful order-detail context (the dimmed
/// screen the mockup shows behind every sheet). Two modes:
///
///  * [preview] set — opens that single state once (for gallery/state review).
///  * [runFlow] true — runs [showFailureFlow] end to end.
///
/// The `showAppSheet` modal supplies the dimming scrim over this background, so
/// the host itself only paints the order context.
class FailureStatesHost extends StatefulWidget {
  const FailureStatesHost({super.key, this.preview, this.runFlow = false});

  final FailureStatePreview? preview;
  final bool runFlow;

  @override
  State<FailureStatesHost> createState() => _FailureStatesHostState();
}

class _FailureStatesHostState extends State<FailureStatesHost> {
  final _ctx = sampleFailureContext();
  final _needsReopen = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  @override
  void dispose() {
    _needsReopen.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    _needsReopen.value = false;
    if (widget.runFlow || widget.preview == null) {
      await showFailureFlow(context, context_: _ctx);
    } else {
      await _openPreview(widget.preview!);
    }
    if (mounted) _needsReopen.value = true;
  }

  Future<void> _openPreview(FailureStatePreview state) {
    final child = switch (state) {
      FailureStatePreview.reason => _ReasonSheet(ctx: _ctx),
      FailureStatePreview.notPresent => _NotPresentSheet(ctx: _ctx),
      FailureStatePreview.wrongAddress => _WrongAddressSheet(ctx: _ctx),
      FailureStatePreview.productMismatch => _ProductMismatchSheet(ctx: _ctx),
      FailureStatePreview.returnToBranch =>
        _ReturnToBranchSheet(ctx: _ctx, reason: FailureReason.notPresent),
    };
    return showAppSheet<Object?>(context, child: child);
  }

  Widget? get _statusBadge => switch (widget.preview) {
        FailureStatePreview.reason || null => _StatusPill(
            label: LocaleKeys.failureStatusInTransit.tr(),
            bg: AppColors.transitPillBg,
            fg: AppColors.transitBg,
          ),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final showAddress = widget.preview == FailureStatePreview.reason ||
        widget.preview == null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              _OrderContextBackground(
                ctx: _ctx,
                statusBadge: _statusBadge,
                body: showAddress
                    ? _AddressCard(ctx: _ctx).paddingSymmetric(
                        horizontal: AppPadding.pW20,
                        vertical: AppPadding.pH16,
                      )
                    : null,
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _needsReopen,
                builder: (context, show, _) => show
                    ? Center(
                        child: _OutlineButton(
                          label: LocaleKeys.failureReopenSheet.tr(),
                          onTap: _open,
                        ).paddingSymmetric(horizontal: AppPadding.pW32),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The order's address card, shown in the reason-step context (1a).
class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.ctx});
  final FailureContext ctx;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderCardFaint),
      ),
      padding: EdgeInsets.all(AppPadding.pH16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ctx.address, style: const TextStyle().setMainTextColor.s14.bold),
          8.szH,
          Text(
            ctx.addressDetail,
            style: const TextStyle().setSecondaryColor.s12.regular.withHeight(1.7),
          ),
        ],
      ),
    );
  }
}
