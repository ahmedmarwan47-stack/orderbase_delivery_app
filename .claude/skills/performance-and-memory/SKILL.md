---
name: performance-and-memory
description: Performance tuning + memory/lifecycle checklist for Flutter_Base features.
---

## Performance & Memory — Core Rules

### 1. Const Everywhere Possible

- **Widgets**: استخدم `const` لكل widget لا يعتمد على state متغير.
- **Collections**: استخدم `const []`, `const {}` عندما تكون ثابتة.
- **Benefit**: يقلل rebuilds، ويحسن performance و memory.

```dart
// ✅ CORRECT
class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LocaleKeys.title.tr(), style: const TextStyle().setMainTextColor.s14.bold),
        8.szH,
        Text(LocaleKeys.subtitle.tr(), style: const TextStyle().setHintColor.s12.regular),
      ],
    );
  }
}

// ❌ WRONG
class _TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LocaleKeys.title.tr(), style: const TextStyle().setMainTextColor.s14.bold),
        SizedBox(height: 8.h),
        Text(LocaleKeys.subtitle.tr(), style: const TextStyle().setHintColor.s12.regular),
      ],
    );
  }
}
```

### 2. List & Grid Performance

- استخدم:
  - `ListView.builder` / `SliverList.builder`
  - `GridView.builder` / `SliverGrid.builder`
- **ممنوع**:
  - `ListView(children: [...])` لقوائم طويلة
  - `shrinkWrap: true` داخل `SingleChildScrollView` (إلا لو محتاج static-only)
  - Nested scrollables بدون `CustomScrollView + Slivers` (مغطي في `flutter-feature-development.mdc`)

قاعدة بسيطة:
- قائمة واحدة فقط → `ListView.builder` مباشرة.
- أكثر من قسم scrollable واحد → `CustomScrollView + Slivers` فقط.

### 3. Heavy JSON Parsing

- لو الشاشة فيها:
  - 4+ API calls متوازية
  - أو response كبير (20+ items مع nested objects)
  - أو user شكا من jank أثناء التحميل
- **استخدم** `compute()` أو isolate كما في `flutter-feature-development.mdc`.

### 4. Avoid Unnecessary Rebuilds

- افصل الـ widgets الكبيرة إلى:
  - Widgets صغيرة ذات مسؤولية واحدة.
  - استخدم `const` عليها قدر الإمكان.
- لو جزء من الشاشة فقط يتغير:
  - انقله إلى widget جديدة، ومرر له القيمة المتغيرة بدلاً من إعادة build كل الـ body.

```dart
// ✅ CORRECT — extract list item
class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.items});
  final List<OrderEntity> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => _OrderCard(item: items[i]),
    );
  }
}
```

---

## Memory & Lifecycle — No Leaks

### 5. Always Dispose Controllers

كل `StatefulWidget` عنده أي من الآتي **لازم** يعمل `dispose()`:

- `TextEditingController`
- `ScrollController`
- `AnimationController`
- `TabController`
- `FocusNode`
- أي `StreamSubscription`
- أي `PublishSubject` / `BehaviorSubject` (rxdart)

```dart
class _MyFormState extends State<_MyForm> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _animationController;
  final _searchSubject = PublishSubject<String>();
  late final StreamSubscription<String> _searchSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 500))
        .listen(_onSearch);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _searchSubscription.cancel();
    _searchSubject.close();
    super.dispose();
  }
}
```

### 6. mounted قبل setState بعد async

```dart
Future<void> _loadData() async {
  setState(() => _isLoading = true);
  final result = await repo.fetch();
  if (!mounted) return;
  setState(() {
    _isLoading = false;
    _data = result;
  });
}
```

### 7. Use Cubit/Bloc Instead of Keeping Heavy State in Widgets

- State المعقد (lists كبيرة، كائنات كثيرة) مكانها في Cubit/Bloc.
- الـ widget تحتفظ فقط بـ:
  - controllers الخاصة بالـ UI
  - selection الخفيف (tab index, expanded item id)

---

## Quick Checklist (Per Feature)

قبل التسليم تأكد من:

- **Const**
  - [ ] كل الـ widgets الثابتة معلّمة بـ `const`.
  - [ ] لا يوجد `new` في الكود.
- **Lists**
  - [ ] لا يوجد `ListView(children: ...)` لقوائم كبيرة.
  - [ ] لا يوجد `shrinkWrap: true` داخل `SingleChildScrollView` لقوائم بيانات.
  - [ ] الشاشات متعددة الأقسام تستخدم `CustomScrollView + Slivers`.
- **Heavy Work**
  - [ ] فكرت إذا الشاشة تحتاج `compute()` / isolate عند 4+ خدمات أو data كثيرة.
- **Lifecycle**
  - [ ] كل `TextEditingController` / `ScrollController` / `AnimationController` له `dispose()`.
  - [ ] كل `StreamSubscription` يتم `cancel` في `dispose()`.
  - [ ] كل `PublishSubject` / `BehaviorSubject` يتم `close()` في `dispose()`.
  - [ ] `mounted` مفحوص قبل أي `setState` بعد `await`.
