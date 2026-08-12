---
name: design-tokens
description: Map Figma design values (colors, sizes, fonts, spacing) to Flutter_Base token classes.
---

# Skill: Design Tokens — Flutter_Base

## Purpose
Map Figma design values to existing Flutter_Base token classes. The token files are already created — just use them correctly.

---

## Token Files Location

```
lib/src/config/res/
├── config_imports.dart    ← import this in any file to get all tokens
├── color_manager.dart     ← AppColors class
├── app_sizes.dart         ← AppSize, AppPadding, AppMargin, AppCircular,
│                             FontSizeManager, FontWeightManager
├── constants_manager.dart ← ConstantManager, SkeltonizerManager
├── fonts.gen.dart         ← FontFamily.expo = 'Expo'
└── assets.gen.dart        ← AppAssets (generated)
```

**Single import gives access to everything:**
```dart
import 'package:flutterbase/src/config/res/config_imports.dart';
// Gives: AppColors, AppSize, AppPadding, AppMargin, AppCircular,
//        FontSizeManager, FontWeightManager, ConstantManager, injector
```

---

## Figma Color → AppColors Mapping

### ⚠️ CRITICAL: Color Reuse Policy (READ BEFORE EVERY SCREEN)

> **ALWAYS reuse existing AppColors before adding new ones.**
> The core colors (`main`, `primary`, `secondary`, `hintText`, `fill`, `border`, etc.) are shared across ALL screens.

**Mandatory workflow for EVERY color from Figma:**
1. Extract the hex from Figma
2. Compare against ALL existing AppColors (read `color_manager.dart` first)
3. **Exact match** → use existing AppColors directly
4. **Close match** (similar tone/purpose) → use the existing one, don't create a new one
5. **Truly new** and no close match exists → add with a **GENERIC name** (never screen-prefixed)

### Close-Match Examples (USE EXISTING):
```
Figma #6B7280 (grey text)     → USE AppColors.hintText (#666666) — close enough
Figma #4B5563 (body text)     → USE AppColors.primary (#474747) — same purpose
Figma #374151 (label)         → USE AppColors.secondary (#292929) or AppColors.primary — dark text
Figma #F5F5F5 (light bg)      → USE AppColors.fill (#F9FAFB) — same purpose
Figma #E5E7EB (divider)       → USE AppColors.grey1 (#DFDFDF) or AppColors.border — similar
```

### ❌ FORBIDDEN — Screen-Prefixed Color Names:
```dart
// ❌ NEVER name colors after a specific screen
static const Color loginPrimary = Color(0xFF224D9B);
static const Color cartBackground = Color(0xFFF5F5F5);
static const Color profileDivider = Color(0xFFE5E7EB);

// ✅ CORRECT — generic reusable names
static const Color accentBlue = Color(0xFF224D9B);    // if truly new
static const Color lightBackground = Color(0xFFF5F5F5); // if truly new
```

### Exact Color Values (Base Palette)
```
#1C1C1C → AppColors.main         (darkest text — titles, headings)
#474747 → AppColors.primary      (primary text — body, labels)
#292929 → AppColors.secondary    (dark secondary text)
#1F2A37 → AppColors.third        (dark blue-grey)
#583D82 → AppColors.forth        (purple accent)
#666666 → AppColors.hintText     (hint/placeholder/subtitle text)
#F9FAFB → AppColors.fill         (light fill background for fields)
#000000 → AppColors.black
#FFFFFF → AppColors.white / AppColors.scaffoldBackground
#583D82 → AppColors.buttonColor  (purple button bg)
#F7F7F8 → AppColors.buttonText   (button text color)
#C5C6C9 → AppColors.border       (input borders, dividers)
#583D82 → AppColors.activeBorder (focused border)
#E34D4D → AppColors.error        (error red)
#DFDFDF → AppColors.grey1        (light grey — dividers, backgrounds)
#C7C7C7 → AppColors.grey2        (medium grey)
```

### Semantic Usage Guide (which color for what purpose):
```
Screen title / heading    → AppColors.main
Body text / labels        → AppColors.primary or AppColors.secondary
Hint / placeholder / subtitle → AppColors.hintText
Field fill background     → AppColors.fill
Borders / dividers        → AppColors.border or AppColors.grey1
Button background         → AppColors.buttonColor
Button text               → AppColors.buttonText
Error messages            → AppColors.error
Light card/section bg     → AppColors.fill or AppColors.scaffoldBackground
```

### Gradient Mapping
```
Figma linear gradient (dark to dark, bottom to top) → AppColors.gradient
Figma linear gradient (grey to grey, disabled)       → AppColors.disableGradient
```

### Shadow Mapping
```
Figma: Drop shadow, color=#F0F0F0, blur=4, offset=(0,0), spread=0
→ AppColors.containerShadow (BoxShadow)
```

---

## Figma Size → AppSize Mapping

### Height Mapping
```
Figma height → AppSize constant
1px  → AppSize.sH1
2px  → AppSize.sH2
4px  → AppSize.sH4
6px  → AppSize.sH6
8px  → AppSize.sH8
10px → AppSize.sH10
12px → AppSize.sH12
14px → AppSize.sH14
16px → AppSize.sH16
18px → AppSize.sH18
20px → AppSize.sH20
22px → AppSize.sH22
25px → AppSize.sH25
30px → AppSize.sH30
35px → AppSize.sH35
40px → AppSize.sH40
44px → AppSize.sH44
45px → AppSize.sH45 (default button height)
50px → AppSize.sH50
55px → AppSize.sH55
60px → AppSize.sH60
70px → AppSize.sH70
85px → AppSize.sH85
```

### Width Mapping
```
4px  → AppSize.sW4
6px  → AppSize.sW6
8px  → AppSize.sW8
10px → AppSize.sW10
12px → AppSize.sW12
14px → AppSize.sW14
16px → AppSize.sW16
18px → AppSize.sW18
20px → AppSize.sW20
25px → AppSize.sW25
30px → AppSize.sW30
40px → AppSize.sW40
50px → AppSize.sW50
60px → AppSize.sW60
70px → AppSize.sW70
```

---

## Figma Padding → AppPadding Mapping

```
Figma paddingVertical   → AppPadding.pHXX (H = height-based)
Figma paddingHorizontal → AppPadding.pWXX (W = width-based)

2px  → AppPadding.pH2
4px  → AppPadding.pH4 / AppPadding.pW4(→pW actually =pH4, use pH4)
6px  → AppPadding.pH6
8px  → AppPadding.pH8 / AppPadding.pW8
10px → AppPadding.pH10 / AppPadding.pW10
12px → AppPadding.pH12 / AppPadding.pW12
14px → AppPadding.pH14 / AppPadding.pW14
16px → AppPadding.pH16 / AppPadding.pW16
18px → AppPadding.pH18 / AppPadding.pW18
20px → AppPadding.pH20 / AppPadding.pW20
35px → AppPadding.pH35
60px → AppPadding.pW60
```

---

## Figma Margin → AppMargin Mapping

```
1px  → AppMargin.mH1
2px  → AppMargin.mH2
4px  → AppMargin.mH4 / AppMargin.mW4
6px  → AppMargin.mH6 / AppMargin.mW6
8px  → AppMargin.mH8 / AppMargin.mW8
10px → AppMargin.mH10 / AppMargin.mW10
12px → AppMargin.mH12 / AppMargin.mW12
14px → AppMargin.mH14 / AppMargin.mW14
16px → AppMargin.mH16 / AppMargin.mW16
18px → AppMargin.mH18 / AppMargin.mW18
20px → AppMargin.mH20 / AppMargin.mW20
30px → AppMargin.mH30
40px → AppMargin.mH40
```

---

## Figma Border Radius → AppCircular Mapping

```
2px  → AppCircular.r2
5px  → AppCircular.r5
8px  → AppCircular.r8
10px → AppCircular.r10
12px → AppCircular.r12
15px → AppCircular.r15
20px → AppCircular.r20
40px → AppCircular.r40
fully round → AppCircular.infinity
```

---

## ⚠️ Icon Size Adjustment (Figma → Code) — CRITICAL

> **الأيقونات بتتحط أكبر من التصميم لو مستخدمتش الحجم الصح من Figma.**
> **لازم تقرأ حجم الأيقونة من Figma بدقة وتطبقه بالظبط — أو تقلله لو شكله كبير.**

**Rules:**
1. **اقرأ `width` و `height` من Figma MCP بدقة** — مش تقدر من شكلها
2. **طبق الحجم بالظبط** — `IconWidget(height: AppSize.sHXX, width: AppSize.sWXX)`
3. **لو الأيقونة شكلها كبير عن التصميم** → قلل 2-4px
4. **لو الأيقونة جوا Container** → حجم الأيقونة ≠ حجم الـ Container. Container أكبر والأيقونة أصغر جواه

```dart
// ✅ CORRECT — icon size matches Figma exactly
// Figma: icon 20x20 inside 40x40 container
Container(
  width: AppSize.sW40, height: AppSize.sH40,
  decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(AppCircular.r10)),
  child: Center(
    child: IconWidget(icon: AppAssets.svg.baseSvg.search.path, height: AppSize.sH20, width: AppSize.sW20),
  ),
)

// ✅ CORRECT — standalone icon with exact Figma size
IconWidget(icon: AppAssets.svg.baseSvg.notification.path, height: AppSize.sH24, width: AppSize.sW24)

// ❌ WRONG — icon too large (used container size for icon)
IconWidget(icon: AppAssets.svg.baseSvg.search.path, height: AppSize.sH40)  // ← should be sH20!

// ❌ WRONG — guessed icon size instead of reading from Figma
IconWidget(icon: ..., height: AppSize.sH30)  // Figma says 20 → should be sH20
```

**Quick icon size guide:**
| Figma context | Typical icon size | Container size |
|---|---|---|
| Small inline icon (next to text) | 14-18px | No container |
| Medium icon (card, list item) | 20-24px | 36-44px (if has bg) |
| Large icon (feature/empty state) | 28-40px | 48-60px (if has bg) |

---

## Figma Font Size → FontSizeManager Mapping

### ⚠️ CRITICAL: Font Size Adjustment Rule

> Figma font sizes need adjustment when converting to Flutter code.
> This compensates for rendering differences between Figma and Flutter (especially with Expo Arabic font + ScreenUtil `.sp`).

**Adjustment guideline:**
- **Figma ≤ 13sp (10, 11, 12, 13) → KEEP AS-IS — لا تقلل.** النصوص الصغيرة تبقى زي ما هي.
- Figma 14–18sp → reduce by **1–2sp** (prefer 1sp for readability)
- Figma ≥ 20sp → reduce by **2sp**

### Figma → Code Mapping Table

```
Figma fontSize → Code fontSize (EXACT — no guessing)
10sp → .s10  (keep)
11sp → .s11  (keep)
12sp → .s12  (keep)
13sp → .s13  (keep)
14sp → .s13  (reduce 1)
15sp → .s13  (reduce 2)
16sp → .s14  (reduce 2)
17sp → .s15  (reduce 2)
18sp → .s16  (reduce 2)
20sp → .s18  (reduce 2)
22sp → .s20  (reduce 2)
24sp → .s22  (reduce 2)
26sp → .s24  (reduce 2, use TextStyleEx .s24)
28sp → .s26  (reduce 2, use TextStyleEx .s26)
30sp → .s28  (reduce 2, use TextStyleEx .s28)
```

### Available FontSizeManager constants
```
FontSizeManager.s6 / s8 / s10 / s11 / s12 / s13 / s14 / s15 / s16 / s18 / s20 / s22
```

**If Figma font size not in list:** Use TextStyleEx getter: `.s14` etc. up to `.s50`

### Example
```dart
// Figma: title 16sp bold
// ✅ CORRECT — reduced to 14sp
const TextStyle().setMainTextColor.s14.bold

// ❌ WRONG — used Figma value directly
const TextStyle().setMainTextColor.s16.bold

// Figma: body 14sp regular
// ✅ CORRECT — reduced to 13sp or 12sp
const TextStyle().setHintColor.s13.regular

// Figma: heading 22sp bold
// ✅ CORRECT — reduced to 20sp
const TextStyle().setMainTextColor.s20.bold
```

---

## Figma Font Weight → FontWeightManager / TextStyleEx

> **⚠️ تنبيه: `FontWeightManager.regular` = w500 (مش w400). استخدم الجدول ده بالظبط:**

| Figma weight | FontWeightManager | TextStyleEx | Flutter FontWeight |
|---|---|---|---|
| 300 | `FontWeightManager.light` | `.light` | `w300` |
| 400 | — (use TextStyleEx) | `.regular` | `w400` |
| 500 | `FontWeightManager.regular` | `.medium` | `w500` |
| 600 | — (use TextStyleEx) | `.semiBold` | `w600` |
| 700 | `FontWeightManager.bold` | `.bold` | `w700` |

```dart
// Figma weight 400 → .regular (w400)
const TextStyle().setMainTextColor.s14.regular

// Figma weight 500 → .medium (w500) — NOT .regular!
const TextStyle().setMainTextColor.s14.medium

// Figma weight 600 → .semiBold (w600)
const TextStyle().setMainTextColor.s14.semiBold

// Figma weight 700 → .bold (w700)
const TextStyle().setMainTextColor.s14.bold
```

---

## Figma Font Family

```
All text in this project uses: FontFamily.expo = 'Expo'
Already set in AppTheme: fontFamily: ConstantManager.fontFamily
No need to set fontFamily on individual TextStyle — inherited from theme.
Exception: if a specific text node in Figma uses a different font, set explicitly.
```

---

## When Figma Has Non-Standard Values

If Figma uses a value not in the token map (e.g., 9px, 17px, 27px):
1. Round to nearest available token
2. Use `.h`, `.w`, `.sp`, `.r` from flutter_screenutil directly if needed:
   ```dart
   SizedBox(height: 9.h)
   Container(padding: EdgeInsets.all(17.w))
   ```
3. Add a comment: `// Figma: 17px - no AppPadding equivalent`

---

## Available Extensions (core/extensions/)

> **Check these BEFORE writing any custom logic.**

| Extension | File | Key methods |
|---|---|---|
| `TextStyleEx` | `text_style_extensions.dart` | `.setMainTextColor`, `.s14`, `.bold`, `.ellipsis`, `.setColor()` |
| `FormatString` | `string_extension.dart` | `.toEnglishNumbers()`, `.capitalize()`, `.toCurrency()`, `.copyToClipboard()`, `.isNumeric()` |
| `DateTimeFormatHelper` | `string_extension.dart` | `.toFullDate()`, `.toTime()`, `.toDayMonthYear()`, `.toMonth()` |
| `ContextExtension` | `context_extension.dart` | `context.width`, `context.height`, `context.hideKeyboard()`, `context.isArabic`, `context.isRight` |
| `PaddingExtension` | `widgets/padding_extension.dart` | `.paddingAll()`, `.paddingStart()`, `.paddingEnd()`, `.paddingOnlyDirectional()` |
| `MarginExtension` | `widgets/margin_extention.dart` | `.marginAll()`, `.marginStart()`, `.marginEnd()`, `.marginOnlyDirectional()` |
| `OnClick` | `widgets/widget_extension.dart` | `.onClick(onTap: fn)` |
| `TextWithIcon` | `widgets/widget_extension.dart` | `.withIcon(icon)` |
| `SizedBoxHelper` | `widgets/sized_box_helper.dart` | `12.szH`, `16.szW` |
| `SliverExtension` | `widgets/sliver_extension.dart` | `.toSliver()` |
| `SeparatorExtension` | `widgets/seperator_helper.dart` | `listOfWidgets.joinWith(separator)` |
| `IndexedMap` | `indexed_map.dart` | `list.indexedMap((index, item) => ...)` |
| `FormMixin` | `form_mixin.dart` | `formKey`, `validate()`, `validateAndScroll()` — MANDATORY for all forms |

---

## Available Helpers (core/helpers/)

> **Read this folder BEFORE creating any utility logic.**

| Helper | File | What it provides |
|---|---|---|
| `Validators` | `validators.dart` | `validateEmpty`, `validateEmail`, `validatePhone`, `validatePassword`, `validatePasswordConfirm`, `validateDropDown`, `noValidate` |
| Input Formatters | `input_formatters.dart` | `PhoneNumberFormatter`, `EmailFormatter`, `NumberOnlyFormatter`, `TextOnlyFormatter`, `TextWithNumberFormatter`, `IntegerNumberFormatter`, `DecimalNumberFormatter`, `DateTimeFormatter`, `NoSpecialCharactersFormatter` |
| `ArabicNumbersFormatter` | `arabic_numbers_formatter.dart` | Auto-converts ٠-٩ → 0-9 in text fields (MANDATORY for number/phone fields) |
| `Helpers` | `helpers.dart` | `showByLang(ar, en)`, `getFcmToken()`, `changeStatusbarColor()`, `shareApp()`, `getDeviceType()` |
| `ImageHelper` | `image_helper.dart` | Pick/crop single/multi images, camera, gallery, file picker |
| `LauncherHelper` | `lancher_helper.dart` | Launch URL, WhatsApp, YouTube, Twitter, Instagram, Snapchat, TikTok, phone call, email |
| `CacheStorage` | `cache_service.dart` | SharedPreferences wrapper (read, write, delete, readList) |
| `SecureStorage` | `cache_service.dart` | FlutterSecureStorage for sensitive data (tokens, credentials) |
| `FullScreenLoadingManager` | `loading_manager.dart` | Full-screen loading overlay (`show()` / `hide()`) |

---

## Available Shared (core/shared/)

> **Check before creating common models or cubits.**

| Shared | File | What it provides |
|---|---|---|
| `BaseModel<T>` | `models/base_model.dart` | Generic API response wrapper (message, data, key) |
| `UserModel` | `models/user_model.dart` | User entity: `initial()`, `fromJson()`, `copyWith()`, `toJson()` |
| `ImageEntity` | `models/image_entity.dart` | Image model: network + local file support, `initial()`, `fromJson()` |
| `UserCubit` | `cubits/user_cubit/` | Current user state management |
| `BaseUrlCubit` | `cubits/base_url/` | API base URL management |
| Service Locator | `service_locators/` | GetIt + Injectable: `Modular.get<T>()` |
