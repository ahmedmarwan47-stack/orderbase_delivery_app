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

  /// Defaults to [sampleSettlement] (a runtime getter — the cashier name is
  /// localized) when null.
  final SettlementData? data;
  final SettlementStage startStage;

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  late final SettlementController _vc = SettlementController(
    data: widget.data ?? sampleSettlement,
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
