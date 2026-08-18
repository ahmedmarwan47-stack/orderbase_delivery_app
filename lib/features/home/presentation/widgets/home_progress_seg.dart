part of '../imports/home_imports.dart';

/// One segment of the next-stop progress bar — just the coloured bar; the
/// caller ([_HomeStopProgress]) supplies the `Expanded` and the tap target.
class _HomeProgressSeg extends StatelessWidget {
  const _HomeProgressSeg(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.sH6,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(
          AppCircular.r3,
        ), // radii exempt from 4px rule
      ),
    );
  }
}
