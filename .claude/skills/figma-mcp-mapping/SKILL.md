---
name: figma-mcp-mapping
description: Figma MCP to Flutter_Base token mapping — colors, sizes, padding, radius, fonts. Use when reading Figma nodes via MCP.
---

# Figma MCP → Flutter_Base Token Mapping

## ⚠️ RTL Conversion

> **See `rtl-arabic` skill for full RTL rules.** Core equation:
> `Figma RIGHT → Flutter "start"` | `Figma LEFT → Flutter "end"` | `Row first child → physical RIGHT`

---

## ⚠️ Screen-Level Padding/Margin Adjustment (Figma → Code)

> Figma MCP often returns large padding/margin values for the overall screen body.
> These values look oversized on real devices. **Reduce them for visual accuracy.**

| Figma body padding | Code adjustment |
|---|---|
| ≤ 12px | Keep as-is — use the exact value |
| > 12px (e.g. 14, 16, 20, 24) | Reduce by **2–4px** (e.g. Figma 16 → use 12 or 14, Figma 20 → use 16) |

```dart
// Figma screen body has padding: 20px all sides
// ✅ CORRECT — reduced
body.paddingSymmetric(horizontal: AppPadding.pW16, vertical: AppPadding.pH16)

// ❌ WRONG — used Figma value directly, looks too spacious
body.paddingSymmetric(horizontal: AppPadding.pW20, vertical: AppPadding.pH20)

// Figma body padding: 12px → keep as-is
body.paddingAll(AppPadding.pH12) // ✅ no reduction needed
```

**This applies ONLY to screen-level body padding/margin — NOT to card-internal spacing or component padding.**

---

## ⚠️ RTL Section Verification (Figma MCP Reading — CRITICAL)

> Figma MCP sometimes returns sections **mirrored/reversed** from the actual design.
> Images that appear on the RIGHT in Figma may be reported on the LEFT, or filter tabs may appear reversed.

**MANDATORY verification for EVERY section read from Figma MCP:**
1. After reading a section via MCP, **cross-check** with the actual Figma screenshot
2. Verify that **Arabic text starts from the RIGHT side** (start in RTL)
3. Verify that **horizontal lists/filters start from the RIGHT** — the first item (e.g. "عرض الكل") must be on the physical RIGHT
4. Verify **images in cards** are positioned correctly (match the Figma visual, not just MCP coordinates)
5. If MCP data contradicts the visual — **trust the visual screenshot, not the raw MCP data**

```dart
// Figma: filter tabs → "عرض الكل" on the RIGHT, then categories flow to the LEFT
// ✅ CORRECT — first child in Row = physical RIGHT in RTL
Row(children: [showAllTab, category1Tab, category2Tab])

// ❌ WRONG — MCP returned reversed order
Row(children: [category2Tab, category1Tab, showAllTab])

// Figma: card with image on the RIGHT and text on the LEFT
// ✅ CORRECT — image is first child (physical RIGHT in RTL)
Row(children: [CachedImage(...), Expanded(child: textColumn)])

// ❌ WRONG — MCP reported image on left
Row(children: [Expanded(child: textColumn), CachedImage(...)])
```

---

## ⚠️ Icons — Use AppAssets As-Is (NO color, NO wrapper)

> **القاعدة الأساسية:** الـ AppAssets icons موجودة بالألوان والـ borders والـ backgrounds الصحيحة من الديزاينر.
> **استخدمهم زي ما هم — لا تضيف `color:` ولا Container بـ bg/border.**

**Workflow per icon من Figma:**
1. شفت icon ملون / داخل circle / بـ bg في Figma → استخدم `IconWidget(icon: AppAssets.xxx.path)` مباشرة بدون أي إضافات
2. شفت icon transparent بدون bg → برضو استخدم `IconWidget(icon: AppAssets.xxx.path)` مباشرة. **لا تضيف Container** غير لو فعلاً الـ asset transparent ومحتاج container (edge case نادر).
3. مفيش icon مطابق في AppAssets → اطلب من المستخدم يضيف الـ asset — مش `Icons.*` fallback.

```dart
// ✅ CORRECT — use AppAssets icon as-is
IconWidget(icon: AppAssets.svg.featureSvg.myIcon.path, height: AppSize.sH40)
IconWidget(icon: AppAssets.svg.baseSvg.search.path, height: AppSize.sH20)

// ❌ FORBIDDEN — color override
IconWidget(icon: AppAssets.svg.baseSvg.search.path, color: AppColors.primary)

// ❌ FORBIDDEN — IconData (Material Icons)
Icon(Icons.search, color: AppColors.primary)

// ❌ FORBIDDEN — wrapping in Container with bg/border
Container(
  decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(AppCircular.r10)),
  child: IconWidget(icon: AppAssets.svg.baseSvg.search.path),  // ← double bg if asset has its own
)
```

---

## Reading Figma Nodes

```
1. get_node_info(nodeId)              → dimensions, fills, cornerRadius, padding
2. scan_nodes_by_types(nodeId, types) → all children IDs
3. get_nodes_info([...ids])           → batch fetch (max 10 at a time)
4. scan_text_nodes(nodeId)            → text content + styles
```

**Per node extract:**
- `width/height` → `AppSize.sWXX` / `AppSize.sHXX`
- `fills[0].color` (RGBA 0-1) → `AppColors.*`
- `cornerRadius` → `AppCircular.rXX`
- `paddingTop/Bottom` → `AppPadding.pHXX`
- `paddingLeft/Right` → `AppPadding.pWXX`
- `itemSpacing` → `AppMargin.mHXX` / `.szH`
- `style.fontSize` → `FontSizeManager.sXX`
- `layoutMode` → VERTICAL=Column, HORIZONTAL=Row, NONE=Stack

---

## Color Mapping

> **See `design-tokens` skill for full AppColors table and close-match rules.**

**Workflow:** Figma hex → read `color_manager.dart` → match by **purpose** (not just hex) → use existing → truly new? add with **generic name** (never screen-prefixed)

---

## Size Mapping

| Figma px | AppSize Height | AppSize Width |
|----------|---------------|--------------|
| 8 | `AppSize.sH8` | `AppSize.sW8` |
| 10 | `AppSize.sH10` | `AppSize.sW10` |
| 12 | `AppSize.sH12` | `AppSize.sW12` |
| 14 | `AppSize.sH14` | `AppSize.sW14` |
| 16 | `AppSize.sH16` | `AppSize.sW16` |
| 20 | `AppSize.sH20` | `AppSize.sW20` |
| 25 | `AppSize.sH25` | `AppSize.sW25` |
| 30 | `AppSize.sH30` | `AppSize.sW30` |
| 40 | `AppSize.sH40` | `AppSize.sW40` |
| 44 | `AppSize.sH44` | — |
| 45 | `AppSize.sH45` | — |
| 50 | `AppSize.sH50` | `AppSize.sW50` |
| 60 | `AppSize.sH60` | `AppSize.sW60` |
| 70 | `AppSize.sH70` | `AppSize.sW70` |
| 85 | `AppSize.sH85` | — |

---

## Padding Mapping

| Figma px | AppPadding (vertical) | AppPadding (horizontal) |
|----------|----------------------|------------------------|
| 4 | `AppPadding.pH4` | — |
| 6 | `AppPadding.pH6` | — |
| 8 | `AppPadding.pH8` | `AppPadding.pW8` |
| 10 | `AppPadding.pH10` | `AppPadding.pW10` |
| 12 | `AppPadding.pH12` | `AppPadding.pW12` |
| 14 | `AppPadding.pH14` | `AppPadding.pW14` |
| 16 | `AppPadding.pH16` | `AppPadding.pW16` |
| 18 | `AppPadding.pH18` | `AppPadding.pW18` |
| 20 | `AppPadding.pH20` | `AppPadding.pW20` |
| 35 | `AppPadding.pH35` | — |
| 60 | — | `AppPadding.pW60` |

---

## Border Radius Mapping

| Figma | AppCircular |
|-------|-------------|
| 2 | `AppCircular.r2` |
| 5 | `AppCircular.r5` |
| 8 | `AppCircular.r8` |
| 10 | `AppCircular.r10` |
| 12 | `AppCircular.r12` |
| 15 | `AppCircular.r15` |
| 20 | `AppCircular.r20` |
| 40 | `AppCircular.r40` |
| full circle | `AppCircular.infinity` |

---

## Font Mapping

### ⚠️ Font Size Adjustment Rule (MANDATORY)

> Figma font sizes MUST be reduced by **1-2sp** in Flutter code.
> This ensures visual consistency between Figma design and the rendered app (Expo font + ScreenUtil).

| Figma size | Code size (adjusted) | TextStyleEx |
|---|---|---|
| 10 | 10 (keep) | `.s10` |
| 11 | 11 (keep) | `.s11` |
| 12 | 12 (keep) | `.s12` |
| 13 | 13 (keep) | `.s13` |
| 14 | 13 or 12 | `.s13` or `.s12` |
| 15 | 14 or 13 | `.s14` or `.s13` |
| 16 | 14 or 15 | `.s14` or `.s15` |
| 17 | 15 or 16 | `.s15` or `.s16` |
| 18 | 16 or 17 | `.s16` or `.s17` |
| 20 | 18 | `.s18` |
| 22 | 20 | `.s20` |
| 24 | 22 | `.s22` |

**Quick rule:** Figma ≤13 → keep as-is. Figma 14-18 → subtract 1-2. Figma >=20 → subtract 2.

| Figma weight | FontWeightManager / TextStyleEx | Note |
|-------------|-------------------------------|------|
| 300 | `FontWeightManager.light` / `.light` | w300 |
| 400 | `.regular` | w400 (TextStyleEx only) |
| 500 | `FontWeightManager.regular` / `.medium` | w500 — ⚠️ FontWeightManager.regular = w500, not w400 |
| 600 | `.semiBold` | w600 |
| 700 | `FontWeightManager.bold` / `.bold` | w700 |

**For non-standard px:** Use `SizedBox(height: 9.h)` directly with screenutil.

---

## Widget Mapping

> **See `flutter-base-coding-standards.mdc` section 11 for full widget inventory with usage examples.**
> **See sections 12-13 for extension and helper quick references.**

Key mappings: Screen→`DefaultScaffold`, Button→`LoadingButton`/`DefaultButton`, Input→`CustomTextFiled`, Image→`CachedImage`, State→`AsyncBlocBuilder`, Icon→`IconWidget`
