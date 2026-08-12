---
name: coding-standards
description: Master coding standards reference — colors, sizes, text styles, core widgets, extensions, helpers, forms, navigation, naming, entity safety, slivers, and platform config.
---

# Flutter_Base — Coding Standards

## 🚨 The Strict Six Rules (موصى بها بقوة في كل feature)

> **هذه القواعد الست هي عمود الفقري. أي مخالفة لازم تتبرّر بمبرر فني واضح.**

| # | القاعدة | كيف تطبّق |
|---|--------|----------|
| 1 | **No unnecessary comments.** Comments تشرح **"لماذا"** (intent, gotcha, trade-off) — مش "ماذا" (الكود نفسه يقول ماذا). | امسح أي comment بيكرر اسم متغير/method. لا comments تلقائية. |
| 2 | **No hardcoded values in the View.** ممنوع `Text('hi')` / `Color(0xFFAA)` / `EdgeInsets.all(16)` / `Icons.x` / `'assets/...'` داخل أي Screen أو widget. | كله من `LocaleKeys.*.tr()` / `AppColors` / `AppSize`/`AppPadding`/`AppCircular` / `IconWidget(icon: AppAssets.svg....path)`. |
| 3 | **The View is clean — no functions inside it.** ممنوع أي method داخل الـ Screen غير `build()`، `initState()`، `dispose()`. كل handler / formatter / validator / sheet-opener في **Cubit** أو **ViewController** أو **widget منفصل**. | لو لقيت `void _onTap()` أو `Widget _buildCard()` داخل الـ Screen → انقله. |
| 4 | **Performance is top priority — no `setState`, no unnecessary rebuilds.** الافتراضي: `ValueNotifier<T>` + `ValueListenableBuilder` للـ ephemeral UI state، `BlocSelector` لجزء صغير من cubit state، `BlocBuilder` للـ full state، `AsyncBlocBuilder` للـ AsyncCubit. | `setState` فقط بمبرر فني واضح (مفيش له ولا حالة في الـ products feature). |
| 5 | **Most classes should be Stateless.** `StatefulWidget` فقط لحاجة حقيقية: `AnimationController` lifecycle، focus management، cubit/ViewController ownership (initState/dispose). | الـ state الفعلي في cubit أو ViewController، مش في الـ widget. |
| 6 | **Functions of type `Widget _buildSomething()` are FORBIDDEN inside the View.** أي widget داخل الـ View يصير ملفّ منفصل في `presentation/widgets/` كـ `class _Something extends StatelessWidget` (private — يبدأ بـ `_`)، part-of الـ imports hub. | الـ `_build*` ما بياخدش `const`، ما يستفيدش من Flutter rebuild scope، وبيخبّي tree complexity. |

**Quick check قبل أي commit:**
```
□ Comments تشرح "لماذا" بس
□ View: مفيش string/color/size/icon خام
□ View: مفيش method غير build/initState/dispose
□ ValueNotifier/BlocSelector — مفيش setState
□ Stateless حيث ممكن
□ ملفات منفصلة لكل widget — مفيش Widget _buildX()
```

---

## 0. Developer Mindset — Advanced Senior Flutter Developer (الأهم)

> **أنت بتشتغل كـ Advanced Senior Flutter Developer — مش junior ولا mid-level.**
> **كل سطر كود لازم يعكس خبرة عميقة في Flutter + Dart + Performance + Clean Architecture.**

### 0.1 — Core Principles

| المبدأ | معناه عملياً |
|--------|-------------|
| **Think before you type** | قبل أي widget/cubit، اسأل: "هل ده أفضل حل؟ هل فيه pattern أنضف؟ هل ده هيـ scale؟" |
| **Performance-first** | لا rebuilds مش لازمة، لا nested scrollables، استخدم `const` aggressively، `compute()` للـ heavy JSON |
| **Composition over inheritance** | اقسم الـ widgets لـ small reusable pieces — مش widget واحد فيه 500 سطر |
| **Edge cases من البداية** | null، empty، loading، error، offline، slow network — مش بعدين |
| **Readability over cleverness** | كود senior تاني يفهمه في 30 ثانية بدون شرح |
| **No premature abstraction** | لا تعمل abstraction قبل ما تحتاجها فعلاً — YAGNI |

### 0.2 — Dart 3.10 — Use Modern Features

> **استخدم features الـ Dart 3.10 لما تخلي الكود أنضف. مش لمجرد الـ syntax.**

```dart
// ✅ Records — return multiple values cleanly
(String, int) parseDimension(String input) {
  final parts = input.split('x');
  return (parts.first, int.tryParse(parts.last) ?? 0);
}
final (name, size) = parseDimension('logo x 24');

// ✅ Sealed classes — exhaustive state matching
sealed class PaymentResult {}
class PaymentSuccess extends PaymentResult { final String txId; PaymentSuccess(this.txId); }
class PaymentFailure extends PaymentResult { final String message; PaymentFailure(this.message); }

final label = switch (result) {
  PaymentSuccess(:final txId) => 'Paid: $txId',
  PaymentFailure(:final message) => 'Failed: $message',
};

// ✅ Pattern matching in switch expressions
final tier = switch (orderTotal) {
  < 100 => 'bronze',
  < 500 => 'silver',
  < 1000 => 'gold',
  _ => 'platinum',
};

// ✅ Null-aware spread
final items = [if (header != null) header, ...?optionalList, footer];

// ✅ Late final for expensive computed-once values
late final processedData = _heavyComputation();
```

**Don't overuse:**
- لا تستخدم records في public APIs لو class أوضح
- لا تستخدم sealed classes لمجرد 2 cases بسيطة
- `late` بحذر — ممكن يعمل runtime crash لو ما اتقريش

### 0.3 — Widget Selection — Choose the Best Tool

> **اختار أفضل widget للموقف — مش أول widget يخطر في بالك.**

| لو محتاج | استخدم | بدل من |
|----------|--------|--------|
| Listen to a single value | `ValueListenableBuilder` | `BlocBuilder` (overkill) |
| Listen to part of bloc state only | `BlocSelector` | `BlocBuilder` (rebuilds on every state) |
| Side effect on state change (snackbar, navigation) | `BlocListener` | `BlocConsumer` (don't combine if no UI rebuild needed) |
| Build UI from bloc state | `BlocBuilder` / `AsyncBlocBuilder` | `BlocConsumer` (if no side effect) |
| Animate value smoothly | `TweenAnimationBuilder` / `AnimatedBuilder` | manual `setState` |
| Conditional UI without state | `Visibility(visible:, maintainState:)` | empty `Container` / `SizedBox.shrink()` بشكل عشوائي |
| Boundary for expensive paints | `RepaintBoundary` | (none — just slower) |
| List with constant item extent | `ListView.builder` + `itemExtent` | regular `ListView.builder` (faster) |
| Layout that depends on parent size | `LayoutBuilder` | `MediaQuery.of` (less precise) |
| Run code once after first build | `WidgetsBinding.instance.addPostFrameCallback` | `Future.delayed(Duration.zero)` |
| Async data with built-in loading/error | `AsyncBlocBuilder` (project) | `FutureBuilder` raw |

### 0.4 — Performance Mindset

```dart
// ✅ const everywhere possible — prevents rebuilds
const _MyBody()
const SizedBox.shrink()
const TextStyle()

// ✅ Extract const subtrees — they don't rebuild
class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) => Row(...);
}

// ✅ Use RepaintBoundary for expensive subtrees
RepaintBoundary(child: _AnimatedChart())

// ✅ BlocSelector when you only care about one field
BlocSelector<CartCubit, AsyncState<CartEntity>, int>(
  selector: (state) => state.data.itemCount,
  builder: (_, count) => Badge(count: count),
)

// ❌ BlocBuilder rebuilds on every state change
BlocBuilder<CartCubit, AsyncState<CartEntity>>(
  builder: (_, state) => Badge(count: state.data.itemCount),  // rebuilds for price changes too
)

// ✅ Use ListView.builder with itemExtent when items are same height
ListView.builder(itemExtent: AppSize.sH80, ...)

// ❌ Don't use SingleChildScrollView + Column with 100+ children — kills performance
```

### 0.5 — Code Smells to Avoid

```dart
// ❌ Magic numbers
SizedBox(height: 16)            // → 16.szH or AppSize.sH16
Container(padding: EdgeInsets.all(12))  // → .paddingAll(AppPadding.pH12)

// ❌ God widgets — 200+ line build methods
Widget build(BuildContext context) {
  return Column(children: [
    // 50 lines of header
    // 50 lines of filters
    // 100 lines of list
  ]);
}
// → Split into _Header(), _Filters(), _List()

// ❌ Re-fetching after CRUD instead of local update
onTap: () async {
  await deleteItem();
  await fetchList();  // ← WRONG! Update state locally instead.
}

// ❌ setState for everything
class _MyState extends State<_MyWidget> {
  bool _isExpanded = false;
  void _toggle() => setState(() => _isExpanded = !_isExpanded);
}
// → Use ValueNotifier inside ViewController + ValueListenableBuilder
```

### 0.6 — Widget Efficiency — Golden Rule (التفاصيل في `widget-efficiency` skill)

> **قبل ما تكتب أي wrapper widget، اسأل نفسك 3 أسئلة بالترتيب:**
> 1. هل الـ **child** عنده الـ attribute ده natively؟
> 2. هل الـ **parent** بيدعم الـ behavior ده من attributes بتاعته؟
> 3. هل فيه **widget أكثر دلالة (semantic, single-purpose)** متعمل بالظبط للحالة دي؟
>
> لو الـ 3 إجابات `لا` → وقتها فقط الـ wrapper مقبول.

**أسرع 25+ anti-pattern لازم تتجنبهم (الباقي في الـ skill):**

```dart
// ❌ Padding wrapper       → ✅ Container/Card/ListTile الـ padding/contentPadding/margin الـ native
// ❌ SizedBox بين children → ✅ Column(spacing:) / Row(spacing:) / Wrap(spacing:, runSpacing:)
// ❌ Expanded(SizedBox())  → ✅ Spacer() أو mainAxisAlignment: spaceBetween
// ❌ Container للـ sizing فقط → ✅ SizedBox / SizedBox.shrink() / SizedBox.expand()
// ❌ MediaQuery للـ % sizing → ✅ Flexible(flex:) / FractionallySizedBox / AspectRatio
// ❌ ClipRRect حوالين Container بـ borderRadius → ✅ Container(clipBehavior: Clip.antiAlias)
// ❌ Stack لـ shadow      → ✅ Container(decoration: BoxDecoration(boxShadow:))
// ❌ Opacity على color/icon → ✅ color.withValues(alpha:) — أرخص (مفيش saveLayer)
// ❌ Container حول Scaffold body للـ bg → ✅ Scaffold(backgroundColor:)
// ❌ GestureDetector على ListTile/Button → ✅ ListTile(onTap:) / Button(onPressed:) أو .onClick(...)
// ❌ GestureDetector للـ ripple → ✅ InkWell(onTap:, borderRadius:)
// ❌ Custom drag للـ swipe → ✅ Dismissible
// ❌ Row من Text widgets لـ inline styling → ✅ Text.rich(TextSpan(children: [...]))
// ❌ SizedBox/Container حول Image للـ sizing → ✅ Image(width:, height:, fit:)
// ❌ ClipOval + Image → ✅ CircleAvatar
// ❌ ListView بكل الـ items → ✅ ListView.builder / .separated
// ❌ shrinkWrap: true داخل scrollable → ✅ Sliver* family في CustomScrollView
// ❌ Stack + Positioned لـ badge → ✅ Badge(label: Text('3'), child: Icon(...))
// ❌ isVisible ? W : SizedBox → ✅ Visibility(visible:, maintainState:) أو IndexedStack
// ❌ AnimationController لـ simple transitions → ✅ AnimatedContainer / AnimatedOpacity / ...
// ❌ Container + shadow بدل Card → ✅ Card / Card.filled / Card.outlined
// ❌ Container + GestureDetector للـ chip → ✅ FilterChip / ChoiceChip / InputChip / ActionChip
// ❌ Container(height: 1, color:) → ✅ Divider() / VerticalDivider()
// ❌ M2 widgets (BottomNavigationBar/DropdownButton/PopupMenuButton) → ✅ M3 (NavigationBar/DropdownMenu/MenuAnchor)
```

**التفاصيل + 12 part كامل** (layout, decoration, gestures, text, images, lists/slivers, inputs, navigation, visibility, animation, Stack, M3) **+ جدول M2→M3 migration → `.claude/skills/widget-efficiency/SKILL.md`**.

---

## 1. Single Import Per Feature File — Per-Feature Imports Hub

> **كل feature له imports hub خاص باسمه:** `presentation/imports/<feature>_imports.dart` (مثلاً `products_imports.dart`، `orders_imports.dart`). الاسم **يتغير بحسب اسم الفيتشر** — مش `view_imports.dart` ثابت.

```dart
// ✅ CORRECT — header of any presentation file (cubits/, controllers/, view/, widgets/)
part of '../imports/products_imports.dart';

// ❌ WRONG — scattered imports inside presentation files
import 'package:flutter/material.dart';
import '../../../../config/res/app_sizes.dart';
```

**The hub itself** (`presentation/imports/<feature>_imports.dart`):
```dart
library;

// External packages
import 'dart:async';
import 'package:dartz/dartz.dart' show Either, Left, Right, Unit;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

// App-level helpers (config tokens, locale)
import '../../../../config/res/config_imports.dart';

// Cross-cutting core
import '../../../../core/state/async/async.dart';
import '../../../../core/network/error/failures.dart';

// Feature domain (entities, enums, use-cases)
import '../../domain/entities/product_entity.dart';
import '../../domain/enums/product_status.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/create_product_usecase.dart';

// Cubits (state)
part '../cubits/products_cubit.dart';
part '../cubits/product_details_cubit.dart';

// ViewControllers (ephemeral UI state — TextEditingControllers, ValueNotifiers, ScrollControllers)
part '../controllers/products_view_controller.dart';

// Screens (public entry points)
part '../view/products_screen.dart';
part '../view/product_details_screen.dart';

// Widgets (private to the feature, used by Screens above)
part '../widgets/products_body.dart';
part '../widgets/products_search_field.dart';
part '../widgets/product_card.dart';
part '../widgets/product_delete_dialog.dart';
part '../widgets/products_filter_sheet.dart';
```

**Rule of thumb:**
- `part`/`part of` is for **presentation only**. The `domain/` and `data/` layers use normal imports so they stay portable and testable.
- Private classes (`_ProductsBody`, `_ProductCard`, …) declared in `widgets/*.dart` are usable across the whole feature without exposing them outside.

---

## 2. Colors → AppColors ONLY (Reuse Before Creating)

### ⚠️ Color Reuse Rule

> Read `color_manager.dart` FIRST. Match Figma colors against existing AppColors **by purpose**, not just exact hex.
> Core colors are shared across ALL screens. Only add truly new colors with **generic names** (never screen-prefixed).

```dart
// ✅ CORRECT — use existing AppColors
color: AppColors.forth,
backgroundColor: AppColors.scaffoldBackground,
style: const TextStyle().setColor(AppColors.primary) // for labels/body text

// ❌ FORBIDDEN — raw colors
Color(0xFF583D82)
Colors.purple

// ❌ FORBIDDEN — screen-prefixed color names for NEW colors
// AppColors.cartBackground // use AppColors.fill if close enough
// Note: AppColors.loginPrimary is a legacy name already used in DefaultScaffold/status bar — do NOT rename it, but do NOT create new screen-prefixed colors
```

| Hex | AppColors | Purpose |
|-----|-----------|---------|
| #1C1C1C | `AppColors.main` | Titles, headings |
| #474747 | `AppColors.primary` | Body text, labels |
| #292929 | `AppColors.secondary` | Dark secondary text |
| #583D82 | `AppColors.forth` / `AppColors.buttonColor` | Purple accent, buttons |
| #666666 | `AppColors.hintText` | Hints, subtitles, placeholders |
| #F9FAFB | `AppColors.fill` | Field/card light background |
| #FFFFFF | `AppColors.white` / `AppColors.scaffoldBackground` | White backgrounds |
| #C5C6C9 | `AppColors.border` | Borders, dividers |
| #E34D4D | `AppColors.error` | Error red |
| #DFDFDF | `AppColors.grey1` | Light grey |
| #C7C7C7 | `AppColors.grey2` | Medium grey |

**Close-match rule:** If Figma has a similar-purpose color (e.g. #6B7280 for grey text), use `AppColors.hintText` instead of creating a new one.

---

## 3. Sizes → AppSize / AppPadding / AppMargin / AppCircular

```dart
// ✅
SizedBox(height: AppSize.sH16)
padding: EdgeInsets.all(AppPadding.pH16)
BorderRadius.circular(AppCircular.r8)

// ❌ FORBIDDEN
SizedBox(height: 16)
BorderRadius.circular(8)
```

---

## 4. Text Style → Extension Chain ONLY

### ⚠️ Font Size Adjustment (Figma → Code)

> When converting from Figma:
> - **Figma ≤ 13sp (10, 11, 12, 13) → KEEP AS-IS — لا تقلل.** النصوص الصغيرة لازم تفضل زي ما هي.
> - Figma 14–18sp → reduce by 1–2sp (e.g. Figma 16 → `.s14` or `.s15`)
> - Figma ≥ 20sp → reduce by 2sp (e.g. Figma 22 → `.s20`)

```dart
// ✅ REQUIRED
Text('title', style: const TextStyle().setMainTextColor.s14.medium)
Text('hint', style: const TextStyle().setHintColor.s12.regular)
Text('error', style: const TextStyle().setErrorColor.s12.bold)

// ✅ Figma 12sp small text → keep .s12 (don't reduce small text)
Text('small', style: const TextStyle().setHintColor.s12.regular)

// ✅ Figma 16sp title → code .s14
Text('title', style: const TextStyle().setMainTextColor.s14.bold)

// ✅ Figma 14sp body → code .s13 or .s12
Text('body', style: const TextStyle().setMainTextColor.s13.regular)

// ❌ FORBIDDEN — raw TextStyle
TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1C1C1C))

// ❌ FORBIDDEN — using Figma font size directly without adjustment
// Figma says 16sp → DON'T use .s16, use .s14 or .s15 instead
```

### ⚠️ Font Weight Adjustment (Figma → Code)

> الخطوط من Figma أحياناً بتطلع أتقل في Flutter. جرب وزن أخف أولاً.

```dart
// Figma Bold (700) → try SemiBold (600) first, if too light then 700
// Figma SemiBold (600) → try Medium (500) first
// Figma Medium (500) → keep 500
// Figma Regular (400) → keep 400

// ✅ CORRECT — adjusted from Figma Bold 24sp
Text(title, style: const TextStyle().s22.semiBold)

// ❌ WRONG — raw Figma values (will look too big/heavy)
Text(title, style: const TextStyle().s24.bold)
```

---

## 5. Spacing → .szH / .szW Extensions ONLY (NEVER SizedBox)

> **في Column أو Row، استخدم `.szH` / `.szW` دايماً للـ spacing. ممنوع SizedBox.**

```dart
// ✅ CORRECT — use spacing extensions
Column(children: [
  Text('Title'),
  12.szH,    // SizedBox(height: 12.h)
  Text('Subtitle'),
  8.szH,
])

Row(children: [
  IconWidget(...),
  8.szW,     // SizedBox(width: 8.w)
  Text('Label'),
])

// ❌ FORBIDDEN — raw SizedBox for spacing
SizedBox(height: 12)
SizedBox(width: 8)
const SizedBox(height: 16)
```

---

## 6. Padding/Margin → Widget Extensions ONLY (NEVER Padding Widget)

> **ممنوع استخدام `Padding(...)` widget مباشرة. استخدم الـ extensions دايماً.**

```dart
// ✅ CORRECT — use padding/margin extensions
myWidget.paddingAll(AppPadding.pH16)
myWidget.paddingSymmetric(horizontal: AppPadding.pW20)
myWidget.paddingStart(AppPadding.pW16)   // RTL-safe
myWidget.paddingEnd(AppPadding.pW16)     // RTL-safe
myWidget.paddingOnly(top: AppPadding.pH8, bottom: AppPadding.pH8)
myWidget.paddingOnlyDirectional(start: AppPadding.pW16)
myWidget.marginAll(AppMargin.mH8)
myWidget.marginStart(AppMargin.mW16)     // RTL-safe
myWidget.onClick(onTap: () {})

// ❌ FORBIDDEN — Padding widget directly
Padding(
  padding: EdgeInsets.symmetric(horizontal: AppPadding.pW20),
  child: myWidget,
)

// ❌ FORBIDDEN — GestureDetector directly
GestureDetector(onTap: fn, child: myWidget)
```

---

## 7. Navigation → Go Class

```dart
// ✅
Modular.to.pushNamed('/target')
Modular.to.pop()
Modular.to.pushNamed(Routes.myScreen)

// ❌
Modular.to.pushNamed('/some_route'))
```

---

## 8. Localization → lang.json + LocaleKeys (MANDATORY)

> **⚠️ قاعدة أساسية: كل نص يظهر للمستخدم لازم يتضاف في `lang.json` أولاً ويُستخدم من `LocaleKeys` فقط — بدون أي استثناء.**

### 8.0.1 — Format ملف lang.json

```json
// assets/translations/lang.json
{
  "key_name #$ English text": "Arabic text",
  "feature_title #$ Feature Title": "عنوان الميزة"
}
```

**Format القاعدة:** `"snake_case_key #$ English Text": "النص العربي"`
- الـ key بـ `snake_case`
- بعد `#$` → النص الإنجليزي
- القيمة → النص العربي

### 8.0.2 — Strings مع Parameters (Variables)

```json
{
  "provider_welcome_back #$ Welcome back, {name}": "أهلا بعودتك، {name}"
}
```

```dart
Text(LocaleKeys.providerWelcomeBack(name: user.name))
```

### 8.0.3 — Generate بعد أي تعديل

```bash
dart run generate/strings/main.dart
```

يولّد: `en.json` + `ar.json` + `locale_keys.g.dart`

### 8.0.4 — تسمية الـ Keys

| القاعدة | مثال صح | مثال غلط |
|---------|---------|----------|
| `snake_case` دائماً | `my_reservations` | `myReservations` |
| البداية باسم الـ feature | `complaints_title` | `title` |
| وصفي ومحدد | `complaints_reason_label` | `label1` |

### 8.0.5 — عند قراءة تصميم من Figma MCP

```
1. scan_text_nodes() → اجمع كل النصوص من التصميم
2. أضف كل نص في lang.json (عناوين، أزرار، hints، placeholders، tabs، labels، رسائل خطأ)
3. شغّل dart run generate/strings/main.dart
4. استخدم LocaleKeys فقط في الكود — لا تتجاوز أي نص حتى لو كلمة واحدة
```

### 8.0.6 — أمثلة

```dart
// ✅ CORRECT
Text(LocaleKeys.screenTitle)
DefaultScaffold(title: LocaleKeys.myReservations)
hint: LocaleKeys.searchForTeam
EmptyWidget(title: LocaleKeys.noReservationsTitle, desc: LocaleKeys.noReservationsDesc)

// ❌ FORBIDDEN — hardcoded text
Text('العنوان')
Text('Title')
Text('OK')
hint: 'ابحث هنا'
```

### 8.0.7 — Checklist

```
□ كل النصوص في lang.json بـ format "key #$ English": "عربي"
□ كل key بـ snake_case ويبدأ باسم الـ feature
□ تم تشغيل generate command
□ كل widget يستخدم LocaleKeys — لا يوجد نص مباشر في dart files
□ Parameters تستخدم {variableName} في lang.json
```

---

## 8.1. Forms → FormMixin + validateAndScroll() ALWAYS

```dart
// ✅ Params class uses FormMixin
class MyParams with FormMixin {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
}

// ✅ Form uses params.formKey
Form(key: params.formKey, child: Column(children: [...]))

// ✅ Submit uses validateAndScroll() (auto-scrolls to first error)
if (params.validateAndScroll()) { await cubit.submit(params); }

// ❌ FORBIDDEN — manual form validation
final formKey = GlobalKey<FormState>();
if (formKey.currentState?.validate() ?? false) { ... }
```

---

## 8.2. Number Keyboard → toEnglishNumbers() ALWAYS

> Arabic keyboard inputs ٠١٢٣ instead of 0123. MUST convert before API calls.

```dart
// ✅ Convert Arabic numerals before sending
final phone = params.phoneController.text.toEnglishNumbers();
final amount = params.amountController.text.toEnglishNumbers();

// ✅ Add ArabicNumbersFormatter to number/phone fields
inputFormatters: [ArabicNumbersFormatter(), PhoneNumberFormatter()]

// ❌ FORBIDDEN — sending text directly from number fields
final phone = params.phoneController.text; // may contain ٠١٢٣٤
```

---

## 8.3. Fields → Validators + InputFormatters ALWAYS (Per-Field Mandatory)

> **كل field في كل شاشة لازم له `validator` + `inputFormatters` يعبروا عن نوع محتواه.**
> **مفيش "field عام". الـ phone field عنده قواعده، الـ price عنده قواعده، الـ commercial registration عنده قواعده.**

### 8.3.1 — Full Field Type Matrix

| Field type | Validator | InputFormatters | Length / Max |
|---|---|---|---|
| **Name (Arabic/English)** | `Validators.validateEmpty` | `TextOnlyFormatter(allowArabic: true)` | min 2 chars |
| **Free text** | `Validators.validateEmpty` | `NoSpecialCharactersFormatter()` | — |
| **Email** | `Validators.validateEmail` | `EmailFormatter()` | — |
| **Password** | `Validators.validatePassword` | — | 8–16 (built-in) |
| **Generic Phone** | `Validators.validatePhone` | `PhoneNumberFormatter()`, `ArabicNumbersFormatter()` | 8–15 digits |
| **Saudi Mobile** | `Validators.validateSaudiPhone` | `SaudiPhoneFormatter()`, `ArabicNumbersFormatter()`, `LengthLimitingTextInputFormatter(13)` | 10 (`05xxx…`) / 13 (`+9665xxx…`) |
| **Commercial Registration** | `Validators.validateCommercialReg` | `NumberOnlyFormatter()`, `ArabicNumbersFormatter()`, `LengthLimitingTextInputFormatter(10)` | exactly 10 digits |
| **National ID (Saudi)** | `Validators.validateNationalId` | `NumberOnlyFormatter()`, `ArabicNumbersFormatter()`, `LengthLimitingTextInputFormatter(10)` | 10 digits, starts with 1 (citizen) or 2 (resident) |
| **IBAN (SA)** | `Validators.validateIban` | `IbanFormatter()`, `LengthLimitingTextInputFormatter(24)` | `SA` + 22 digits |
| **VAT Number** | `Validators.validateVat` | `NumberOnlyFormatter()`, `LengthLimitingTextInputFormatter(15)` | exactly 15 digits |
| **OTP code** | `Validators.validateEmpty` | `NumberOnlyFormatter()`, `ArabicNumbersFormatter()`, `LengthLimitingTextInputFormatter(6)` | 4–6 digits |
| **Price / Amount** | `Validators.validatePrice` | `CurrencyFormatter(maxValue: 999_999_999)`, `ArabicNumbersFormatter()` | display `3,000,000` |
| **Quantity (cart)** | `Validators.validateEmpty` | `IntegerNumberFormatter(maxValue: 999)`, `ArabicNumbersFormatter()` | max 999 |
| **Quantity (inventory)** | `Validators.validateEmpty` | `IntegerNumberFormatter(maxValue: 99_999)`, `ArabicNumbersFormatter()` | max 99,999 |
| **Decimal (rating/weight)** | `Validators.validateEmpty` | `DecimalNumberFormatter(decimalPlaces: 2)`, `ArabicNumbersFormatter()` | 2 decimals max |
| **Age** | `Validators.validateEmpty` | `IntegerNumberFormatter(maxValue: 120)`, `ArabicNumbersFormatter()` | max 120 |
| **Discount %** | `Validators.validateEmpty` | `IntegerNumberFormatter(maxValue: 100)`, `ArabicNumbersFormatter()` | max 100 |
| **Date** | `Validators.validateEmpty` | `DateTimeFormatter()` | auto `DD/MM/YYYY` |
| **URL** | `Validators.validateUrl` | `NoSpecialCharactersFormatter(allowArabic: false)` | valid URL pattern |
| **Dropdown** | `Validators.validateDropDown<T>` | — | — |
| **Optional any** | `Validators.noValidate` | (حسب الـ data type) | — |

### 8.3.2 — Display vs API Value (CRITICAL)

> **بعض الـ fields بتتعرض بـ format واحد بس بتتبعت للـ API بـ format تاني.**
> **لازم cleanup قبل أي API call.**

```dart
// ✅ Price field — display formatted, API plain
final priceClean = params.priceController.text
  .replaceAll(',', '')            // remove thousands separators
  .toEnglishNumbers();             // ٠١٢٣ → 0123
final amount = double.tryParse(priceClean) ?? 0;

// ✅ Phone — normalize to canonical Saudi format
final phone = Helpers.normalizeSaudiPhone(
  params.phoneController.text.toEnglishNumbers(),
);
// "05xxxxxxxx"   → "9665xxxxxxxx"
// "+9665xxxxxxxx" → "9665xxxxxxxx"

// ✅ Date — convert DD/MM/YYYY to ISO for API
final isoDate = DateFormat('yyyy-MM-dd').format(
  DateFormat('dd/MM/yyyy').parse(params.dateController.text),
);

// ✅ IBAN — strip spaces before sending
final iban = params.ibanController.text.replaceAll(' ', '').toUpperCase();
```

### 8.3.3 — Numeric Limits (Hard Rule)

> **مفيش numeric field بدون `maxValue` cap. ولا واحد.**
> **المستخدم لو سابتله يكتب 9999999999999، الكود هيقع أو الـ API هيرفض.**

```dart
// ❌ FORBIDDEN — numeric field بدون cap
inputFormatters: [IntegerNumberFormatter()]              // ← unbounded
inputFormatters: [NumberOnlyFormatter()]                  // ← unbounded

// ✅ MANDATORY — always cap
inputFormatters: [
  IntegerNumberFormatter(maxValue: 999),
  ArabicNumbersFormatter(),
]
inputFormatters: [
  CurrencyFormatter(maxValue: 999_999_999),  // 9-digit price max
  ArabicNumbersFormatter(),
]
```

### 8.3.4 — Currency / Price Field Pattern (Display Formatting)

> **الـ price field بيتعرض بـ thousand separators (`3,000,000`) عشان المستخدم يقرا الرقم بسهولة.**
> **بيتبعت للـ API بدون commas (`3000000`).**

```dart
// ✅ The field
CustomTextFiled(
  title: LocaleKeys.price.tr(),
  hint: LocaleKeys.enterPrice.tr(),
  controller: params.priceController,
  validator: Validators.validatePrice,
  inputFormatters: [
    CurrencyFormatter(maxValue: 999_999_999),
    ArabicNumbersFormatter(),
  ],
  textInputType: const TextInputType.numberWithOptions(decimal: false),
  textInputAction: TextInputAction.next,
)

// ✅ The submit logic
if (params.validateAndScroll()) {
  final amount = double.tryParse(
    params.priceController.text.replaceAll(',', '').toEnglishNumbers(),
  ) ?? 0;
  await cubit.submit({'amount': amount, ...});
}
```

### 8.3.5 — Saudi Phone Pattern

```dart
// ✅ Accept multiple formats — validator normalizes
CustomTextFiled(
  title: LocaleKeys.phone.tr(),
  hint: '05XXXXXXXX',
  controller: params.phoneController,
  validator: Validators.validateSaudiPhone,
  inputFormatters: [
    SaudiPhoneFormatter(),                  // allows: digits, +, with smart prefix logic
    ArabicNumbersFormatter(),
    LengthLimitingTextInputFormatter(13),
  ],
  textInputType: TextInputType.phone,
)

// ✅ Normalize before API
final phone = Helpers.normalizeSaudiPhone(
  params.phoneController.text.toEnglishNumbers(),
);
```

### 8.3.6 — Helpers Missing? Add Them.

> **لو الـ validator/formatter اللي محتاجه مش موجود في `validators.dart` أو `input_formatters.dart` → ضيفه. مش تستخدم validator عام مع TODO.**

محتاج تضيف هذه الـ helpers لو مش موجودين:

```dart
// validators.dart
static String? validateSaudiPhone(String? value, {String? fieldTitle}) { ... }
static String? validateCommercialReg(String? value, {String? fieldTitle}) { ... }
static String? validateNationalId(String? value, {String? fieldTitle}) { ... }
static String? validateIban(String? value, {String? fieldTitle}) { ... }
static String? validateVat(String? value, {String? fieldTitle}) { ... }
static String? validatePrice(String? value, {String? fieldTitle, double? maxValue}) { ... }
static String? validateUrl(String? value, {String? fieldTitle}) { ... }

// input_formatters.dart
class SaudiPhoneFormatter extends TextInputFormatter { ... }
class CurrencyFormatter extends TextInputFormatter {
  final num? maxValue;
  // adds thousand separators: 3000000 → 3,000,000
}
class IbanFormatter extends TextInputFormatter {
  // adds space every 4 chars: SA0380000000608010167519 → SA03 8000 0000 6080 1016 7519
}

// helpers.dart
static String normalizeSaudiPhone(String input) {
  final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('966')) return digits;
  if (digits.startsWith('05')) return '966${digits.substring(1)}';
  if (digits.startsWith('5')) return '966$digits';
  return digits;
}
```

### 8.3.7 — Field Checklist (Run Mentally for Every Field)

```
□ Validator مناسب لنوع المحتوى (مش validateEmpty لكل حاجة)
□ InputFormatters تمنع كتابة قيم غلط من البداية
□ ArabicNumbersFormatter في numeric/phone/date/OTP fields
□ Max value للـ numeric fields (إلزامي — مفيش استثناء)
□ Length limit للـ fixed-length fields (OTP/CR/NID/IBAN/Phone)
□ Display formatter للـ price (CurrencyFormatter) والـ date (DateTimeFormatter) والـ IBAN
□ Cleanup قبل API: strip commas/dashes/spaces + .toEnglishNumbers()
□ textInputType مناسب (.phone / .number / .emailAddress / .url)
□ textInputAction (.next للـ fields الوسط، .done للـ آخر field)
```

---

## 8.4. Helpers & Shared → AUDIT BEFORE CREATING

> **Read `core/helpers/` and `core/shared/` FIRST before writing any utility logic.**

**Available Helpers (`core/helpers/`):**
- `Validators` — form validation (empty, email, phone, password, dropdown, XSS)
- `InputFormatters` — Phone, Email, NumberOnly, TextOnly, DateTime, Integer, Decimal, NoSpecialChars
- `ArabicNumbersFormatter` — auto-converts ٠-٩ → 0-9 in text fields
- `Helpers` — `showByLang()`, `getFcmToken()`, `changeStatusbarColor()`, `shareApp()`, `getDeviceType()`
- `ImageHelper` — pick/crop images, camera, gallery, file picker
- `LauncherHelper` — launch URL, WhatsApp, social media, phone, email
- `CacheStorage` / `SecureStorage` — local storage wrappers
- `CustomLoading` — full-screen loading overlay

**Available Shared (`core/shared/`):**
- `BaseModel<T>` — generic API response wrapper
- `UserModel` — user entity
- `ImageEntity` — image model (network + local)
- `UserCubit` — current user state
- Service Locator — `Modular.get<T>()`

**Available Extensions (`core/extensions/`):**
- `TextStyleEx` — text style chain (color, size, weight)
- `FormatString` — `.toEnglishNumbers()`, `.capitalize()`, `.toCurrency()`, `.copyToClipboard()`
- `DateTimeFormatHelper` — `.toFullDate()`, `.toTime()`, `.toDayMonthYear()`, etc.
- `ContextExtension` — `context.width`, `context.hideKeyboard()`, `context.isArabic`
- `PaddingExtension` / `MarginExtension` — RTL-safe widget padding/margin
- `OnClick` — `.onClick(onTap: fn)`
- `SizedBoxHelper` — `.szH`, `.szW`
- `SliverExtension` — `.toSliver()`
- `SeparatorExtension` — `.joinWith(separator)` on List<Widget>
- `IndexedMap` — `.indexedMap((index, item) => ...)` on List
- `FormMixin` — `formKey`, `validate()`, `validateAndScroll()`

---

## 8.5. Entity Safety → initial() + fromJson defaults + tryParse ALWAYS

### Every entity MUST have:
1. `factory initial()` — with safe default values (for Skeletonizer + null-safety)
2. `fromJson` with `??` defaults — for ALL non-nullable fields (API data can change anytime)
3. `tryParse` with fallback — NEVER use `parse` (crashes on bad data)

```dart
// ✅ CORRECT — safe entity
class ItemEntity {
  final int id;
  final String name;
  final double price;
  final String? image;

  const ItemEntity({required this.id, required this.name, required this.price, this.image});

  factory ItemEntity.initial() => const ItemEntity(id: 0, name: '', price: 0.0);

  factory ItemEntity.fromJson(Map<String, dynamic> json) => ItemEntity(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    price: double.tryParse(json['price'].toString()) ?? 0.0,
    image: json['image'],  // nullable — no ??
  );
}

// ❌ FORBIDDEN — unsafe entity
class ItemEntity {
  factory ItemEntity.fromJson(Map<String, dynamic> json) => ItemEntity(
    id: int.parse(json['id']),       // CRASH on null/wrong type
    name: json['name'],               // CRASH on null
    price: json['price'] as double,   // CRASH on null/wrong type
  );
  // Missing factory initial() ← FORBIDDEN
}
```

### tryParse rule:
```dart
// ✅ ALWAYS use tryParse + fallback
int.tryParse(value.toString()) ?? 0
double.tryParse(value.toString()) ?? 0.0

// ❌ NEVER use parse (throws on bad data)
int.parse(value)
double.parse(value)
```

---

## 8.6. Multiple Scrollables → CustomScrollView + Slivers (MANDATORY)

> When a screen body has **more than one scrollable section** (e.g. banner + list, header + grid + list, filters + products), **ALWAYS** use `CustomScrollView` with slivers instead of nesting scroll widgets inside `SingleChildScrollView`.

### Why?
- `SingleChildScrollView` + nested `ListView` = **double scroll conflict** → jank, layout errors, bad performance
- `shrinkWrap: true` on nested lists forces Flutter to **lay out ALL items at once** → defeats lazy loading, kills performance on large lists
- `CustomScrollView` with slivers = **single unified scroll** → smooth, lazy-loaded, no conflicts

### Decision Rule:

| Screen structure | Approach |
|---|---|
| Single list/grid only | `ListView.builder` or `GridView.builder` directly |
| Static content + 1 list at bottom | `CustomScrollView` + `SliverToBoxAdapter` (static) + `SliverList` |
| Multiple sections (header + filters + list + footer) | `CustomScrollView` + slivers for everything |
| Multiple API sections (banners + categories + products) | `CustomScrollView` + `AsyncSliverBlocBuilder` per section |

### ✅ CORRECT — CustomScrollView with slivers:

```dart
CustomScrollView(
  physics: const AlwaysScrollableScrollPhysics(),
  slivers: [
    // Static header → wrap in SliverToBoxAdapter (or use .toSliver())
    _buildHeader().toSliver(),

    // Filter chips → wrap in SliverToBoxAdapter
    _buildFilters().toSliver(),

    // API list → use SliverList.builder (lazy loaded!)
    SliverList.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => ItemCard(item: items[i]),
    ),

    // Bottom spacing
    SliverToBoxAdapter(child: 20.szH),
  ],
)
```

### ✅ CORRECT — Multi-API screen with AsyncSliverBlocBuilder:

```dart
CustomScrollView(
  physics: const AlwaysScrollableScrollPhysics(),
  slivers: [
    // Banners section
    AsyncSliverBlocBuilder<BannersCubit, List<BannerEntity>>(
      builder: (ctx, banners) {
        if (banners.isEmpty) return const SizedBox.shrink().toSliver();
        return BannerCarousel(banners: banners).toSliver();
      },
    ),

    // Categories section
    AsyncSliverBlocBuilder<CategoriesCubit, List<CategoryEntity>>(
      builder: (ctx, cats) {
        if (cats.isEmpty) return const SizedBox.shrink().toSliver();
        return CategoriesRow(categories: cats).toSliver();
      },
    ),

    // Products grid
    AsyncSliverBlocBuilder<ProductsCubit, List<ProductEntity>>(
      builder: (ctx, products) {
        if (products.isEmpty) return const SizedBox.shrink().toSliver();
        return SliverGrid.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: products.length,
          itemBuilder: (_, i) => ProductCard(product: products[i]),
        );
      },
    ),
  ],
)
```

### ❌ FORBIDDEN — nested scrollables:

```dart
// ❌ SingleChildScrollView + nested ListView = BAD performance
SingleChildScrollView(
  child: Column(
    children: [
      _buildHeader(),
      _buildFilters(),
      ListView.builder(           // ← nested scroll inside scroll!
        shrinkWrap: true,          // ← forces layout of ALL items
        physics: NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (_, i) => ItemCard(item: items[i]),
      ),
    ],
  ),
)

// ❌ Multiple shrinkWrap lists = VERY BAD
SingleChildScrollView(
  child: Column(
    children: [
      ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), ...),
      ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), ...),
      GridView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), ...),
    ],
  ),
)
```

### Sliver Quick Reference:

| Normal widget | Sliver equivalent |
|---|---|
| Any widget | `widget.toSliver()` or `SliverToBoxAdapter(child: widget)` |
| `ListView.builder` | `SliverList.builder(itemCount, itemBuilder)` |
| `ListView.separated` | `SliverList.separated(itemCount, itemBuilder, separatorBuilder)` |
| `GridView.builder` | `SliverGrid.builder(gridDelegate, itemCount, itemBuilder)` |
| `Padding` around slivers | `SliverPadding(padding, sliver: ...)` |
| Fill remaining space | `SliverFillRemaining(child: ...)` |
| `AsyncBlocBuilder` | `AsyncSliverBlocBuilder` |

### When SingleChildScrollView IS acceptable:
- Screen has **only static content** (forms, text, images — no lists/grids)
- Auth screens (login, register) where content is fixed and short
- Detail screens with **no lists** — just static fields

---

## 9. Screen Structure

> **See `scaffold-statusbar.mdc` rule for which scaffold to use per screen type.**

```dart
// ✅ Inner screens (most screens): StatelessWidget + BlocProvider + DefaultScaffold
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<MyCubit>()..fetchData(),
      child: DefaultScaffold(
        title: LocaleKeys.myTitle.tr(),
        body: const _MyBody(),
      ),
    );
  }
}

// ✅ Auth screens: plain Scaffold + SafeArea (no appbar)
// Status bar: Helpers.changeStatusbarColor(statusBarColor: AppColors.scaffoldBackground, statusBarIconBrightness: Brightness.dark)

// ❌ FORBIDDEN — building custom header inside body widget for inner screens
// Use DefaultScaffold instead — it handles colored header, back arrow, title, status bar
```

---

## 10. RTL Rules — CRITICAL

**App is RTL by default — use directional APIs everywhere.**

> **See `rtl-arabic` skill for full RTL rules, conversion tables, and examples.**

### The Core Equation:
```
Flutter "start" = physical RIGHT = Arabic text side = Figma RIGHT side
Flutter "end"   = physical LEFT  = Figma LEFT side
Row first child = physical RIGHT | Row last child = physical LEFT
```

### Quick Forbidden List:
```dart
// ❌ ALL FORBIDDEN — use directional alternatives
Positioned(left/right: x)       // use PositionedDirectional(end/start: x)
Align(Alignment.centerLeft/Right) // use AlignmentDirectional.centerEnd/Start
EdgeInsets.only(left/right: x)   // use EdgeInsetsDirectional.only(end/start: x)
TextAlign.left/right             // use TextAlign.start/end
```

> **Note:** `Directionality(textDirection: TextDirection.rtl)` مسموح على مستوى widget واحد فقط لحل مشكلة نص معكوس داخل component — ممنوع على مستوى الشاشة.

---

## 11. Core Widgets — USE BEFORE BUILDING NEW

> **Golden Rule:** Search `core/widgets/` before writing any widget. If it exists → use it.

### 11.1 — Buttons (`core/widgets/buttons/`)

| Widget | Usage |
|--------|-------|
| `LoadingButton(title, onTap)` | Async button with built-in loading state — use for ALL form submits |
| `DefaultButton(title, onTap)` | Simple non-async button |
| `ButtonClose()` | Standard close/dismiss button |
| `CustomAnimatedButton(...)` | Animated press-effect button |

```dart
// ✅ CORRECT — async form submit
LoadingButton(
  title: LocaleKeys.submit.tr(),
  color: AppColors.primary,
  borderRadius: AppCircular.r12,
  onTap: () async => context.read<MyCubit>().submit(params),
)
```

---

### 11.2 — Text Fields (`core/widgets/fields/text_fields/`)

| Widget | Usage |
|--------|-------|
| `CustomTextFiled(hint, title, controller, validator, textInputType, textInputAction)` | **Primary field** — includes label + asterisk + validation styling. Use for all form fields. |
| `DefaultTextField(...)` | Base field — used inside CustomTextFiled. Use directly only if no label needed. |
| `CustomPinTextField(controller, onCompleted)` | OTP / PIN 4-digit field with pinput |

```dart
// ✅ CORRECT — form field with label
CustomTextFiled(
  title: LocaleKeys.phoneLabel.tr(),
  hint: LocaleKeys.phoneHint.tr(),
  controller: params.phoneController,
  textInputType: TextInputType.phone,
  textInputAction: TextInputAction.next,
  validator: Validators.validatePhone,
  inputFormatters: [PhoneNumberFormatter()],
)

// ❌ WRONG — don't build a custom labeled field from scratch
```

---

### 11.3 — Dropdowns (`core/widgets/fields/drop_downs/`)

| Widget | Usage |
|--------|-------|
| `AppDropdown<T>(items, onChanged, itemAsString, label, hint, isLoading)` | Full-featured dropdown with search, multi-select, internal loading shimmer |

```dart
// ✅ CORRECT — pass items + isLoading directly (NO BlocBuilder wrapper)
final state = context.watch<GetCitiesCubit>().state;
AppDropdown<CityEntity>(
  items: state.data,                          // ← [] if API failed, no error UI
  label: LocaleKeys.city.tr(),
  hint: LocaleKeys.selectCity.tr(),
  value: selectedCity,
  itemAsString: (c) => c.name,
  onChanged: (c) => setState(() => selectedCity = c),
  validator: Validators.validateDropDown,
  isLoading: state is AsyncLoading,                  // ← AppDropdown shows internal shimmer
)
```

Key params: `isMultiSelect`, `showSearchBox`, `isLoading`, `readonly`, `maxHeight`

> **⚠️ See Section 32:** AppDropdown with API → NEVER wrap in `BlocBuilder` / `AsyncBlocBuilder`. NO error UI on dropdowns. If API fails → items shows empty, that's it.

---

### 11.4 — Dialogs & Bottom Sheets (`core/widgets/dialogs/` + `core/widgets/pickers/`)

| Function | Usage |
|----------|-------|
| `successDialog(context, title: ..., desc: ...)` | Standard success popup with Lottie animation + auto-close |
| `showCustomDialog(context, child: ...)` | Generic styled dialog with scale+fade animation |
| `showDefaultBottomSheet(child: ...)` | Standard bottom sheet with drag handle |
| `CustomDatePicker` | Date picker widget |

```dart
// ✅ CORRECT — success after API call
successDialog(context, title: LocaleKeys.savedSuccessfully.tr());

// ✅ CORRECT — custom dialog
showCustomDialog(
  context,
  child: MyDialogContent(),
  barrierDismissible: true,
);

// ✅ CORRECT — bottom sheet
showDefaultBottomSheet(child: MySheetContent());
```

---

### 11.5 — State Handling (`core/widgets/handling_views/` + `core/widgets/tools/`)

| Widget | Usage |
|--------|-------|
| `AsyncBlocBuilder<Cubit, DataType>(builder: ..., loadingBuilder: ...)` | Wraps loading/error/success states automatically |
| `AsyncSliverBlocBuilder<Cubit, DataType>(...)` | Sliver version for CustomScrollView |
| `PaginatedListWidget<Cubit, ItemType>(itemBuilder: ..., config: ...)` | Paginated list with infinite scroll |
| `EmptyWidget(title: ..., desc: ..., path: ...)` | Empty state with image/lottie |
| `ErrorView(error: ...)` | Error state with Lottie animation |

```dart
// ✅ CORRECT — API-driven list
AsyncBlocBuilder<GetItemsCubit, List<ItemEntity>>(
  loadingBuilder: (ctx) => ItemSkeleton(),
  builder: (ctx, items) => items.isEmpty
      ? EmptyWidget(title: LocaleKeys.noItems.tr(), desc: '')
      : ListView.builder(itemBuilder: ...),
)

// ✅ CORRECT — paginated list
PaginatedListWidget<GetItemsCubit, ItemEntity>(
  itemBuilder: (ctx, item, idx) => ItemCard(item: item),
  emptyWidget: EmptyWidget(title: LocaleKeys.noItems.tr(), desc: ''),
)
```

---

### 11.6 — Image Widgets (`core/widgets/image_widgets/`)

| Widget | Usage |
|--------|-------|
| `CachedImage(url, width, height)` | Cached network image with placeholder + tap-to-view |
| `CustomAvatar(url, radius)` | Circular avatar from network |
| `UploadImageWidget(onUpload)` | Image upload with native picker, single or multi |
| `ImageView(mediaPath, mediaType, mediaSource)` | Full-screen image/video viewer |

```dart
// ✅ Network image
CachedImage(url: item.image, width: AppSize.sW60, height: AppSize.sH60,
  borderRadius: BorderRadius.circular(AppCircular.r8))

// ✅ Circular avatar
CachedImage(url: user.photo, width: AppSize.sW44, height: AppSize.sH44,
  boxShape: BoxShape.circle)

// ✅ Upload
UploadImageWidget(
  uploadImageType: UploadImageType.single,
  onUpload: (files) => params.imageFile = files.first,
)
```

---

### 11.7 — Other Widgets

| Widget | Usage |
|--------|-------|
| `IconWidget(icon, color, height, width)` | Versatile — handles SVG/PNG/Lottie/network/IconData automatically |
| `BadgeIconWidget(child, badgeCount)` | Badge overlay on any widget |
| `CustomHtmlWidget(data)` | Renders HTML content with project styles |
| `RiyalPriceText(price)` | Saudi Riyal symbol with correct font |
| `CustomLoading.showLoadingView()` | Centered SpinKit loading indicator |
| `CustomLoading.showFullScreenLoading()` | Full-screen overlay loader |
| `MessageUtils.showSnackBar(context, baseStatus, message)` | Themed snackbar |

```dart
// ✅ Icon (SVG from AppAssets) — NO color, NO IconData (see Section 17)
IconWidget(icon: AppAssets.svg.baseSvg.search.path, height: AppSize.sH20)

// ✅ Badge
BadgeIconWidget(child: IconWidget(...), badgeCount: unreadCount)

// ✅ Price
RiyalPriceText(price: '250.00', priceTextStyle: const TextStyle().setMainTextColor.s14.bold)
// OR
Text('250.00', style: ...).withRiyalPrice(color: AppColors.primary)

// ✅ Snackbar
MessageUtils.showSnackBar(context: context, baseStatus: BaseStatus.success, message: LocaleKeys.saved.tr())
```

---

### 11.8 — Scaffold + Status Bar

> **See `scaffold-statusbar.mdc` for full scaffold selection guide and status bar rules.**

- Inner screens → `DefaultScaffold` (handles header + status bar automatically)
- Auth screens → plain `Scaffold` + `SafeArea` (no appbar)
- Home → custom `Scaffold` + `CustomNavigationBar`
- **NEVER** build custom header containers in body widgets

---

## 12. Extensions — USE ALWAYS

### 12.1 — TextStyleEx (`core/extensions/text_style_extensions.dart`)

```dart
// Font weight
const TextStyle().bold       // FontWeight.bold
const TextStyle().semiBold   // w600
const TextStyle().medium     // w500
const TextStyle().regular    // w400
const TextStyle().light      // w300

// Font size (uses screenutil .sp)
const TextStyle().s12   // 12.sp
const TextStyle().s14   // 14.sp
const TextStyle().s16   // 16.sp

// Colors (from AppColors)
const TextStyle().setMainTextColor    // AppColors.main
const TextStyle().setSecondryColor    // AppColors.secondary
const TextStyle().setHintColor        // AppColors.hintText
const TextStyle().setErrorColor       // AppColors.error
const TextStyle().setWhiteColor       // AppColors.white
const TextStyle().setPrimaryColor     // AppColors.primary
const TextStyle().setColor(AppColors.xxx)  // custom color

// Chain example
const TextStyle().setMainTextColor.s14.semiBold
```

### 12.2 — Padding/Margin Extensions

```dart
// Padding (RTL-safe versions preferred)
widget.paddingAll(AppPadding.pH16)
widget.paddingSymmetric(horizontal: AppPadding.pW20, vertical: AppPadding.pH8)
widget.paddingStart(AppPadding.pW16)   // ✅ RTL-safe (physical right)
widget.paddingEnd(AppPadding.pW16)     // ✅ RTL-safe (physical left)
widget.paddingOnly(top: AppPadding.pH8, bottom: AppPadding.pH8)
widget.paddingOnlyDirectional(start: AppPadding.pW16)

// Margin
widget.marginAll(AppMargin.mH8)
widget.marginSymmetric(horizontal: AppMargin.mW16)
widget.marginTop(AppMargin.mH12)
widget.marginBottom(AppMargin.mH12)
widget.marginStart(AppMargin.mW16)   // ✅ RTL-safe
widget.marginEnd(AppMargin.mW16)     // ✅ RTL-safe
```

### 12.3 — SizedBox Helpers

```dart
12.szH   // SizedBox(height: 12.h)
16.szW   // SizedBox(width: 16.w)
// Use AppSize constants: AppSize.sH12.szH
```

### 12.4 — Click Extension

```dart
myWidget.onClick(onTap: () => Modular.to.pushNamed('/target'))
```

### 12.5 — Context Extension

```dart
context.width    // MediaQuery width
context.height   // MediaQuery height
context.locale   // current Locale
```

---

## 13. Helpers — USE BEFORE WRITING CUSTOM LOGIC

### 13.1 — Validators (`core/helpers/validators.dart`)

```dart
// ✅ Use in form fields
validator: Validators.validateEmpty
validator: Validators.validateEmail
validator: Validators.validatePhone    // digits only, 8-15 chars
validator: Validators.validatePassword // uppercase + lowercase + digit + special
validator: (v) => Validators.validatePasswordConfirm(v, pass)
validator: Validators.validateDropDown<T>
validator: Validators.noValidate      // no validation, XSS check only
```

### 13.2 — InputFormatters (`core/helpers/input_formatters.dart`)

```dart
inputFormatters: [PhoneNumberFormatter()]        // digits + +, -, (, )
inputFormatters: [EmailFormatter()]              // email chars only
inputFormatters: [NumberOnlyFormatter()]         // digits only
inputFormatters: [TextOnlyFormatter()]           // letters + arabic + spaces
inputFormatters: [TextWithNumberFormatter()]     // letters + numbers + arabic
inputFormatters: [IntegerNumberFormatter()]      // integers, optional max value
inputFormatters: [DecimalNumberFormatter()]      // decimals, optional decimal places
inputFormatters: [DateTimeFormatter()]           // auto-format DD/MM/YYYY
inputFormatters: [NoSpecialCharactersFormatter()] // no special chars
```

### 13.3 — Helpers (`core/helpers/helpers.dart`)

```dart
Helpers.showByLang(ar: 'عربي', en: 'English')  // returns string based on locale
Helpers.getFcmToken()                            // FCM push token
Helpers.changeStatusbarColor(statusBarColor: ...) // status bar tint
Helpers.shareApp(url)                           // share via share_plus
Helpers.getDeviceType()                         // 'ios' or 'android'
```

### 13.4 — CacheService (`core/helpers/cache_service.dart`)

Local storage via shared preferences — use for tokens, user prefs, etc.

---

## 14. Navigation → Go Class (ONLY)

```dart
Modular.to.pushNamed('/target')                  // push
Modular.to.pushReplacementNamed('/target'))                 // pushReplacement
Modular.to.navigate('/target'))              // pushAndRemoveUntil (clear stack)
Modular.to.pop()                               // pop
Modular.to.popUntil((route) => route.isFirst)                      // pop to first route
Modular.to.pushNamed(NamedRoutes.myScreen)        // named push
Modular.to.pushReplacementNamed(NamedRoutes.myScreen)       // named replacement
Modular.to.navigate(NamedRoutes.myScreen)    // named clear stack
Modular.routerDelegate.navigatorKey.currentContext                              // global context (for dialogs etc.)

// ❌ FORBIDDEN
Navigator.push(context, MaterialPageRoute(...))
```

---

## 15. Network — `BaseRemoteSource.request<T>` + Repository / UseCase Pipeline

> **الـ network layer كله مبني على `DioClient` singleton + `BaseRemoteSource` abstract class.**
> **الـ Cubit ما يستدعيش `BaseRemoteSource` مباشرة — يأخذ UseCases. الـ UseCase يستدعي Repository. الـ Repository يستدعي DataSource.**

### 15.1 — DataSource (talks to the network)

```dart
// data/datasources/products_remote_data_source_impl.dart
@LazySingleton(as: ProductsRemoteDataSource)
class ProductsRemoteDataSourceImpl extends BaseRemoteSource
    implements ProductsRemoteDataSource {

  // GET list with query params
  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({int page = 1, String? search}) =>
    request<List<ProductEntity>>(
      method: HttpMethod.get,
      endpoint: ApiEndpoints.products,
      queryParameters: {
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      fromJson: _parseProductList,
    );

  // POST create with body
  @override
  Future<Either<Failure, ProductEntity>> createProduct({
    required String name, required String description, required double price,
  }) =>
    request<ProductEntity>(
      method: HttpMethod.post,
      endpoint: ApiEndpoints.products,
      body: {'name': name, 'description': description, 'price': price},
      fromJson: _parseProduct,
    );

  // DELETE with no response body
  @override
  Future<Either<Failure, Unit>> deleteProduct(int id) =>
    request<Unit>(
      method: HttpMethod.delete,
      endpoint: ApiEndpoints.productById(id),
      fromJson: (_) => unit,
    );

  // POST public — skip Bearer token
  Future<Either<Failure, AuthToken>> login(String email, String pwd) =>
    request<AuthToken>(
      method: HttpMethod.post,
      endpoint: ApiEndpoints.login,
      body: {'email': email, 'password': pwd},
      skipAuth: true,
      fromJson: (j) => AuthToken.fromJson(j),
    );

  // Multipart upload — opt-in via asFormData
  Future<Either<Failure, UploadResult>> upload(String filePath) =>
    request<UploadResult>(
      method: HttpMethod.post,
      endpoint: ApiEndpoints.upload,
      body: {'file': await MultipartFile.fromFile(filePath)},
      asFormData: true,
      fromJson: (j) => UploadResult.fromJson(j),
    );

  // Private parsers — keep Model ↔ Entity mapping here
  static List<ProductEntity> _parseProductList(dynamic j) =>
    ((j is Map ? j['data'] : j) as List? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(ProductModel.fromJson)
      .map((m) => m.toEntity())
      .toList();
  static ProductEntity _parseProduct(dynamic j) =>
    ProductModel.fromJson(((j is Map ? j['data'] ?? j : j) as Map<String, dynamic>)).toEntity();
}
```

### 15.2 — `request<T>` parameters reference

| Param | Purpose |
|-------|---------|
| `method` | `HttpMethod.get / post / put / patch / delete` |
| `endpoint` | relative path — `DioClient` prepends `baseUrl` |
| `queryParameters` | `?key=value&…` map |
| `body` | Map / List / String / FormData / MultipartFile-bearing Map |
| `headers` | extra request headers merged on top of globals |
| `fromJson` | `T Function(dynamic json)` — required parser (use `(_) => unit` for void) |
| `skipAuth` | skip Bearer token attachment (login/register/public endpoints) |
| `asFormData` | wrap Map body in `FormData.fromMap(...)` automatically |
| `normalizeArabicDigits` | default `true` — convert ٠١٢٣ → 0123 inside body & query strings |
| `cancelKey` | dedupe key (default `"$METHOD:$endpoint"`) — auto-cancels previous in-flight |
| `cancelPrevious` | default `true` — cancel previous in-flight with same key |
| `responseType` | override Dio response parsing (rarely needed) |

**Returns** `Future<Either<Failure, T>>` — caller `.fold` without try/catch.

### 15.3 — Repository (data → domain bridge)

```dart
// domain/repositories/products_repository.dart
abstract interface class ProductsRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({String? search});
  Future<Either<Failure, ProductEntity>> createProduct({required String name, required String description, required double price});
  Future<Either<Failure, Unit>> deleteProduct(int id);
}

// data/repositories/products_repository_impl.dart
@LazySingleton(as: ProductsRepository)
class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remote);
  final ProductsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({String? search}) =>
    _remote.getProducts(search: search);

  @override
  Future<Either<Failure, ProductEntity>> createProduct({...}) =>
    _remote.createProduct(...);

  @override
  Future<Either<Failure, Unit>> deleteProduct(int id) =>
    _remote.deleteProduct(id);
}
```

### 15.4 — UseCase (single-purpose, what the Cubit depends on)

```dart
// domain/usecases/get_products_usecase.dart
@lazySingleton
class GetProductsUseCase {
  GetProductsUseCase(this._repo);
  final ProductsRepository _repo;
  Future<Either<Failure, List<ProductEntity>>> call({String? search}) =>
    _repo.getProducts(search: search);
}
```

### 15.5 — Endpoints registry

All endpoints → `ApiEndpoints` in `core/network/api_endpoints.dart`. Add new endpoints there:
```dart
class ApiEndpoints {
  static const String baseUrl = 'https://api.example.com/v1/';
  static const String products = 'products';
  static String productById(int id) => 'products/$id';
  static const String login = 'auth/login';
}
```

### 15.6 — Anti-patterns

```dart
// ❌ Raw Dio in features
Dio().get('https://api.example.com/products');

// ❌ Cubit talking to DataSource directly (skips Repository + UseCase layers)
class XCubit extends AsyncCubit<List<X>> {
  XCubit(this._dataSource);
  final XRemoteDataSource _dataSource;  // ← wrong; should be UseCase
}

// ❌ Hardcoded endpoint string in DataSource
request<X>(method: HttpMethod.get, endpoint: '/products', ...);  // ← wrong; use ApiEndpoints.products

// ❌ Building FormData manually then passing it as body — let asFormData handle it
final fd = FormData.fromMap({'file': ...});
request<X>(method: HttpMethod.post, body: fd, ...);  // works but verbose; prefer asFormData: true
```

**Interceptor order (in `DioClient` — already wired):**
```
LocaleInterceptor → AuthInterceptor → RetryInterceptor → AppCacheInterceptor → LoggingInterceptor (debug only)
```
- `validateStatus: (s) => s != null && s < 500` — 4xx travel as `Failure` via `ResponseParser`, only 5xx hit Dio's `onError`.

---

## 15.7. Notifications — `NotificationManager` + `NotificationRouter`

> **Module:** `lib/src/core/notifications/` — singleton-based FCM via `awesome_notifications` + `awesome_notifications_fcm`.
> **FORBIDDEN packages:** `firebase_messaging`, `flutter_local_notifications` (يتعارضوا مع awesome_notifications).
> **Full deep-dive:** `.claude/skills/notifications/SKILL.md` + `lib/src/core/notifications/EXPLANATION.md`.

**Quick reference:**
```dart
// Bootstrap (main.dart)
await NotificationManager.instance.initialize(
  router: const AppNotificationRouter(),   // uses Modular.routerDelegate.navigatorKey
  debug: kDebugMode,
);
NotificationManager.instance.requestPermissions();  // iOS + Android 13+
NotificationManager.instance.requestToken();        // FCM token to send to backend

// Sealed routing
sealed class NotificationAction { const NotificationAction(); }
final class NavigateToChat extends NotificationAction { final String chatId; ... }
final class OpenUrl extends NotificationAction { final Uri url; ... }
// ... compiler enforces exhaustive switch in AppNotificationRouter.route
```

**Golden rules:**
- كل static handler بتتنادى من native لازم `@pragma('vm:entry-point')`.
- `channelKey` لازم يتطابق مع المسجل في `initialize` (Messaging / General / System).
- `id` في `NotificationContent` لازم `int` — استخدم `payload.id.hashCode`.
- ممنوع `BuildContext` في static handlers — استخدم `Modular.routerDelegate.navigatorKey`.
- التواصل background→main عبر `IsolateNameServer.lookupPortByName` فقط.
- السيرفر يبعت **data-only** messages (`data` بدون `notification` key).

---

## 16. Screen-Level Padding/Margin Adjustment (Figma → Code)

> Figma MCP often returns large padding/margin for the screen body. These look oversized on device.
> - Figma body padding ≤ 12px → **keep as-is**
> - Figma body padding > 12px → **reduce by 2–4px** (e.g. Figma 16 → 12 or 14, Figma 20 → 16)
> - This applies ONLY to screen-level body padding — NOT card-internal or component padding.

---

## 17. Icons — Use AppAssets As-Is (NO color, NO border, NO bg wrapper)

> **AppAssets icons exported from Figma بالـ colors والـ borders والـ backgrounds الصحيحة.**
> **استخدمهم زي ما هم — لا تضيف color override، ولا Container wrapper بـ bg/border.**
> **ده الـ default — مفيش استثناء غير لو الـ icon فعلاً template SVG بلون واحد.**

### Rule 17.1 — NEVER use IconData (Icons.*)

```dart
// ❌ FORBIDDEN — Material Icons / Cupertino Icons
Icon(Icons.search)
Icon(Icons.notifications, color: AppColors.primary)
IconWidget(icon: Icons.arrow_back)

// ✅ ALWAYS — AppAssets paths
IconWidget(icon: AppAssets.svg.baseSvg.search.path, height: AppSize.sH20)
IconWidget(icon: AppAssets.svg.baseSvg.notification.path, height: AppSize.sH24)
IconWidget(icon: AppAssets.svg.baseSvg.arrowBack.path, height: AppSize.sH20)
```

**لو الـ icon المطلوب مش موجود في AppAssets:** اطلب من المستخدم يضيف الـ asset. مش تستخدم `Icons.*` كـ fallback.

### Rule 17.2 — NEVER override icon color from AppAssets

```dart
// ❌ FORBIDDEN — adding color override
IconWidget(
  icon: AppAssets.svg.baseSvg.search.path,
  color: AppColors.primary,  // ← الـ icon already بلونه الصح من الديزاينر
  height: AppSize.sH20,
)

// ✅ CORRECT — icon used as-is
IconWidget(icon: AppAssets.svg.baseSvg.search.path, height: AppSize.sH20)
```

**استثناء وحيد:** لو الـ icon في AppAssets template SVG (single-fill بدون colors defined) — وقتها فقط `color:` parameter مسموح. لكن **افتراضياً افترض إن الـ icon ملون صح**.

### Rule 17.3 — NEVER wrap AppAssets icon in Container with bg/border

> **لو شفت icon في Figma داخل circle/rect بـ bg أو border:**
> **الـ icon في AppAssets موجود بالـ container/border/bg مرسومين فيه — مش محتاج تعمل Container إضافي.**

```dart
// ❌ FORBIDDEN — wrapping AppAssets icon in Container
Container(
  width: AppSize.sH48, height: AppSize.sH48,
  decoration: BoxDecoration(
    color: AppColors.fill,                                  // ← double bg!
    borderRadius: BorderRadius.circular(AppCircular.r8),
    border: Border.all(color: AppColors.border),            // ← double border!
  ),
  child: IconWidget(icon: AppAssets.svg.featureSvg.myIcon.path),
)

// ✅ CORRECT — icon already includes its circle/bg/border
IconWidget(icon: AppAssets.svg.featureSvg.myIcon.path, height: AppSize.sH48)
```

### Workflow بعد قراءة Figma (إلزامي)

```
1. شفت في الديزاين icon داخل border / bg / circle / rounded rect?
   → افتح AppAssets — الـ icon المفروض موجود بكل الـ details دي
   → استخدمه مباشرة بـ IconWidget، لا تضيف Container
2. شفت icon ملون بلون معين في Figma?
   → الـ icon في AppAssets موجود باللون الصحيح
   → لا تضيف color: parameter
3. مفيش icon في AppAssets يطابق المطلوب?
   → اطلب من المستخدم يضيف الـ asset — مش تستخدم Icons.* fallback
```

### القاعدة الذهبية

> **AppAssets path = complete visual.** لا تضيف عليه color، border، أو background. الـ designer رفعها بالشكل الصح، وأنت بس بتستدعيها.

---

## 18. Network Images → CachedImage ALWAYS

> ALL network/remote images (cards, lists, details, avatars) MUST use `CachedImage` from `core/widgets/image_widgets/cached_image.dart`.
> Never use `Image.network()` directly.

```dart
// ✅ Card image
CachedImage(url: item.image, width: AppSize.sW60, height: AppSize.sH60,
  borderRadius: BorderRadius.circular(AppCircular.r8))

// ✅ Circular avatar
CachedImage(url: user.photo, width: AppSize.sW44, height: AppSize.sH44,
  boxShape: BoxShape.circle)

// ❌ FORBIDDEN
Image.network(item.image, width: 60, height: 60)
```

---

## 19. Access Modifiers — ALWAYS Apply

> Use proper Dart access modifiers when creating classes, methods, and fields.

```dart
// ✅ Private widget (used only inside same file / part-of file)
class _MyFeatureBody extends StatelessWidget { ... }

// ✅ Private method (not exposed outside class)
void _handleTap() { ... }

// ✅ Private field
final String _internalValue;

// ✅ Public API — only what needs to be accessed from outside
class MyFeatureCubit extends AsyncCubit<List<ItemEntity>> {
  Future<void> fetchItems() async { ... }  // public — called from view
  void _processData(List data) { ... }     // private — internal logic
}

// ❌ WRONG — everything public by default
class MyWidget {
  String helperValue = '';          // should be _helperValue if internal
  void processInternal() { ... }   // should be _processInternal if not needed outside
}
```

**Rules:**
- Widget classes used only within their feature file → prefix with `_` (private)
- Helper methods not called from outside → prefix with `_`
- Fields not exposed to other classes → prefix with `_`
- Only expose what is needed for the public API

---

## 20. Naming Conventions — MANDATORY

> Every variable, function, class, and file name MUST be descriptive and self-documenting.

| Element | Convention | Example |
|---|---|---|
| File names | `snake_case` | `category_factories_body.dart` |
| Class names | `PascalCase` | `CategoryFactoriesBody` |
| Variables / fields | `camelCase` | `selectedCategory`, `isLoading` |
| Constants | `camelCase` or `SCREAMING_SNAKE` | `maxRetryCount`, `API_TIMEOUT` |
| Functions / methods | `camelCase`, verb-first | `fetchCategories()`, `deleteItem()`, `handleSubmit()` |
| Cubits | `VerbNounCubit` | `GetCategoriesCubit`, `DeleteItemCubit` |
| Entities | `NounEntity` | `CategoryEntity`, `ProductEntity` |
| Params | `NounParams` | `AddProductParams`, `LoginParams` |
| Screens | `NounScreen` | `CategoryFactoriesScreen` |
| Body widgets | `NounBody` | `CategoryFactoriesBody` |

```dart
// ✅ GOOD — descriptive names
final List<CategoryEntity> availableCategories;
Future<void> fetchCategoryFactories() async { ... }
class GetCategoryFactoriesCubit extends AsyncCubit<...> { ... }

// ❌ BAD — vague/abbreviated
final List<CategoryEntity> data;    // "data" tells nothing
Future<void> fetch() async { ... }  // fetch what?
class MyCubit extends AsyncCubit<...> { ... } // "My" is meaningless
```

---

## 21. Shared Widget Reuse — AUDIT BEFORE CREATING (CRITICAL)

> **قبل إنشاء أي widget جديد — لازم تراجع الشاشات والـ features اللي اتعملت قبل كده.**
> لو فيه card أو component بنفس التصميم أو تصميم قريب → **استدعيه بدل ما تكرره.**

**Rule:** Before building ANY card/component widget:
1. **Search `app_shared/widgets/`** — is it already shared?
2. **Search existing features** — does a similar widget exist (especially from recent screens)?
3. If same design 100% → **use it directly**
4. If minor differences → **add optional params** to the existing widget (don't create a copy)
5. If used in 2+ features → **move to `app_shared/widgets/`**
6. **Never duplicate** card widgets across features

```
lib/src/features/logic/app_shared/
├── widgets/
│   ├── product_card_widget.dart    ← reused across home, search, category screens
│   ├── factory_card_widget.dart    ← reused across categories and search
│   └── order_summary_widget.dart   ← reused across orders and checkout
```

```dart
// ✅ Reuse shared card
import '../../../app_shared/widgets/product_card_widget.dart';
ProductCardWidget(product: item)

// ✅ Same card with minor variations → optional params
ProductCardWidget(product: item, showPrice: false, showRating: true)

// ❌ WRONG — duplicate the same card in every feature
// features/home/widgets/home_product_card.dart  ← copy 1
// features/search/widgets/search_product_card.dart  ← copy 2 (same widget!)
// features/favorites/widgets/fav_product_card.dart  ← copy 3 (same widget!)
```

---

## 22. ViewController Class Pattern (MANDATORY — `presentation/cubit/`)

> **⚠️ ممنوع نهائياً: أي Controller أو ValueNotifier أو AnimationController أو ScrollController أو FocusNode داخل الـ View مباشرة.**
> **كل حاجة تتعلق بالـ ephemeral UI state + handlers بتاعتها لازم تكون في class منفصل (ViewController) داخل `presentation/cubit/<feature>_view_controller.dart`. الـ View تستدعي الـ class بس.**

### القاعدة الأساسية:
- **Location:** `presentation/cubit/<feature>_view_controller.dart` — part of `<feature>_imports.dart`.
- **ممنوع** وضع `TextEditingController`, `ValueNotifier`, `ScrollController`, `AnimationController`, `FocusNode` داخل الـ State أو الـ Widget.
- **ممنوع** استخدام `setState` للـ UI state — استخدم `ValueNotifier` + `ValueListenableBuilder`.
- **إلزامي** إنشاء class منفصل (ViewController) يحتوي: الـ controllers + الـ notifiers + الـ handlers الصغيرة (clear, toggle, …).
- الـ View تستخدم **object واحد** من الـ ViewController، تنشئه في `initState`، وتـ `dispose` منه في `dispose`.
- **الـ server data في الـ Cubit، الـ ephemeral UI state في الـ ViewController.** ما تخلطش بين الاثنين.

```dart
// ✅ CORRECT — Separate ViewController class in presentation/cubit/
// products_view_controller.dart
part of '../imports/products_imports.dart';

class ProductsViewController {
  ProductsViewController({required this.onSearch});
  final ValueChanged<String> onSearch;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<ProductStatus?> statusFilter = ValueNotifier(null);
  final FocusNode searchFocus = FocusNode();

  void setStatusFilter(ProductStatus? s) => statusFilter.value = s;
  void clearSearch() { searchController.clear(); onSearch(''); }

  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    statusFilter.dispose();
    searchFocus.dispose();
  }
}
```

```dart
// ✅ Screen owns the ViewController lifecycle (initState + dispose)
// products_screen.dart
part of '../imports/products_imports.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final ProductsCubit _cubit;
  late final ProductsViewController _vc;
  final BehaviorSubject<String> _searchSubject = BehaviorSubject.seeded('');
  StreamSubscription<String>? _searchSub;

  @override
  void initState() {
    super.initState();
    _cubit = Modular.get<ProductsCubit>()..fetchProducts();
    _vc = ProductsViewController(onSearch: _searchSubject.add);
    _searchSub = _searchSubject
        .debounceTime(const Duration(milliseconds: 350))
        .distinct()
        .listen((q) => _cubit.fetchProducts(search: q));
  }

  @override
  void dispose() {
    _searchSub?.cancel();
    _searchSubject.close();
    _vc.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<ProductsCubit>.value(
    value: _cubit,
    child: Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.products.tr())),
      body: _ProductsBody(controller: _vc),  // ← ViewController passed down
    ),
  );
}
```

```dart
// ✅ Inner widgets listen via ValueListenableBuilder — leaf-level rebuilds
// widgets/products_body.dart
part of '../imports/products_imports.dart';

class _ProductsBody extends StatelessWidget {
  const _ProductsBody({required this.controller});
  final ProductsViewController controller;

  @override
  Widget build(BuildContext context) => Column(children: [
    _ProductsSearchField(controller: controller),
    Expanded(
      child: AsyncBlocBuilder<ProductsCubit, List<ProductEntity>>(
        onRetry: () => context.read<ProductsCubit>().fetchProducts(
          search: controller.searchController.text,
        ),
        builder: (context, products) => ValueListenableBuilder<ProductStatus?>(
          valueListenable: controller.statusFilter,
          builder: (_, filter, _) {
            final visible = filter == null
                ? products
                : products.where((p) => p.status == filter).toList(growable: false);
            return _ProductsList(items: visible, controller: controller);
          },
        ),
      ),
    ),
  ]);
}
```

```dart
// ❌ FORBIDDEN — controllers/notifiers في الـ View
class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();              // ❌ يجب أن يكون في ViewController
  bool _isFiltering = false;                                       // ❌ استخدم ValueNotifier في ViewController
  final ValueNotifier<int> _tabIndex = ValueNotifier(0);           // ❌ يجب أن يكون في ViewController
  void _onSearch(String q) { setState(() => ...); }                // ❌ no setState — ValueNotifier + handler في ViewController
  Widget _buildFilterChip(String label) => Chip(...);              // ❌ Strict Rule #6 — انقله لـ widgets/<feature>_filter_chip.dart كـ _FilterChip
}
```

**Rules:**
- Folder location: `presentation/cubit/<feature>_view_controller.dart`. ملف واحد لكل screen (أو screen-group مرتبط).
- كل `TextEditingController`, `ValueNotifier`, `ScrollController`, `FocusNode`, `AnimationController` → داخل ViewController **فقط**.
- UI-only handlers الصغيرة (clear, toggle, setFilter) → ViewController. الـ server interactions → Cubit.
- استخدم `ValueNotifier` + `ValueListenableBuilder` (أو `ListenableBuilder` للـ multiple notifiers) بدل `setState`.
- الـ Screen ينشئ الـ ViewController في `initState` ويـ `dispose` منه في `dispose`.
- الـ inner widgets تستقبل الـ ViewController كـ `final` parameter — تستهلكه بدون أي state خاصة بها.

---

## 23. Icon Inside Container — Center Widget (Edge Case Only)

> **القاعدة الأساسية في Section 17: AppAssets icons موجودة بالـ bg/border بتاعها — مش محتاج Container إضافي.**
> **القسم ده يطبّق فقط في الحالات النادرة اللي محتاج فيها فعلاً Container (مثلاً icon-only badge counter جنب icon موجود) — وقتها لف الـ icon في `Center` widget.**

```dart
// ⚠️ Edge case — لو حقيقي محتاج Container حوالين الـ icon (مش الحالة العادية)
Container(
  width: AppSize.sH48, height: AppSize.sH48,
  decoration: BoxDecoration(color: AppColors.grey1, borderRadius: BorderRadius.circular(AppCircular.r8)),
  child: Center(
    child: IconWidget(icon: AppAssets.svg.appSvg.sent.path, width: AppSize.sW24, height: AppSize.sH24),
  ),
)
```

**في الـ 99% من الحالات:** الـ icon في AppAssets already فيه الـ container/bg/border — استخدمه مباشرة بدون لف. راجع Section 17.

---

## 24. Section Sub-Folders — Complex Screens

> **لما الشاشة فيها 4+ sections مختلفة، كل مجموعة مرتبطة حطها في sub-folder.**

```
widgets/
├── feature_body.dart          ← layout only (stays at root)
├── header/                    ← header group
│   ├── header_widget.dart
│   └── search_bar.dart
├── products/                  ← products group
│   ├── products_section.dart
│   └── product_card.dart
```

- 4+ sections مع 2+ widgets لكل section → sub-folders
- شاشة بسيطة (body + card + filter) → flat structure

---

## 25. Platform Configuration — Android & iOS (MANDATORY)

> **أي feature تحتاج camera, gallery, microphone, location, maps → لازم تضيف permissions للـ Android و iOS.**

| Feature | Android (AndroidManifest.xml) | iOS (Info.plist) |
|---------|------|------|
| Camera | `CAMERA` permission | `NSCameraUsageDescription` |
| Gallery | `READ_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES` | `NSPhotoLibraryUsageDescription` |
| Microphone | `RECORD_AUDIO` | `NSMicrophoneUsageDescription` |
| Location/Maps | `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` | `NSLocationWhenInUseUsageDescription` |
| Google Maps | `com.google.android.geo.API_KEY` meta-data | `GMSServices.provideAPIKey()` in AppDelegate |

**Prefer method channels over `permission_handler` package** — أقل dependencies وتحكم أكبر.

---

## 26. Package Preference — Use Existing Packages

> **لو فيه حاجة ممكن تتعمل بـ package مستقر → استخدمه. لا تبني من الصفر.**

| Feature | Use Package | Don't Build |
|---------|-------------|-------------|
| Rating stars | `flutter_rating_bar` | ❌ Custom star widget |
| Charts | `fl_chart` | ❌ Custom canvas |
| QR code | `qr_flutter` / `mobile_scanner` | ❌ Custom renderer |
| Maps | `google_maps_flutter` | ❌ Custom map |
| Signature | `signature` | ❌ Custom gesture drawing |
| WebView | `webview_flutter` | ❌ Custom browser |
| Dotted border | `dotted_border` | ❌ Custom dashed paint |

قبل ما تبني أي حاجة: ابحث pub.dev → تأكد إنه مستقر → أضفه للـ pubspec → `flutter pub get`.

---

## 27. RTL — Text Inside Components Mirroring Fix

> **نص داخل components أحياناً بيتعكس. لو النص بيظهر معكوس داخل widget معقد → استخدم `textDirection`.**

```dart
// ✅ Fix reversed text inside complex components
Text(
  LocaleKeys.itemName.tr(),
  textDirection: TextDirection.rtl,
  style: const TextStyle().setMainTextColor.s14.regular,
)

// ✅ Alternative — wrap in Directionality
Directionality(
  textDirection: TextDirection.rtl,
  child: Text(LocaleKeys.description.tr()),
)
```

**متى تستخدم:** داخل dialog, bottom sheet, custom card, أو third-party widget لو النص ظهر معكوس.
**متى لا تستخدم:** النص طبيعي → لا تضيف textDirection.

---

## 28. Installed Packages — Do NOT Re-Add

dio, firebase_core, firebase_messaging, cached_network_image, flutter_bloc,
get_it, flutter_screenutil, skeletonizer, flutter_animate, lottie, flutter_svg,
carousel_slider, dropdown_search, pinput, easy_localization, image_picker,
flutter_html, video_player, rxdart, share_plus, url_launcher, injectable

---

## 29. Clean Code — Remove Unused Imports & Parameters (MANDATORY)

> **كل ملف لازم يكون نظيف — لا imports مش مستخدمة ولا parameters مش مستخدمة.**

```dart
// ❌ FORBIDDEN — unused import
import 'package:flutter/foundation.dart'; // ← not used anywhere in file

// ❌ FORBIDDEN — unused optional parameter warning
class MyWidget extends StatelessWidget {
  final String? subtitle;  // ← never passed by any caller → REMOVE IT
  const MyWidget({super.key, this.subtitle});
}
// Warning: "A value for optional parameter 'subtitle' isn't ever given."

// ✅ CORRECT — only declare parameters that are actually used
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
}
```

**Rules:**
- بعد كل feature → شغّل `flutter analyze` وشيل كل unused imports
- لو parameter مش بيتبعت من أي caller → شيله
- لو parameter هيتحتاج في المستقبل → أضفه لما تحتاجه فعلاً، مش من الأول

---

## 30. const — Add to EVERY Widget That Can Be const (MANDATORY)

> **أي widget أو constructor ممكن يبقى const → لازم يبقى const.**

```dart
// ✅ CORRECT
const _MyBody()
const SizedBox.shrink()
const EdgeInsets.all(0)
children: const [Divider()]

// ❌ WRONG — missing const
_MyBody()           // ← can be const, add it!
SizedBox.shrink()   // ← can be const, add it!
```

**Quick rule:** لو Flutter analyzer بيقولك "Prefer const" → أضفها. دي بتقلل rebuilds وبتحسن performance.

---

## 31. Models & Enums → Entity Folder ONLY (NEVER Inside Widgets)

> **أي model, enum, helper class خاص بالـ feature لازم يكون في `entity/` folder — مش جوا widget class.**

```dart
// ✅ CORRECT — status model in entity folder
// entity/transaction_status_model.dart
class TransactionStatusModel {
  final String key;
  final String label;
  final Color bgColor;
  final Color textColor;

  const TransactionStatusModel({
    required this.key, required this.label,
    required this.bgColor, required this.textColor,
  });

  static TransactionStatusModel fromStatus(String status) {
    switch (status) {
      case 'paid':
        return TransactionStatusModel(
          key: status, label: LocaleKeys.paid.tr(),
          bgColor: AppColors.danger.withValues(alpha: 0.1),
          textColor: AppColors.danger,
        );
      case 'completed':
        return TransactionStatusModel(
          key: status, label: LocaleKeys.completed.tr(),
          bgColor: AppColors.green10,
          textColor: AppColors.green,
        );
      default:
        return TransactionStatusModel(
          key: status, label: status,
          bgColor: AppColors.grey1,
          textColor: AppColors.hintText,
        );
    }
  }
}

// ✅ Usage in widget — clean and simple
final statusModel = TransactionStatusModel.fromStatus(transaction.status);
Text(statusModel.label, style: const TextStyle().setColor(statusModel.textColor).s12.medium)

// ❌ FORBIDDEN — helper methods scattered inside widget class
class _TransactionCard extends StatelessWidget {
  String _statusKey(String status) { ... }      // ← move to model!
  Color _statusBgColor(String status) { ... }   // ← move to model!
  Color _statusTextColor(String status) { ... } // ← move to model!
}
```

**Rules:**
- كل logic خاص بتحويل data (status → color, status → label) → model/entity
- Widget = UI فقط، يستدعي الـ model ويعرض النتيجة
- لو الـ model مشترك بين أكثر من feature → `app_shared/entity/`

---

## 32. AppDropdown with API — NO BlocBuilder, NO Error UI (CRITICAL)

> **AppDropdown بياخد data من API service → لا تلفّه في `BlocBuilder` / `AsyncBlocBuilder` ولا تضيف error UI.**
> **لو الـ API فشلت → الـ dropdown هيظهر فاضي (items = []). كده وخلاص.**
> **مفيش retry button، مفيش "Failed to load cities" message، مفيش error widget على الـ dropdown.**

### Why?

الـ dropdown service صغيرة وثانوية. لو فشلت:
- المستخدم لو فعلاً محتاج اللي فيها (city, category) → يقفل ويفتح الشاشة تاني
- مفيش حاجة في الـ form الباقي تتأثر بفشل الـ dropdown
- إضافة error UI على dropdown بيضيف noise بصري ومش بيحل مشكلة

### ✅ CORRECT — pass cubit/items directly, no wrapper

```dart
class _MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<GetCitiesCubit>()..fetchCities(),
      child: Column(children: [
        // باقي الـ form
        const _OtherFields(),
        12.szH,
        // The dropdown — uses context.watch to react to cubit state
        Builder(builder: (ctx) {
          final state = ctx.watch<GetCitiesCubit>().state;
          return AppDropdown<CityEntity>(
            items: state.data,                    // ← []  لو فشلت، items هتبقى
            label: LocaleKeys.city.tr(),
            itemAsString: (c) => c.name,
            isLoading: state is AsyncLoading,           // ← AppDropdown يعرض shimmer داخلياً
            onChanged: (c) => params.city = c,
            validator: Validators.validateDropDown,
          );
        }),
      ]),
    );
  }
}
```

### ❌ FORBIDDEN — wrapping dropdown in BlocBuilder/AsyncBlocBuilder

```dart
// ❌ Adds error UI for a dropdown — لا
AsyncBlocBuilder<GetCitiesCubit, List<CityEntity>>(
  errorBuilder: (ctx, err) => ErrorView(error: err),   // ← لا — الـ dropdown مش محتاج error UI
  loadingBuilder: (_) => const _CityDropdownSkeleton(),
  builder: (ctx, cities) => AppDropdown(items: cities, ...),
)

// ❌ BlocBuilder حواليه — لا تستخدمه للـ dropdown
BlocBuilder<GetCitiesCubit, AsyncState<List<CityEntity>>>(
  builder: (ctx, state) => AppDropdown(items: state.data, ...),
)
```

### Rules

- AppDropdown مع service: استخدم `context.watch` أو direct cubit state → pass `items:` + `isLoading:` فقط
- **لا** تستخدم `AsyncBlocBuilder` ولا `BlocBuilder` حواليه
- **لا** تضيف `errorBuilder` ولا error state على الـ dropdown
- **لا** تضيف retry mechanism — الـ user يقفل ويرجع لو محتاج
- لو الـ data جاية مع باقي الـ form data (مثلاً من cubit واحد بيجيب form + dropdowns) → اقرأها بـ `state.data.cities`

### Multi-screen exception

> **AppDropdown داخل cubit الـ form الرئيسي:** ممكن تقرا من نفس الـ cubit بـ BlocSelector لو محتاج تتجنب unnecessary rebuilds. لكن مش `AsyncBlocBuilder` كامل.

---

## 33. Sliver vs Box — No Double-Wrap (CRITICAL)

> **`SliverToBoxAdapter` expects a child of type `RenderBox`, NOT `RenderSliver`.**
> If you wrap a widget that already returns a Sliver (e.g. `SliverToBoxAdapter`, `SliverList`) with `.toSliver()`, you get: *"expected a child of type RenderBox but received a child of type RenderSliverToBoxAdapter"*.

**Rule:** For any widget used inside `CustomScrollView`'s `slivers` list, choose **one** of:

| Approach | Widget returns | Parent usage |
|----------|----------------|--------------|
| **A** | Regular widget (Column, Container, etc.) | `MyWidget().toSliver()` |
| **B** | Sliver (SliverToBoxAdapter, SliverList, etc.) | `MyWidget()` — **no** `.toSliver()` |

```dart
// ✅ CORRECT — section returns Box, parent wraps once
class _SectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(children: [...]);  // Box
}
// In body: _SectionWidget().toSliver()

// ✅ CORRECT — section returns Sliver, parent does NOT wrap
class _SectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(child: Column(children: [...]));
}
// In body: _SectionWidget()   ← no .toSliver()

// ❌ FORBIDDEN — double wrap
class _SectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(child: Column(children: [...]));
}
// In body: _SectionWidget().toSliver()   ← SliverToBoxAdapter(child: SliverToBoxAdapter(...)) → CRASH
```

**Recommendation:** Prefer **Approach A**: section widgets return normal widgets (Column, Row, etc.); the parent uses `.toSliver()` once. Avoid returning `SliverToBoxAdapter` from a child if that child is ever used with `.toSliver()`.

---

## 34. Extensions — READ & USE Before Writing Custom Logic (CRITICAL)

> **قبل ما تكتب أي logic جديد — لازم تقرأ كل الـ extension files في `core/extensions/` وتستخدمها.**
> ده بيشمل: `text_style_extensions`, `string_extension`, `context_extension`, `padding_extension`, `margin_extention`, `widget_extension`, `sized_box_helper`, `sliver_extension`, `seperator_helper`, `indexed_map`, `form_mixin`.

**Full path:** `lib/src/core/extensions/`

```dart
// ✅ CORRECT — using existing extensions
myWidget.paddingAll(AppPadding.pH16)        // from padding_extension.dart
myWidget.marginStart(AppMargin.mW12)        // from margin_extention.dart
myWidget.onClick(onTap: () => Modular.to.pushNamed('/target'))   // from widget_extension.dart
12.szH                                       // from sized_box_helper.dart
widget.toSliver()                            // from sliver_extension.dart
widgets.joinWith(8.szH)                      // from seperator_helper.dart
list.indexedMap((i, item) => ...)            // from indexed_map.dart
'٠١٢٣'.toEnglishNumbers()                   // from string_extension.dart

// ❌ WRONG — writing custom logic that already exists as extension
SizedBox(height: 12.h)                       // use 12.szH
Padding(padding: EdgeInsets.all(16), ...)    // use .paddingAll()
GestureDetector(onTap: fn, child: widget)    // use .onClick()
SliverToBoxAdapter(child: widget)            // use .toSliver()
```
