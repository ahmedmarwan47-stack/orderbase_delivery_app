part of '../imports/home_imports.dart';

/// The five-segment "station X of 5" progress bar shared by the Glance / Compact
/// / Flat home variants. Segment 1 done (green), 2 active (brand), 3–5 pending.
/// [segHeight] and [gap] vary per mockup (1b=6/8, 1c=5/4, 2a=4/4).
class _HomeProgressBar extends StatelessWidget {
  const _HomeProgressBar({required this.segHeight, required this.gap});

  final double segHeight;
  final double gap;

  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.greenAccent,
      AppColors.brand,
      AppColors.borderDefault,
      AppColors.borderDefault,
      AppColors.borderDefault,
    ];
    return Row(
      spacing: gap,
      children: [
        for (final c in colors)
          Expanded(
            child: Container(
              height: segHeight,
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(AppCircular.r3), // radii exempt
              ),
            ),
          ),
      ],
    );
  }
}
