part of '../imports/auth_imports.dart';

/// The OTP row (Auth.dc.html 1c): [CodeController.len] boxes drawn over a single
/// hidden input (the COD overlay trick — tapping anywhere focuses the input).
/// Box states mirror the mockup: filled = white + 2px ink border, active (next
/// slot) = white + 2px red border, empty = muted fill + 1px hairline.
class _AuthCodeBoxes extends StatelessWidget {
  const _AuthCodeBoxes({required this.vc});
  final CodeController vc;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: vc.codeController,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(vc.len),
              ],
              onChanged: vc.onCodeChanged,
              showCursor: false,
              enableInteractiveSelection: false,
              style: const TextStyle(fontSize: 1, color: Color(0x00000000)),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: ValueListenableBuilder<String>(
            valueListenable: vc.code,
            builder: (context, code, _) => Row(
              // LTR so the digits fill left→right within the RTL screen.
              textDirection: TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < vc.len; i++) ...[
                  if (i > 0) 8.szW,
                  _AuthCodeBox(
                    char: i < code.length ? code[i] : '',
                    filled: i < code.length,
                    active: i == code.length,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthCodeBox extends StatelessWidget {
  const _AuthCodeBox({
    required this.char,
    required this.filled,
    required this.active,
  });
  final String char;
  final bool filled;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color border = filled
        ? AppColors.inkFill
        : (active ? AppColors.brand : AppColors.borderDefault);
    final double width = (filled || active) ? 2 : 1;
    return Container(
      height: AppSize.sH56,
      width: AppSize.sW48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: filled ? AppColors.surface : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppCircular.r14),
        border: Border.all(color: border, width: width),
      ),
      child: Text(
        char,
        textDirection: TextDirection.ltr,
        style: const TextStyle().setMainTextColor.s20.bold.tabular,
      ),
    );
  }
}
