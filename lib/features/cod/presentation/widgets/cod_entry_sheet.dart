part of '../imports/cod_imports.dart';

/// Formats the amount field's digits with thousands separators as the courier
/// types (1250 → "1,250"), collapsing leading zeros and capping at 7 digits.
class _ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue _, TextEditingValue next) {
    var digits = next.text.replaceAll(RegExp(r'[^0-9]'), '');
    digits = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (digits.length > 7) digits = digits.substring(0, 7);
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final text = formatThousands(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// COD 2a — screen 1: tap the amount field to bring up the phone's own numeric
/// keyboard and type the collected cash. The field re-tints live (neutral /
/// amber for excess / red for short); confirm enables once the order value is met.
class _CodEntrySheet extends StatefulWidget {
  const _CodEntrySheet({
    required this.due,
    required this.orderNum,
    required this.customerName,
    this.initial = '',
  });

  final int due;
  final String orderNum;
  final String customerName;
  final String initial;

  @override
  State<_CodEntrySheet> createState() => _CodEntrySheetState();
}

class _CodEntrySheetState extends State<_CodEntrySheet> {
  late final TextEditingController _text =
      TextEditingController(text: widget.initial);
  final FocusNode _focus = FocusNode();

  CodAmount get _amount => CodAmount(raw: _text.text, due: widget.due);

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetShell(
      title: LocaleKeys.codEntryTitle.tr(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.codOrderLine.tr(namedArgs: {
              'num': widget.orderNum,
              'name': widget.customerName,
              'due': formatThousands(widget.due),
            }),
            style: const TextStyle().setSecondaryColor.s14.regular,
          ),
          20.szH,
          ListenableBuilder(
            listenable: _text,
            builder: (_, _) => _AmountField(
              a: _amount,
              controller: _text,
              focusNode: _focus,
            ),
          ),
          20.szH,
          ListenableBuilder(
            listenable: _text,
            builder: (_, _) => _ConfirmButton(
              a: _amount,
              onConfirm: () => Navigator.of(context).pop(_amount.amount),
            ),
          ),
        ],
      ),
    );
  }
}

/// The big collected-amount readout. A transparent [TextField] fills the field
/// to own the OS keyboard; the visible number is drawn on top and passes taps
/// through, so tapping anywhere in the field focuses it.
class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.a,
    required this.controller,
    required this.focusNode,
  });

  final CodAmount a;
  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = a.isShort
        ? AppColors.failedBorder
        : (a.hasExtra ? AppColors.codExcessAmber : AppColors.borderHeader);
    final Color amountColor =
        a.isEmpty ? AppColors.timelineDotMuted : AppColors.textPrimary;

    final String hint;
    final Color hintColor;
    if (a.isShort) {
      hint = LocaleKeys.codHintShort
          .tr(namedArgs: {'amount': formatThousands(a.short)});
      hintColor = AppColors.failedText;
    } else if (a.hasExtra) {
      hint = LocaleKeys.codHintExtra
          .tr(namedArgs: {'amount': formatThousands(a.extra)});
      hintColor = AppColors.postponedText;
    } else {
      hint = LocaleKeys.codHintMatch.tr();
      hintColor = AppColors.textSecondary;
    }

    final amountStyle = const TextStyle()
        .setColor(amountColor)
        .s24 // was s28 — big-font trim sweep
        .bold
        .withHeight(1)
        .tabular;

    // Tapping anywhere in the field focuses the input → OS numeric keyboard.
    return GestureDetector(
      onTap: focusNode.requestFocus,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.reasonRowBg,
          borderRadius: BorderRadius.circular(AppCircular.r16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                IntrinsicWidth(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: false),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ThousandsInputFormatter(),
                    ],
                    textDirection: TextDirection.ltr,
                    cursorColor: AppColors.brand,
                    style: amountStyle,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: amountStyle.copyWith(
                          color: AppColors.timelineDotMuted),
                    ),
                  ),
                ),
                8.szW,
                Text(
                  LocaleKeys.codUnit.tr(),
                  style: const TextStyle()
                      .setColor(AppColors.chipCountMuted)
                      .s16
                      .semiBold,
                ),
              ],
            ),
            8.szH,
            Text(hint,
                style: const TextStyle().setColor(hintColor).s12.semiBold),
          ],
        ).paddingSymmetric(
            horizontal: AppPadding.pW20, vertical: AppPadding.pH16),
      ),
    );
  }
}

/// Ink-black when the full amount is collected; disabled grey otherwise, with
/// a label that names why ("اكتب المبلغ" / "المبلغ غير مكتمل" / "تأكيد").
class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.a, required this.onConfirm});
  final CodAmount a;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final enabled = a.canConfirm;
    final String label = (a.isEmpty || a.amount == 0)
        ? LocaleKeys.codConfirmWrite.tr()
        : (a.short > 0
            ? LocaleKeys.codConfirmIncomplete.tr()
            : LocaleKeys.codConfirm.tr());
    final Color fg = enabled ? AppColors.surface : AppColors.chipCountMuted;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Container(
        height: AppSize.sH56,
        decoration: BoxDecoration(
          color: enabled ? AppColors.inkFill : AppColors.borderDefault,
          borderRadius: BorderRadius.circular(AppCircular.r16),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconWidget(
              icon: AppAssets.svg.check,
              color: fg,
              height: AppSize.sH20,
              width: AppSize.sW20,
            ),
            8.szW,
            Text(label, style: const TextStyle().setColor(fg).s14.semiBold),
          ],
        ),
      ).onClick(onTap: enabled ? onConfirm : null),
    );
  }
}
