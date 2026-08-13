part of '../imports/pickup_imports.dart';

/// One ready-to-collect order: merchant thumb, number + pay pill, customer name,
/// and area·pieces meta.
///
/// On first appearance the card fades + rises into place. The delay is
/// [index]-based so the batch reads as a list assembling top-to-bottom, but the
/// total stagger is capped (see [PickupScreen]) so a long list never crawls.
class _PickupCard extends StatelessWidget {
  const _PickupCard({required this.order, this.entranceDelay = Duration.zero});
  final FlowOrder order;

  /// Staggered lead-in before this card animates in. Zero under Reduce Motion.
  final Duration entranceDelay;

  @override
  Widget build(BuildContext context) {
    return _PickupCardEntrance(
      delay: entranceDelay,
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final payLabel =
        order.cod ? LocaleKeys.payCod.tr() : LocaleKeys.pickupPayPaid.tr();
    final payFg = order.cod ? AppColors.postponedText : AppColors.deliveredText;
    final payBg = order.cod ? AppColors.heroCodPillBg : AppColors.deliveredBg;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderCardFaint),
        boxShadow: AppShadows.card,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 84.w, // fixed thumb width (no matching token)
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppCircular.r12),
                child: Image.asset(AppAssets.img.fudgeCake, fit: BoxFit.cover),
              ),
            ),
            12.szW,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        order.num,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle().setMainTextColor.s16.extraBold,
                      ),
                      8.szW,
                      Container(
                        decoration: BoxDecoration(
                          color: payBg,
                          borderRadius: BorderRadius.circular(AppCircular.r7), // pay pill
                        ),
                        child: Text(
                          payLabel,
                          style: const TextStyle().setColor(payFg).s12.bold,
                        ).paddingSymmetric(
                          horizontal: AppPadding.pW8,
                          vertical: AppPadding.pH4,
                        ),
                      ),
                    ],
                  ),
                  4.szH,
                  Text(
                    order.name,
                    style: const TextStyle().setColor(AppColors.textBody).s14.semiBold,
                  ),
                  4.szH,
                  Text(
                    order.meta,
                    style: const TextStyle().setSecondaryColor.s12.regular,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).paddingAll(AppPadding.pH16),
    );
  }
}

/// Plays a one-shot fade + rise for its [child] after [delay], then settles.
/// Under Reduce Motion it renders the child settled immediately (no animation).
class _PickupCardEntrance extends StatefulWidget {
  const _PickupCardEntrance({required this.child, required this.delay});
  final Widget child;
  final Duration delay;

  @override
  State<_PickupCardEntrance> createState() => _PickupCardEntranceState();
}

class _PickupCardEntranceState extends State<_PickupCardEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.settle,
  );
  late final Animation<double> _t =
      CurvedAnimation(parent: _controller, curve: AppMotion.ease);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (AppMotion.reduced(context)) {
      _controller.value = 1; // settled instantly, no stagger
    } else if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _t.value,
          child: Transform.translate(
            // rise ~12px into place
            offset: Offset(0, (1 - _t.value) * 12.h),
            child: child,
          ),
        );
      },
    );
  }
}
