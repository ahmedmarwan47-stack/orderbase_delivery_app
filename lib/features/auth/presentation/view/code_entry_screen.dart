part of '../imports/auth_imports.dart';

/// Auth 1c — Code entry. Six OTP boxes over a hidden input, a resend countdown,
/// a help note, and the ink primary "تأكيد" (disabled until the code is
/// complete). `codeLength` follows the mockup's prop (default 6).
class CodeEntryScreen extends StatefulWidget {
  const CodeEntryScreen({super.key, this.codeLength = 6, this.maskedPhone});

  final int codeLength;

  /// The masked destination number, e.g. "+20 10•• ••56".
  final String? maskedPhone;

  @override
  State<CodeEntryScreen> createState() => _CodeEntryScreenState();
}

class _CodeEntryScreenState extends State<CodeEntryScreen> {
  late final CodeController _vc = CodeController(len: widget.codeLength);

  @override
  void initState() {
    super.initState();
    _vc.start();
  }

  @override
  void dispose() {
    _vc.dispose();
    super.dispose();
  }

  void _confirm() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const NewPasswordScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final phone = widget.maskedPhone ?? '+20 10•• ••56';
    return _AuthScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AuthBackLink(onTap: () => Navigator.of(context).maybePop()),
          20.szH,
          Text(LocaleKeys.authCodeTitle.tr(),
              style: const TextStyle().setMainTextColor.s24.extraBold),
          8.szH,
          Text(
            LocaleKeys.authCodeSubtitle.tr(namedArgs: {'phone': phone}),
            style: const TextStyle().setSecondaryColor.s14.regular.withHeight(1.5),
          ),
          24.szH,
          _AuthCodeBoxes(vc: _vc),
          20.szH,
          _AuthResendRow(vc: _vc),
          16.szH,
          Text(LocaleKeys.authCodeHelp.tr(),
              style: const TextStyle().setSecondaryColor.s12.regular.withHeight(1.5)),
        ],
      ),
      footer: AnimatedBuilder(
        animation: _vc.code,
        builder: (context, _) => _AuthPrimaryButton(
          label: LocaleKeys.authCodeConfirm.tr(),
          enabled: _vc.isComplete,
          onTap: _confirm,
        ),
      ),
    );
  }
}

/// The resend line: a clock glyph + "إعادة إرسال الكود بعد 0:48" while locked,
/// switching to a tappable "إعادة إرسال الكود" once the countdown expires.
class _AuthResendRow extends StatelessWidget {
  const _AuthResendRow({required this.vc});
  final CodeController vc;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: vc.resendSeconds,
      builder: (context, secs, _) {
        if (secs > 0) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconWidget(
                icon: AppAssets.svg.clock,
                color: AppColors.textSecondary,
                height: AppSize.sH16,
                width: AppSize.sW16,
              ),
              8.szW,
              Text(
                LocaleKeys.authResendIn.tr(namedArgs: {'clock': vc.resendClock}),
                style: const TextStyle().setSecondaryColor.s14.regular,
              ),
            ],
          );
        }
        return Align(
          alignment: Alignment.center,
          child: Text(LocaleKeys.authResend.tr(),
                  style: const TextStyle().setMainTextColor.s14.bold)
              .onClick(onTap: vc.resend),
        );
      },
    );
  }
}
