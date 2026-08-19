part of '../imports/settlement_imports.dart';

/// State A — OPEN ("تسوية نهاية اليوم"): white header + scrolling paper body
/// (dark cash card, today's collections, locked note, settle CTA) + bottom nav.
/// Stateful so the header can fade its surface background in as the body scrolls
/// beneath it (iOS large-title behaviour; see [HomeScreen]).
class _SettlementOpenView extends StatefulWidget {
  const _SettlementOpenView({
    required this.vc,
    this.onSelectTab,
    this.onOpenNotifications,
    this.onOpenSearch,
  });
  final SettlementController vc;
  final ValueChanged<NavTab>? onSelectTab;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenSearch;

  @override
  State<_SettlementOpenView> createState() => _SettlementOpenViewState();
}

class _SettlementOpenViewState extends State<_SettlementOpenView> {
  final ScrollController _scroll = ScrollController();

  // The header is transparent at the top and gains its surface background once
  // content scrolls beneath it.
  final ValueNotifier<bool> _scrolled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final v = _scroll.offset > 2;
    if (v != _scrolled.value) _scrolled.value = v;
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    _scrolled.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSelectTab = widget.onSelectTab;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: onSelectTab == null,
        child: Column(
          children: [
            // Shell tab: unified header on top, the date/branch + "not settled"
            // pill become a transparent sub-head. Standalone: keep back + fade.
            if (onSelectTab != null) ...[
              AppHeader(
                onSearch: widget.onOpenSearch,
                onOpenNotifications: widget.onOpenNotifications,
              ),
              const _SettlementHeader(showBack: false, scrolled: false),
            ] else
              ValueListenableBuilder<bool>(
                valueListenable: _scrolled,
                builder: (_, scrolled, _) =>
                    _SettlementHeader(showBack: true, scrolled: scrolled),
              ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scroll,
                padding: EdgeInsetsDirectional.only(
                  start: AppPadding.pW20,
                  end: AppPadding.pW20,
                  top: AppPadding.pH8,
                  bottom: AppPadding.pH24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CashInHandCard(vc: widget.vc),
                    20.szH,
                    _CollectionsSection(data: widget.vc.data),
                    16.szH,
                    const _LockedNote(),
                  ],
                ),
              ),
            ),
            if (onSelectTab != null)
              BottomNav(active: NavTab.settlement, onTap: onSelectTab),
          ],
        ),
      ),
    );
  }
}

/// White header: back button (standalone only), title (standalone only) +
/// subtitle, and the amber "not settled" pill. Transparent at the top of the
/// scroll and fades in its surface background + hairline once scrolled.
class _SettlementHeader extends StatelessWidget {
  const _SettlementHeader({this.showBack = true, this.scrolled = false});

  /// Standalone mode: shows the back button + the big page-name title. Hidden
  /// when Settlement is a shell tab (a root tab has nowhere to go back, and the
  /// tab bar already names the page).
  final bool showBack;

  /// True once the page has scrolled under the header — the header then fades
  /// in its surface background + hairline (transparent while at the top).
  final bool scrolled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        // Fade the SAME white in/out (transparent-white, never transparent-
        // black) so the transition never flashes a dark tint.
        color: AppColors.surface.withValues(alpha: scrolled ? 1 : 0),
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderHeader.withValues(alpha: scrolled ? 1 : 0),
          ),
        ),
      ),
      child:
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showBack) ...[const HeaderBackButton(), 12.szW],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBack) ...[
                      Text(
                        LocaleKeys.settlementTitle.tr(),
                        style: const TextStyle().setMainTextColor.s16.bold,
                      ),
                      4.szH,
                    ],
                    Text(
                      LocaleKeys.settlementSubtitle.tr(),
                      style: const TextStyle().setMainTextColor.s16.bold,
                    ),
                  ],
                ),
              ),
              12.szW,
              const _NotSettledPill(),
            ],
          ).paddingOnlyDirectional(
            start: AppPadding.pW20,
            end: AppPadding.pW20,
            top: AppPadding.pH12,
            bottom: AppPadding.pH16,
          ),
    );
  }
}

/// Amber "غير مُسوّاة" (not settled) status pill.
class _NotSettledPill extends StatelessWidget {
  const _NotSettledPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.heroCodPillBg,
        borderRadius: BorderRadius.circular(AppCircular.r8),
      ),
      child: Text(
        LocaleKeys.settlementNotSettled.tr(),
        style: const TextStyle().setColor(AppColors.postponedText).s12.semiBold,
      ).paddingSymmetric(horizontal: AppPadding.pW8, vertical: AppPadding.pH4),
    );
  }
}
