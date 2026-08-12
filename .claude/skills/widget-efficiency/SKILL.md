---
name: widget-efficiency
description: The "use the widget's own attribute before wrapping" rules for Flutter. Read BEFORE building any UI to pick the most semantic, minimum-depth widget tree (padding, alignment, spacing, decoration, gestures, text, images, lists/slivers, inputs, navigation, visibility, animation, Stack, M3 widgets, const). Reduces wrapper noise, prevents wasted rebuilds, and forces Material 3 modern widgets.
---

# Skill: Widget Efficiency — Pick the Right Widget, Build the Minimum Tree

> **اقرأ ده قبل أي شاشة UI. القاعدة الأساسية:** قبل ما تـ wrap حاجة في widget جديد، اسأل نفسك 3 أسئلة:
> 1. هل الـ **child widget** عنده الـ attribute ده natively؟
> 2. هل الـ **parent widget** بيدعم الـ behavior ده من attributes بتاعته؟
> 3. هل فيه **widget أكثر دلالة (semantic, single-purpose)** متعمل بالظبط للحالة دي؟
>
> لو الـ 3 إجابات `لا` → وقتها فقط الـ wrapper مقبول.

## كيف تستخدم الـ skill ده

- **قبل الـ feature:** اقرأه كامل (الـ checklist في آخر الملف يكفي للـ refresh السريع).
- **أثناء البناء:** كل ما تكتب `Padding(...)` / `Center(...)` / `Container(...)` / `Stack(...)` → ارجع للقسم المناسب وتأكد إنه مش فيه بديل أفضل.
- **بعد الـ feature:** استخدم الـ ULTIMATE QUICK REFERENCE TABLE في الآخر كـ self-review checklist قبل ما تعمل commit.

## علاقته بـ Flutter_Base

- الـ project رولز (`AppColors`, `AppSize`, `AppPadding`, `LocaleKeys`, `IconWidget`, `CachedImage`, `CustomTextFiled`, `AppDropdown`, `LoadingButton`, `DefaultScaffold`, ...) هي الـ **first-line widgets** — لو الكود فيها → استخدمها.
- الـ rules تحت بتطبق على **أي widget مش متغطي بالـ base** (الـ raw Flutter widgets) — أو لو بتبني widget جديد في `core/widgets/`.
- **`spacing:` في Column/Row الـ default** بدل `SizedBox` بين الـ children، إلا لو الـ spacing مش متساوي.
- **`InkWell` / `Widget.onTap` بدل `GestureDetector`** — والـ extension `.onClick(onTap:)` المتاحة في الـ base هي اللي بتستعمل دايماً.
- **Material 3 widgets** (`NavigationBar`, `DropdownMenu`, `SegmentedButton`, `MenuAnchor`, `SearchBar`, `Badge`, `Card.filled/outlined`, Chip variants, ...) → دايماً preferred على M2 widgets.

---

# Flutter Widget Efficiency Rules — Complete Reference
## Core Principle: "Use the widget's own attributes before adding any wrapper"

---

## THE GOLDEN RULE
Before writing ANY wrapper widget, answer these 3 questions in order:
1. Does the **child widget** already have this attribute natively?
2. Does the **parent widget** support this behavior via its own attributes?
3. Is there a **more semantic, single-purpose widget** designed exactly for this?

Only if all three answers are NO → a wrapper widget is justified.

---
---

# PART 1 — LAYOUT & SPACING

## 1.1 Padding — Use the Widget's Own Attribute

```dart
// ❌ WRONG — Wrapping with Padding when child already has padding support
Padding(padding: EdgeInsets.all(16), child: Container(...))
Padding(padding: EdgeInsets.all(16), child: Card(...))
Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Hello'))

// ✅ RIGHT — Use the widget's own attribute
Container(padding: EdgeInsets.all(16), ...)
Card(margin: EdgeInsets.all(8), ...)        // Card uses margin for outer spacing
ListTile(contentPadding: EdgeInsets.symmetric(horizontal: 24), ...)
AlertDialog(contentPadding: EdgeInsets.all(20), ...)
```

**Widgets with built-in `padding`:**
`Container`, `AnimatedContainer`, `ListTile` (contentPadding), `Card`, `AlertDialog`, `SimpleDialog`, `Drawer`, `BottomSheet`, `DataTable`, `ExpansionTile`, `NavigationDrawerDestination`, `Tooltip`, `PopupMenuButton`, all Button widgets (via ButtonStyle), `TextField` (via InputDecoration.contentPadding).

---

## 1.2 Margin — Use the Widget's Own Attribute

```dart
// ❌ WRONG — Padding widget for outer margin
Padding(
  padding: EdgeInsets.all(16),
  child: Container(color: Colors.blue),
)

// ✅ RIGHT — Container has margin
Container(
  margin: EdgeInsets.all(16),
  color: Colors.blue,
)
Card(margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8), ...)
```

---

## 1.3 Column / Row Spacing — Use spacing Attribute (Flutter 3.7+)

```dart
// ❌ WRONG — SizedBox between every child
Column(children: [W1(), SizedBox(height: 12), W2(), SizedBox(height: 12), W3()])
Row(children: [W1(), SizedBox(width: 8), W2(), SizedBox(width: 8), W3()])

// ✅ RIGHT — spacing attribute (Flutter 3.7+)
Column(spacing: 12, children: [W1(), W2(), W3()])
Row(spacing: 8, children: [W1(), W2(), W3()])
```

**Exception:** Use `SizedBox` only when spacing differs between specific items, or Flutter < 3.7.

---

## 1.4 Wrap Spacing — Use spacing + runSpacing (NOT SizedBox between items)

```dart
// ❌ WRONG — Manual SizedBox in Wrap
Wrap(
  children: [
    Chip(label: Text('Tag 1')),
    SizedBox(width: 8),
    Chip(label: Text('Tag 2')),
  ],
)

// ✅ RIGHT — Wrap has built-in spacing
Wrap(
  spacing: 8,       // horizontal gap between items
  runSpacing: 4,    // vertical gap between lines
  children: [
    Chip(label: Text('Tag 1')),
    Chip(label: Text('Tag 2')),
    Chip(label: Text('Tag 3')),
  ],
)
```

**Use `Wrap` instead of `Row`** when items might overflow horizontally (tags, chips, filter buttons).

---

## 1.5 Flex Space — Spacer vs Expanded(SizedBox)

```dart
// ❌ WRONG
Row(children: [Text('Left'), Expanded(child: SizedBox()), Text('Right')])
Row(children: [Text('Left'), Expanded(child: Container()), Text('Right')])

// ✅ RIGHT — Spacer is semantic and purpose-built
Row(children: [Text('Left'), Spacer(), Text('Right')])

// ✅ OR — use mainAxisAlignment
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [Text('Left'), Text('Right')],
)
```

---

## 1.6 Alignment — Use Widget's Own alignment Attribute

```dart
// ❌ WRONG
Align(alignment: Alignment.centerRight, child: Container(width: 100))
Center(child: Container(width: 200, height: 200))

// ✅ RIGHT — Container has alignment
Container(width: double.infinity, alignment: Alignment.centerRight, child: SomeWidget())

// ✅ RIGHT — Column/Row control alignment with their own attributes
Column(
  crossAxisAlignment: CrossAxisAlignment.center,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [...],
)
```

**Use `Align` / `Center` only** when: the widget has no alignment support AND is a non-positioned child of Stack, or a child whose parent provides no alignment control.

---

## 1.7 Sizing — SizedBox vs Container

```dart
// ❌ WRONG — Container used only for size (no decoration, no color, no padding)
Container(width: 48, height: 48, child: Icon(Icons.star))
Container(height: 16)  // spacer

// ✅ RIGHT — SizedBox for pure sizing
SizedBox(width: 48, height: 48, child: Icon(Icons.star))
SizedBox(height: 16)          // spacer
SizedBox.expand(child: W())   // fill all available space
SizedBox.shrink()             // zero-size placeholder instead of Container()
```

**Decision rule:** Use `Container` only when you need ≥2 of: color, padding, margin, decoration, constraints, transform. For everything else → `SizedBox`.

---

## 1.8 Aspect Ratio

```dart
// ❌ WRONG — Manual MediaQuery math
SizedBox(
  width: MediaQuery.of(context).size.width,
  height: MediaQuery.of(context).size.width * 0.5625,
  child: VideoPlayer(),
)

// ✅ RIGHT
AspectRatio(aspectRatio: 16 / 9, child: VideoPlayer())
AspectRatio(aspectRatio: 1, child: GridItem())  // perfect square
```

---

## 1.9 Flexible Proportional Sizing

```dart
// ❌ WRONG — Percentage width via MediaQuery
SizedBox(width: MediaQuery.of(context).size.width * 0.5, child: W())

// ✅ RIGHT — Flexible / Expanded for proportional sizing
Row(children: [
  Flexible(flex: 1, child: Container(color: Colors.red)),
  Flexible(flex: 2, child: Container(color: Colors.blue)),  // 2× wider
])

// ✅ FractionallySizedBox for percentage-based sizing
FractionallySizedBox(widthFactor: 0.5, child: W())  // 50% of parent width
```

---

## 1.10 Intrinsic Sizing — Use Sparingly (Expensive)

```dart
// ✅ Only when children MUST match each other's intrinsic size
IntrinsicHeight(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [LeftPanel(), VerticalDivider(), RightPanel()],
  ),
)
```
⚠️ `IntrinsicHeight` / `IntrinsicWidth` do a double layout pass — use only when there's no alternative.

---
---

# PART 2 — DECORATION & VISUAL EFFECTS

## 2.1 Border Radius + Clipping

```dart
// ❌ WRONG — ClipRRect wrapping a Container with borderRadius (double clipping)
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Container(
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
    child: Image.network(url),
  ),
)

// ✅ RIGHT — Container's clipBehavior handles it
Container(
  clipBehavior: Clip.antiAlias,
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
  child: Image.network(url),
)

// ✅ EVEN BETTER — use DecorationImage (no clip needed at all)
Container(
  width: 120,
  height: 120,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
  ),
)
```

**Use `ClipRRect`** only when clipping a widget that doesn't support `clipBehavior` (e.g. third-party widgets, video players, map widgets).

---

## 2.2 Shadows + Borders — Container decoration, Not Stack

```dart
// ❌ WRONG — Stack to simulate shadow
Stack(children: [
  Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(boxShadow: [...]))),
  YourWidget(),
])

// ✅ RIGHT — BoxDecoration handles everything
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 4))],
    border: Border.all(color: Colors.grey.shade200),
  ),
  child: YourWidget(),
)
```

---

## 2.3 Opacity — Avoid Opacity Widget for Single-Color Widgets

```dart
// ❌ WRONG — Opacity triggers expensive saveLayer() call
Opacity(opacity: 0.5, child: Container(color: Colors.blue))
Opacity(opacity: 0.5, child: Icon(Icons.star, color: Colors.yellow))

// ✅ RIGHT — Use color with opacity directly
Container(color: Colors.blue.withValues(alpha: 0.5))
Icon(Icons.star, color: Colors.yellow.withValues(alpha: 0.5))

// ❌ WRONG — Opacity on Image
Opacity(opacity: 0.8, child: Image.network(url))

// ✅ RIGHT — FadeInImage or ColorFiltered
ColorFiltered(
  colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.2), BlendMode.srcOver),
  child: Image.network(url),
)
```

**Use `Opacity`** only when applying transparency to a group of overlapping widgets that can't share a single color.
**Use `AnimatedOpacity`** for smooth opacity transitions.

---

## 2.4 Background Color

```dart
// ❌ WRONG — Container around entire Scaffold body just for bg color
Scaffold(body: Container(color: Colors.grey[100], child: YourContent()))

// ✅ RIGHT — Scaffold has backgroundColor
Scaffold(backgroundColor: Colors.grey[100], body: YourContent())
```

---

## 2.5 Gradient

```dart
// ❌ WRONG — Wrapping Scaffold with a Container
Container(
  decoration: BoxDecoration(gradient: LinearGradient(...)),
  child: Scaffold(...),
)

// ✅ RIGHT — Gradient in body's Container
Scaffold(
  body: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: SafeArea(child: YourContent()),
  ),
)
```

---

## 2.6 Blur / Frosted Glass

```dart
// ✅ RIGHT — BackdropFilter for blur behind widget
Stack(children: [
  BackgroundImage(),
  Positioned.fill(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(color: Colors.white.withValues(alpha: 0.1)),
    ),
  ),
  ForegroundContent(),
])
```
⚠️ `BackdropFilter` is expensive — use `RepaintBoundary` around the blurred region if it's inside an animated tree.

---
---

# PART 3 — INTERACTION & GESTURES

## 3.1 Built-in Tap — Always Use onTap/onPressed First

```dart
// ❌ WRONG — GestureDetector on widgets with native tap support
GestureDetector(onTap: nav, child: ListTile(title: Text('Item')))
GestureDetector(onTap: doIt, child: ElevatedButton(onPressed: null, child: Text('Go')))
GestureDetector(onTap: toggle, child: CheckboxListTile(...))
GestureDetector(onTap: open, child: ExpansionTile(...))

// ✅ RIGHT — Use native callback
ListTile(onTap: nav, title: Text('Item'))
ElevatedButton(onPressed: doIt, child: Text('Go'))
CheckboxListTile(onChanged: (v) => toggle(v), ...)
```

**Widgets with native tap:** `ListTile`, `CheckboxListTile`, `RadioListTile`, `SwitchListTile`, `ExpansionTile`, `ElevatedButton`, `TextButton`, `OutlinedButton`, `FilledButton`, `FilledButton.tonal`, `IconButton`, `FloatingActionButton`, `Chip` variants, `DropdownButton`, `PopupMenuButton`, `MenuAnchor`, `NavigationBar`, `NavigationRail`, `NavigationDrawer`, `SegmentedButton`, `DatePickerDialog`, `TimePickerDialog`.

---

## 3.2 InkWell vs GestureDetector

```dart
// ❌ WRONG — GestureDetector loses Material ripple
GestureDetector(onTap: () {}, child: Container(color: Colors.blue, child: Text('Tap')))

// ✅ RIGHT — InkWell for ripple effect
Material(
  color: Colors.blue,
  borderRadius: BorderRadius.circular(8),
  child: InkWell(
    onTap: () {},
    borderRadius: BorderRadius.circular(8),
    child: Padding(padding: EdgeInsets.all(12), child: Text('Tap')),
  ),
)
```

**Rule:** `GestureDetector` → no ripple, custom/canvas/third-party widgets. `InkWell` → Material ripple. `Widget.onTap` → always preferred when available.

---

## 3.3 Swipe Actions — Dismissible

```dart
// ❌ WRONG — Custom drag detector
GestureDetector(
  onHorizontalDragEnd: (d) { if (d.velocity.pixelsPerSecond.dx > 300) remove(); },
  child: ListTile(...),
)

// ✅ RIGHT
Dismissible(
  key: Key(item.id),
  onDismissed: (direction) => remove(item),
  confirmDismiss: (direction) async => await showConfirmDialog(),
  background: Container(color: Colors.red, alignment: Alignment.centerLeft,
    child: Padding(padding: EdgeInsets.all(16), child: Icon(Icons.delete, color: Colors.white))),
  secondaryBackground: Container(color: Colors.blue, alignment: Alignment.centerRight,
    child: Icon(Icons.archive, color: Colors.white)),
  child: ListTile(...),
)
```

---

## 3.4 Long Press Menu — Use ContextMenuController or PopupMenuButton

```dart
// ❌ WRONG — GestureDetector + custom overlay for context menu
GestureDetector(onLongPress: () => showCustomOverlay(), child: MyWidget())

// ✅ RIGHT — AdaptiveTextSelectionToolbar or MenuAnchor
MenuAnchor(
  controller: _menuController,
  menuChildren: [
    MenuItemButton(onPressed: copy, child: Text('Copy')),
    MenuItemButton(onPressed: delete, child: Text('Delete')),
  ],
  child: GestureDetector(
    onLongPress: () => _menuController.open(),
    child: MyWidget(),
  ),
)
```

---
---

# PART 4 — TEXT & TYPOGRAPHY

## 4.1 Text Attributes — Don't Wrap for Basic Styling

```dart
// ❌ WRONG
Center(child: Text('Title'))
Padding(padding: EdgeInsets.only(top: 4), child: Text('Subtitle'))

// ✅ RIGHT — Text has rich native attributes
Text(
  'Hello World',
  textAlign: TextAlign.center,
  style: TextStyle(
    fontSize: 18, fontWeight: FontWeight.bold,
    color: Colors.black87, letterSpacing: 0.5, height: 1.4,
  ),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
  softWrap: true,
)
```

---

## 4.2 Mixed Inline Styles — Text.rich, Not Row of Texts

```dart
// ❌ WRONG — Row of separate Text widgets for inline mixed styling
Row(children: [
  Text('Hello ', style: TextStyle(fontWeight: FontWeight.normal)),
  Text('World', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
])

// ✅ RIGHT — Text.rich / RichText for inline spans
Text.rich(TextSpan(
  text: 'Hello ',
  style: TextStyle(fontSize: 16),
  children: [
    TextSpan(text: 'World', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
    WidgetSpan(child: Icon(Icons.star, size: 16)),  // even inline widgets!
  ],
))
```

---

## 4.3 Selectable Text

```dart
// ❌ WRONG — Complex gesture for text copying
GestureDetector(onLongPress: () => Clipboard.setData(ClipboardData(text: 'text')), child: Text('text'))

// ✅ RIGHT
SelectableText('Tap and hold to select and copy')

// For selecting a region of mixed content
SelectionArea(child: Column(children: [Text('...'), Text('...')]))
```

---

## 4.4 Multiline / Overflow

```dart
// ❌ WRONG — SizedBox + SingleChildScrollView for a text that might be long
SizedBox(height: 100, child: SingleChildScrollView(child: Text(longText)))

// ✅ RIGHT — Use maxLines + overflow, or Expanded in a Column
Text(longText, maxLines: 3, overflow: TextOverflow.ellipsis)

// For truly unlimited scrollable text:
Expanded(child: SingleChildScrollView(child: Text(longText)))
```

---
---

# PART 5 — IMAGES & MEDIA

## 5.1 Image Sizing — Use Built-in Attributes

```dart
// ❌ WRONG — Wrapping Image with SizedBox or Container just for sizing
SizedBox(width: 100, height: 100, child: Image.network(url))
Container(width: 100, height: 100, child: Image.network(url))

// ✅ RIGHT — Image has width, height, fit
Image.network(url, width: 100, height: 100, fit: BoxFit.cover)
Image.asset('assets/img.png', width: double.infinity, fit: BoxFit.fitWidth)
```

---

## 5.2 Circle Avatar — Not ClipOval + Container

```dart
// ❌ WRONG
ClipOval(child: Container(width: 48, height: 48, child: Image.network(url)))
ClipOval(child: Image.network(url, width: 48, height: 48))

// ✅ RIGHT
CircleAvatar(radius: 24, backgroundImage: NetworkImage(url))
CircleAvatar(radius: 24, backgroundColor: Colors.blue, child: Text('AB'))
CircleAvatar(radius: 24, backgroundImage: NetworkImage(url),
  onBackgroundImageError: (e, s) => /* fallback */)
```

---

## 5.3 Network Image Placeholder — FadeInImage

```dart
// ❌ WRONG — Stack + AnimatedOpacity for placeholder
Stack(children: [
  Image.asset('placeholder.png'),
  AnimatedOpacity(opacity: _loaded ? 1.0 : 0.0, duration: Duration(milliseconds: 300),
    child: Image.network(url)),
])

// ✅ RIGHT
FadeInImage.assetNetwork(
  placeholder: 'assets/placeholder.png',
  image: url,
  fit: BoxFit.cover,
  width: double.infinity,
)

// ✅ Or FadeInImage.memoryNetwork for a tiny placeholder
FadeInImage(
  placeholder: MemoryImage(kTransparentImage),  // from transparent_image package
  image: NetworkImage(url),
)
```

---

## 5.4 Image with Color Overlay — Use colorBlendMode

```dart
// ❌ WRONG — Stack + Container for color overlay
Stack(children: [
  Image.network(url),
  Positioned.fill(child: Container(color: Colors.black.withValues(alpha: 0.4))),
])

// ✅ RIGHT — Image has color + colorBlendMode
Image.network(
  url,
  color: Colors.black.withValues(alpha: 0.4),
  colorBlendMode: BlendMode.darken,
)
```

---

## 5.5 Icon Sizing + Color — Use Icon Attributes

```dart
// ❌ WRONG — Container wrapping Icon for color/size
Container(child: Icon(Icons.star, size: 24), color: Colors.amber)

// ✅ RIGHT
Icon(Icons.star, size: 24, color: Colors.amber)
Icon(Icons.star, size: 24, color: Theme.of(context).colorScheme.primary)
```

---
---

# PART 6 — LISTS & SCROLLING

## 6.1 ListView Variants

```dart
// ❌ WRONG — ListView with all items (no lazy loading)
ListView(children: items.map((e) => ItemWidget(e)).toList())

// ✅ RIGHT — ListView.builder (lazy, visible items only)
ListView.builder(
  itemCount: items.length,
  itemBuilder: (ctx, i) => ItemWidget(items[i]),
)

// ✅ RIGHT — ListView.separated (built-in dividers, no manual SizedBox)
ListView.separated(
  itemCount: items.length,
  itemBuilder: (ctx, i) => ItemWidget(items[i]),
  separatorBuilder: (ctx, i) => const Divider(height: 1),
)

// ✅ RIGHT — ReorderableListView for drag-to-reorder
ReorderableListView.builder(
  itemCount: items.length,
  itemBuilder: (ctx, i) => ListTile(key: Key('$i'), title: Text(items[i])),
  onReorder: (oldIndex, newIndex) => reorder(oldIndex, newIndex),
)
```

---

## 6.2 GridView Variants

```dart
// ❌ WRONG — Wrap + SizedBox for manual grid
Wrap(children: items.map((e) => SizedBox(width: 160, child: Card(child: ...))).toList())

// ✅ RIGHT — GridView.builder
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.8,
  ),
  itemCount: items.length,
  itemBuilder: (ctx, i) => ItemCard(items[i]),
)

// ✅ RIGHT — GridView.extent for size-based grid
GridView.extent(
  maxCrossAxisExtent: 200,  // items are at most 200px wide
  children: [...],
)

// ✅ Flutter 3.38+ — SliverGrid.list convenience constructor
CustomScrollView(slivers: [
  SliverGrid.list(
    children: items.map((e) => ItemCard(e)).toList(),
  ),
])
```

---

## 6.3 Avoid Nested Scrollables — Use Slivers

```dart
// ❌ WRONG — nested scroll views (causes layout errors + jank)
SingleChildScrollView(child: Column(children: [
  HeaderWidget(),
  ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), ...)
]))

// ✅ RIGHT — CustomScrollView + Slivers
CustomScrollView(slivers: [
  SliverAppBar(expandedHeight: 200, flexibleSpace: FlexibleSpaceBar(...), pinned: true),
  SliverToBoxAdapter(child: HeaderWidget()),
  SliverList(delegate: SliverChildBuilderDelegate(
    (ctx, i) => ItemWidget(items[i]), childCount: items.length,
  )),
  SliverGrid(
    delegate: SliverChildBuilderDelegate((ctx, i) => GridItem(i), childCount: n),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
  ),
  SliverPadding(padding: EdgeInsets.all(16), sliver: SliverList(...)),
  SliverFillRemaining(child: EmptyState()),  // fills remaining viewport
])
```

---

## 6.4 Avoid shrinkWrap: true for Long Lists

```dart
// ❌ WRONG — shrinkWrap calculates ALL item extents → very expensive
ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics(), itemBuilder: ...)

// ✅ RIGHT — SliverList inside CustomScrollView
CustomScrollView(slivers: [
  SliverList(delegate: SliverChildBuilderDelegate(
    (ctx, i) => ItemWidget(i), childCount: items.length,
  )),
])
```

---

## 6.5 Pull-to-Refresh

```dart
// ❌ WRONG — Manual gesture detector + animation for pull-to-refresh
// ✅ RIGHT
RefreshIndicator(
  onRefresh: () async => await loadData(),
  child: ListView.builder(...),
)
```

---

## 6.6 Carousel / Page View

```dart
// ❌ WRONG — Manual Stack + GestureDetector + PageController for carousel
// ✅ RIGHT — PageView
PageView.builder(
  itemCount: slides.length,
  itemBuilder: (ctx, i) => SlideWidget(slides[i]),
)

// ✅ RIGHT — CarouselView (Flutter 3.24+, Material 3)
CarouselView(
  itemExtent: 300,
  children: items.map((e) => CarouselItem(e)).toList(),
)

// ✅ CarouselView.weighted for hero-style layout (Flutter 3.27+)
CarouselView.weighted(
  flexWeights: const [1, 7, 1],  // small - large - small
  children: items.map((e) => CarouselItem(e)).toList(),
)
```

---
---

# PART 7 — INPUT & FORMS

## 7.1 InputDecoration — Use ALL Its Attributes

```dart
// ❌ WRONG — Manually wrapping TextField for icons and labels
Row(children: [Icon(Icons.search), SizedBox(width: 8), Expanded(child: TextField())])
Stack(children: [TextField(), Positioned(right: 0, child: IconButton(...))])

// ✅ RIGHT — InputDecoration has everything
TextField(
  decoration: InputDecoration(
    // Icons
    icon: Icon(Icons.person),           // outside the field, before it
    prefixIcon: Icon(Icons.search),     // inside the field, leading
    suffixIcon: IconButton(icon: Icon(Icons.clear), onPressed: clear),
    prefix: Text('+20 '),               // inline prefix widget
    suffix: Text('EGP'),                // inline suffix widget
    prefixText: '\$',                   // prefix text
    suffixText: '.00',                  // suffix text

    // Labels
    labelText: 'Email',
    hintText: 'example@mail.com',
    helperText: 'We\'ll never share your email',
    errorText: hasError ? 'Invalid email' : null,
    counterText: '${value.length}/100',

    // Borders
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue, width: 2)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),

    // Fill
    filled: true,
    fillColor: Colors.grey[100],
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    isDense: true,  // reduces height

    // Behavior
    floatingLabelBehavior: FloatingLabelBehavior.always,
    alignLabelWithHint: true,
  ),
)
```

---

## 7.2 Form Validation — TextFormField + Form

```dart
// ❌ WRONG — Manual error state with plain TextField
bool _error = false;
TextField(
  onChanged: (v) => setState(() => _error = v.isEmpty),
  decoration: InputDecoration(errorText: _error ? 'Required' : null),
)

// ✅ RIGHT — TextFormField + Form handles all validation state
final _formKey = GlobalKey<FormState>();
Form(
  key: _formKey,
  child: Column(spacing: 16, children: [
    TextFormField(
      validator: (v) => v!.isEmpty ? 'Required' : null,
      decoration: InputDecoration(labelText: 'Name'),
    ),
    TextFormField(
      validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
      decoration: InputDecoration(labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
    ),
    ElevatedButton(
      onPressed: () { if (_formKey.currentState!.validate()) submit(); },
      child: Text('Submit'),
    ),
  ]),
)
```

---

## 7.3 Toggle Widgets — Use Semantic Variants

```dart
// ❌ WRONG — Manual Row for checkbox + label
GestureDetector(
  onTap: () => setState(() => _checked = !_checked),
  child: Row(children: [
    Checkbox(value: _checked, onChanged: null),
    SizedBox(width: 8), Text('Enable notifications'),
  ]),
)

// ✅ RIGHT
CheckboxListTile(
  value: _checked,
  onChanged: (v) => setState(() => _checked = v!),
  title: Text('Enable notifications'),
  subtitle: Text('Receive push alerts'),
  secondary: Icon(Icons.notifications),
  controlAffinity: ListTileControlAffinity.leading,
)

SwitchListTile(
  value: _enabled,
  onChanged: (v) => setState(() => _enabled = v),
  title: Text('Dark mode'),
)

RadioListTile<String>(
  value: 'option1',
  groupValue: _selected,
  onChanged: (v) => setState(() => _selected = v!),
  title: Text('Option 1'),
)
```

---

## 7.4 Segmented Toggle — SegmentedButton (M3)

```dart
// ❌ WRONG — Manual Row of toggle buttons with Container styling
Row(children: [
  GestureDetector(onTap: () => select(0), child: Container(
    decoration: BoxDecoration(color: _sel == 0 ? Colors.blue : Colors.grey[200]),
    child: Padding(padding: EdgeInsets.all(8), child: Text('Day')),
  )),
  // ...repeat...
])

// ✅ RIGHT — SegmentedButton (Material 3)
SegmentedButton<String>(
  segments: const [
    ButtonSegment(value: 'day', label: Text('Day'), icon: Icon(Icons.today)),
    ButtonSegment(value: 'week', label: Text('Week'), icon: Icon(Icons.view_week)),
    ButtonSegment(value: 'month', label: Text('Month'), icon: Icon(Icons.calendar_month)),
  ],
  selected: {_selected},
  onSelectionChanged: (s) => setState(() => _selected = s.first),
  multiSelectionEnabled: false,
)

// ✅ Vertical direction (Flutter 3.27+)
SegmentedButton<String>(
  direction: Axis.vertical,
  segments: [...],
  selected: {_selected},
  onSelectionChanged: (s) => setState(() => _selected = s.first),
)
```

---

## 7.5 Dropdown — DropdownMenu vs DropdownButton

```dart
// ❌ OLD — DropdownButton (Material 2, avoid for new code)
DropdownButton<String>(
  value: _selected,
  items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
  onChanged: (v) => setState(() => _selected = v),
)

// ✅ RIGHT — DropdownMenu (Material 3, supports search + filter)
DropdownMenu<String>(
  initialSelection: _selected,
  onSelected: (v) => setState(() => _selected = v),
  label: Text('Sort by'),
  leadingIcon: Icon(Icons.sort),
  enableSearch: true,        // type to filter
  enableFilter: true,
  dropdownMenuEntries: items.map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
)
```

---

## 7.6 Context Menu / Overflow Menu — MenuAnchor

```dart
// ❌ OLD — PopupMenuButton (Material 2)
PopupMenuButton<String>(
  itemBuilder: (ctx) => [
    PopupMenuItem(value: 'edit', child: Text('Edit')),
    PopupMenuItem(value: 'delete', child: Text('Delete')),
  ],
  onSelected: (v) => handle(v),
)

// ✅ RIGHT — MenuAnchor (Material 3)
MenuAnchor(
  builder: (context, controller, child) => IconButton(
    icon: Icon(Icons.more_vert),
    onPressed: () => controller.isOpen ? controller.close() : controller.open(),
  ),
  menuChildren: [
    MenuItemButton(
      leadingIcon: Icon(Icons.edit),
      onPressed: () => edit(),
      child: Text('Edit'),
    ),
    MenuItemButton(
      leadingIcon: Icon(Icons.delete),
      onPressed: () => delete(),
      child: Text('Delete'),
    ),
    const Divider(),
    SubmenuButton(
      menuChildren: [
        MenuItemButton(onPressed: () {}, child: Text('Option A')),
        MenuItemButton(onPressed: () {}, child: Text('Option B')),
      ],
      child: Text('More'),
    ),
  ],
)
```

---

## 7.7 Search — SearchBar + SearchAnchor (M3)

```dart
// ❌ WRONG — Manual Row with TextField styled to look like search
Row(children: [
  Icon(Icons.search),
  SizedBox(width: 8),
  Expanded(child: TextField(decoration: InputDecoration(hintText: 'Search...'))),
])

// ✅ RIGHT — SearchBar (Material 3)
SearchBar(
  controller: _controller,
  hintText: 'Search...',
  leading: Icon(Icons.search),
  trailing: [
    IconButton(icon: Icon(Icons.mic), onPressed: voiceSearch),
    IconButton(icon: Icon(Icons.tune), onPressed: openFilters),
  ],
  onChanged: (q) => runSearch(q),
)

// ✅ SearchAnchor for full search view with suggestions
SearchAnchor(
  builder: (context, controller) => SearchBar(
    controller: controller,
    onTap: () => controller.openView(),
    hintText: 'Search products',
    leading: Icon(Icons.search),
  ),
  suggestionsBuilder: (context, controller) async {
    final results = await search(controller.text);
    return results.map((r) => ListTile(
      title: Text(r.name),
      onTap: () { controller.closeView(r.name); selectResult(r); },
    )).toList();
  },
)
```

---

## 7.8 Date & Time Pickers — Use showDatePicker / showTimePicker

```dart
// ❌ WRONG — Custom calendar built with GridView + GestureDetector
// ✅ RIGHT — Material-provided pickers
final date = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  helpText: 'Select appointment date',
  initialEntryMode: DatePickerEntryMode.calendarOnly,
)

final time = await showTimePicker(
  context: context,
  initialTime: TimeOfDay.now(),
  helpText: 'Select time',
)

// For date range
final range = await showDateRangePicker(
  context: context,
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
)
```

---
---

# PART 8 — NAVIGATION & STRUCTURE

## 8.1 AppBar — Use All Dedicated Slots

```dart
// ❌ WRONG — Putting navigation UI inside title manually
AppBar(title: Row(children: [Icon(Icons.arrow_back), SizedBox(width: 8), Text('Page')]))
AppBar(title: Row(children: [Text('Title'), Spacer(), Icon(Icons.more_vert)]))

// ✅ RIGHT — AppBar has dedicated slots for everything
AppBar(
  // Navigation
  leading: BackButton(),             // or custom IconButton
  automaticallyImplyLeading: true,   // auto back button

  // Title
  title: Text('Page Title'),
  centerTitle: true,                 // platform-aware centering

  // Actions
  actions: [
    IconButton(icon: Icon(Icons.search), onPressed: search),
    IconButton(icon: Icon(Icons.share), onPressed: share),
    PopupMenuButton(itemBuilder: (ctx) => [...]),  // or MenuAnchor (M3)
  ],

  // Tabs below toolbar
  bottom: TabBar(tabs: [Tab(text: 'Tab 1'), Tab(text: 'Tab 2')]),

  // Collapsible hero image (for SliverAppBar)
  flexibleSpace: FlexibleSpaceBar(
    title: Text('Hero Title'),
    background: Image.network(url, fit: BoxFit.cover),
    collapseMode: CollapseMode.parallax,
  ),

  // Styling
  backgroundColor: Colors.transparent,
  foregroundColor: Colors.white,
  elevation: 0,
  toolbarHeight: 70,
  leadingWidth: 80,
  shadowColor: Colors.black26,
  surfaceTintColor: Colors.transparent,
  systemOverlayStyle: SystemUiOverlayStyle.light,
)
```

---

## 8.2 SliverAppBar — For Collapsible App Bar

```dart
// ❌ WRONG — Manually animating app bar height with scroll listener
// ✅ RIGHT
CustomScrollView(slivers: [
  SliverAppBar(
    expandedHeight: 250,
    pinned: true,      // stays visible when collapsed
    floating: false,   // doesn't reappear when scrolling up
    snap: false,
    stretch: true,     // stretches on overscroll
    flexibleSpace: FlexibleSpaceBar(
      title: Text('Page'),
      background: Image.network(url, fit: BoxFit.cover),
    ),
    actions: [IconButton(icon: Icon(Icons.share), onPressed: share)],
  ),
  SliverList(...),
])
```

---

## 8.3 Scaffold Slots — Use All Available Slots

```dart
// ❌ WRONG — Stack + Positioned for FAB
Scaffold(body: Stack(children: [
  Content(),
  Positioned(right: 16, bottom: 16, child: FloatingActionButton(...)),
]))

// ✅ RIGHT — Scaffold has dedicated slots
Scaffold(
  // App bar
  appBar: AppBar(title: Text('Home')),

  // Main content
  body: Content(),

  // FAB
  floatingActionButton: FloatingActionButton.extended(
    onPressed: add,
    icon: Icon(Icons.add),
    label: Text('New Item'),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

  // Bottom
  bottomNavigationBar: NavigationBar(...),  // or BottomAppBar
  bottomSheet: PersistentBottomSheet(),     // persistent sheet

  // Drawers
  drawer: NavigationDrawer(...),
  endDrawer: Drawer(...),

  // Colors
  backgroundColor: Theme.of(context).colorScheme.surface,
  extendBody: true,         // body goes behind bottom bar
  extendBodyBehindAppBar: true,  // body goes behind app bar (for transparent bars)
)
```

---

## 8.4 Bottom Navigation — NavigationBar (M3)

```dart
// ❌ OLD — BottomNavigationBar (Material 2)
BottomNavigationBar(
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ],
)

// ✅ RIGHT — NavigationBar (Material 3)
NavigationBar(
  selectedIndex: _index,
  onDestinationSelected: (i) => setState(() => _index = i),
  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
  destinations: const [
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
    NavigationDestination(
      icon: Badge(child: Icon(Icons.notifications_outlined)),  // with badge!
      selectedIcon: Badge(label: Text('3'), child: Icon(Icons.notifications)),
      label: 'Alerts',
    ),
    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
  ],
)
```

---

## 8.5 Side Navigation — NavigationDrawer (M3) + NavigationRail

```dart
// ❌ OLD — Drawer with manual ListView of ListTiles
Drawer(child: ListView(children: [
  DrawerHeader(...),
  ListTile(leading: Icon(Icons.home), title: Text('Home'), onTap: goHome),
  ListTile(leading: Icon(Icons.settings), title: Text('Settings'), onTap: goSettings),
]))

// ✅ RIGHT — NavigationDrawer (Material 3)
NavigationDrawer(
  selectedIndex: _index,
  onDestinationSelected: (i) { setState(() => _index = i); Navigator.pop(context); },
  children: [
    Padding(padding: EdgeInsets.fromLTRB(28, 16, 16, 10), child: Text('Mail')),
    NavigationDrawerDestination(
      icon: Icon(Icons.inbox_outlined),
      selectedIcon: Icon(Icons.inbox),
      label: Text('Inbox'),
      badge: Badge(label: Text('24')),
    ),
    NavigationDrawerDestination(icon: Icon(Icons.send_outlined), label: Text('Sent')),
    Divider(indent: 28, endIndent: 28),
    NavigationDrawerDestination(icon: Icon(Icons.settings_outlined), label: Text('Settings')),
  ],
)

// ✅ RIGHT — NavigationRail for tablet/desktop side rail
NavigationRail(
  selectedIndex: _index,
  onDestinationSelected: (i) => setState(() => _index = i),
  labelType: NavigationRailLabelType.selected,
  leading: FloatingActionButton(onPressed: compose, child: Icon(Icons.add)),
  destinations: [
    NavigationRailDestination(icon: Icon(Icons.inbox), label: Text('Inbox')),
    NavigationRailDestination(icon: Icon(Icons.send), label: Text('Sent')),
    NavigationRailDestination(icon: Icon(Icons.settings), label: Text('Settings')),
  ],
)
```

---

## 8.6 Tab Navigation — TabBar + TabBarView

```dart
// ❌ WRONG — Manual index-based page switching with IndexedStack + Row of buttons
// ✅ RIGHT
DefaultTabController(
  length: 3,
  child: Scaffold(
    appBar: AppBar(
      title: Text('App'),
      bottom: TabBar(
        tabs: [
          Tab(icon: Icon(Icons.home), text: 'Home'),
          Tab(icon: Icon(Icons.search), text: 'Search'),
          Tab(icon: Icon(Icons.person), text: 'Profile'),
        ],
      ),
    ),
    body: TabBarView(children: [HomeScreen(), SearchScreen(), ProfileScreen()]),
  ),
)
```

---
---

# PART 9 — VISIBILITY & STATE

## 9.1 Visibility — Preserve Widget State

```dart
// ❌ WRONG — Ternary destroys & recreates widget, loses state
isVisible ? MyWidget() : SizedBox.shrink()
isVisible ? MyWidget() : const SizedBox()

// ✅ RIGHT — Visibility preserves widget state
Visibility(visible: isVisible, child: MyWidget())

// ✅ With state preservation
Visibility(
  visible: isVisible,
  maintainState: true,        // keeps state even when invisible
  maintainAnimation: true,    // keeps animations running
  maintainSize: true,         // keeps layout space (like opacity 0)
  child: MyWidget(),
)

// ✅ AnimatedSwitcher for smooth transition
AnimatedSwitcher(
  duration: Duration(milliseconds: 250),
  child: isVisible
    ? MyWidget(key: ValueKey('visible'))
    : SizedBox.shrink(key: ValueKey('hidden')),
)
```

---

## 9.2 Offstage — Preload Without Displaying

```dart
// ✅ Offstage renders but doesn't display — useful for preloading heavy widgets
Offstage(offstage: !isPreloaded, child: HeavyWidget())
```

---

## 9.3 IndexedStack — Multi-Tab State Preservation

```dart
// ❌ WRONG — Conditional rendering loses state on tab switch
body: _index == 0 ? HomeScreen() : ProfileScreen()

// ✅ RIGHT — IndexedStack keeps all children alive
body: IndexedStack(
  index: _index,
  children: const [HomeScreen(), SearchScreen(), ProfileScreen(), SettingsScreen()],
)
```

---

## 9.4 Badge — Notification Count (M3)

```dart
// ❌ WRONG — Stack + Positioned for a notification badge
Stack(children: [
  Icon(Icons.notifications, size: 24),
  Positioned(top: 0, right: 0, child: Container(
    width: 8, height: 8,
    decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
  )),
])

// ✅ RIGHT — Badge widget (Material 3)
Badge(child: Icon(Icons.notifications))                    // small dot
Badge(label: Text('3'), child: Icon(Icons.notifications)) // with count
Badge(label: Text('99+'), isLabelVisible: hasAlerts, child: Icon(Icons.notifications))
```

---
---

# PART 10 — ANIMATION

## 10.1 Implicit Animations — No AnimationController Needed

```dart
// ❌ WRONG — AnimationController boilerplate for simple transitions (40+ lines)

// ✅ RIGHT — Implicit widgets auto-animate when their value changes
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  width: isExpanded ? 200 : 100,
  height: isExpanded ? 200 : 100,
  color: isActive ? Colors.blue : Colors.grey,
  padding: isExpanded ? EdgeInsets.all(16) : EdgeInsets.all(8),
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(isExpanded ? 16 : 8)),
)

AnimatedOpacity(duration: Duration(milliseconds: 200), opacity: isVisible ? 1.0 : 0.0, child: W())
AnimatedAlign(duration: Duration(milliseconds: 300), alignment: isBottom ? Alignment.bottomCenter : Alignment.topCenter, child: W())
AnimatedPadding(duration: Duration(milliseconds: 200), padding: isOpen ? EdgeInsets.all(16) : EdgeInsets.zero, child: W())
AnimatedDefaultTextStyle(duration: Duration(milliseconds: 200), style: isSelected ? boldStyle : normalStyle, child: Text('Label'))
AnimatedPositioned(duration: Duration(milliseconds: 300), top: isOpen ? 0.0 : -100.0, left: 0, right: 0, child: W())  // inside Stack
AnimatedRotation(duration: Duration(milliseconds: 300), turns: isOpen ? 0.5 : 0.0, child: Icon(Icons.expand_more))
AnimatedScale(duration: Duration(milliseconds: 200), scale: isPressed ? 0.95 : 1.0, child: Button())
AnimatedSlide(duration: Duration(milliseconds: 300), offset: isHidden ? Offset(1, 0) : Offset.zero, child: Panel())

AnimatedSwitcher(
  duration: Duration(milliseconds: 200),
  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
  child: Text('$_count', key: ValueKey(_count)),
)

AnimatedCrossFade(
  duration: Duration(milliseconds: 300),
  crossFadeState: showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
  firstChild: FirstWidget(),
  secondChild: SecondWidget(),
)
```

---

## 10.2 AnimatedList / AnimatedGrid — Animated Item Insertion/Removal

```dart
// ❌ WRONG — Manually tracking animation state for list item add/remove
// ✅ RIGHT
final _listKey = GlobalKey<AnimatedListState>();
AnimatedList(
  key: _listKey,
  initialItemCount: items.length,
  itemBuilder: (ctx, i, animation) => SlideTransition(
    position: animation.drive(Tween(begin: Offset(1, 0), end: Offset.zero)),
    child: ItemWidget(items[i]),
  ),
)
// Insert: _listKey.currentState!.insertItem(index)
// Remove: _listKey.currentState!.removeItem(index, (ctx, animation) => ItemWidget(...))
```

---

## 10.3 Hero — Shared Element Transitions

```dart
// ✅ RIGHT — Hero for shared element between routes
// In source screen:
Hero(tag: 'product-${product.id}', child: Image.network(product.imageUrl))

// In destination screen:
Hero(tag: 'product-${product.id}', child: Image.network(product.imageUrl, width: double.infinity))
```

---

## 10.4 AnimationStyle — Customize System Animations (Flutter 3.19+)

```dart
// ✅ Override animation duration/curve on Material widgets that support it
showModalBottomSheet(
  context: context,
  sheetAnimationStyle: AnimationStyle(
    duration: Duration(milliseconds: 500),
    curve: Curves.easeInOutCubic,
    reverseCurve: Curves.easeIn,
  ),
  builder: (ctx) => MyBottomSheet(),
)
```

---
---

# PART 11 — STACK USAGE

## 11.1 When Stack IS the Right Choice

✅ Use Stack for:
- Overlapping layers (badge over icon, gradient over image, overlay over content)
- Positioned absolute elements (watermarks, floating labels, bottom overlays)
- Complex layered UIs (cards with sticker-like elements)

❌ Don't use Stack for:
- Simple centering or alignment (use `Container(alignment:)`)
- Adding shadow or border (use `BoxDecoration`)
- Positioning a single button (use `Scaffold(floatingActionButton:)`)

---

## 11.2 Positioned — All Variants

```dart
Stack(children: [
  // Fill entire Stack
  Positioned.fill(child: BackgroundWidget()),

  // From a Rect
  Positioned.fromRect(rect: Rect.fromLTWH(10, 10, 100, 50), child: Widget()),

  // Specific edges
  Positioned(top: 8, right: 8, child: Badge()),

  // Only some edges (widget sizes itself on unconstrained axes)
  Positioned(bottom: 0, left: 0, right: 0, child: BottomBar()),

  // Non-positioned — uses Stack's alignment
  // (no Positioned wrapper)
  AlignedWidget(),  // aligned by Stack's alignment attribute
])
```

---

## 11.3 Stack alignment vs Align vs Positioned

```dart
// Stack.alignment — applies to ALL non-positioned children
Stack(
  alignment: Alignment.center,  // all non-positioned children are centered
  children: [Background(), CenteredContent()],
)

// Align — individual child alignment
Stack(children: [
  Background(),
  Align(alignment: Alignment.topRight, child: CloseButton()),
  Align(alignment: Alignment.bottomCenter, child: CaptionText()),
])

// Positioned — pixel-exact offset from edges
Stack(children: [
  Background(),
  Positioned(top: 12, right: 12, child: Badge()),  // preferred over Align + Padding
])
```

---
---

# PART 12 — MATERIAL 3 MODERN WIDGETS

## 12.1 Button Hierarchy — Use the Right Button

```dart
// Material 3 button hierarchy (from most to least emphasis):
FilledButton(onPressed: primaryAction, child: Text('Confirm'))        // highest emphasis
FilledButton.tonal(onPressed: secondaryAction, child: Text('Save'))   // secondary
ElevatedButton(onPressed: action, child: Text('Submit'))              // elevated
OutlinedButton(onPressed: action, child: Text('Cancel'))              // medium
TextButton(onPressed: action, child: Text('Skip'))                    // lowest emphasis

// Icon buttons (M3)
IconButton(icon: Icon(Icons.favorite), onPressed: like)
IconButton.filled(icon: Icon(Icons.favorite), onPressed: like)
IconButton.filledTonal(icon: Icon(Icons.favorite), onPressed: like)
IconButton.outlined(icon: Icon(Icons.favorite), onPressed: like)
```

---

## 12.2 Card — Use surfaceVariant and elevation

```dart
// ❌ WRONG — Container with manual shadow
Container(
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)]),
  child: Content(),
)

// ✅ RIGHT — Card variants (Material 3)
Card(elevation: 1, child: Padding(padding: EdgeInsets.all(16), child: Content()))
Card.filled(child: Content())    // filled with surfaceContainerHighest color
Card.outlined(child: Content())  // no shadow, has border
```

---

## 12.3 Chip Variants — All Four Types

```dart
// ❌ WRONG — Custom Container + GestureDetector for chips
GestureDetector(
  onTap: select,
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(20)),
    child: Text('Label'),
  ),
)

// ✅ RIGHT — Use the semantic Chip variant
FilterChip(label: Text('Music'), selected: isSelected, onSelected: (v) => toggle(v))
ChoiceChip(label: Text('S'), selected: _size == 'S', onSelected: (v) => _size = 'S')
InputChip(label: Text('Flutter'), onDeleted: () => remove('Flutter'), avatar: FlutterLogo())
ActionChip(label: Text('Edit'), onPressed: edit, avatar: Icon(Icons.edit))
```

---

## 12.4 Divider — Semantic and Themed

```dart
// ❌ WRONG
Container(height: 1, color: Colors.grey[300])
SizedBox(height: 1, child: ColoredBox(color: Colors.grey[300]!))

// ✅ RIGHT
Divider()                              // full width, respects ThemeData
Divider(thickness: 1, indent: 16, endIndent: 16)  // inset divider
Divider(height: 0)                     // no extra space around line
VerticalDivider(width: 1, thickness: 1) // vertical, inside Row
```

---

## 12.5 ExpansionTile — Built-in Collapse

```dart
// ❌ WRONG — StatefulWidget + bool + AnimatedContainer for expand/collapse
// ✅ RIGHT
ExpansionTile(
  title: Text('Section Header'),
  subtitle: Text('Tap to expand'),
  leading: Icon(Icons.category),
  trailing: Icon(Icons.expand_more),  // auto-rotates
  initiallyExpanded: false,
  onExpansionChanged: (expanded) => onToggle(expanded),
  children: [
    ListTile(title: Text('Item 1')),
    ListTile(title: Text('Item 2')),
  ],
)

// ExpansionPanelList for multiple collapsible panels
ExpansionPanelList(
  expansionCallback: (i, isExpanded) => setState(() => _expanded[i] = !isExpanded),
  children: panels.map((p) => ExpansionPanel(
    headerBuilder: (ctx, isExpanded) => ListTile(title: Text(p.title)),
    body: ListTile(title: Text(p.content)),
    isExpanded: _expanded[panels.indexOf(p)],
  )).toList(),
)
```

---

## 12.6 SnackBar / Dialog / BottomSheet — Use ScaffoldMessenger

```dart
// ❌ WRONG — Custom overlay for temporary messages
// ✅ RIGHT
ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  content: Text('Item deleted'),
  action: SnackBarAction(label: 'Undo', onPressed: undo),
  behavior: SnackBarBehavior.floating,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
))

// Material 3 Dialog
showDialog(context: context, builder: (ctx) => AlertDialog(
  icon: Icon(Icons.warning),
  title: Text('Delete item?'),
  content: Text('This action cannot be undone.'),
  actions: [
    TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
    FilledButton(onPressed: () { delete(); Navigator.pop(ctx); }, child: Text('Delete')),
  ],
))

// Bottom Sheet
showModalBottomSheet(context: context, builder: (ctx) => DraggableScrollableSheet(
  expand: false,
  builder: (ctx, controller) => ListView.builder(
    controller: controller,
    itemCount: items.length,
    itemBuilder: (ctx, i) => ListTile(title: Text(items[i])),
  ),
))
```

---
---

# PART 13 — CONST CONSTRUCTORS

## 13.1 Always const — Reduces Rebuilds

```dart
// ❌ WRONG — Missing const causes unnecessary rebuilds on every setState
Text('Static Label')
Icon(Icons.home)
SizedBox(height: 16)
EdgeInsets.all(16)
Padding(padding: EdgeInsets.all(16), child: Text('Static'))

// ✅ RIGHT — const short-circuits Flutter's rebuild mechanism
const Text('Static Label')
const Icon(Icons.home)
const SizedBox(height: 16)
const EdgeInsets.all(16)
const Padding(padding: EdgeInsets.all(16), child: Text('Static'))
```

**Enable lint:** `flutter_lints` or `prefer_const_constructors` to auto-detect missing consts.

---
---

# QUICK REFERENCE — M2 → M3 WIDGET MIGRATION

| Material 2 (Old) | Material 3 (New) | Notes |
|-----------------|-----------------|-------|
| `BottomNavigationBar` | `NavigationBar` | Taller, no shadow |
| `Drawer` (manual) | `NavigationDrawer` | M3 destinations |
| `ToggleButtons` | `SegmentedButton` | Multi-select support |
| `DropdownButton` | `DropdownMenu` | Searchable, filterable |
| `PopupMenuButton` | `MenuAnchor` | Submenus, cascading |
| `TextField` (search) | `SearchBar` + `SearchAnchor` | Full search view |
| `FlatButton` | `TextButton` | Deprecated in 2.0 |
| `RaisedButton` | `ElevatedButton` / `FilledButton` | Deprecated in 2.0 |
| `ButtonBar` | `OverflowBar` | Auto-wraps on overflow |
| `Chip` (toggle) | `FilterChip` / `ChoiceChip` | Semantic |
| Manual badge Stack | `Badge` | M3 native |
| Manual carousel | `CarouselView` / `CarouselView.weighted` | Flutter 3.24+ / 3.27+ |
| `TabBar` (primary) | `TabBar` + `TabBar.secondary` | Secondary tier M3.10+ |

---

# ULTIMATE QUICK REFERENCE TABLE

| Need | ❌ Wrong | ✅ Right |
|------|---------|---------|
| Padding on Container | `Padding` wrapper | `Container(padding:)` |
| Outer margin | `Padding` wrapper | `Container(margin:)` |
| Equal spacing in Column/Row | `SizedBox` between items | `Column/Row(spacing:)` |
| Spacing in Wrap items | `SizedBox` between items | `Wrap(spacing:, runSpacing:)` |
| Flow layout that wraps | `Row` (overflows) | `Wrap` |
| Flex space between items | `Expanded(child: SizedBox())` | `Spacer()` |
| Distribute children evenly | Manual math | `mainAxisAlignment: spaceBetween` |
| Fixed size, no style | `Container(w/h:)` | `SizedBox(w/h:)` |
| Zero-size placeholder | `Container()` | `SizedBox.shrink()` |
| Fill available space | `Container(double.infinity)` | `SizedBox.expand()` |
| Align child in Container | `Align` wrapper | `Container(alignment:)` |
| Align all children in Col/Row | `Center` / `Align` each | `crossAxisAlignment:` |
| Proportional sizing | MediaQuery math | `Flexible(flex:)` |
| Percentage sizing | MediaQuery math | `FractionallySizedBox(widthFactor:)` |
| Aspect ratio | MediaQuery math | `AspectRatio(aspectRatio:)` |
| Border radius + clip | `ClipRRect` + Container | `Container(clipBehavior:, decoration:)` |
| Image in rounded box | ClipRRect + Image | `Container(decoration: DecorationImage)` |
| Shadow + border | Stack + DecoratedBox | `Container(decoration: BoxDecoration)` |
| Opacity on color | `Opacity` widget | `color.withValues(alpha:)` |
| Opacity on image | `Opacity` wrapper | `FadeInImage` / `ColorFiltered` |
| Scaffold bg color | Container wrapping body | `Scaffold(backgroundColor:)` |
| Tap on ListTile | `GestureDetector` wrapper | `ListTile(onTap:)` |
| Tap on Button | `GestureDetector` wrapper | `Button(onPressed:)` |
| Ripple tap effect | `GestureDetector` | `InkWell` |
| Swipe to dismiss | Custom drag detector | `Dismissible` |
| Pull to refresh | Custom gesture | `RefreshIndicator` |
| Inline mixed text styles | `Row` of `Text` widgets | `Text.rich` / `RichText` |
| Selectable text | `GestureDetector` + Clipboard | `SelectableText` |
| Selectable region | Multiple `SelectableText` | `SelectionArea` wrapper |
| Image sizing | `SizedBox` wrapping Image | `Image.network(width:, height:, fit:)` |
| Circle avatar | `ClipOval` + Container | `CircleAvatar` |
| Image placeholder/fade | Stack + AnimatedOpacity | `FadeInImage` |
| Image color overlay | Stack + Container | `Image(color:, colorBlendMode:)` |
| Long dynamic list | `ListView(children: all)` | `ListView.builder` |
| List with dividers | `SizedBox`/`Divider` between | `ListView.separated` |
| Drag-to-reorder list | Custom drag | `ReorderableListView` |
| Grid layout | `Wrap` + manual `SizedBox` | `GridView.builder` |
| Scrollable + AppBar | `SingleChildScrollView` | `CustomScrollView` + Slivers |
| Long list in Column | `shrinkWrap: true` | `SliverList` in `CustomScrollView` |
| Fill remaining scroll space | Manual spacer | `SliverFillRemaining` |
| Carousel / page swipe | Manual Stack + drag | `PageView` / `CarouselView` |
| Weighted carousel | Custom PageView | `CarouselView.weighted(flexWeights:)` |
| TextField with icon | `Row` + Icon + TextField | `InputDecoration(prefixIcon:)` |
| TextField with suffix button | `Stack` over TextField | `InputDecoration(suffixIcon:)` |
| Form validation | Manual bool + setState | `TextFormField` + `Form` + `validator:` |
| Checkbox + label | `Row` + Checkbox + Text | `CheckboxListTile` |
| Switch + label | `Row` + Switch + Text | `SwitchListTile` |
| Segmented toggle | Manual Row + Containers | `SegmentedButton` |
| Dropdown selection | `DropdownButton` | `DropdownMenu` (M3, searchable) |
| Context menu | `PopupMenuButton` | `MenuAnchor` (M3, submenus) |
| Search bar | Styled TextField | `SearchBar` + `SearchAnchor` |
| Date selection | Custom calendar | `showDatePicker()` |
| Time selection | Custom clock widget | `showTimePicker()` |
| AppBar back + title | `Row` inside title | `AppBar(leading:, title:)` |
| AppBar action buttons | Manually positioned | `AppBar(actions: [IconButton...])` |
| Collapsible app bar | Scroll listener hack | `SliverAppBar` + `FlexibleSpaceBar` |
| FAB placement | `Stack` + `Positioned` | `Scaffold(floatingActionButton:)` |
| Bottom tab bar (M2) | `Row` in Container | `BottomNavigationBar` |
| Bottom tab bar (M3) | `BottomNavigationBar` | `NavigationBar` |
| Side drawer (M2) | `Drawer` + manual ListTiles | `NavigationDrawer` |
| Side rail | Custom column | `NavigationRail` |
| Tabs | Custom tab system | `TabBar` + `TabBarView` |
| Notification badge | `Stack` + `Positioned` Container | `Badge(label:)` |
| Show/hide widget (state) | `condition ? W : SizedBox` | `Visibility(maintainState:)` |
| Switch pages (keep state) | Conditional rendering | `IndexedStack` |
| Preload hidden widget | Remove from tree | `Offstage(offstage:)` |
| Simple value animation | `AnimationController` | `AnimatedContainer` / etc. |
| Fade between two states | Manual animation | `AnimatedCrossFade` |
| Widget swap animation | Manual animation | `AnimatedSwitcher` |
| List item add/remove | setState + manual | `AnimatedList` |
| Shared element transition | Custom route animation | `Hero` |
| Card UI (M2) | Container + shadow | `Card(elevation:)` |
| Card UI (M3) | `Card(elevation:)` | `Card.filled()` / `Card.outlined()` |
| Selectable tag | Container + GestureDetector | `FilterChip` / `ChoiceChip` |
| Deletable tag | Container + GestureDetector | `InputChip(onDeleted:)` |
| Action tag | Container + GestureDetector | `ActionChip(onPressed:)` |
| Horizontal divider | `Container(height: 1)` | `Divider` |
| Vertical divider | `Container(width: 1)` | `VerticalDivider` |
| Expandable section | StatefulWidget + bool | `ExpansionTile` |
| Multiple panels | Multiple ExpansionTiles | `ExpansionPanelList` |
| Toast / snackbar | Custom overlay | `ScaffoldMessenger.showSnackBar()` |
| Static widget | No `const` | Always add `const` |
