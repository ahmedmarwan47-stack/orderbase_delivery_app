part of '../imports/auth_imports.dart';

/// The account card atop Change password (Auth.dc.html 1e): a paper-toned card
/// with an ink avatar (initials), the courier's name, and a "username · merchant"
/// meta line set LTR.
class _AuthProfileCard extends StatelessWidget {
  const _AuthProfileCard({
    required this.initials,
    required this.name,
    required this.username,
    required this.merchant,
  });

  final String initials;
  final String name;
  final String username;
  final String merchant;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppCircular.r16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      padding: EdgeInsets.all(AppPadding.pW16),
      child: Row(
        children: [
          Container(
            height: AppSize.sH48,
            width: AppSize.sW48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.inkFill,
              borderRadius: BorderRadius.circular(AppCircular.r14),
            ),
            child: Text(initials,
                style: const TextStyle().setWhite.s16.bold),
          ),
          12.szW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle().setMainTextColor.s18.bold),
                4.szH,
                Text(
                  '$username · $merchant',
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                  style: const TextStyle().setSecondaryColor.s13.regular.tabular,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
