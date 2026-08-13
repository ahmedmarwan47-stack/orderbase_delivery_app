part of '../imports/failure_states_imports.dart';

/// 1g · «الطلبات» with a «مرتجعات للفرع» banner — the active orders list showing
/// what's in the courier's custody at the top (not in settlement). The banner
/// disappears once the returns are handed to the branch. This lives in the
/// active queue, not the settlement screen.
///
/// Public route entry point for the returns list state.
class ReturnsListScreen extends StatelessWidget {
  const ReturnsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: const SafeArea(child: _ReturnsListBody()),
      ),
    );
  }
}
