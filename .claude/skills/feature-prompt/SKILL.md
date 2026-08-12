---
name: feature-prompt
description: Full feature development workflow — fill in feature name, Figma link, and Postman link, then follow all phases from audit to verify.
disable-model-invocation: true
---

# Feature Development Prompt

## 🚨 The Strict Six Rules (تطبّق في كل feature)

| # | القاعدة |
|---|--------|
| 1 | **No unnecessary comments** — Comments تشرح "لماذا"، مش "ماذا". الكود الجيد يشرح نفسه. |
| 2 | **No hardcoded values in the View** — نصوص/ألوان/مقاسات/icons/assets من `LocaleKeys` / `AppColors` / `AppSize`/`AppPadding`/`AppCircular` / `AppAssets`. |
| 3 | **The View is clean** — لا functions داخل الـ Screen غير `build/initState/dispose`. كل handler / validator / formatter / sheet-opener في Cubit أو ViewController أو widget منفصل. |
| 4 | **Performance is top priority — no `setState`, no rebuilds بدون داعي** — `ValueNotifier` + `ValueListenableBuilder` للـ ephemeral UI state، `BlocSelector` للـ partial state، `AsyncBlocBuilder` للـ AsyncCubit. |
| 5 | **Most classes Stateless** — `StatefulWidget` فقط لـ lifecycle حقيقي (cubit/ViewController ownership، animations، focus). الـ state في cubit/ViewController. |
| 6 | **No `Widget _buildSomething()` inside the View** — كل widget ملف منفصل في `presentation/widgets/` كـ `class _Something extends StatelessWidget` (private — يبدأ بـ `_`)، part-of الـ imports hub. |

التفاصيل + checklist في `coding-standards` skill — قسم "The Strict Six Rules".

---

## 🎯 STEP 0 — Mindset & Non-Negotiables (اقرأها قبل أي حاجة تانية)

> **قبل ما تبدأ أي شغل في الفيتشر دي، خد القواعد دي كأنها قانون — مش suggestion.**

### 1. أنت Advanced Senior Flutter Developer
- فكّر قبل ما تكتب. كل decision (widget، cubit، architecture) لازم يكون مدروس.
- اختار **أفضل widget للموقف** — مش أول widget يخطر في بالك.
- Performance + Readability + Clean Architecture = priorities متساوية.
- التفاصيل: `coding-standards` skill — section 0.

### 2. Dart 3.10
- استخدم records، sealed classes، pattern matching، switch expressions لما تخلي الكود أنضف.
- لا تستخدمهم لمجرد الـ syntax.

### 3. BlocConsumer / BlocListener — للضرورة القصوى فقط
- الافتراضي: `BlocBuilder` / `AsyncBlocBuilder`.
- `BlocListener` فقط لما يكون فيه **side effect** (snackbar، navigation، dialog). و لازم `listenWhen`.
- `BlocConsumer` نادر — preferred هو split: `BlocListener` + `BlocBuilder` منفصلين.
- التفاصيل: `bloc-patterns` skill — أول قسم.

### 4. RTL — التصميم بيتقرا من اليمين للشمال
- كل title، كل first child في Row، كل CrossAxisAlignment.start → بيقع على **اليمين**.
- كل padding/margin: `start`/`end` فقط — مش `left`/`right`.
- كل Positioned: `PositionedDirectional` — مش `Positioned`.
- لو شاكك في ترتيب → افتح الـ Figma كصورة، حدد العنصر يمين، خليه `first child`.
- التفاصيل: `rtl-arabic` skill — أول قسم.

### 5. Widget Building — Best Practices
- `const` كل ما أمكن.
- Stateless > Stateful (الـ state في ViewController/cubit).
- Composition: كل section في widget منفصل.
- `BlocSelector` / `ValueListenableBuilder` لو محتاج جزء صغير من state.
- التفاصيل: `flutter-patterns` skill — أول قسم.

---

Feature: [FEATURE_NAME]
Figma Nodes:
  - Screen 1: [FIGMA_URL_1]
  - Screen 2: [FIGMA_URL_2]
Screenshots:
  - Screen 1: (attach screenshot 1)
  - Screen 2: (attach screenshot 2)
Mode: [UI_ONLY / UI_AND_API]
API Source: [EXISTING_POSTMAN / AUTO_GENERATE / NONE]

> If **EXISTING_POSTMAN** → provide: Postman Collection: [POSTMAN_URL]
> If **AUTO_GENERATE** → will be generated from Figma in STEP 4
> If **NONE** → UI_ONLY mode (no API)

---

## ⚠️ FIRST — ASK THE USER (سؤالين):

> **قبل ما تبدأ أي شغل — لازم تسأل المستخدم:**
>
> ### السؤال 1: "عاوز تصميم UI بس ولا UI + API مع بعض؟"
>
> - **UI Only** → اعمل الشاشات بـ static data مباشرة في الـ widgets، بدون cubits، بدون API calls، بدون Postman.
> - **UI + API** → كمّل للسؤال 2.
>
> ### السؤال 2 (لو UI + API): "عندك Postman Collection جاهزة ولا أولّدلك الـ API؟"
>
> - **A) عندي Postman جاهز** → ادّيني الـ link وأنا هقرأه وأنفذه (STEP 4 Path A)
> - **B) ولّدلي الـ API** → هحلل شاشات Figma وأولّد Postman Collection JSON + entities أوتوماتيك (STEP 4 Path B)
>
> ### ملخص الأوضاع الثلاثة:
>
> | الوضع | Cubits | API Source | Postman |
> |-------|--------|------------|--------|
> | **UI Only** | ❌ لا | — | ❌ لا |
> | **UI + API (Existing Postman)** | ✅ نعم | Postman Collection جاهزة | ✅ جاهز |
> | **UI + API (Auto Generate)** | ✅ نعم | يتولّد من Figma | ✅ يتولّد في STEP 4 |

---

Before writing ANY code, follow this exact order:

══════════════════════════════════════════════════════════════
STEP 1 — LOAD SKILLS (إلزامي)
══════════════════════════════════════════════════════════════

All skills in `.claude/skills/` are available. Ensure you've internalized:

**Workflow & Entry Points:**
- `feature-development` — full workflow, phases, cubit patterns, CRUD, checklist
- `post-feature-review` — auto code review after completing any feature

**Architecture & Patterns:**
- `coding-standards` — colors, sizes, text styles, RTL, core widgets, entity safety, extensions, helpers, slivers
- `bloc-patterns` — AsyncCubit, CRUD local updates, BlocListener, PaginatedCubit
- `flutter-patterns` — Widget patterns, file structure, key widgets, screen/body patterns
- `di-and-architecture` — Modular.get<T>(), layering, ApiConstants
- `bloc-provider-scoping` — where to provide cubits, single vs multi, shared vs isolated, decision tree

**API & Data Flow:**
- `api-pipeline` — Complete Postman → ApiEndpoints → Model + Mapper → Entity → DataSource (`BaseRemoteSource.request<T>`) → Repository → UseCase → Cubit → UI pipeline
- `api-design` — Auto-generate Postman Collection JSON from Figma screens (unified entities, pagination, multi-step forms, file upload)
- `form-api-pipeline` — Complete form → ViewController → Params → validation → API submit → success
- `navigation-patterns` — Modular.to.pushNamed() with arguments, back with result, refresh parent, tab navigation
- `multi-screen-flow` — List/detail/edit/create patterns with data passing and screen linking

**Figma & Design:**
- `design-tokens` — Figma → Flutter token mapping
- `figma-to-flutter` — Figma MCP conversion workflow + safety checks
- `figma-widget-mapping` — Comprehensive Figma element → Flutter widget mapping table
- `figma-mcp-mapping` — Figma MCP token conversion cheatsheet
- `figma-task-extractor` — Auto-generate tasks from Figma file

**RTL & Localization:**
- `rtl-arabic` — RTL rules, layout mirroring prevention, directional APIs

**UI Patterns:**
- `scaffold-patterns` — 3 scaffold types + status bar rules
- `search-field-debounce` — real TextField + rxdart debounce

**Quality & Standards:**
- `clean-code-and-refactoring` — widget splitting (separate files!), shared reuse, naming
- `error-handling-and-resilience` — ErrorView, retries, fromJson safety
- `performance-and-memory` — const, lists, slivers, dispose
- `logging-and-debugging` — no print/debugPrint in final code
- `pubspec-manager` — package detection, platform config
- `accessibility` — tap targets >=44, semantic labels for icon-only buttons (consider when building UI)

══════════════════════════════════════════════════════════════
STEP 2 — AUDIT EXISTING CODE (إلزامي)
══════════════════════════════════════════════════════════════

1. Read `color_manager.dart` → list all AppColors (reuse by PURPOSE, not just hex)
2. Read `app_sizes.dart` → list AppSize, AppPadding, AppMargin, AppCircular, FontSizeManager
3. Read `assets.gen.dart` → list all AppAssets
4. Check `core/widgets/` — buttons, fields, dialogs, handling_views, image_widgets, scaffolds
5. Check `features/` — any existing entity or shared widget that matches (reuse, don't duplicate)
6. Check `app_shared/widgets/` — any card/component already built for another feature

Golden rule: If it exists in core/ or config/ → use it. Never reinvent.

══════════════════════════════════════════════════════════════
STEP 3 — READ FIGMA (via Figma MCP)
══════════════════════════════════════════════════════════════

Multi-Screen Verification (إلزامي):
- Check ALL provided screenshots and Figma nodes for the feature before starting.
- Compare each Figma node to its corresponding screenshot.
- Ensure that the workflow and navigation between these screens are well understood.

- Read ALL screens: main state, empty state, loading state, error state, modals, bottom sheets
- For EVERY value: map color hex → AppColors, map px → AppSize/AppPadding/AppCircular, map font → FontSizeManager

Screen-Level Padding Adjustment (إلزامي):
- Body padding <= 12px → keep as-is
- Body padding > 12px → reduce by 2-4px (Figma 16 → 12 or 14, Figma 20 → 16)
- Applies ONLY to screen body padding — NOT card-internal or component padding

RTL Section Verification (إلزامي):
- Figma MCP sometimes returns sections MIRRORED/REVERSED from actual design
- ALWAYS cross-check each section with the Figma screenshot
- If MCP data contradicts the visual → TRUST THE SCREENSHOT

Icon Background Check (إلزامي):
- Some AppAssets icons already include their background (circle/rect with fill)
- Check asset BEFORE wrapping in Container — avoid double-background

Color Reuse Rule (إلزامي):
- Read color_manager.dart FIRST — match by PURPOSE, not just hex
- Close-match → use existing, DON'T create new
- Truly new → add with GENERIC name (never screen-prefixed like loginPrimary)

Font Size Adjustment (إلزامي):
- Figma ≤ 13sp (10, 11, 12, 13) → KEEP AS-IS — لا تقلل النصوص الصغيرة
- Figma 14-18sp → reduce by 1-2sp | Figma >= 20sp → reduce by 2sp

RTL Conversion (إلزامي):
- Figma RIGHT = Flutter "start" → CrossAxisAlignment.start, AlignmentDirectional.centerStart, PositionedDirectional(start:), paddingStart
- Figma LEFT = Flutter "end" → CrossAxisAlignment.end, AlignmentDirectional.centerEnd, PositionedDirectional(end:), paddingEnd
- Row: RIGHT element = FIRST child, LEFT element = LAST child
- NEVER: Positioned(left:/right:), Align(centerLeft/Right), EdgeInsets.only(left/right:), TextAlign.left, Directionality on layouts (exception: single Text widget fix inside complex components)

══════════════════════════════════════════════════════════════
STEP 4 — API SOURCE — SKIP IF UI_ONLY MODE
══════════════════════════════════════════════════════════════

**If UI_ONLY mode:** Skip STEP 4 + STEP 5 entirely.

---

### Path A: EXISTING_POSTMAN (عندي Postman جاهز)

> المستخدم عنده Postman Collection جاهزة — اقرأها ونفّذها.

- Read full request/response schema from the provided Postman Collection
- Check pagination → PaginatedCubit + PaginatedListWidget if yes
- Check actions (delete/update/toggle) → plan local state update (NEVER re-fetch):
  - Add: insert at index 0 → setData([newItem, ...(lastData ?? const [])])
  - Edit: map + replace → (lastData ?? const []).map((e) => e.id == id ? updated : e).toList()
  - Delete: removeWhere → state.data..removeWhere((e) => e.id == id)
- One cubit per endpoint — never merge
- Entity safety: factory initial(), fromJson with ?? defaults, tryParse only (never parse)

→ **بعد ما تخلص، روح STEP 6 (Plan)**

---

### Path B: AUTO_GENERATE (ولّدلي الـ API من Figma)

> مفيش Postman — هنولّد كل حاجة أوتوماتيك من شاشات Figma باستخدام `api-design` skill.

**Phase 1: Analyze & Design**

1. Analyze the Figma screens → extract required services using extraction rules:
   - Multi-section screen → separate service per section
   - List screens → pagination required
   - Multi-step forms → validate-step-{n} per step + final create
   - File uploads → separate `upload-file` service
   - CRUD → 5 standard services (list/detail/create/update/delete)

2. Design endpoints (naming, method, URL structure, unified entities)

3. **عرض التحليل على المستخدم والانتظار للموافقة قبل التوليد:**
   - عدد الـ services المستخرجة
   - كل endpoint: method + URL + وصف
   - الـ entities الموحدة وحقولها

**Phase 2: Generate (بعد الموافقة)**

4. Generate endpoints into **ONE single Postman Collection** `postman/app_name.postman_collection.json`:
   - Add endpoints as a **folder** inside the existing collection (Auth, Products, Settings, Shared, etc.)
   - If collection doesn't exist → create it with all folders
   - If collection exists → add/update the relevant folder only
   - Unified response format: `{status, code, message, data?}`
   - Arabic messages for all responses
   - Success + Error response examples for every endpoint
   - Unified entities (same shape everywhere)
   - **❌ NEVER create separate files** like `auth.postman_collection.json`, `products.postman_collection.json`

5. Add endpoints to `ApiConstants`

6. Create entities with `factory initial()` + safe `fromJson`

7. Create cubits with `execute` (AsyncCubit) or `fetchPageData` override (PaginatedCubit)

→ **بعد ما تخلص، روح STEP 6 (Plan) — الـ entities والـ cubits جاهزين، فالـ plan هيركز على الـ UI**

**⚠️ API Design Rules (لازم تتبع في الـ Postman generation):**
- Pagination key: `data.pagination` (NOT `data.meta`)
- Body mode: `urlencoded` for text, `formdata` for files, `raw JSON` for complex nested only
- Boolean values: integer `1`/`0` in responses, string `"1"`/`"0"` in requests
- Validation errors: `data.items.{field}: [errors]` (NOT `errors.{field}`)
- All success = HTTP 200 (no 201, 204)
- Status/enum fields: rich objects `{value, text_ar, text_en, tag_color}` (NOT plain strings)
- Emoji-commented JSON body sections (👤📱🎂🌍🏦📄🔐)
- Every endpoint: Figma link(s) + Arabic description
- Response examples: scenario-based names (`success first step`, `fail validation`, `empty response`)

---

══════════════════════════════════════════════════════════════
STEP 5 — (RESERVED — merged into STEP 4 paths above)
══════════════════════════════════════════════════════════════

> **This step is now handled within STEP 4 Path A and Path B above.**
> Proceed directly to STEP 6.

══════════════════════════════════════════════════════════════
STEP 6 — PLAN BEFORE CODING (انتظر الموافقة)
══════════════════════════════════════════════════════════════

Show me:
1. Feature folder structure (each section/card in separate widget file — NOT methods in body)
2. Entity fields with fromJson types
3. List of cubits (one per endpoint) — each with // Registered in Module (e.g., Bind.factory)
4. New AppColors/AppSizes needed (justify why existing ones don't match)
5. New locale keys needed
6. Scaffold type per screen (DefaultScaffold / plain Scaffold+SafeArea / Home custom)
7. CRUD local update plan (how add/edit/delete will update state locally)
8. Shared widgets — any card/component from existing features → plan to reuse or move to app_shared/
9. Isolate needed? (4+ concurrent services → yes)

Wait for my approval before writing code.

══════════════════════════════════════════════════════════════
STEP 7 — IMPLEMENT
══════════════════════════════════════════════════════════════

Structure (Clean Architecture — لكل feature):
- Every presentation file: `part of '../imports/<feature>_imports.dart';` (الاسم يتغير بحسب الـ feature — مثل `products_imports.dart`).
- `<feature>_imports.dart`: all external imports + part declarations (cubits → controllers → view → body → section widgets → card widgets).
- Feature folder layout:
  ```
  features/<feature>/
  ├── data/{datasources, models, mappers, repositories}/
  ├── domain/{datasources, entities, enums, repositories, usecases}/
  └── presentation/
      ├── imports/<feature>_imports.dart
      ├── cubits/<feature>_cubit.dart                  (AsyncCubit<T> — server state)
      ├── controllers/<feature>_view_controller.dart   (TextEditingController, ValueNotifier, etc.)
      ├── view/<feature>_screen.dart                   (Screen — wires cubit + ViewController)
      └── widgets/                                     (private `_X` widgets)
  ```
- The Cubit depends on **UseCases** (`domain/usecases/`) — never on `BaseRemoteSource` directly.

Widget Splitting (إلزامي):
- Body widget = layout ONLY — assembles sections
- Each section / card / component in a SEPARATE file inside widgets/
- NO `_buildXxx()` methods returning 10+ lines in body files
- Each widget file added as `part` in <feature>_imports.dart

Widget Reuse (إلزامي):
- Before creating ANY widget → search app_shared/widgets/ AND existing features (especially recent screens)
- Same design 100% → reuse directly
- Minor differences → add optional params to existing widget (don't create a copy)
- Used in 2+ features → move to app_shared/widgets/
- NEVER duplicate card widgets across features

Entity (in `domain/entities/`):
- factory initial() with sensible defaults — for Skeletonizer placeholders
- The Entity is **pure Dart** — no Map, no JSON, no Dio. The UI sees Entities only.
- All JSON parsing happens in the **Model** (`data/models/<entity>_model.dart`):
  - String ?? '', int/double ?? 0 + tryParse, bool ?? false, List ?? [], nullable → no ??
  - NEVER int.parse() / double.parse() → ONLY tryParse with fallback
- The **Mapper** (`data/mappers/<entity>_mapper.dart`) does Model → Entity. Keep it pure.

State:
- **AsyncCubit<T>** (in `core/state/async/`) for fetched data — extends `AsyncCubit<T>`, takes **UseCases** in the constructor (`// Registered in Module (e.g., Bind.factory)`).
- `execute(() => _useCase(...))` — emits AsyncLoading → AsyncSuccess/AsyncFailure by folding `Either<Failure, T>`.
- `setData(T)` / `setFailure(Failure)` for local updates (no API call).
- `lastData` holds the last successful payload across loading/failure states.
- AsyncState is **sealed**: `AsyncInitial / AsyncLoading(previous) / AsyncSuccess(data) / AsyncFailure(failure, previous)` — pattern-match exhaustively or use `AsyncBlocBuilder`.
- One cubit per resource (list/detail). CRUD does **optimistic local updates** with `setData` + rollback on failure — NEVER re-fetch.
- **PaginatedAsyncCubit<T>** (in `core/state/paginated/`) if pagination.
- Heavy screens (4+ services): use `compute()` for JSON parsing.

API/network (every endpoint):
- DataSource extends `BaseRemoteSource` and calls `request<T>(method, endpoint, ..., fromJson)` — returns `Either<Failure, T>`.
- The Cubit takes **UseCases**, never `BaseRemoteSource` or `Repository` directly.
- `ApiEndpoints` is the only place URL paths live.
- Interceptor order (already wired in `DioClient`): Locale → Auth → Retry → AppCache → Logging (debug).
- Multipart uploads: `asFormData: true` on `request<T>(...)`.

Scaffold:
- Inner screens → DefaultScaffold(title, body) — NEVER build custom header in body
- Auth screens → plain Scaffold + SafeArea + Helpers.changeStatusbarColor(scaffoldBackground, dark)
- Home → custom Scaffold + CustomNavigationBar + Helpers.changeStatusbarColor(loginPrimary, light)

UI — Core Widgets (use these, do NOT create from scratch):
- Buttons: LoadingButton (async submit), DefaultButton (simple)
- Fields: CustomTextFiled (label + validator + inputFormatters), DefaultTextField (raw, for search bars)
- Dropdown: AppDropdown<T>
- State: AsyncBlocBuilder / AsyncSliverBlocBuilder / PaginatedListWidget
- Images: CachedImage for ALL network images — NEVER Image.network()
- Icons: IconWidget(icon: AppAssets.xxx.path) — never Icons.* — check icon bg before wrapping
- Icon inside Container with background → always wrap icon in Center widget
- Dialogs: successDialog, showCustomDialog, showDefaultBottomSheet
- Messages: MessageUtils.showSnackBar
- Empty: EmptyWidget (full-screen only) | SizedBox.shrink() (multi-section empty)

Search Fields (if Figma has search bar):
- MUST be real DefaultTextField — NEVER static Container + Text
- Debounce: rxdart PublishSubject + debounceTime(500ms) + .distinct()
- StatefulWidget for controller + subscription lifecycle (dispose all in dispose())

Scroll Performance:
- Multi-section → CustomScrollView + Slivers (NEVER SingleChildScrollView + nested ListView)
- shrinkWrap: true on nested lists = FORBIDDEN
- Static → .toSliver() | Lists → SliverList.builder | Grids → SliverGrid.builder
- Multi-API → AsyncSliverBlocBuilder per section
- Sliver sections: widget returns Box (Column, etc.) and parent uses .toSliver() once — never double-wrap

Body Widget Pattern:
- RefreshIndicator MANDATORY on ALL data screens + AlwaysScrollableScrollPhysics
- Empty sections in multi-section → SizedBox.shrink() (NOT EmptyWidget)
- Skeleton: Entity.initial() for Skeletonizer

ViewController Pattern (إلزامي — ممنوع خرقها):
- **Location:** `presentation/cubit/<feature>_view_controller.dart` — part of `<feature>_imports.dart`.
- **ممنوع** وضع Controller أو ValueNotifier داخل الـ View — لازم في ViewController class.
- All `TextEditingController`, `ValueNotifier`, `AnimationController`, `ScrollController`, `FocusNode` → inside ViewController class ONLY.
- All small UI-only handlers (clear, toggle, setFilter) → inside ViewController.
- View uses ONE ViewController object → ينشئه في `initState` ويـ `dispose` منه في `dispose`.
- Use `ValueNotifier` + `ValueListenableBuilder` instead of `setState` — الافتراضي.
- ViewController provides `dispose()` for all controllers/notifiers/focus-nodes.
- The Screen is typically `StatefulWidget` to own this lifecycle (cubit + ViewController + subscriptions).
- Server data stays in the **Cubit**, ephemeral UI state in the **ViewController** — never mix.

Forms:
- Params class MUST use `with FormMixin`
- Submit MUST use `params.validateAndScroll()`
- Every field: validator from Validators + inputFormatters from core/helpers
- Number/phone: ArabicNumbersFormatter + .toEnglishNumbers() before API calls

RTL (every screen):
- Column text: CrossAxisAlignment.start (aligns right)
- Row: RIGHT = first child, LEFT = last child
- Align: AlignmentDirectional.centerStart (right), centerEnd (left)
- Stack: PositionedDirectional(start:) for right, (end:) for left
- Padding/Margin: paddingStart/End — never Left/Right
- NEVER: Positioned(left/right), Directionality on layouts, TextAlign.left (Directionality exception: single Text widget fix inside complex components like Slider/DropdownButton)

Values:
- Colors: AppColors only — reuse by purpose first, generic names only
- Sizes: AppSize/AppPadding/AppMargin/AppCircular — never raw numbers
- Text: const TextStyle().setMainTextColor.s14.medium — font ≤13sp keep as-is, 14+ reduce per rule
- Spacing: 12.szH, 16.szW — NEVER SizedBox(height/width:) | Text: LocaleKeys.xxx.tr() only
- Padding: .paddingAll(), .paddingStart() extensions — NEVER Padding(...) widget
- Margin: .marginAll(), .marginStart() extensions
- const: add to EVERY widget/constructor that can be const
- Navigation: Modular.to.push/pop/navigate/pushReplacement — never Navigator.push
- API: ApiEndpoints.xxx — never raw URL strings (skip if UI_ONLY)
- Models: status/color/label mappers in entity/ — NEVER helper methods inside widget
- Imports: delete ALL unused imports | Parameters: remove unused optional params
- Dropdown API: isolate BlocBuilder on the dropdown itself, not wrapping whole screen

══════════════════════════════════════════════════════════════
STEP 8 — VERIFY
══════════════════════════════════════════════════════════════

1. Run: `flutter analyze` — zero errors/warnings
2. Run: `dart run generate/strings/main.dart` (if locale keys added)
3. Run: `dart run build_runner build` (if new // Registered in Module (e.g., Bind.factory) cubit added)
4. RTL visual check: titles/labels on RIGHT, sections match Figma screenshot
5. No raw Color(), Icons.*, SizedBox(N), hardcoded text — all from AppColors/AppAssets/AppSize/LocaleKeys
6. Every entity: factory initial() + fromJson with ?? + tryParse only
7. Scaffold correct per screen + status bar synced
8. Font sizes ≤13sp kept as-is, 14+ reduced from Figma | Screen body padding > 12px reduced 2-4px
9. Colors reused by purpose | Icon backgrounds checked (no double-bg) | Icon SIZES match Figma exactly
10. All network images → CachedImage | Search fields → real DefaultTextField + debounce
11. Card CONTENT verified RTL: titles RIGHT, icon+text rows correct order, every Column has CrossAxisAlignment.start
12. CRUD: local updates only (no re-fetch) | RefreshIndicator on all data screens
13. Multi-section → CustomScrollView + Slivers (no shrinkWrap nested lists) | Sliver sections: no double-wrap with .toSliver()
14. Widget splitting: body = layout only, each section in separate file
15. Widget reuse: no duplicate cards across features, shared moved to app_shared/
16. Forms: FormMixin + validateAndScroll() + ArabicNumbersFormatter + .toEnglishNumbers()
17. Controllers/subscriptions disposed | No print()/debugPrint() in final code
18. DI: // Registered in Module (e.g., Bind.factory) + Modular.get<T>() | Access modifiers: private _ for internal
19. Pre-delivery checklist from `feature-development` skill PHASE 7 — all items passed
20. Run `/post-feature-review` skill — fix any critical/high issues found
