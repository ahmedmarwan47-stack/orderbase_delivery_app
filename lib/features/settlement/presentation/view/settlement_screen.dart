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
  });

  /// Defaults to [shiftSettlement] (built live from today's shift) when null, so
  /// the app shell shows real settlement data. Preview/DevGallery callers pass an
  /// explicit [data] (e.g. [sampleSettlement]).
  final SettlementData? data;
  final SettlementStage startStage;

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  late final SettlementController _vc = SettlementController(
    data: widget.data ?? shiftSettlement,
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
      child: ValueListenableBuilder<SettlementStage>(
        valueListenable: _vc.stage,
        builder: (_, stage, _) => switch (stage) {
          SettlementStage.open => _SettlementOpenView(vc: _vc),
          SettlementStage.settled => _SettlementSettledView(vc: _vc),
        },
      ),
    );
  }
}
