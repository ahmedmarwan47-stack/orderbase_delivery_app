import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Dev-only host that opens a bottom sheet automatically over a neutral
/// backdrop, so a sheet can be previewed on its own (gallery entry, or a
/// temporary `home:` for screenshots) without tapping through the flow.
class SheetPreviewHost extends StatefulWidget {
  const SheetPreviewHost({super.key, required this.open, this.label = ''});

  /// Shows the sheet; typically `(context) => showXSheet(context)`.
  final Future<void> Function(BuildContext context) open;
  final String label;

  @override
  State<SheetPreviewHost> createState() => _SheetPreviewHostState();
}

class _SheetPreviewHostState extends State<SheetPreviewHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _show());
  }

  Future<void> _show() async {
    await widget.open(context);
    if (mounted) await _show(); // reopen after dismissal so it stays previewable
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(widget.label,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ),
      ),
    );
  }
}
