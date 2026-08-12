part of '../imports/home_imports.dart';

/// One segment of the next-stop progress bar.
class _HomeProgressSeg extends StatelessWidget {
  const _HomeProgressSeg(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: AppSize.sH6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3.r), // radii exempt from 4px rule
        ),
      ),
    );
  }
}
