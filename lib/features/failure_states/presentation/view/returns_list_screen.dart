part of '../imports/failure_states_imports.dart';

/// The dedicated «مرتجعات للفرع» (returns to branch) page — a returns-focused
/// screen showing what's in the courier's custody: a prominent count of orders
/// to return, the list of returned orders, and the handover action. Confirming
/// the handover (a confirmation sheet) hands the batch to the branch and flips
/// the page to its empty state. Custody lives here, not in settlement.
///
/// Public route entry point for the returns page.
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
