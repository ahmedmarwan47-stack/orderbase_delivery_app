---
name: rtl-arabic
description: RTL Arabic rules, layout mirroring prevention, directional APIs, and localization for Flutter_Base.
---

# Skill: RTL Arabic — Flutter_Base

## 🚨 الأولوية القصوى — اقرأ الـ Layout من اليمين للشمال (Non-Negotiable)

> **التصميم عربي 100% — وده يعني إن كل شاشة بتتقرا وبتتبنى من اليمين للشمال.**
> **ده مش "feature" أو "نسخة RTL من تصميم LTR" — ده الـ default الوحيد للمشروع كله.**
> **كل title، كل label، كل first child في Row، كل padding `start` → كله بيبدأ من اليمين.**

### القاعدة الذهبية الواحدة

> **اقفل عين الـ LTR. خد التصميم وافترض إنك بتقرا جريدة عربية — من اليمين للشمال.**
> **العين بتبدأ يمين، فأول حاجة هتشوفها (Title، Logo، Back arrow في AppBar، صورة في كارد) → دي `first child` في الـ Row و `CrossAxisAlignment.start` في الـ Column.**

### Mental Model (احفظها)

```
┌─────────────────────────────────────────────────────┐
│  ← اليوزر بيقرا من هنا                              │
│  RIGHT (يمين، start)                  LEFT (شمال، end)
│  ↓                                                ↓ │
│  [Title]   [Subtitle text continues...]   [Action] │
│  ↑                                                  │
│  first child in Row                                 │
│  CrossAxisAlignment.start in Column                 │
│  paddingStart (= physical right)                    │
└─────────────────────────────────────────────────────┘
```

### Common Senior Mistakes (لا تقع فيهم)

```dart
// ❌ MISTAKE 1 — حسبت إن start = left زي LTR
Column(
  crossAxisAlignment: CrossAxisAlignment.end,  // ← التيتل اتحط شمال!
  children: [Text(LocaleKeys.title.tr())],
)
// ✅ FIX
Column(
  crossAxisAlignment: CrossAxisAlignment.start,  // ← التيتل يمين (مكانه الصح في RTL)
  children: [Text(LocaleKeys.title.tr())],
)

// ❌ MISTAKE 2 — نسخت ترتيب Figma MCP زي ما هو
// MCP بيرجع: [backArrow, title, searchIcon] (LTR reading)
Row(children: [BackArrowWidget(), TitleText(), SearchIconWidget()])
// لكن في التصميم العربي الفعلي:
// - BackArrow على اليمين (لأن اليوزر بيرجع لقدام = يمين)
// - SearchIcon على الشمال
// أول child في الـ Row = يمين في RTL → لو BackArrow هو اللي يمين في الديزاين → BackArrow first ✓
// لكن لو الديزاين معكوس (MCP غلط) → اعكس بنفسك

// ❌ MISTAKE 3 — Positioned(left:/right:) — مش بيتعكس في RTL
Positioned(right: 16, child: Badge())  // ← physical LEFT في RTL!
// ✅ FIX
PositionedDirectional(start: 16, child: Badge())  // ← physical RIGHT في RTL

// ❌ MISTAKE 4 — paddingLeft/Right
widget.paddingLeft(16)  // ← physical left دايماً، مش RTL-safe
// ✅ FIX
widget.paddingStart(16)  // ← physical right في RTL

// ❌ MISTAKE 5 — TextAlign.right للنص العربي "عشان يبان يمين"
Text(LocaleKeys.title.tr(), textAlign: TextAlign.right)
// ← غلط conceptually. TextAlign.start بيعمل المطلوب وبيشتغل في الـ LTR لو الـ user قلب اللغة
// ✅ FIX
Text(LocaleKeys.title.tr(), textAlign: TextAlign.start)
```

### Card / Section Build Checklist (لكل widget أفقي)

```
□ شفت الـ Figma كصورة عربية؟ (مش screenshot reflected)
□ حددت العنصر اللي على اليمين فعلياً في الديزاين؟
□ ده العنصر = first child في الـ Row + Column.crossAxisAlignment.start
□ كل Column جوا الكارد فيها CrossAxisAlignment.start (عشان النصوص تبدأ يمين)
□ كل padding/margin استخدمت .paddingStart/.paddingEnd مش paddingLeft/Right
□ كل Positioned استخدمت PositionedDirectional(start/end:)
□ كل Align استخدمت AlignmentDirectional.centerStart/centerEnd
□ TextAlign.start مش TextAlign.left/right
□ مفيش Directionality حوالين الـ layout — فقط حوالين widgets المعروفة بمشاكلها (راجع الجدول تحت)
```

### القاعدة لما تشك

> **شك = افتح الـ Figma كـ image، حدد العنصر اليمين، تأكد إنه `first child` في كودك.**
> **لو لسه شاكك → اسأل المستخدم. مش تحاول وتعدل بعد كده.**

---

## Project Language Setup

This project uses `easy_localization` + Expo Arabic font.
Language detection via `context.isArabic` and `context.isRight`.

---

## Language Files

```
assets/translations/
├── ar.json    ← Arabic strings
└── en.json    ← English strings

// Access:
tr('key')                    // current language
tr('key', args: [value])     // with args
```

---

## Font — Expo Arabic

Already configured in pubspec.yaml:
```
Expo font family:
  - ExpoArabicBold.ttf     (weight: 700)
  - ExpoArabicSemiBold.ttf (weight: 600)
  - ExpoArabicMedium.ttf   (weight: 500)
  - ExpoArabicBook.ttf     (weight: 400)
  - ExpoArabicLight.ttf    (weight: 300)
```

FontFamily: `ConstantManager.fontFamily` = `'Expo'`
Set globally in `AppTheme.light` → no need to set per widget.

---

## ⚠️ THE MOST IMPORTANT RULE — Layout Mirroring Prevention

> Figma shows Arabic RTL design. Elements on the RIGHT in Figma MUST stay on the RIGHT in Flutter.
> The app is already configured as RTL. Flutter's `start` = physical RIGHT, `end` = physical LEFT.

### The Core Equation (memorize this):
```
Figma RIGHT  →  Flutter "start"
Figma LEFT   →  Flutter "end"
Row first child  →  physical RIGHT
Row last child   →  physical LEFT
```

### ⚠️ Figma MCP Reading Direction — القاعدة الأهم (CRITICAL)

> **ثق في الـ Figma MCP واقرأ البيانات منه بدقة — بس افهم إزاي بيقرأ.**
> **الـ MCP بيقرأ الشاشة من الشمال لليمين (LTR) حتى لو التصميم عربي RTL.**
> **يعني: آخر child في ترتيب الـ MCP = العنصر اللي على اليمين فعلياً في التصميم العربي.**
> **لازم تعكس ترتيب الـ MCP في الكود عشان يطلع صح في RTL.**

**المطلوب:** اقرأ الـ MCP بدقة، افهم كل node، لكن اعكس ترتيب الـ children الأفقية (Row) لأن Flutter RTL بيحط أول child على اليمين.

**إيه اللي بيحصل بالظبط:**
```
التصميم العربي الحقيقي (RTL — اللي اليوزر بيشوفه):
┌──────────────────────────────────┐
│  [أيقونة]    عنوان الشاشة    [←] │   ← AppBar: أيقونة يمين، سهم شمال
│──────────────────────────────────│
│  [صورة المنتج]  │  اسم المنتج    │   ← Card: صورة يمين، نص شمال
│                 │  وصف المنتج    │
│──────────────────────────────────│
│  عرض الكل  ⟩  قسم ١  ⟩  قسم ٢  │   ← Tabs: أول tab على اليمين
└──────────────────────────────────┘

الـ MCP بيقرأها كده (LTR — من الشمال لليمين):
children: [backArrow, title, icon]                    ← الأيقونة آخر واحدة (بس هي يمين!)
children: [textColumn, productImage]                   ← الصورة آخر واحدة (بس هي يمين!)
children: [category2Tab, category1Tab, showAllTab]     ← "عرض الكل" آخر (بس هي يمين!)
```

**القاعدة الذهبية:**
> **آخر child في ترتيب الـ MCP = أول child في كود الـ Row (لأنه هيتحط يمين في RTL).**
> **أول child في ترتيب الـ MCP = آخر child في كود الـ Row (لأنه هيتحط شمال في RTL).**
> **ببساطة: اعكس ترتيب الـ MCP الأفقي في الكود.**

**MANDATORY لكل section أفقي (Row):**
1. **اقرأ الـ MCP nodes بدقة** — اسماء الـ nodes، أنواعها، أحجامها، محتواها
2. **حدد الترتيب الأفقي** — الـ MCP هيرجعه LTR (شمال → يمين)
3. **اعكس الترتيب في الكود** — لأن Row في RTL بيحط أول child على اليمين
4. **النصوص والمحتوى** → اقرأهم من الـ MCP بالظبط (مش محتاج تعكس المحتوى — بس الترتيب)
5. **الـ MCP مصدرك الأساسي** — اقرأه بعناية، الأحجام والألوان والنصوص صح — بس الترتيب الأفقي بس هو اللي محتاج عكس

```dart
// الـ MCP رجع children بالترتيب: [category2Tab, category1Tab, showAllTab]
// → آخر واحد (showAllTab) هو اللي على اليمين فعلياً
// → اعكس الترتيب في الكود:

// ✅ CORRECT — عكسنا ترتيب الـ MCP (آخر عنصر بقى أول child = يمين)
Row(children: [showAllTab, category1Tab, category2Tab])

// ❌ WRONG — نسخت ترتيب الـ MCP من غير عكس
Row(children: [category2Tab, category1Tab, showAllTab])

// الـ MCP رجع: [textColumn, productImage]
// → productImage آخر واحد = هو اللي على اليمين فعلياً
// → اعكس:

// ✅ CORRECT — الصورة first child (يمين في RTL)
Row(children: [CachedImage(...), Expanded(child: textColumn)])

// ❌ WRONG — ترتيب الـ MCP من غير عكس
Row(children: [Expanded(child: textColumn), CachedImage(...)])
```

**خطوات عملية لكل section:**
```
□ Step 1: اقرأ الـ MCP nodes بدقة — النصوص، الأحجام، الألوان (كلهم صح كما هم)
□ Step 2: لكل Row/مجموعة أفقية → اعكس ترتيب الـ children
□ Step 3: أول child في الكود = آخر child في الـ MCP (ده اللي على اليمين)
□ Step 4: آخر child في الكود = أول child في الـ MCP (ده اللي على الشمال)
□ Step 5: Column/عناصر رأسية → الترتيب صح كما هو (من فوق لتحت — مش محتاج عكس)
□ Step 6: كل Column → CrossAxisAlignment.start (عشان النص يبدأ من اليمين)
□ Step 7: لو المستخدم أدى screenshot → استخدمه للتأكيد. لو مأداش → اعتمد على الـ MCP مع عكس الترتيب الأفقي
```

**ملخص — إيه بيتعكس وإيه لأ:**
| البيانات | هل تعكسها؟ | السبب |
|---|---|---|
| ترتيب children الأفقي (Row) | ✅ نعم — اعكس | MCP بيقرأ LTR، Flutter RTL بيحط أول child يمين |
| ترتيب children الرأسي (Column) | ❌ لا — خليه زي ما هو | من فوق لتحت واحد في LTR و RTL |
| النصوص (content) | ❌ لا — خليها زي ما هي | النص العربي هو هو |
| الأحجام (width/height) | ❌ لا — خليها زي ما هي | الأحجام مش بتتأثر بالاتجاه |
| الألوان | ❌ لا — خليها زي ما هي | الألوان مش بتتأثر بالاتجاه |
| padding start/end | ✅ نعم — اعكس | MCP left → Flutter end, MCP right → Flutter start |

### ⚠️ Card Content RTL — Line-by-Line Verification (CRITICAL)

> **مش كفاية إن الكارد نفسه يكون في المكان الصح — المحتوى جوا الكارد لازم يكون RTL صح برده.**
> **ده أكتر حاجة بتطلع غلط — الكارد يبان صح بس جواه النصوص والأيقونات معكوسة.**

**لكل كارد أو component في الشاشة، راجع كل سطر:**

1. **العنوان (Title):** لازم يبقى على **اليمين** — `CrossAxisAlignment.start`
2. **الوصف/النص الفرعي:** لازم يبقى على **اليمين** — `CrossAxisAlignment.start`
3. **أيقونة + نص جنب بعض (Row):** الأيقونة على **اليمين** = first child، النص على **الشمال** = second child
4. **صورة + نص (Row):** طابق الـ Figma بالظبط — لو الصورة يمين في Figma → first child
5. **أزرار/أكشن:** لو على الشمال في Figma → `CrossAxisAlignment.end` أو last child في Row
6. **Badge/Tag:** موقعها يطابق الـ Figma — `PositionedDirectional(start:)` لليمين أو `PositionedDirectional(end:)` للشمال

```dart
// ✅ CORRECT — Card with image RIGHT, text LEFT (matching Figma)
class _ItemCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Image on RIGHT (first child = physical RIGHT in RTL)
        CachedImage(url: item.image, width: AppSize.sW60, height: AppSize.sH60),
        12.szW,
        // Text column on LEFT (second child)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,  // ← text starts from RIGHT
            children: [
              Text(item.name, style: const TextStyle().setMainTextColor.s14.semiBold),
              4.szH,
              Text(item.category, style: const TextStyle().setHintColor.s12.regular),
            ],
          ),
        ),
        // Action icon on far LEFT (last child)
        IconWidget(icon: AppAssets.svg.baseSvg.arrowLeft.path, height: AppSize.sH16),
      ],
    );
  }
}

// ❌ WRONG — Card structure correct but content inside Column is not RTL
Column(
  // crossAxisAlignment missing → text may center instead of aligning RIGHT
  children: [
    Text(item.name),    // ← will be centered, not RIGHT-aligned!
    Text(item.desc),
  ],
)

// ❌ WRONG — Icon and text in wrong order inside card
Row(children: [
  Text('الاسم'),             // ← text on RIGHT (wrong — icon should be first)
  IconWidget(icon: ...),     // ← icon on LEFT
])
// Should be: Row(children: [IconWidget(...), 8.szW, Text('الاسم')])
```

**الـ Checklist لكل كارد:**
```
□ Title/subtitle → CrossAxisAlignment.start (يمين)
□ Icon + Text rows → Icon first child (يمين)، Text second (شمال) — حسب التصميم
□ Image position → يطابق Figma بالظبط (يمين أو شمال)
□ Action buttons/arrows → last child في Row (شمال) أو حسب التصميم
□ كل Column جوا الكارد فيها CrossAxisAlignment.start
□ Padding directional (paddingStart/End) مش paddingLeft/Right
```

---

## RTL Rules for Flutter_Base

### Rule 1 — Column: Text Alignment (Most Common Issue)

The most frequent bug: Arabic titles appearing on LEFT instead of RIGHT.

```dart
// Figma: title is on the RIGHT (Arabic default)
// ✅ CORRECT
Column(
  crossAxisAlignment: CrossAxisAlignment.start,  // → physical RIGHT ✓
  children: [
    Text(LocaleKeys.title.tr()),
    Text(LocaleKeys.subtitle.tr()),
  ],
)

// ❌ WRONG — this pushes titles to physical LEFT
Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  children: [...]
)

// ❌ WRONG — default is center in some contexts
Column(
  // no crossAxisAlignment — text may center
  children: [...]
)
```

### Rule 2 — Row: Children Order

```dart
// Figma AppBar: [← Back on RIGHT]  [Title center]  [Search on LEFT]
// ✅ CORRECT — Figma RIGHT = Row first child
Row(
  children: [
    BackArrowWidget(),        // first = physical RIGHT ✓
    Expanded(child: TitleText()),
    SearchIconWidget(),       // last = physical LEFT ✓
  ],
)

// ❌ WRONG — visually mirrors the whole AppBar
Row(
  children: [
    SearchIconWidget(),       // ends up on RIGHT ✗
    Expanded(child: TitleText()),
    BackArrowWidget(),        // ends up on LEFT ✗
  ],
)
```

### Rule 3 — Stack + Positioned → Always PositionedDirectional

```dart
// ✅ CORRECT
PositionedDirectional(start: 16, top: 10, child: widget)  // physical RIGHT
PositionedDirectional(end: 16, top: 10, child: widget)    // physical LEFT

// ❌ WRONG — reverses in RTL (appears on wrong side)
Positioned(right: 16, top: 10, child: widget)  // → physical LEFT in RTL ✗
Positioned(left: 16, top: 10, child: widget)   // → physical RIGHT in RTL ✗
```

### Rule 4 — Align → Always AlignmentDirectional

```dart
// ✅ CORRECT
Align(alignment: AlignmentDirectional.centerStart)  // physical RIGHT
Align(alignment: AlignmentDirectional.centerEnd)    // physical LEFT
Align(alignment: AlignmentDirectional.topStart)     // top-RIGHT

// ❌ WRONG — LTR specific
Align(alignment: Alignment.centerRight)  // doesn't adapt to RTL
Align(alignment: Alignment.centerLeft)
```

### Rule 5 — Text Alignment

```dart
// ✅ CORRECT
Text(text, textAlign: TextAlign.start)  // → physical RIGHT in RTL

// ❌ WRONG
Text(text, textAlign: TextAlign.left)   // always physical LEFT
Text(text, textAlign: TextAlign.right)  // always physical RIGHT (LTR semantic)
```

### Rule 6 — Padding/Margin → Use Directional Extensions

```dart
// The base project has .paddingStart() and .paddingEnd() extensions
// ALWAYS use these instead of .paddingLeft() / .paddingRight():

widget.paddingStart(AppPadding.pW16)   // → right padding in RTL ✓
widget.paddingEnd(AppPadding.pW16)     // → left padding in RTL ✓

widget.paddingOnlyDirectional(
  start: AppPadding.pW16,   // right
  end: AppPadding.pW8,      // left
  top: AppPadding.pH12,
)

// Same for margin:
widget.marginStart(AppMargin.mW12)    // right margin in RTL
widget.marginEnd(AppMargin.mW12)      // left margin in RTL
widget.marginOnlyDirectional(start: AppMargin.mW16)

// ❌ WRONG
widget.paddingLeft(16)    // always physical left
widget.paddingRight(16)   // always physical right
EdgeInsets.only(right: x) // LTR-specific
```

### Rule 7 — Forbidden List (NEVER use in this project)

```dart
❌ Row(textDirection: TextDirection.rtl, ...)
   → unnecessary, breaks consistency

❌ Positioned(left: x)     → PositionedDirectional(end: x)
❌ Positioned(right: x)    → PositionedDirectional(start: x)
❌ Align(Alignment.centerLeft)    → AlignmentDirectional.centerEnd
❌ Align(Alignment.centerRight)   → AlignmentDirectional.centerStart
❌ EdgeInsets.only(left: x)       → EdgeInsetsDirectional.only(end: x)
❌ EdgeInsets.only(right: x)      → EdgeInsetsDirectional.only(start: x)
❌ TextAlign.left                 → TextAlign.start
```

### Rule 8 — Figma `left` Values → Flutter Conversion

Figma reports element position as `left` value from left edge of screen (physical pixels):

```
Screen width ≈ 390px
Figma left: 340px → means element is near physical RIGHT → PositionedDirectional(start: ~16)
Figma left: 16px  → means element is near physical LEFT  → PositionedDirectional(end: 16)
```

### Rule 9 — Localize All Text

```dart
// ✅ CORRECT — always use LocaleKeys
Text(LocaleKeys.greeting.tr())
Text(LocaleKeys.screenTitle.tr())

// ❌ WRONG
Text('مرحباً')
Text('Hello')
```

### Rule 10 — Add ALL Strings to Translation Files (NO EXCEPTIONS)

> **كل نص متوقع في الشاشة لازم يتضاف في `lang.json` ويستخدم من `LocaleKeys`.**
> **ممنوع تنسى أي نص — حتى labels, hints, button text, error messages, placeholders.**

```json
// assets/translations/lang.json (then run generate)
{
  "feature_name": {
    "title": "عنوان الشاشة",
    "button_submit": "إرسال",
    "hint_search": "ابحث هنا...",
    "error_empty": "هذا الحقل مطلوب",
    "status_paid": "مدفوع",
    "status_completed": "مكتمل"
  }
}
```

```bash
dart run generate/strings/main.dart
```

**ممنوع:**
```dart
// ❌ FORBIDDEN — hardcoded text
Text('مدفوع')
Text('إرسال')
hint: 'ابحث هنا'

// ✅ CORRECT — always from LocaleKeys
Text(LocaleKeys.featureName_statusPaid.tr())
Text(LocaleKeys.featureName_buttonSubmit.tr())
hint: LocaleKeys.featureName_hintSearch.tr()
```

---

## Rule 11 — AppBar, BottomSheet, Dialog RTL (CRITICAL)

> **محتوى الـ AppBar, BottomSheet, Dialog, Modal أحياناً مبيحترمش الـ RTL ومحتاج تظبيطه يدوي.**

```dart
// ✅ CORRECT — Force RTL on dialog/bottom sheet content
showDefaultBottomSheet(
  child: Directionality(
    textDirection: TextDirection.rtl,
    child: _MySheetContent(),
  ),
);

// ✅ CORRECT — Force RTL on dialog content
showCustomDialog(
  context,
  child: Directionality(
    textDirection: TextDirection.rtl,
    child: _MyDialogContent(),
  ),
);

// ✅ CORRECT — AppBar actions/title RTL fix if needed
DefaultScaffold(
  title: LocaleKeys.myTitle.tr(),
  // DefaultScaffold already handles RTL — but if custom AppBar:
  body: const _MyBody(),
)
```

**متى تستخدم Directionality:**
- محتوى bottom sheet / dialog / modal مش بيتعرض RTL صح
- عناصر AppBar مش في المكان الصح
- **على مستوى الـ content widget فقط — مش الشاشة كلها**

---

## Rule 12 — Text Directionality Inside Components (CRITICAL)

> **نص داخل components أحياناً بيتعكس من اليمين للشمال. لازم تتأكد أن النص بيظهر صح.**

بعض الـ widgets (خصوصاً custom components) ممكن النص جواها يتعكس بشكل غير متوقع. الحل:

```dart
// ✅ CORRECT — Force text direction when text appears reversed inside a component
Directionality(
  textDirection: TextDirection.rtl,
  child: Text(LocaleKeys.description.tr()),
)

// ✅ CORRECT — Use textDirection on Text widget directly
Text(
  LocaleKeys.itemName.tr(),
  textDirection: TextDirection.rtl,
  style: const TextStyle().setMainTextColor.s14.regular,
)
```

**متى تستخدم هذا:**
- لو النص داخل component معقد (مثلاً dialog, bottom sheet, custom card) بيظهر معكوس
- لو النص داخل third-party widget مش بيحترم الـ RTL
- فقط على مستوى الـ Text/widget المتأثر — مش على الـ screen كلها

**متى لا تستخدمه:**
- النص طبيعي ومعروض صح → لا تضيف Directionality
- الـ screen-level RTL شغال → لا تكرره

---

## RTL Diagnostic Workflow (MANDATORY for Every Section)

> **بدل ما تتعامل مع RTL كـ checklist عام — استخدم الخطوات دي لكل section:**

**Step 1 — اقرأ الـ MCP nodes ورتبهم:**
```
MCP returns children: [nodeA, nodeB, nodeC]
→ في RTL: nodeA = physical RIGHT, nodeC = physical LEFT
```

**Step 2 — قارن مع الـ screenshot:**
```
Screenshot يوري: صورة على اليمين، نص على الشمال
MCP يقول: [textNode, imageNode]  ← معكوس!
→ النتيجة: MCP mirrored → اعكس الترتيب في الكود
```

**Step 3 — اكتب الكود بناءً على الـ screenshot:**
```dart
// Screenshot: image RIGHT, text LEFT
// ✅ Trust screenshot → image first child
Row(children: [CachedImage(...), Expanded(child: textColumn)])
```

**Step 4 — تحقق من كل Row:**
```
لكل Row في الشاشة:
1. مين أول child؟ → لازم يكون اللي على اليمين في الـ screenshot
2. مين آخر child؟ → لازم يكون اللي على الشمال في الـ screenshot
3. لو مش مطابق → اعكس الـ children order
```

---

## Directionality Wrapper — Exceptions List (CRITICAL)

> **الـ Directionality widget ممنوع على layouts — بس في widgets معينة بتحتاجه.**
> **دي القائمة الكاملة:**

| Widget | المشكلة | الحل |
|---|---|---|
| `DropdownButton` / `DropdownButtonFormField` items | النص جوا الـ items بيتعكس | `Directionality(textDirection: TextDirection.rtl, child: item)` |
| `Slider` / `RangeSlider` labels | الـ labels بتظهر معكوسة | لف الـ Slider في `Directionality` |
| `TabBar` tabs (لو فيها أرقام) | الأرقام بتتعكس | لف الـ Tab content في `Directionality` |
| Third-party date/time pickers | المحتوى مش بيحترم RTL | لف الـ picker content في `Directionality` |
| `showModalBottomSheet` content | المحتوى أحياناً LTR | لف الـ child في `Directionality` |
| `AlertDialog` / `showDialog` content | المحتوى أحياناً LTR | لف الـ content في `Directionality` |

```dart
// ✅ CORRECT — Directionality on specific widget content
DropdownButtonFormField<String>(
  items: cities.map((c) => DropdownMenuItem(
    value: c.id,
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: Text(c.name),
    ),
  )).toList(),
)

// ❌ WRONG — Directionality on entire screen layout
Directionality(
  textDirection: TextDirection.rtl,
  child: Scaffold(body: ...),  // ← NEVER do this
)
```

---

## Figma Arabic Text Detection

When reading Figma text nodes via MCP:

```
If text contains characters in range U+0600–U+06FF → Arabic text
→ Confirm app is running RTL locale
→ Add to ar.json
→ Use tr('key') in generated code
```

Regex to detect Arabic: `[\u0600-\u06FF]`

---

## Language Switching (already in base)

```dart
// lang_cubit.dart already handles this
// Settings screen toggles language:
context.read<LangCubit>().changeLanguage(context, Languages.arabic);
context.read<LangCubit>().changeLanguage(context, Languages.english);
```
