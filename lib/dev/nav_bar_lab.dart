import 'dart:async';

import 'package:flutter/material.dart';

import '../config/res/config_imports.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/nav_bar_controller.dart';

/// «مختبر شريط التبويب» — the tab bar over content that shows what glass
/// does: dark cards, amber pills, colour bands, text rows. With [autoplay] the
/// page scrolls itself and switches tabs on a timer, so the fold, the lens
/// and the material can be watched (and screenshotted) without a finger on
/// the screen; the bar stays fully live for a real finger too.
class NavBarLab extends StatefulWidget {
  const NavBarLab({super.key, this.autoplay = true, this.cycleMaterials = true});

  final bool autoplay;

  /// With [autoplay], step the material tier (auto → blur → opaque) once per
  /// loop, so the three renderings can be compared in one sitting.
  final bool cycleMaterials;

  @override
  State<NavBarLab> createState() => _NavBarLabState();
}

class _NavBarLabState extends State<NavBarLab> {
  NavTab _tab = NavTab.home;
  final ScrollController _scroll = ScrollController();
  Timer? _timer;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    if (widget.autoplay) {
      _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) => _play());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scroll.dispose();
    // Leave the app on the tier the device would pick for itself.
    NavBarController.instance.material = NavMaterial.auto;
    super.dispose();
  }

  /// One beat of the demo: scroll down (fold), scroll up (open), walk the
  /// tabs, back to the top. Loops.
  void _play() {
    if (!mounted) return;
    switch (_step % 8) {
      case 0:
        if (widget.cycleMaterials && _step > 0) {
          const tiers = [NavMaterial.auto, NavMaterial.blur, NavMaterial.opaque];
          NavBarController.instance.material =
              tiers[(_step ~/ 8) % tiers.length];
        }
        _to(360);
      case 1:
        break;
      case 2:
        _to(200);
      case 3:
        setState(() => _tab = NavTab.orders);
      case 4:
        setState(() => _tab = NavTab.profile);
      case 5:
        setState(() => _tab = NavTab.settlement);
      case 6:
        setState(() => _tab = NavTab.home);
      case 7:
        _to(0);
    }
    _step++;
  }

  void _to(double offset) {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      offset,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        bottomNavigationBar: BottomNav(
          active: _tab,
          onTap: (t) {
            setState(() => _tab = t);
            NavBarController.instance.expand();
          },
        ),
        body: SafeArea(
          bottom: false,
          child: NotificationListener<ScrollNotification>(
            onNotification: NavBarController.instance.handleScroll,
            child: ListView(
              controller: _scroll,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: BottomNav.reservedHeight(context),
              ),
              children: [
                Text(
                  'مختبر شريط التبويب',
                  style: const TextStyle().setMainTextColor.s24.bold,
                ),
                8.szH,
                Text(
                  'المحتوى يمر تحت الشريط: انزل لتطويه، اطلع لتفتحه، اسحب عليه لتنتقل.',
                  style: const TextStyle().setSecondaryColor.s14.regular,
                ),
                16.szH,
                for (var i = 0; i < 3; i++) ...[
                  const _DarkCard(),
                  12.szH,
                  const _Band(),
                  12.szH,
                  for (var r = 0; r < 6; r++) _Row(index: i * 6 + r),
                  16.szH,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkCard extends StatelessWidget {
  const _DarkCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.cashCardTop, AppColors.cashCardBottom],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'النقدية التي معك الآن',
            style: const TextStyle().setColor(AppColors.paymentLabel).s12.medium,
          ),
          8.szH,
          Text('1,250 جم', style: const TextStyle().setWhite.s28.bold),
        ],
      ),
    );
  }
}

/// A band of the app's own colours — the lens has something to bend.
class _Band extends StatelessWidget {
  const _Band();

  static const _colors = [
    AppColors.brand,
    AppColors.transitBg,
    AppColors.greenAccent,
    AppColors.postponedText,
    AppColors.heroBannerTop,
    AppColors.codExcessAmber,
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            for (final c in _colors)
              Expanded(child: ColoredBox(color: c)),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final cod = index.isEven;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Row(
        children: [
          Text(
            '#893${10 + index}',
            textDirection: TextDirection.ltr,
            style: const TextStyle().setMainTextColor.s14.bold,
          ),
          12.szW,
          Expanded(
            child: Text(
              'محمد حمدي · زهراء مدينة نصر · ٤ قطعة',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle().setSecondaryColor.s12.regular,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cod ? AppColors.heroCodPillBg : AppColors.deliveredBg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              cod ? '640 جم' : 'مدفوع',
              style: const TextStyle()
                  .setColor(cod ? AppColors.postponedText : AppColors.deliveredText)
                  .s12
                  .semiBold,
            ),
          ),
        ],
      ),
    );
  }
}
