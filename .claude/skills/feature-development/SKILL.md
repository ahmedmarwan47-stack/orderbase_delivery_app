---
name: feature-development
description: Flutter feature development workflow — Figma MCP + Postman MCP + full phase checklist.
disable-model-invocation: true
---

# Flutter Feature Development — Full Workflow

## 🚨 Strict Six Rules (تطبّق في كل feature)

| # | القاعدة |
|---|--------|
| 1 | **No unnecessary comments** — اشرح "لماذا"، مش "ماذا". |
| 2 | **No hardcoded in the View** — نصوص/ألوان/مقاسات/icons من `LocaleKeys` / `AppColors` / `AppSize`/`AppPadding`/`AppCircular` / `AppAssets`. |
| 3 | **The View is clean — no functions inside it** — handlers/validators/formatters في Cubit أو ViewController، widgets في ملفات منفصلة. |
| 4 | **Performance is top priority — no setState, no needless rebuilds** — `ValueNotifier` + `ValueListenableBuilder`، `BlocSelector` لجزء صغير، `AsyncBlocBuilder` للـ AsyncCubit. |
| 5 | **Most classes Stateless** — `StatefulWidget` فقط لـ lifecycle حقيقي (animations/cubit/ViewController ownership). |
| 6 | **No `Widget _buildSomething()` inside the View** — كل widget ملف منفصل في `presentation/widgets/` كـ `class _Something extends StatelessWidget`. |

التفاصيل + checklist في `coding-standards` skill — قسم "The Strict Six Rules".

---

## Folder Structure (لكل feature — Clean Architecture كاملة)

```
features/<feature>/
├── data/
│   ├── datasources/<feature>_remote_data_source_impl.dart   (extends BaseRemoteSource)
│   ├── models/<entity>_model.dart                            (DTO with fromJson)
│   ├── mappers/<entity>_mapper.dart                          (Model ↔ Entity)
│   └── repositories/<feature>_repository_impl.dart           (implements domain interface)
├── domain/
│   ├── datasources/<feature>_remote_data_source.dart         (abstract interface)
│   ├── entities/<entity>_entity.dart                         (pure Dart)
│   ├── enums/<entity>_status.dart
│   ├── repositories/<feature>_repository.dart                (abstract interface)
│   └── usecases/<action>_usecase.dart                        (Either<Failure, T>)
└── presentation/
    ├── imports/<feature>_imports.dart                        (part-of hub — per-feature name, e.g. products_imports.dart)
    ├── cubits/<feature>_cubit.dart                           (AsyncCubit<T> — server state only)
    ├── controllers/<feature>_view_controller.dart            (TextEditingController, ValueNotifier, ScrollController — ephemeral UI state)
    ├── view/<feature>_screen.dart                            (Screens — public entry points; cubit + ViewController lifecycle owner)
    └── widgets/                                              (private `_X` widgets — `_FooBody`, `_FooCard`, …)
```

**Imports hub:** every presentation file declares `part of '../imports/<feature>_imports.dart';` (e.g. `products_imports.dart` for products feature — the name **changes per feature**).

---

## ⚠️ Mandatory Pre-Flight Reading (إلزامي قبل أي feature جديد)

> **هذا الـ skill ده هو الـ workflow — لكن قبل ما تبدأ، اقرأ الـ skills دي بـ `Read` tool عشان تكون شاحن الـ context كله:**

### 📚 القراءة الإلزامية (لكل feature جديد — بالترتيب):

```
1. .claude/skills/feature-prompt/SKILL.md       ← الـ workflow الكامل (STEP 0-8)
2. .claude/skills/coding-standards/SKILL.md     ← Senior mindset + entity safety + 30+ rule
3. .claude/skills/rtl-arabic/SKILL.md           ← RTL layout mirroring + Figma reading direction
4. .claude/skills/flutter-patterns/SKILL.md     ← Senior widget building + file structure
5. .claude/skills/widget-efficiency/SKILL.md    ← اختيار الـ widget الصح + بناء أقل widget tree (no wrappers)
6. .claude/skills/bloc-patterns/SKILL.md        ← BlocConsumer/Listener strict rules + AsyncCubit
```

> **`widget-efficiency` مش optional** — هي الـ rulebook لاختيار الـ widget الصح وتجنّب الـ wrappers الزيادة.
> قبل ما تكتب `Padding(...)` / `Center(...)` / `Container()` للـ sizing / `GestureDetector` / `Stack` للـ badge / `ClipRRect` حوالين `Image` / `Opacity` على `color` — راجع الـ skill ده.

### 🎯 القراءة الـ Conditional (حسب نوع الفيتشر):

```
لو الفيتشر فيه API           → .claude/skills/api-pipeline/SKILL.md
لو الفيتشر فيه form          → .claude/skills/form-api-pipeline/SKILL.md
لو فيه Figma design           → .claude/skills/figma-to-flutter/SKILL.md
                                .claude/skills/figma-widget-mapping/SKILL.md
                                .claude/skills/figma-mcp-mapping/SKILL.md
لو navigation معقد            → .claude/skills/navigation-patterns/SKILL.md
                                .claude/skills/multi-screen-flow/SKILL.md
لو search field               → .claude/skills/search-field-debounce/SKILL.md
لو scaffold/status bar        → .claude/skills/scaffold-patterns/SKILL.md
لو bloc scoping سؤال          → .claude/skills/bloc-provider-scoping/SKILL.md
لو DI أو architecture         → .claude/skills/di-and-architecture/SKILL.md
لو design tokens              → .claude/skills/design-tokens/SKILL.md
لو محتاج تولّد Postman         → .claude/skills/api-design/SKILL.md
```

### ✅ بعد ما تخلص الـ Feature (إلزامي):

```
.claude/skills/post-feature-review/SKILL.md   ← code review checklist + critical/high issues
```

### 🔍 Trigger Rules — متى تقرأ إيه:

| المهمة | الـ skills اللازم قراءتها |
|--------|---------------------------|
| **Feature كامل من Figma + API** | الـ 6 إلزامية + figma + api-pipeline + post-feature-review |
| **Feature UI فقط (لا API)** | الـ 6 إلزامية + figma — تخطي api/bloc لو مفيش cubits |
| **Cubit/Endpoint جديد** | feature-prompt + bloc-patterns + api-pipeline + coding-standards |
| **Form + API submit** | feature-prompt + form-api-pipeline + bloc-patterns + widget-efficiency + coding-standards |
| **Refactor widget موجود** | flutter-patterns + widget-efficiency + coding-standards |
| **بناء widget جديد في core/widgets** | widget-efficiency + flutter-patterns + coding-standards |


## ⚠️ MCP Critical Rules

### Figma MCP:
- Raw numbers (16, 20) → convert to `AppSize`/`AppPadding`/`AppCircular`
- **Colors → read `color_manager.dart` FIRST, reuse existing AppColors by purpose** (e.g. dark text → `AppColors.primary`, grey text → `AppColors.hintText`, light bg → `AppColors.fill`). Only add truly new colors with **generic names** — NEVER screen-prefixed (`loginPrimary` ❌)
- **Font sizes → Figma ≤13sp keep as-is, Figma 14-18sp reduce by 1–2sp, Figma ≥20sp reduce by 2sp** (Figma 12 → `.s12`, Figma 16 → `.s14`, Figma 22 → `.s20`)
- **Screen-level body padding > 12px → reduce by 2–4px** (Figma 16 → 12 or 14, Figma 20 → 16). ≤ 12px → keep as-is.
- **RTL Section Verification** — Figma MCP sometimes returns sections mirrored. ALWAYS cross-check with the visual screenshot. Verify: Arabic text starts from RIGHT, horizontal lists/filters start from RIGHT, card images match Figma visual position. Trust screenshot over raw MCP data.
- **Icon background check** — some AppAssets icons already include their background. Check before wrapping in Container. If icon has built-in bg → use directly. If transparent → add Container bg.
- App is RTL — read positions from Figma AS-IS, never mirror
- No `Directionality` widget on layouts (exception: wrapping a single Text widget to fix mirrored text inside complex components like Slider/DropdownButton)
- No `Icons.*` from Material — use `AppAssets` only

### Postman MCP:
- Every Entity needs `factory initial()` — mandatory
- Every `fromJson` field needs `?? defaultValue` or nullable
- One cubit per endpoint — never merge
- Check response fully for pagination before starting
- **List endpoints → MUST be `PaginatedCubit`** (not `AsyncCubit<List<T>>`)

### RTL — Mandatory Check on EVERY Screen:
- `CrossAxisAlignment.start` → physical RIGHT (use for Arabic text alignment) ✅
- `CrossAxisAlignment.end` → physical LEFT ✅
- `AlignmentDirectional.centerStart` → physical RIGHT ✅
- `PositionedDirectional(start:)` → physical RIGHT ✅
- `PositionedDirectional(end:)` → physical LEFT ✅
- Row: first child → physical RIGHT, last child → physical LEFT
- Never: `Positioned(left/right:)`, `Align(Alignment.centerLeft/Right)`, `EdgeInsets.only(left/right:)`, `TextAlign.left`

---

## PHASE 1 — Audit Before Build

### Check config/ before writing any value:
- `color_manager.dart` → AppColors
- `app_sizes.dart` → AppSize, AppPadding, AppMargin, AppCircular, FontSizeManager
- `assets.gen.dart` → AppAssets
- `locale_keys.g.dart` → LocaleKeys

### Check core/ before building any widget:

> **See `flutter-base-coding-standards.mdc` sections 8.4 and 11 for full widget/helper/extension inventory.**

**Quick Reference — Must-Use Widgets:**
- Buttons: `LoadingButton` (async submit), `DefaultButton` (simple)
- Fields: `CustomTextFiled` (with label), `DefaultTextField` (raw), `AppDropdown<T>`
- State: `AsyncBlocBuilder` / `AsyncSliverBlocBuilder` / `PaginatedListWidget`
- Images: `CachedImage` (network), `UploadImageWidget`
- Scaffold: `DefaultScaffold` (inner screens) — see `scaffold-statusbar.mdc`
- Dialogs: `successDialog`, `showCustomDialog`, `showDefaultBottomSheet`
- Icons: `IconWidget` (handles SVG/PNG/Lottie/network)
- Messages: `MessageUtils.showSnackBar`

**Must-Use Helpers:** `Validators.*`, `InputFormatters.*`, `FormMixin`, `Modular.to.*`, `ApiEndpoints.*`

**Golden Rule:** If it exists in `core/` or `config/` → use it. Never reinvent.

---

## PHASE 2 — Figma Analysis

### Multi-Screen Verification (إلزامي):
- Check ALL provided screenshots and Figma nodes for the feature before starting.
- Compare each Figma node to its corresponding screenshot.
- Ensure that the workflow and navigation between these screens are well understood.

### Read ALL screens for the feature:
1. Main screen (default state)
2. Empty state
3. Loading/skeleton state
4. Error state
5. All modals & bottom sheets
6. Success/failure states
7. Pagination load-more state (if applicable)

### For every Figma value:
```
Color hex → match AppColors → add if not found
Number px → match AppSize/AppPadding/AppMargin → add if not found
Font size → match FontSizeManager → add if not found
Icon → match AppAssets → add if not found
```

---

## PHASE 3 — API / Entity Rules

> **⚠️ If UI_ONLY mode → SKIP this phase entirely.** Create entities with static/dummy data. No API calls. No Postman.

> **See `flutter-base-coding-standards.mdc` section 8.5 for full entity template, fromJson type table, and tryParse rules.**

### ⚠️ Entity Safety Summary (NON-NEGOTIABLE):
1. **`factory initial()`** — MANDATORY for every entity (Skeletonizer + null-safety)
2. **`fromJson` with `??` defaults** — String→`''`, int→`0`, double→`0.0`, bool→`false`, List→`[]`, Object→`.initial()`, nullable→no `??`
3. **`tryParse` ONLY** — NEVER use `int.parse()` or `double.parse()` (crashes on bad data)
4. **DateTime fields** → `DateTime.tryParse(json['date'] ?? '') ?? DateTime(2000)` — NEVER `DateTime.parse()`
5. **Enum fields** → `Status.values.firstWhere((e) => e.name == json['status'], orElse: () => Status.initial)` — NEVER without `orElse`
6. **Nested List<Entity>** → `(json['items'] as List?)?.map((e) => e != null ? Entity.fromJson(e) : Entity.initial()).toList() ?? []` — null-check each element
7. **One cubit per endpoint** — never merge multiple services in one cubit
8. **Check response** for pagination before starting

---

## PHASE 4 — Feature Folder Structure

> **كل section / component في الشاشة لازم يكون في ملف منفصل** — مش method في نفس الـ body file.
> الـ body widget يجمع الـ sections فقط. كل section في ملف خاص.

```
lib/src/features/feature_name/
├── entity/
│   └── feature_name_entity.dart
└── presentation/
    ├── imports/
    │   └── <feature>_imports.dart              ← all imports + part declarations
    ├── cubits/
    │   └── feature_name_cubit.dart        ← part of <feature>_imports.dart
    ├── view/
    │   └── feature_name_screen.dart       ← part of <feature>_imports.dart
    └── widgets/
        ├── feature_name_body.dart         ← layout only — يجمع الـ sections
        ├── feature_name_header_widget.dart ← ملف منفصل لكل section
        ├── feature_name_list_widget.dart   ← ملف منفصل
        └── feature_name_card_widget.dart   ← ملف منفصل
```

**❌ FORBIDDEN — كتابة كل الـ widgets في ملف الـ body كـ methods:**
```dart
// ❌ Everything in one file as _build methods
class _FeatureBody extends StatelessWidget {
  Widget _buildHeader() => Container(...);  // NO!
  Widget _buildFilters() => Row(...);       // NO!
  Widget _buildList() => ListView(...);     // NO!
}
```

**✅ CORRECT — كل section في ملف منفصل:**
```dart
// feature_name_body.dart — layout only
class _FeatureBody extends StatelessWidget {
  const _FeatureBody();
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      const _FeatureHeader().toSliver(),
      const _FeatureFilterBar().toSliver(),
      const _FeatureList(),
    ]);
  }
}
```

---

## PHASE 5 — Cubit Pattern

### Standard Cubit

```dart
// part of '../imports/<feature>_imports.dart'
// Registered in Module (e.g., Bind.factory)
class MyFeatureCubit extends AsyncCubit<List<MyFeatureEntity>> {
  MyFeatureCubit(this._getItems, this._deleteItem);
  final GetItemsUseCase _getItems;
  final DeleteItemUseCase _deleteItem;

  Future<void> fetchItems({String? search}) =>
    execute(() => _getItems(search: search));

  // Local update on delete — NO re-fetch (optimistic)
  Future<Either<Failure, Unit>> delete(int id) async {
    final before = lastData ?? const <MyFeatureEntity>[];
    setData(before.where((e) => e.id != id).toList());
    final result = await _deleteItem(id);
    return result.fold(
      (failure) { setData(before); return Left(failure); },
      Right.new,
    );
  }
}
```

**Pagination (when the list paginates server-side):**
```dart
// Use PaginatedAsyncCubit<T> from core/state/paginated/. The cubit takes a UseCase.
// Registered in Module (e.g., Bind.factory)
class MyListCubit extends PaginatedAsyncCubit<ItemEntity> {
  MyListCubit(this._getPage);
  final GetItemsPageUseCase _getPage;

  @override
  Future<Either<Failure, PaginatedData<ItemEntity>>> fetchPage(int page, {String? key}) =>
    _getPage(page: page, search: key);
}

// domain/usecases/get_items_page_usecase.dart
@lazySingleton
class GetItemsPageUseCase {
  GetItemsPageUseCase(this._repo);
  final ItemsRepository _repo;
  Future<Either<Failure, PaginatedData<ItemEntity>>> call({required int page, String? search}) =>
    _repo.getItemsPage(page: page, search: search);
}

// data/datasources/items_remote_data_source_impl.dart
@override
Future<Either<Failure, PaginatedData<ItemEntity>>> getItemsPage({
  required int page, String? search,
}) => request<PaginatedData<ItemEntity>>(
  method: HttpMethod.get,
  endpoint: ApiEndpoints.items,
  queryParameters: {'page': page, if (search != null && search.isNotEmpty) 'search': search},
  fromJson: (j) => PaginatedData<ItemEntity>(
    items: ((j['data'] as List?) ?? const [])
      .whereType<Map<String, dynamic>>().map(ItemModel.fromJson).map((m) => m.toEntity()).toList(),
    meta: PaginationMeta.fromJson(j['meta'] as Map<String, dynamic>),
  ),
);
// View: PaginatedListWidget(cubit: ..., itemBuilder: ...)
```
> **Exception:** Plain `AsyncCubit<List<T>>` is fine for dropdowns, small sub-sections, and filter chips that don't paginate.

### ⚠️ CRUD Local Update Rule (NON-NEGOTIABLE)

> **NEVER re-fetch the entire list after add/edit/delete.** Always update the local state immediately — preferably **optimistically** (mutate first, then call the API, rollback on failure).
> The API response from the action (add/edit/delete) contains the server-confirmed entity. Use that, not the user's input.

**Add (optimistic insert + rollback on failure):**
```dart
Future<Either<Failure, ItemEntity>> create(AddItemParams params) async {
  final temp = ItemEntity.tempFromParams(params);     // negative id = temp marker
  final before = lastData ?? const <ItemEntity>[];
  setData([temp, ...before]);                          // optimistic insert

  final result = await _createItem(params);
  return result.fold(
    (failure) { setData(before); return Left(failure); },                              // rollback
    (saved) {                                                                            // replace temp with confirmed entity
      setData((lastData ?? before).map((e) => e.id == temp.id ? saved : e).toList());
      return Right(saved);
    },
  );
}
```

**Edit (local — when an edit screen returns):**
```dart
void updateItem(ItemEntity updated) {
  final current = lastData ?? const <ItemEntity>[];
  setData(current.map((e) => e.id == updated.id ? updated : e).toList());
}
```

**Delete (optimistic remove + rollback):**
```dart
Future<Either<Failure, Unit>> delete(int id) async {
  final before = lastData ?? const <ItemEntity>[];
  setData(before.where((e) => e.id != id).toList());
  final result = await _deleteItem(id);
  return result.fold(
    (failure) { setData(before); return Left(failure); },
    Right.new,
  );
}
```

```dart
// ❌ FORBIDDEN — re-fetching the entire list after action
onDeleteSuccess: () => fetchItems()      // wasteful, causes flash
onAddSuccess: () => fetchItems()         // bad UX, user loses scroll position
```

---

### RefreshIndicator — MANDATORY on All Data Screens

> Every screen that displays data from API MUST have a `RefreshIndicator` to allow pull-to-refresh.

```dart
// ✅ CORRECT — list screen with RefreshIndicator
RefreshIndicator(
  onRefresh: () => context.read<MyCubit>().fetchItems(),
  child: ListView.builder(
    physics: const AlwaysScrollableScrollPhysics(),
    itemCount: items.length,
    itemBuilder: (_, i) => ItemCard(item: items[i]),
  ),
)

// ✅ For screens with CustomScrollView
RefreshIndicator(
  onRefresh: () => Future.wait([
    context.read<BannersCubit>().fetchBanners(),
    context.read<CategoriesCubit>().fetchCategories(),
  ]),
  child: CustomScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    slivers: [...],
  ),
)

// ❌ FORBIDDEN — no refresh capability
ListView.builder(itemCount: items.length, itemBuilder: ...)
```

---

### Empty Sections → Hide When No Data (Multi-Section Screens)

> When a screen has multiple sections, each with its own API service, **hide sections that return empty data** so the screen looks clean.

```dart
// ✅ CORRECT — section hidden when empty
AsyncBlocBuilder<BannersCubit, List<BannerEntity>>(
  builder: (context, banners) {
    if (banners.isEmpty) return const SizedBox.shrink();  // hidden!
    return BannerCarousel(banners: banners);
  },
  loadingBuilder: (_) => const BannerSkeleton(),
)

// ❌ WRONG — showing empty section or EmptyWidget inside a multi-section screen
AsyncBlocBuilder<BannersCubit, List<BannerEntity>>(
  builder: (context, banners) {
    if (banners.isEmpty) return EmptyWidget(title: 'No banners');  // ugly in multi-section
    return BannerCarousel(banners: banners);
  },
)
```

**Rule:** `EmptyWidget` is for **full-screen empty states** (single-service screens). For sections within a multi-service screen, use `SizedBox.shrink()` to hide.

**لو كل الـ sections فاضية؟** → اعرض `EmptyWidget` واحد على مستوى الشاشة كلها:
```dart
// Check if ALL sections are empty → show full-screen empty
if (banners.isEmpty && categories.isEmpty && products.isEmpty) {
  return EmptyWidget(title: LocaleKeys.noContent.tr());
}
```

---

### Isolate for Heavy Screens (Performance Optimization)

> When a screen has **many concurrent API calls** (e.g. Home screen with 4+ services), consider using `compute()` / `Isolate` for heavy JSON parsing to prevent UI jank.

```dart
// ✅ For screens with many services (home, dashboard, etc.)
// Use compute() for heavy parsing in the mapper
mapper: (json) => compute(_parseItems, json),

// Standalone parsing function (must be top-level or static)
static List<ItemEntity> _parseItems(Map<String, dynamic> json) {
  return (json['data']['data'] as List)
      .map((e) => ItemEntity.fromJson(e))
      .toList();
}
```

**When to use Isolate:**
- Screen has 4+ concurrent API calls
- Each response has large lists (20+ items with nested objects)
- User reports jank/freeze during loading

---

## PHASE 6 — Localization

```
1. Extract all text from Figma
2. Add to assets/translations/lang.json (snake_case keys)
3. Run: dart run generate/strings/main.dart
4. Use LocaleKeys.xxx.tr() in all widgets
```

```dart
// ✅
Text(LocaleKeys.featureTitle.tr())

// ❌
Text('عنوان الصفحة')
```

---

## PHASE 7 — Pre-Delivery Checklist

```
Design & Tokens:
□ No raw Color(), Icons.*, SizedBox(N), TextStyle() — use AppColors, AppAssets, AppSize, TextStyleEx
□ Font sizes ≤13sp kept as-is, 14+ reduced 1–2sp from Figma | Screen body padding > 12px reduced 2–4px
□ All text uses LocaleKeys.xxx.tr() | Design matches Figma 100%

Entity & API:
□ Every entity has factory initial() + fromJson with ?? defaults + tryParse (never parse)
□ One cubit per endpoint | Part-of system in <feature>_imports.dart
□ Local update on add/edit/delete (never re-fetch) | ApiConstants for all URLs
□ List endpoints use PaginatedCubit (not AsyncCubit<List>) for standalone screens

RTL (see rtl-arabic skill for full rules):
□ No Positioned(left/right), Align(centerLeft/Right), EdgeInsets.only(left/right), TextAlign.left
□ CrossAxisAlignment.start for text alignment | Row: RIGHT element = FIRST child
□ No Directionality on layouts (single Text exception only) | Visual test: titles on RIGHT

Core Widgets (see flutter-base-coding-standards.mdc section 11):
□ LoadingButton, CustomTextFiled, AppDropdown, AsyncBlocBuilder, CachedImage, Modular.to.xxx
□ DefaultScaffold (inner) | Scaffold+SafeArea (auth) | Status bar synced

Forms:
□ FormMixin + validateAndScroll() | Validators.* + InputFormatters.* | .toEnglishNumbers()

Scroll & Performance:
□ Multi-section → CustomScrollView + Slivers (no shrinkWrap) | RefreshIndicator on data screens
□ Sliver sections: widget returns **Box** (Column, etc.) and parent uses `.toSliver()` once — never double-wrap (SliverToBoxAdapter expects RenderBox, not RenderSliver)
□ Empty sections → SizedBox.shrink() | Heavy screens (4+ APIs) → compute()

Widget Splitting (MANDATORY):
□ Body = layout only — no _buildXxx() methods returning 10+ lines
□ Every section/card in SEPARATE file | Each added as part in <feature>_imports.dart

Clean Code (MANDATORY):
□ No unused imports | No unused optional parameters
□ const on every widget/constructor that can be const
□ Spacing: .szH/.szW only (no SizedBox) | Padding: extensions only (no Padding widget)
□ Models/enums in entity/ folder (no helper methods in widget classes)
□ Dropdown/small widget API → isolated BlocBuilder (not wrapping whole screen)
□ All text from LocaleKeys — no hardcoded Arabic/English strings
□ AppBar/BottomSheet/Dialog content checked for RTL correctness

Shared Widget Reuse (CRITICAL):
□ Searched app_shared/ + existing features before creating new widget
□ No duplicate cards across features | Optional params for minor variations
```
