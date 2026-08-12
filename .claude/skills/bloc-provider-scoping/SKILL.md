---
name: bloc-provider-scoping
description: BlocProvider scoping rules — where to provide cubits, single vs multi, shared vs isolated, and common mistakes in Flutter_Base.
---

# Skill: BlocProvider Scoping Rules

## When to Use

- عند إضافة BlocProvider لشاشة جديدة
- عند الحيرة: أوفر الـ cubit فين؟ في الـ screen ولا فوقيها؟
- عند مشاركة cubit بين أكتر من شاشة
- عند ظهور أخطاء "Could not find" أو "BlocProvider.of() called with a context that does not contain"

---

## Rule #1: Every Screen Creates Its Own BlocProvider

> **كل شاشة بتتعمل push ليها عن طريق `Modular.to.pushNamed()` لازم تنشئ الـ BlocProvider بتاعها بنفسها.**
> **ممنوع تعتمد على BlocProvider من شاشة قبلها — الـ context بيتقطع مع `Modular.to.pushNamed()`.**

```dart
// CORRECT — Screen creates its own BlocProvider
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<ProductDetailCubit>()..fetchProduct(product.id),
      child: DefaultScaffold(
        title: product.name,
        body: _ProductDetailBody(product: product),
      ),
    );
  }
}

// WRONG — Assuming cubit is available from previous screen's context
class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This CRASHES — ProductDetailCubit was never provided in this route!
    return AsyncBlocBuilder<ProductDetailCubit, ProductEntity>(
      builder: (ctx, product) => /* ... */,
    );
  }
}
```

---

## Rule #2: Cubit Lifecycle = Screen Lifecycle

```dart
// DEFAULT: cubit created + disposed with screen
BlocProvider(
  create: (_) => Modular.get<MyCubit>()..fetch(),
  child: const MyScreen(),
)

// EXCEPTION: Sharing existing cubit (already created elsewhere)
BlocProvider.value(
  value: existingCubitInstance,
  child: const ChildScreen(),
)
```

**Warning:** `BlocProvider.value` does NOT dispose the cubit.

---

## Rule #3: Single API = Single BlocProvider

```dart
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<NotificationsCubit>()..fetchInitialData(),
      child: DefaultScaffold(
        title: LocaleKeys.notifications.tr(),
        body: const _NotificationsBody(),
      ),
    );
  }
}
```

---

## Rule #4: Multiple APIs = MultiBlocProvider

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => Modular.get<BannersCubit>()..fetchBanners()),
        BlocProvider(create: (_) => Modular.get<CategoriesCubit>()..fetchCategories()),
        BlocProvider(create: (_) => Modular.get<ProductsCubit>()..fetchProducts()),
      ],
      child: DefaultScaffold(
        title: LocaleKeys.home.tr(),
        body: const _HomeBody(),
      ),
    );
  }
}
```

---

## Rule #5: Action Cubits — NO ..fetch()

```dart
MultiBlocProvider(
  providers: [
    // Data cubits — fetch on create
    BlocProvider(create: (_) => Modular.get<ProductDetailCubit>()..fetchProduct(id)),

    // Action cubits — NO fetch, just create
    BlocProvider(create: (_) => Modular.get<DeleteProductCubit>()),
    BlocProvider(create: (_) => Modular.get<ToggleFavoriteCubit>()),
  ],
  child: /* ... */,
)
```

---

## Rule #6: Dropdown/Widget-Level BlocProvider (Isolated)

> **Dropdown أو widget صغير بيجيب data من API → الـ BlocProvider يكون داخل الـ widget نفسه.**

```dart
// CORRECT — Isolated BlocProvider inside the widget
class _CityDropdown extends StatelessWidget {
  const _CityDropdown({required this.onChanged});
  final ValueChanged<CityEntity?> onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<GetCitiesCubit>()..fetchCities(),
      child: AsyncBlocBuilder<GetCitiesCubit, List<CityEntity>>(
        builder: (ctx, cities) => AppDropdown<CityEntity>(
          items: cities,
          label: LocaleKeys.city.tr(),
          itemAsString: (c) => c.name,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// WRONG — Providing at screen level for a dropdown
// If cities API fails → entire screen shows error
```

---

## Rule #7: Tab Screens — Provide ABOVE IndexedStack

```dart
class _HomeTabsScreenState extends State<HomeTabsScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => Modular.get<HomeCubit>()..fetchHome()),
        BlocProvider(create: (_) => Modular.get<OrdersCubit>()..fetchOrders()),
        BlocProvider(create: (_) => Modular.get<ProfileCubit>()..fetchProfile()),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [HomeTab(), OrdersTab(), ProfileTab()],
        ),
        bottomNavigationBar: /* ... */,
      ),
    );
  }
}
```

---

## Rule #8: BlocListener Placement

> **`BlocListener` يكون أقرب ما يمكن للـ widget اللي بيستخدمه.**

```dart
// CORRECT — BlocListener wraps only the relevant part
class _ProductDetailBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteProductCubit, AsyncState<BaseModel?>>(
      listener: (context, state) {
        if (state is AsyncSuccess) Modular.to.pop(true);
      },
      child: /* body content */,
    );
  }
}
```

---

## Common Scoping Mistakes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| No BlocProvider in pushed screen | "Could not find X" crash | Add BlocProvider in screen's build |
| Using `context.read<X>()` before Provider | "X not found" at runtime | Ensure read is under BlocProvider widget tree |
| Providing action cubit with `..fetch()` | Unnecessary API call on screen load | Remove `..fetch()` from action cubits |
| All cubits at top level | Single API failure kills entire UI | Isolate dropdown/widget cubits inside the widget |
| BlocProvider.value without manual dispose | Memory leak | Dispose the cubit manually when its owner disposes |
| Sharing cubit between Modular.to.pushNamed() routes | Context breaks between routes | Each pushed screen creates its own BlocProvider |

---

## Decision Tree

```
Need a cubit?
│
├── Is it for fetching screen data?
│   ├── Single API → BlocProvider(create: _ => Modular.get<X>()..fetch())
│   └── Multiple APIs → MultiBlocProvider with all data cubits
│
├── Is it for an action (submit/delete/toggle)?
│   └── BlocProvider(create: _ => Modular.get<X>()) — NO ..fetch()
│
├── Is it for a small widget (dropdown/badge)?
│   └── BlocProvider INSIDE the widget itself — isolated
│
├── Is it for tab navigation?
│   └── MultiBlocProvider ABOVE IndexedStack
│
└── Do I need to share it between screens?
    ├── Between pushed screens (Go.to) → DON'T share. Use back-with-result instead
    └── Between parent and children in same tree → BlocProvider.value
```

---

## Scoping Checklist

- [ ] Every pushed screen has its own BlocProvider(s)
- [ ] Data cubits use `..fetch()` in create, action cubits don't
- [ ] MultiBlocProvider for 2+ cubits on same screen
- [ ] Dropdown/widget cubits are isolated inside the widget
- [ ] Tab cubits provided above IndexedStack
- [ ] BlocListener placed near the widget that uses it
- [ ] No `BlocProvider.value` across Modular.to.pushNamed() navigation boundaries
- [ ] `build_runner` ran after adding any new `// Registered in Module (e.g., Bind.factory)` cubit
