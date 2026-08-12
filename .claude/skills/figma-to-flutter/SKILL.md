---
name: figma-to-flutter
description: Convert Figma designs to Flutter code using Flutter_Base architecture with safety checks and token mapping.
---

# Skill: Figma → Flutter (Flutter_Base Architecture)

## Purpose
Convert Figma designs to Flutter code using Flutter_Base architecture.
For design token values, see `design-tokens` skill.
For widget patterns, see `flutter-patterns` skill.
For coding standards, see `flutter-base-coding-standards.mdc`.

---

## ⚠️ POST-FIGMA RULES — اقرأها بعد ما تشوف الديزاين

### Rule 1: Icons — Use AppAssets As-Is (CRITICAL)

> **لما تشوف icon في Figma، خد بالك من 3 حاجات:**

```
1. الـ icon داخل circle / rect / colored bg / border?
   → الـ AppAssets icon موجود بـ كل الـ details دي (designer رفعها بالشكل النهائي)
   → استخدم IconWidget(icon: AppAssets.svg.x.path, height: ...) مباشرة
   → ❌ لا تلف الـ icon في Container إضافي بـ bg/border

2. الـ icon ملون بلون معين في الديزاين?
   → الـ AppAssets icon ملون صح
   → ❌ لا تضيف color: parameter

3. مفيش icon في AppAssets يطابق المطلوب?
   → اطلب من المستخدم يضيف الـ asset
   → ❌ لا تستخدم Icons.search / Icons.notifications / أي IconData كـ fallback
```

**أمثلة:**

```dart
// Figma: search icon
// ✅ CORRECT
IconWidget(icon: AppAssets.svg.baseSvg.search.path, height: AppSize.sH20)

// ❌ FORBIDDEN — color override
IconWidget(icon: AppAssets.svg.baseSvg.search.path, color: AppColors.hintText)

// ❌ FORBIDDEN — Material Icons
Icon(Icons.search, color: AppColors.hintText)

// Figma: notification icon داخل circle بـ fill رمادي
// ✅ CORRECT — AppAssets icon already includes the circle/bg
IconWidget(icon: AppAssets.svg.featureSvg.notificationCircle.path, height: AppSize.sH48)

// ❌ FORBIDDEN — wrapping in Container with bg/border
Container(
  decoration: BoxDecoration(color: AppColors.fill, shape: BoxShape.circle),
  child: IconWidget(icon: AppAssets.svg.featureSvg.notification.path),
)
```

### Rule 2: AppDropdown with API — NO BlocBuilder Wrapper (CRITICAL)

> **لما تشوف dropdown في الديزاين بياخد options من API service:**

```
1. وفّر الـ cubit بـ BlocProvider
2. اقرا الـ state بـ context.watch (مش AsyncBlocBuilder!)
3. pass state.data كـ items + state is AsyncLoading للـ AppDropdown
4. ❌ لا تلف الـ AppDropdown في AsyncBlocBuilder/BlocBuilder
5. ❌ لا تضيف errorBuilder أو error UI على الـ dropdown
6. لو فشلت الـ service → items فاضي، الـ user يقفل ويرجع
```

**مثال:**

```dart
// ✅ CORRECT — context.watch + items/isLoading directly
BlocProvider(
  create: (_) => Modular.get<GetCitiesCubit>()..fetchCities(),
  child: Builder(builder: (ctx) {
    final s = ctx.watch<GetCitiesCubit>().state;
    return AppDropdown<CityEntity>(
      items: s.data,
      isLoading: s.isLoading,
      label: LocaleKeys.city.tr(),
      itemAsString: (c) => c.name,
      onChanged: (c) => params.city = c,
      validator: Validators.validateDropDown,
    );
  }),
)

// ❌ FORBIDDEN — wrapping in AsyncBlocBuilder with error UI
AsyncBlocBuilder<GetCitiesCubit, List<CityEntity>>(
  errorBuilder: (_, e) => ErrorView(error: e),
  builder: (ctx, cities) => AppDropdown(items: cities, ...),
)
```

---

## Phase 1: Read Figma Node via MCP

```
1. get_node_info(nodeId)              → dimensions, fills, effects, layout
2. scan_nodes_by_types(nodeId, types) → all child node IDs
3. get_nodes_info([...ids])           → batch fetch max 10 at a time
4. scan_text_nodes(nodeId)            → all text content + styles
5. get_styles()                       → if design tokens needed
```

**Extract per node:**
- `width`, `height` → `AppSize.sWXX` / `AppSize.sHXX`
- `fills[0].color` (RGBA 0-1) → `AppColors.*`
- `cornerRadius` → `AppCircular.rXX`
- `padding*` → `AppPadding.pHXX` / `AppPadding.pWXX`
- `itemSpacing` → `.szH` / `.szW`
- `style.fontSize` → **reduce 1–2sp** then map to `FontSizeManager.sXX`
- `layoutMode` → VERTICAL=Column, HORIZONTAL=Row, NONE=Stack

---

## Phase 2: Figma MCP Safety Checks

### Screen-Level Padding Adjustment
- Body padding ≤ 12px → keep as-is
- Body padding > 12px → reduce by 2–4px (Figma 16 → 12 or 14)
- Only screen body — not card-internal padding

### RTL Section Verification (CRITICAL)
- MCP sometimes returns sections mirrored from actual design
- **ALWAYS cross-check with Figma screenshot**
- Arabic text/filters must start from RIGHT
- If MCP contradicts visual → trust the screenshot

### Icon Background Check
- Some AppAssets icons include their own background
- Check before wrapping in Container with bg color
- Has background → use `IconWidget` directly
- Transparent → wrap in Container

### Figma Hidden Layers Warning (CRITICAL)

> **الـ MCP ممكن ميرجعش hidden/invisible layers من Figma.**
> **لازم تشيك الـ screenshot عشان conditional UI اللي بتكون مخفية في التصميم.**

**ابحث عن:**
- Error banners / validation messages (مخفية في الحالة الطبيعية)
- Empty state designs (مخفية لما فيه data)
- Loading overlays / shimmer states
- Tooltip / popover content
- Conditional badges / tags (مثلاً "New", "Sale")
- Disabled state variations

**Workflow:**
1. اقرأ الـ nodes من MCP
2. قارن مع الـ screenshot — لو شايف عنصر في الـ screenshot مش موجود في الـ MCP → hidden layer
3. اسأل: "هل الشاشة دي ليها حالات تانية (empty, error, loading, disabled)؟"
4. لو أيوه → ابني الـ conditional UI حتى لو الـ MCP مرجعهاش

---

## Phase 2.5: Text Extraction → lang.json (MANDATORY)

> **⚠️ قبل كتابة أي كود — لازم تجمع كل النصوص من التصميم وتضيفها في `lang.json`.**

### Steps:
1. استخدم `scan_text_nodes(nodeId)` لاستخراج كل النصوص من التصميم
2. لكل نص ظاهر (عناوين، أزرار، labels، hints، placeholders، tabs، رسائل خطأ، empty states):
   - أنشئ key بـ `snake_case` يبدأ باسم الـ feature
   - أضفه في `assets/translations/lang.json` بالـ format: `"key #$ English": "عربي"`
3. شغّل: `dart run generate/strings/main.dart`
4. في الكود استخدم `LocaleKeys.keyName` فقط — **ممنوع أي نص مباشر**

### Format:
```json
{
  "feature_screen_title #$ Screen Title": "عنوان الشاشة",
  "feature_search_hint #$ Search here...": "ابحث هنا...",
  "feature_submit_btn #$ Submit": "إرسال"
}
```

### ⚠️ لا تتجاوز أي نص:
- حتى "OK", "لا", "نعم" → لازم من `LocaleKeys`
- Placeholders, tab labels, chip labels, filter names → كلهم من `LocaleKeys`
- لو النص موجود مسبقاً في `lang.json` → استخدمه، لا تكرره

---

## Phase 3: Mapping Workflow

### Colors
1. Read `color_manager.dart` FIRST
2. Match Figma color by **purpose** (not just hex)
3. Use existing AppColors when close match exists
4. Only add new with **generic names** (never screen-prefixed)

See `design-tokens` skill for full AppColors table.

### Sizes & Spacing
Map to nearest `AppSize` / `AppPadding` / `AppMargin` / `AppCircular` constant.
See `design-tokens` skill for all available values.

### Text Styles
**Font size adjustment from Figma:**
- **Figma ≤ 13sp (10, 11, 12, 13) → KEEP AS-IS — لا تقلل**
- Figma 14–18sp → reduce 1–2sp
- Figma ≥ 20sp → reduce 2sp

```dart
const TextStyle().setMainTextColor.s14.medium   // Figma 16sp title
const TextStyle().setHintColor.s12.regular       // Figma 14sp hint
```

### Widget Mapping
| Figma element | Flutter_Base widget |
|---|---|
| Screen with AppBar | `DefaultScaffold(title, body)` |
| Button (filled) | `DefaultButton` or `LoadingButton` |
| Image (network) | `CachedImage(url, width, height)` |
| Icon | `IconWidget(icon: AppAssets.svg.xxx.path)` |
| Text input (with label) | `CustomTextFiled(title, hint, controller)` — wraps DefaultTextField with label+asterisk |
| Text input (no label) | `DefaultTextField(controller, hint)` — raw base field, use for search bars |
| Dropdown | `AppDropdown<T>` |
| Shadow | `boxShadow: [AppColors.containerShadow]` |
| Loading state | `AsyncBlocBuilder` with `loadingBuilder` |

---

## Phase 4: Pixel Accuracy Checklist

```
□ Colors → AppColors reused by purpose (no raw Color(), no screen-prefixed names)
□ Font → TextStyleEx chain, ≤13sp keep as-is, 14+ reduced from Figma
□ Spacing → AppSize/AppPadding/AppMargin (no raw numbers)
□ Border radius → AppCircular.rXX
□ Images → CachedImage (never Image.network)
□ Icons → IconWidget + AppAssets (never Icons.*), SIZE matches Figma exactly (read width/height)
□ Icon size ≠ Container size → icon is SMALLER than its container (e.g. 20px icon in 40px container)
□ Buttons → DefaultButton / LoadingButton
□ Scaffold → DefaultScaffold (inner) / plain Scaffold (auth)
□ API state → AsyncCubit + AsyncBlocBuilder
□ Forms → FormMixin + CustomTextFiled + validateAndScroll()
□ Body padding > 12px → reduced 2–4px
□ Sections cross-checked with Figma screenshot
□ Card CONTENT RTL → every title, subtitle, icon+text row verified RIGHT-aligned inside cards
□ Widget splitting → each section/card in a SEPARATE file (no _buildXxx methods in body)
□ Similar widgets checked → reuse existing, moved to app_shared/ if 2+ features use it
□ ALL text from Figma added to lang.json BEFORE coding — zero hardcoded strings
□ LocaleKeys used for every Text/hint/label/title/button — no raw Arabic/English
```
