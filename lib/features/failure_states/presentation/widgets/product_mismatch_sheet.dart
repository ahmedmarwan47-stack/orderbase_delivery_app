part of '../imports/failure_states_imports.dart';

/// 1d · «عدم تطابق المنتج» — step 2 of 2 (a final reason). A branch prep error:
/// an optional photo of the wrong product speeds the fix, plus a mandatory
/// note describing the difference, then advance to the return-to-branch confirm.
class _ProductMismatchSheet extends StatefulWidget {
  const _ProductMismatchSheet({required this.ctx});
  final FailureContext ctx;

  @override
  State<_ProductMismatchSheet> createState() => _ProductMismatchSheetState();
}

class _ProductMismatchSheetState extends State<_ProductMismatchSheet> {
  final _note = TextEditingController(
    text: LocaleKeys.failureMismatchSampleNote.tr(),
  );

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetScaffold(
      title: LocaleKeys.failureReasonMismatch.tr(),
      stepCaption: LocaleKeys.failureStep2Final.tr(),
      onBack: () => Navigator.of(context).pop(SecondStepResult.back),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FieldLabel(LocaleKeys.failurePhotoDeliveredLabel.tr(), strong: true),
          8.szH,
          const _PhotoCaptureButton(),
          8.szH,
          Text(
            LocaleKeys.failurePhotoHint.tr(),
            style: const TextStyle().setSecondaryColor.s12.regular.withHeight(1.5),
          ),
          16.szH,
          _FieldLabel(LocaleKeys.failureDiffNoteLabel.tr()),
          8.szH,
          _NoteField(controller: _note),
          16.szH,
          _Callout(
            icon: FailureIcons.alert,
            iconColor: AppColors.dangerAccent,
            text: LocaleKeys.failureMismatchWarning.tr(),
            bg: AppColors.failedBg,
            textColor: AppColors.failWarnRedText,
            borderColor: AppColors.failWarnRedBorder,
          ),
          20.szH,
          _PrimaryButton(
            label: LocaleKeys.failureNextReturnToBranch.tr(),
            leadingIcon: FailureIcons.box,
            onTap: () => Navigator.of(context).pop(SecondStepResult.next),
          ),
        ],
      ),
    );
  }
}

class _PhotoCaptureButton extends StatelessWidget {
  const _PhotoCaptureButton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: CustomPaint(
        painter: _DashedRectPainter(
          color: AppColors.dashedBorder,
          radius: AppCircular.r16,
          strokeWidth: 2,
        ),
        child: Container(
          height: 140.h, // photo dropzone — no token
          decoration: BoxDecoration(
            color: AppColors.photoDashBg,
            borderRadius: BorderRadius.circular(AppCircular.r16),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52.w, // camera tile — no token
                height: AppSize.sH52,
                decoration: BoxDecoration(
                  color: AppColors.photoTile,
                  borderRadius: BorderRadius.circular(AppCircular.r14),
                ),
                child: Center(
                  child: IconWidget(
                    icon: FailureIcons.cam,
                    color: AppColors.textTertiary,
                    height: AppSize.sH24,
                    width: AppSize.sW24,
                  ),
                ),
              ),
              4.szH,
              Text(LocaleKeys.failureCaptureWrongProduct.tr(),
                  style: const TextStyle().setMainTextColor.s14.bold),
              4.szH,
              Text(LocaleKeys.failureCaptureHint.tr(),
                  style: const TextStyle().setSecondaryColor.s12.regular),
            ],
          ),
        ),
      ).onClick(onTap: () {}),
    );
  }
}

/// Draws a dashed rounded-rect stroke (the mockup's `border:2px dashed`, which
/// Flutter's `Border` can't express).
class _DashedRectPainter extends CustomPainter {
  _DashedRectPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 2,
  });
  final Color color;
  final double radius;
  final double strokeWidth;
  static const double dash = 6;
  static const double gap = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter old) =>
      old.color != color || old.radius != radius || old.strokeWidth != strokeWidth;
}
