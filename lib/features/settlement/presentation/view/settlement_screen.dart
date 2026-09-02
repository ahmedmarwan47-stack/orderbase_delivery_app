part of '../imports/settlement_imports.dart';

/// Settlement — the day's cash, batch by batch, and the week before it.
/// Ported from Settlement.dc.html and grown: one screen with two sub-views.
/// OPEN shows what the courier is carrying (per batch) with a status pill
/// that moves from «غير مُسوّاة» to «بانتظار التسوية» once they are expected
/// at the branch; there is no settle button — the branch settles from its
/// dashboard, and when it does the view flips to SETTLED on its own. Both
/// views end with the last seven days.
class SettlementScreen extends StatefulWidget {
  const SettlementScreen({
    super.key,
    this.data,
    this.startStage = SettlementStage.open,
    this.onSelectTab,
    this.onOpenNotifications,
    this.onOpenPendingBatch,
    this.onOpenSearch,
  });

  /// Defaults to [shiftSettlement] (built live from today's shift) when null.
  /// Preview/DevGallery callers pass an explicit [data] (e.g. [sampleSettlement]).
  final SettlementData? data;
  final SettlementStage startStage;

  /// When provided the screen is a shell tab: it renders the shared bottom nav
  /// and drops the standalone back link so it behaves like a normal tab page.
  final ValueChanged<NavTab>? onSelectTab;

  /// Unified-header actions (shell-tab mode).
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenPendingBatch;
  final VoidCallback? onOpenSearch;

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  late final SettlementController _vc = SettlementController(
    data: widget.data,
    startStage: widget.startStage,
  );

  @override
  void dispose() {
    _vc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      // Rebuild as the shift mutates so the live figures stay current and the
      // branch's settlement flips the view.
      child: AnimatedBuilder(
        animation: ShiftController.instance,
        builder: (_, _) => ValueListenableBuilder<SettlementStage>(
          valueListenable: _vc.stage,
          builder: (_, _, _) {
            final data = _vc.data;
            return data.isSettled
                ? _SettlementSettledView(
                    vc: _vc,
                    data: data,
                    onSelectTab: widget.onSelectTab,
                    onOpenNotifications: widget.onOpenNotifications,
                    onOpenPendingBatch: widget.onOpenPendingBatch,
                    onOpenSearch: widget.onOpenSearch,
                  )
                : _SettlementOpenView(
                    vc: _vc,
                    data: data,
                    onSelectTab: widget.onSelectTab,
                    onOpenNotifications: widget.onOpenNotifications,
                    onOpenPendingBatch: widget.onOpenPendingBatch,
                    onOpenSearch: widget.onOpenSearch,
                  );
          },
        ),
      ),
    );
  }
}

/// One past day, read-only — reached from «الأيام السابقة». The same page
/// shape as today (cash card, batches, receipt) with a back button.
class SettlementDayScreen extends StatelessWidget {
  const SettlementDayScreen({super.key, required this.day});
  final SettlementData day;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _SettlementHeader(data: day, showBack: true, scrolled: true),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsetsDirectional.only(
                    start: AppPadding.pW20,
                    end: AppPadding.pW20,
                    top: AppPadding.pH8,
                    bottom: AppPadding.pH24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CashInHandCard(data: day, showBreakdown: true),
                      if (day.settledAt != null) ...[
                        12.szH,
                        _ReceiptCard(data: day),
                      ],
                      20.szH,
                      _BatchesSection(data: day),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
