part of '../imports/settlement_imports.dart';

/// Settlement — end-of-day cash settlement. Ported from Settlement.dc.html.
/// A single screen with two sub-views (OPEN review → SETTLED confirmation); the
/// Screen owns the [SettlementController] lifecycle and swaps views on its
/// `stage`. [startStage] seeds the mockup's `startScreen` prop.
class SettlementScreen extends StatefulWidget {
  const SettlementScreen({
    super.key,
    this.data,
    this.startStage = SettlementStage.open,
    this.onSelectTab,
  });

  /// Defaults to [shiftSettlement] (built live from today's shift) when null, so
  /// the app shell shows real settlement data. Preview/DevGallery callers pass an
  /// explicit [data] (e.g. [sampleSettlement]).
  final SettlementData? data;
  final SettlementStage startStage;

  /// When provided the screen is a shell tab: it renders the shared bottom nav
  /// and drops the standalone back link so it behaves like a normal tab page.
  final ValueChanged<NavTab>? onSelectTab;

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
      // Rebuild as the shift mutates so the live settlement figures stay current
      // (the controller reads shift data live; this drives the redraw).
      child: AnimatedBuilder(
        animation: ShiftController.instance,
        builder: (_, _) => ValueListenableBuilder<SettlementStage>(
          valueListenable: _vc.stage,
          builder: (_, stage, _) => switch (stage) {
            SettlementStage.open =>
              _SettlementOpenView(vc: _vc, onSelectTab: widget.onSelectTab),
            SettlementStage.settled =>
              _SettlementSettledView(vc: _vc, onSelectTab: widget.onSelectTab),
          },
        ),
      ),
    );
  }
}
