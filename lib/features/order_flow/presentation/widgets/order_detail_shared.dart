part of '../imports/order_flow_imports.dart';

/// Full-width hairline divider between detail sections.
class _HDivider extends StatelessWidget {
  const _HDivider();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: AppSize.sH1,
        child: const ColoredBox(color: AppColors.borderHeader),
      );
}

/// A simple filled circle (status dot / timeline dot).
class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.h,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// An outlined pill button with a leading icon and centered label — used for
/// call / whatsapp / open-on-map actions.
class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.icon,
    required this.label,
    required this.fg,
    required this.border,
    required this.background,
  });

  final String icon;
  final String label;
  final Color fg;
  final Color border;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.sH48,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppCircular.r13),
        border: Border.all(color: border),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconWidget(
            icon: icon,
            color: fg,
            height: 19.h, // between the 18/20 tokens
            width: 19.w,
          ),
          8.szW,
          Text(label, style: const TextStyle().setColor(fg).s14.semiBold),
        ],
      ),
    );
  }
}
