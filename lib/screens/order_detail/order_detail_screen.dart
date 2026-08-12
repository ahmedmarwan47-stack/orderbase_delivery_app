import 'package:flutter/material.dart';

import '../../icons/app_icon.dart';
import '../../theme/colors.dart';
import '../../theme/radius.dart';
import '../../theme/spacing.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/map_view.dart';
import '../../widgets/status_bar.dart';

/// Order detail — Order Flow step 2 (Order Flow.dc.html, `isOrder`).
/// A faithful static port of the designed detail for order #89289; the mockup
/// doesn't parametrize this view per order, so neither do we yet.
class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key, this.onDeliver, this.onFail});

  /// Opens the handoff sheet (delivered) / fail sheet — wired once those exist.
  final VoidCallback? onDeliver;
  final VoidCallback? onFail;

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
              const StatusBar(),
              _header(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, AppSpacing.s20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: const [
                      _CustomerSection(),
                      SizedBox(height: AppSpacing.s16),
                      _HDivider(),
                      SizedBox(height: AppSpacing.s16),
                      _AddressSection(),
                      SizedBox(height: AppSpacing.s16),
                      _HDivider(),
                      SizedBox(height: AppSpacing.s16),
                      _ItemsSection(),
                      SizedBox(height: AppSpacing.s16),
                      _NotesCard(),
                      SizedBox(height: AppSpacing.s16),
                      _PaymentCard(),
                      SizedBox(height: AppSpacing.s16),
                      _FailButton(),
                      SizedBox(height: AppSpacing.s16),
                      _Timeline(),
                    ],
                  ),
                ),
              ),
              _DeliverBar(onDeliver: onDeliver),
              const BottomNav(active: NavTab.orders, notificationsBadge: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20, AppSpacing.s8, AppSpacing.s20, AppSpacing.s16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderHeader)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s8),
              child: Row(
                children: [
                  AppIcon(AppIconName.chevronRight, color: AppColors.textTertiary, size: 18),
                  SizedBox(width: AppSpacing.s8),
                  Text('الرجوع',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        AppIcon(AppIconName.chat, color: AppColors.textSecondary, size: 19),
                        SizedBox(width: AppSpacing.s8),
                        Text('#89289',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 28 / 24,
                                fontFeatures: [FontFeature.tabularFigures()])),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s4),
                    const Text('١٣ سبتمبر ٫ ١٢:٣٠',
                        textDirection: TextDirection.ltr,
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s8, vertical: AppSpacing.s4),
                    decoration: BoxDecoration(
                      color: AppColors.transitBg,
                      borderRadius: BorderRadius.circular(AppRadius.r8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _Dot(color: Colors.white, size: 7),
                        SizedBox(width: AppSpacing.s8),
                        Text('في الطريق',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  const Text('الدفع عند الاستلام . 1200 جم',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.failedText)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────── Customer ──────────────────────────────

class _CustomerSection extends StatelessWidget {
  const _CustomerSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                AppIcon(AppIconName.user, color: AppColors.textPrimary, size: 18),
                SizedBox(width: AppSpacing.s8),
                Text('بيانات العميل',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ],
            ),
            Text('Mohmaed Hamdy',
                textDirection: TextDirection.ltr,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        Row(
          children: [
            Expanded(
              child: _OutlineActionButton(
                icon: AppIconName.phone,
                label: 'اتصال',
                fg: AppColors.dangerAccent,
                border: AppColors.brand,
                borderWidth: 1.5,
                background: AppColors.surface,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: _OutlineActionButton(
                icon: AppIconName.chat,
                label: 'واتساب',
                fg: AppColors.deliveredText,
                border: AppColors.deliveredBorder,
                background: AppColors.deliveredBg,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────── Address ───────────────────────────────

class _AddressSection extends StatelessWidget {
  const _AddressSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Padding(
              padding: EdgeInsets.only(top: 2),
              child: AppIcon(AppIconName.pin, color: AppColors.brand, size: 18),
            ),
            SizedBox(width: AppSpacing.s8),
            Expanded(
              child: Text(
                '4290 عمارات الضباط - شارع بن عبدالعزيز، الدور الـ5 شقة رقم 52 - زهراء مدينة نصر، القاهرة',
                style: TextStyle(fontSize: 14, color: AppColors.textBody, height: 1.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        const MapView(
          height: 140,
          borderRadius: AppRadius.r16,
          pinDiameter: 34,
          pinIconSize: 18,
          pinVerticalAlignment: -0.04,
        ),
        const SizedBox(height: AppSpacing.s12),
        _OutlineActionButton(
          icon: AppIconName.nav,
          iconColor: AppColors.brand,
          label: 'فتح العنوان على الخريطة',
          fg: AppColors.textPrimary,
          border: AppColors.borderDefault,
          background: AppColors.surface,
          height: 48,
        ),
      ],
    );
  }
}

// ──────────────────────────────── Items ────────────────────────────────

class _ItemsSection extends StatelessWidget {
  const _ItemsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.s8),
          child: Row(
            children: const [
              AppIcon(AppIconName.bag, color: AppColors.textPrimary, size: 18),
              SizedBox(width: AppSpacing.s8),
              Text('بيانات الطلب',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
        ),
        const _ItemRow(withDivider: true),
        const _ItemRow(withDivider: false),
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.withDivider});
  final bool withDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: AppSpacing.s12, bottom: withDivider ? AppSpacing.s12 : AppSpacing.s4),
      decoration: withDivider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.itemDivider)))
          : null,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 84,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.r12),
                child: Image.asset('assets/merchant/fudge-cake.jpg', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('فادج شوكولاتة بالبندق',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  SizedBox(height: AppSpacing.s4),
                  Text('متوسطة – 20 سم',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  SizedBox(height: AppSpacing.s4),
                  Text('600 جم',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary,
                          fontFeatures: [FontFeature.tabularFigures()])),
                ],
              ),
            ),
            const SizedBox(
              width: 34,
              child: Align(
                alignment: Alignment.center,
                child: Text('×2',
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        fontFeatures: [FontFeature.tabularFigures()])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────── Notes ────────────────────────────────

class _NotesCard extends StatelessWidget {
  const _NotesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.postponedBannerBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.postponedBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              AppIcon(AppIconName.note, color: AppColors.postponedText, size: 18),
              SizedBox(width: AppSpacing.s8),
              Text('ملاحظات العميل',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.postponedText)),
            ],
          ),
          SizedBox(height: AppSpacing.s8),
          Text(
            'برجاء الاتصال قبل التوصيل بساعة على الأقل. العميل في الدور الخامس والمصعد معطّل، فيُرجى الصعود على السلّم. لو لم يردّ على الهاتف، جرّب الرقم البديل 0100 123 4567 أو اترك الطلب مع الأمن في البوابة الرئيسية وأبلغني برسالة.',
            style: TextStyle(fontSize: 14, color: AppColors.postponedTextStrong, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────── Payment ───────────────────────────────

class _PaymentCard extends StatelessWidget {
  const _PaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s16),
      decoration: BoxDecoration(
        color: AppColors.paymentCardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('المطلوب تحصيله نقدًا',
                  style: TextStyle(fontSize: 12, color: AppColors.paymentLabel)),
              const SizedBox(height: AppSpacing.s4),
              Text.rich(
                TextSpan(
                  text: '1,200',
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                      fontFeatures: [FontFeature.tabularFigures()]),
                  children: const [
                    TextSpan(
                        text: ' جم',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.paymentSuffix)),
                  ],
                ),
              ),
            ],
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.paymentTile,
              borderRadius: BorderRadius.circular(AppRadius.r13),
            ),
            child: const Center(
              child: AppIcon(AppIconName.cash, color: AppColors.cashBright, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────── Fail btn ──────────────────────────────

class _FailButton extends StatelessWidget {
  const _FailButton();

  @override
  Widget build(BuildContext context) {
    // Note: wired via the parent's onFail once the fail sheet exists.
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.failedBorder, width: 1.5),
      ),
      alignment: Alignment.center,
      child: const Text('لم يتم التسليم',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.dangerAccent)),
    );
  }
}

// ─────────────────────────────── Timeline ──────────────────────────────

class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.s4, AppSpacing.s8, AppSpacing.s4, AppSpacing.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.s12),
            child: Text('خط سير الطلب',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textTertiary)),
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.brand,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.timelineRing, width: 3),
                      ),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: SizedBox(width: 2, child: ColoredBox(color: AppColors.borderDefault)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.s12),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.s12),
                    child: _TimelineText(
                      title: 'تم التقاط الطلب من الفرع',
                      time: '13 سبتمبر 2024 · 01:30pm',
                      titleColor: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(
                width: 12,
                child: _Dot(color: AppColors.timelineDotMuted, size: 12),
              ),
              SizedBox(width: AppSpacing.s12),
              Expanded(
                child: _TimelineText(
                  title: 'تم اسناد الطلب لك للتوصيل',
                  time: '13 سبتمبر 2024 · 12:30pm',
                  titleColor: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimelineText extends StatelessWidget {
  const _TimelineText({required this.title, required this.time, required this.titleColor});
  final String title;
  final String time;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700, color: titleColor, height: 20 / 14)),
        Text(time,
            textDirection: TextDirection.ltr,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 16 / 12)),
      ],
    );
  }
}

// ─────────────────────────────── Deliver bar ───────────────────────────

class _DeliverBar extends StatelessWidget {
  const _DeliverBar({this.onDeliver});
  final VoidCallback? onDeliver;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderHeader)),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20, AppSpacing.s12, AppSpacing.s20, AppSpacing.s8),
      child: GestureDetector(
        onTap: onDeliver,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.inkFill,
            borderRadius: BorderRadius.circular(15),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              AppIcon(AppIconName.check, color: Colors.white, size: 20),
              SizedBox(width: AppSpacing.s8),
              Text('تم تسليم الطلب للعميل',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────── shared bits ───────────────────────────

class _HDivider extends StatelessWidget {
  const _HDivider();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 1, child: ColoredBox(color: AppColors.borderHeader));
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.icon,
    required this.label,
    required this.fg,
    required this.border,
    required this.background,
    this.iconColor,
    this.borderWidth = 1,
    this.height = 48,
  });

  final AppIconName icon;
  final String label;
  final Color fg;
  final Color? iconColor;
  final Color border;
  final Color background;
  final double borderWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.r13),
        border: Border.all(color: border, width: borderWidth),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppIcon(icon, color: iconColor ?? fg, size: 19),
          const SizedBox(width: AppSpacing.s8),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}
