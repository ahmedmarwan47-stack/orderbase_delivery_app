part of '../imports/auth_imports.dart';

/// Code-entry state (Auth.dc.html 1c). Drives [len] OTP boxes over a hidden
/// input, plus the resend countdown. `codeLength` is 4 or 6 (default 6), matching
/// the mockup's `codeLength` prop. ValueNotifier-driven; no `setState`.
class CodeController {
  CodeController({this.len = 6, String initial = ''})
    : code = ValueNotifier(initial),
      resendSeconds = ValueNotifier(0),
      codeController = TextEditingController(text: initial);

  /// Number of digits in the code (mockup default 6; login flows may use 4).
  final int len;

  /// Seconds the resend action stays locked after a send (mockup shows 0:48).
  static const int _resendFrom = 48;

  final ValueNotifier<String> code;
  final ValueNotifier<int> resendSeconds;
  final TextEditingController codeController;

  Timer? _resendTimer;

  bool get isComplete => code.value.length == len;

  /// Formats the countdown as `m:ss` (48 → "0:48").
  String get resendClock {
    final s = resendSeconds.value;
    final mm = s ~/ 60;
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  void start() => _startResend();

  void onCodeChanged(String value) {
    final capped = _digits(value);
    if (capped != codeController.text) {
      codeController.value = TextEditingValue(
        text: capped,
        selection: TextSelection.collapsed(offset: capped.length),
      );
    }
    code.value = capped;
  }

  void resend() {
    if (resendSeconds.value > 0) return;
    code.value = '';
    codeController.clear();
    _startResend();
  }

  void _startResend() {
    _resendTimer?.cancel();
    resendSeconds.value = _resendFrom;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSeconds.value <= 1) {
        resendSeconds.value = 0;
        t.cancel();
      } else {
        resendSeconds.value -= 1;
      }
    });
  }

  /// Western digits only, capped at [len] (Eastern Arabic digits normalized —
  /// the shared "toEnglishNumbers" rule).
  String _digits(String s) {
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(eastern[i], '$i');
    }
    s = s.replaceAll(RegExp(r'[^0-9]'), '');
    return s.length > len ? s.substring(0, len) : s;
  }

  void dispose() {
    _resendTimer?.cancel();
    code.dispose();
    resendSeconds.dispose();
    codeController.dispose();
  }
}
