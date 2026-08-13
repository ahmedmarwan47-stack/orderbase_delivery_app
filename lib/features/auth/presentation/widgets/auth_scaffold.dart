part of '../imports/auth_imports.dart';

/// Shared shell for every Auth screen: RTL, warm-paper ground, a scrolling body
/// gutter-padded to 20px, an optional non-scrolling [header] bar on top, and an
/// optional sticky white [footer] bar (hairline top border) above the home
/// indicator — the layout the mockups use across all six states.
class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({required this.body, this.footer});

  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsetsDirectional.only(
                    start: AppPadding.pW20,
                    end: AppPadding.pW20,
                    top: AppPadding.pH16,
                    bottom: AppPadding.pH24,
                  ),
                  child: body,
                ),
              ),
              if (footer != null)
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.borderHeader)),
                  ),
                  child: footer!.paddingOnlyDirectional(
                    start: AppPadding.pW20,
                    end: AppPadding.pW20,
                    top: AppPadding.pH16,
                    bottom: AppPadding.pH12,
                  ),
                ),
              const HomeIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The inline "الرجوع" back link at the top of the flow screens (1b–1d): a
/// chevron + label, tappable, above the title.
class _AuthBackLink extends StatelessWidget {
  const _AuthBackLink({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: LocaleKeys.authBack.tr(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconWidget(
            icon: AppAssets.svg.chevronRight,
            color: AppColors.textSecondary,
            height: AppSize.sH20,
            width: AppSize.sW20,
          ),
          4.szW,
          Text(LocaleKeys.authBack.tr(),
              style: const TextStyle().setSecondaryColor.s14.bold),
        ],
      ).onClick(onTap: onTap),
    );
  }
}
