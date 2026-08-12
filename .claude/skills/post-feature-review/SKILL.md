---
name: post-feature-review
description: Automatic code review after completing any feature — finds and fixes critical issues, architecture violations, and quality gaps.
disable-model-invocation: true
---

# Skill: Post-Feature Code Review

## When to Use

- **تلقائياً** بعد الانتهاء من أي feature أو screen جديدة.
- عند طلب المستخدم review على كود موجود.
- قبل عمل commit أو PR.

## Review Process

اعمل Review على **كل الملفات اللي اتعدلت أو اتضافت** في الـ feature.
لكل ملف، طبّق الـ checks الآتية بالترتيب.

---

## 1. Critical Issues (Must Fix — يوقف التسليم)

### 1.1 Crashes & Exceptions
- [ ] `int.parse()` / `double.parse()` → لازم `tryParse` فقط
- [ ] `fromJson` بدون `??` defaults → crash على null response
- [ ] Entity بدون `factory initial()` → Skeletonizer crash
- [ ] Force unwrap `!` على nullable بدون check
- [ ] Missing null checks على API response fields
- [ ] `as List` casting بدون type check

### 1.2 Data Loss & State Bugs
- [ ] Re-fetch بعد add/edit/delete بدل local update → **FORBIDDEN**
- [ ] State مش بيترجع لـ initial عند dispose
- [ ] Stream/Subscription بدون cancel في dispose
- [ ] TextEditingController بدون dispose

### 1.3 Security
- [ ] Hardcoded API keys أو tokens
- [ ] Sensitive data في logs (`print()` أو `debugPrint()`)
- [ ] SQL injection أو XSS في user input بدون sanitization

---

## 2. Architecture Compliance

### 2.1 Clean Architecture Layers
- [ ] Dio / HTTP مستخدم في presentation → **FORBIDDEN** (data layer فقط)
- [ ] `BuildContext` مستخدم في cubit أو domain → **FORBIDDEN**
- [ ] Hardcoded endpoint string بدل `ApiEndpoints.xxx` → **FORBIDDEN**
- [ ] Manual construction لـ repos/usecases في UI بدل `Modular.get<T>()`

### 2.2 Part-of System
- [ ] كل ملف في الـ feature فيه `part of '../imports/<feature>_imports.dart'`
- [ ] كل ملف جديد مضاف كـ `part` في `<feature>_imports.dart`

### 2.3 DI & Injectable
- [ ] كل Cubit معلّم بـ `// Registered in Module (e.g., Bind.factory)`
- [ ] Screen تستخدم `Modular.get<MyCubit>()` داخل `BlocProvider`
- [ ] تم تشغيل `build_runner` بعد إضافة injectable جديد

### 2.4 Feature Structure
- [ ] Entity في `entity/` folder
- [ ] Cubits في `presentation/cubit/`
- [ ] Screen في `presentation/pages/`
- [ ] Widgets في `presentation/widgets/`
- [ ] Imports في `presentation/imports/<feature>_imports.dart`

---

## 3. State Management

### 3.1 Cubit Patterns
- [ ] One cubit per endpoint (مش cubit واحد لـ endpoints كتير)
- [ ] `AsyncCubit<T>` لـ API calls مع `executeAsync()`
- [ ] `PaginatedCubit<T>` لـ paginated lists
- [ ] CRUD: local update (insert at 0 / copyWith / removeWhere)

### 3.2 ViewController Pattern (MANDATORY — ممنوع خرقها)
- [ ] **ممنوع** وضع Controller أو ValueNotifier داخل الـ View/State — لازم في ViewController class
- [ ] UI controllers/notifiers (TextEditingController, ValueNotifier, ScrollController, etc.) في `ViewController` class منفصل فقط
- [ ] كل handlers (onSend, selectTab, onSearch) داخل ViewController
- [ ] الـ View تستدعي الـ ViewController object بس — `_vc.xxx`
- [ ] `ValueNotifier` + `ValueListenableBuilder` بدل `setState`
- [ ] ViewController يعمل dispose لكل الـ controllers/notifiers

### 3.3 BlocListener Usage
- [ ] Navigation بعد success → `BlocListener` مش داخل `builder`
- [ ] SnackBar/Dialog → `BlocListener` مش `BlocBuilder`
- [ ] لا يوجد side effects داخل `build()` method

---

## 4. Widget Quality

### 4.1 Widget Splitting (MANDATORY)
- [ ] Body widget = layout فقط (يجمع sections)
- [ ] لا يوجد `_buildXxx()` methods أكثر من 10 أسطر في body
- [ ] كل section/card/component في ملف منفصل
- [ ] `build()` method أقل من 50 سطر

### 4.2 Widget Reuse
- [ ] تم البحث في `app_shared/widgets/` قبل إنشاء widget جديد
- [ ] لا يوجد widgets مكررة بين features
- [ ] Shared widget → `app_shared/widgets/`
- [ ] فروقات بسيطة → optional params بدل widget جديد

### 4.3 Core Widget Usage
- [ ] `LoadingButton` لـ async submit (مش `ElevatedButton`)
- [ ] `DefaultTextField` / `CustomTextFiled` لـ inputs
- [ ] `AsyncBlocBuilder` / `AsyncSliverBlocBuilder` لـ API state
- [ ] `CachedImage` لـ network images (مش `Image.network`)
- [ ] `IconWidget` لـ icons (مش `Icons.*` أو `Icon()`)
- [ ] `DefaultScaffold` لـ inner screens
- [ ] `Modular.to.pushNamed()` / `Modular.to.pop()` لـ navigation (مش `Navigator.push`)
- [ ] `MessageUtils.showSnackBar` لـ messages

### 4.4 Scaffold & Status Bar
- [ ] Inner screen → `DefaultScaffold`
- [ ] Auth screen → `Scaffold` + `SafeArea` + manual status bar
- [ ] Status bar color matches header (dark header → light icons)

### 4.5 Clean Code Quality
- [ ] لا يوجد unused imports — تم تشغيل `flutter analyze`
- [ ] لا يوجد unused optional parameters — "A value for optional parameter isn't ever given" = 0
- [ ] `const` مضاف على كل widget/constructor ممكن يكون const
- [ ] Spacing: `.szH`/`.szW` فقط — لا يوجد `SizedBox(height:)` أو `SizedBox(width:)`
- [ ] Padding: `.paddingAll()`, `.paddingStart()` extensions — لا يوجد `Padding(...)` widget
- [ ] Helper methods (status→color, status→label) في entity/model — مش جوا widget class
- [ ] Dropdown/small widget API: `BlocBuilder` على الـ widget نفسه — مش wrapping كل الشاشة
- [ ] Inner screen → `DefaultScaffold`
- [ ] Auth screen → `Scaffold` + `SafeArea` + manual status bar
- [ ] Status bar color matches header (dark header → light icons)

---

## 5. RTL Compliance

### 5.1 Forbidden APIs
- [ ] لا يوجد `Directionality` widget على layouts — **ممنوع على الشاشات والأقسام** (التطبيق RTL من MaterialApp). الاستثناء الوحيد: لف Text/RichText واحد لإصلاح نص معكوس داخل components معقدة (مثل Slider/DropdownButton)
- [ ] لا يوجد `Row(textDirection: ...)` — غير ضروري
- [ ] لا يوجد `Positioned(left/right:)` → `PositionedDirectional(start/end:)`
- [ ] لا يوجد `Alignment.centerLeft/Right` → `AlignmentDirectional.centerStart/End`
- [ ] لا يوجد `EdgeInsets.only(left/right:)` → `EdgeInsetsDirectional.only(start/end:)`
- [ ] لا يوجد `TextAlign.left` → `TextAlign.start`

### 5.2 Layout Direction
- [ ] `CrossAxisAlignment.start` = physical RIGHT (Arabic side)
- [ ] Row: أول child = physical RIGHT, آخر child = physical LEFT
- [ ] `Figma RIGHT` = `Flutter start` = physical RIGHT
- [ ] `Figma LEFT` = `Flutter end` = physical LEFT

### 5.3 Figma MCP RTL Verification (CRITICAL)
> الـ Figma MCP بيقرأ الـ layout من اليسار لليمين وممكن يعكس ترتيب العناصر.
> لازم تتحقق من كل section ضد الـ screenshot الحقيقي.

- [ ] تم مقارنة ترتيب العناصر مع الـ Figma screenshot (مش MCP data بس)
- [ ] Arabic text يبدأ من اليمين في الـ output
- [ ] Horizontal lists/tabs تبدأ من اليمين
- [ ] Card images في المكان الصح (يطابق الـ screenshot)
- [ ] **لو الـ MCP data تناقض الـ screenshot → الـ screenshot هو الصح**

---

## 6. Forms & Validation

- [ ] `FormMixin` مستخدم لأي form
- [ ] `params.validateAndScroll()` قبل submit
- [ ] `Validators.*` لـ validation rules
- [ ] `InputFormatters.*` لـ input formatting
- [ ] `.toEnglishNumbers()` لأي input رقمي
- [ ] `LoadingButton` لـ submit button (يمنع double tap)

---

## 7. Error Handling

- [ ] `AsyncBlocBuilder` يعرض loading/error/success تلقائياً
- [ ] Error state فيه retry button (`ErrorView(error, onRetry)`)
- [ ] `setError(showToast: true)` لـ CRUD failures
- [ ] Network errors handled gracefully (مش crash)
- [ ] Empty state: single-service → `EmptyWidget`, multi-section → `SizedBox.shrink()`

---

## 8. Performance & Memory

### 8.1 Memory Leaks
- [ ] كل `TextEditingController` فيه `dispose()`
- [ ] كل `StreamSubscription` فيه `cancel()` في dispose
- [ ] كل `PublishSubject` فيه `close()` في dispose
- [ ] كل `ScrollController` / `TabController` / `AnimationController` فيه dispose
- [ ] ViewController يعمل dispose لكل resources

### 8.2 Performance
- [ ] `const` constructors حيثما أمكن
- [ ] لا يوجد `shrinkWrap: true` في lists كبيرة → استخدم Slivers
- [ ] `RefreshIndicator` على كل data screen
- [ ] `AlwaysScrollableScrollPhysics()` مع RefreshIndicator
- [ ] Heavy screens (4+ APIs) → `compute()` for JSON parsing

### 8.3 Lists
- [ ] `ListView.builder` / `SliverList` لـ dynamic lists (مش `Column` + `map`)
- [ ] `itemExtent` أو `prototypeItem` لـ uniform lists (أسرع)
- [ ] `const` على static items داخل lists

---

## 9. Design Token Compliance

- [ ] لا يوجد raw `Color(0xFF...)` → `AppColors.xxx`
- [ ] لا يوجد raw numbers → `AppSize`, `AppPadding`, `AppMargin`, `AppCircular`
- [ ] لا يوجد raw `TextStyle()` → `context.textTheme.xxx` + extensions
- [ ] Font sizes reduced 1-2sp from Figma
- [ ] Body padding > 12px reduced 2-4px from Figma
- [ ] Font weight قد تحتاج تقليل لو أثقل من التصميم

---

## 10. Localization

- [ ] لا يوجد hardcoded Arabic/English strings
- [ ] كل text يستخدم `LocaleKeys.xxx.tr()`
- [ ] Keys مضافة في `lang.json` بـ snake_case
- [ ] تم تشغيل `dart run generate/strings/main.dart`

---

## 11. Search Fields (if applicable)

- [ ] Search bar = `DefaultTextField` (NOT Container + Text)
- [ ] `PublishSubject` + `debounceTime(500ms)` + `.distinct()`
- [ ] `StatefulWidget` لـ lifecycle management
- [ ] Dispose: controller + subscription + subject
- [ ] Cubit فيه `search()` method

---

## 12. Platform & Packages (if applicable)

- [ ] Camera/gallery/mic → Android+iOS config files updated
- [ ] Method channels preferred over `permission_handler`
- [ ] تم التحقق من الـ packages الموجودة قبل إضافة package جديد
- [ ] `pubspec.yaml` → package versions pinned

---

## Action Plan

### After Review:
1. **Critical Issues** → Fix immediately (لا يتم التسليم بدونها)
2. **Architecture Violations** → Fix immediately
3. **Widget Quality** → Fix (split, reuse, core widgets)
4. **RTL / Localization / Design Tokens** → Fix
5. **Performance / Memory** → Fix
6. **Minor improvements** → Fix if quick, note if not

### Output Format:
```
## Review Results: [Feature Name]

### Critical (must fix):
- [file:line] description → fix applied

### Architecture:
- [file:line] description → fix applied

### Quality:
- [file:line] description → fix applied

### RTL/i18n:
- [file:line] description → fix applied

### Performance:
- [file:line] description → fix applied

### Score: X/10
- 9-10: Production ready
- 7-8: Minor issues fixed
- 5-6: Significant fixes needed
- <5: Major rework needed
```

---

## Developer Assessment

بعد الـ review، قيّم:
- **Code Quality:** هل الكود نظيف ومنظم؟
- **Architecture:** هل يتبع Clean Architecture + Flutter_Base patterns؟
- **Error Handling:** هل كل الحالات متغطية؟
- **Performance:** هل في مشاكل memory أو performance؟
- **Completeness:** هل الـ feature كاملة بكل states (loading, error, empty, success)؟

**الهدف:** كل feature يطلع score 8+ قبل التسليم.
