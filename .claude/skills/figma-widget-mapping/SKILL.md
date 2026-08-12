---
name: figma-widget-mapping
description: Comprehensive mapping from Figma MCP elements (Frame, Auto-layout, Instance, Vector, Text) to Flutter_Base widgets. Use when converting Figma designs.
---

# Skill: Figma Component to Flutter Widget Mapping

## When to Use

- عند تحويل أي تصميم Figma لكود Flutter
- عند قراءة Figma MCP output وتحتاج تعرف الـ widget المقابل
- عند مراجعة كود متحول من Figma

---

## Master Mapping Table

### Layout & Structure

| Figma Element | Figma Properties | Flutter Widget | Notes |
|---------------|-----------------|----------------|-------|
| **Frame** (vertical, no auto-layout) | fixed size | `SizedBox` or `Container` | Use Container only if decoration needed |
| **Frame** (vertical, auto-layout) | auto-layout: vertical | `Column` | Main axis = vertical |
| **Frame** (horizontal, auto-layout) | auto-layout: horizontal | `Row` | Main axis = horizontal. **RTL:** reverse children order from MCP |
| **Frame** (wrap) | auto-layout: wrap | `Wrap` | For tags, chips, badges |
| **Frame** (scrollable, vertical) | overflow: scroll | `ListView` or `SingleChildScrollView` + `Column` | Use ListView for data lists |
| **Frame** (scrollable, horizontal) | overflow: scroll, horizontal | `SingleChildScrollView` + `Row` | scrollDirection: Axis.horizontal |
| **Frame** with clip | clip content: true | `ClipRRect` or Container with `clipBehavior` | |
| **Group** | no auto-layout | `Stack` | Overlapping elements only. Rarely needed |
| **Component** | reusable | Extract to separate widget file | One file per component |
| **Instance** | component instance | Use the extracted widget | Pass different props |

### Auto-Layout to Flex Properties

| Figma Auto-Layout Property | Flutter Equivalent |
|---------------------------|-------------------|
| Primary axis: space-between | `MainAxisAlignment.spaceBetween` |
| Primary axis: center | `MainAxisAlignment.center` |
| Primary axis: start | `MainAxisAlignment.start` |
| Primary axis: end | `MainAxisAlignment.end` |
| Counter axis: center | `CrossAxisAlignment.center` |
| Counter axis: start | `CrossAxisAlignment.start` |
| Counter axis: stretch | `CrossAxisAlignment.stretch` |
| Item spacing: 8 | `8.szH` (vertical) or `8.szW` (horizontal) between children |
| Padding: 16,12,16,12 | `.paddingAll()` or `.paddingSymmetric()` or `.paddingOnly()` |
| Fill container (child) | `Expanded` wrapper on that child |
| Hug contents | No Expanded — natural size |
| Fixed width/height | `SizedBox(width: AppSize.sW___, height: AppSize.sH___)` |

### Spacing & Padding

| Figma | Flutter | Rule |
|-------|---------|------|
| Padding: all 16 | `.paddingAll(AppPadding.p16)` | Reduce body padding > 12 by 2-4px |
| Padding: horizontal 16, vertical 12 | `.paddingSymmetric(h: AppPadding.p16, v: AppPadding.p12)` | |
| Gap between items: 8 | `8.szH` (Column) or `8.szW` (Row) | Never raw `SizedBox` |
| Margin around element | `.paddingAll(...)` on the widget | Flutter has no margin concept on widgets |

### Text

| Figma Property | Flutter Property | Mapping |
|---------------|-----------------|---------|
| Font family: Expo Arabic | Default — already set in theme | Don't specify font |
| Font size: 16sp | `FontSizeManager.fs14` | Reduce: <=13 keep, 14-18 reduce 1-2, >=20 reduce 2 |
| Font weight: Bold (700) | `TextStyleEx.bold` or `FontWeightManager.bold` | |
| Font weight: Semi-Bold (600) | `TextStyleEx.semiBold` or `FontWeightManager.semiBold` | |
| Font weight: Medium (500) | `TextStyleEx.regular` | WARNING: regular = w500, NOT w400 |
| Font weight: Regular (400) | `TextStyleEx.light` or `FontWeightManager.light` | w400 in this project |
| Text color: #333333 | `AppColors.font1` | Match by purpose, not exact hex |
| Text color: #666666 | `AppColors.font2` | Secondary text |
| Text color: #999999 | `AppColors.font3` | Hint/disabled text |
| Max lines: 2 + ellipsis | `maxLines: 2, overflow: TextOverflow.ellipsis` | |
| Text align: right | Default in RTL — don't specify | Only set if explicitly center/left |

### Images & Icons

| Figma Element | Flutter Widget | Pattern |
|---------------|---------------|---------|
| Image (remote URL) | `CachedImage(url, width, height)` | NEVER `Image.network` |
| Image (local asset) | `IconWidget(icon: path)` | SVG/PNG from assets |
| Icon (vector) | `IconWidget(icon: path, color, height)` | NEVER `Icons.*` material icons |
| Icon in circle/square bg | `Container` + `Center` + `IconWidget` | MUST wrap icon in `Center` |
| Avatar/profile image | `CachedImage` with `CircleAvatar` or `ClipRRect` | borderRadius for circle |
| Placeholder image | `CachedImage` handles placeholder internally | |

### Interactive Elements

| Figma Element | Flutter Widget | Notes |
|---------------|---------------|-------|
| Button (primary, filled) | `LoadingButton(title, onTap)` | For form submits (async) |
| Button (primary, not async) | `DefaultButton(title, onTap)` | For navigation/non-API actions |
| Button (outlined) | `DefaultButton` with outline style | Check existing button variants |
| Text input | `CustomTextFiled(title, hint, controller)` | With label + asterisk |
| Text input (no label) | `DefaultTextField(controller, hint)` | Search bars, inline inputs |
| Dropdown | `AppDropdown<T>(items, label, onChanged)` | |
| Checkbox | `Checkbox` or custom | |
| Switch/Toggle | `Switch` or custom | |
| OTP input | `CustomPinTextField(controller)` | 4-6 digit |
| Search field | `DefaultTextField` + rxdart debounce | See search-field-debounce skill |
| Rating stars | `flutter_rating_bar` package | Don't build custom |

### Cards & Containers

| Figma Element | Flutter Pattern | Notes |
|---------------|----------------|-------|
| Card with shadow | `Container` + `BoxDecoration(boxShadow)` | |
| Card with border | `Container` + `BoxDecoration(border)` | |
| Card with border-radius | `Container` + `BorderRadius.circular(AppCircular.r__)` | |
| Dotted border card | `DottedBorder` package | Don't build custom |
| Divider line | `Divider()` or `Container(height: 1, color:)` | |
| Badge/tag/chip | `Container` + text + padding + borderRadius | Small colored label |

### Lists & Scrolling

| Figma Pattern | Flutter Widget | When |
|---------------|---------------|------|
| Vertical list (API data) | `ListView.builder` | Always for data lists |
| Vertical list (fixed items) | `Column` | Static content only |
| Horizontal list (scrollable) | `SizedBox(height) + ListView.builder(horizontal)` | Must constrain height |
| Grid | `GridView.builder` | Products grid, gallery |
| Paginated list | `PaginatedListWidget<C, T>` | API with pagination |
| Pull to refresh | `RefreshIndicator` wrapping the list | All data screens |
| Tabs | `DefaultTabController` + `TabBar` + `TabBarView` | |

### Overlays & Popups

| Figma Element | Flutter Widget | Pattern |
|---------------|---------------|---------|
| Dialog/modal | `showCustomDialog(context, child)` | Scale+fade animation |
| Bottom sheet | `showDefaultBottomSheet(child)` | Drag handle |
| Snackbar/toast | `MessageUtils.showSnackBar(message, baseStatus)` | Success/error/warning |
| Loading overlay | `CustomLoading.showFullScreenLoading()` | |
| Success popup | `successDialog(context, title)` | Auto-closes 2s |

### States (Figma Variants)

| Figma State/Variant | Flutter Implementation |
|---------------------|----------------------|
| Default | `AsyncBlocBuilder` -> `builder:` |
| Loading | `AsyncBlocBuilder` -> `loadingBuilder:` with `Entity.initial()` |
| Error | `AsyncBlocBuilder` -> `errorBuilder:` with `ErrorView` |
| Empty | Inside `builder:` -> `if (data.isEmpty) return EmptyWidget()` |
| Disabled | Widget with `opacity: 0.5` + `IgnorePointer` |
| Selected/Active | Conditional `decoration` or `color` based on state |

---

## RTL Conversion Rules (Figma MCP to Code)

> **Figma MCP outputs nodes in LTR order. For RTL Arabic designs, REVERSE horizontal children.**

| Figma MCP Output | Flutter Code |
|-----------------|--------------|
| Row children: `[Image, Text, Icon]` | Reverse: `[Icon, Text, Image]` — because Image is actually on the RIGHT |
| Padding: left 16, right 8 | `paddingStart(16)` + `paddingEnd(8)` — start=RIGHT in RTL |
| Alignment: left | `AlignmentDirectional.centerStart` |
| Position: left 10 | `PositionedDirectional(start: 10)` |

**What to reverse:** Row children order, padding start/end assignment
**What NOT to reverse:** Column children order, text content, sizes, colors, font sizes

---

## Figma Hidden Layers (CRITICAL)

Before coding, check for hidden/collapsed layers:

- Error banners/validation messages
- Empty states
- Loading overlays
- Tooltips/popovers
- Conditional badges (unread count, status)
- Disabled/inactive states
- Skeleton loading frames

These are often toggled off in Figma but MUST be implemented in code.

---

## Conversion Checklist

- [ ] Every Figma Frame -> correct Flutter layout widget (Row/Column/Stack)
- [ ] Auto-layout spacing -> `.szH` / `.szW` extensions
- [ ] Padding -> `.paddingAll()` / `.paddingStart()` extensions (never `Padding` widget)
- [ ] Text -> `LocaleKeys.xxx.tr()` (never hardcoded strings)
- [ ] Colors -> `AppColors.xxx` (match by purpose)
- [ ] Sizes -> `AppSize.xxx` / `AppPadding.xxx`
- [ ] Font sizes -> adjusted per design-tokens rules
- [ ] Images -> `CachedImage` (remote) or `IconWidget` (local)
- [ ] Icons -> `IconWidget` (never `Icons.*`)
- [ ] Buttons -> `LoadingButton` (async) or `DefaultButton` (sync)
- [ ] RTL -> horizontal children reversed from MCP order
- [ ] Hidden layers -> all states implemented
- [ ] `const` on every eligible widget/constructor
