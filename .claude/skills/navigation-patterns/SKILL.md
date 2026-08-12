---
name: navigation-patterns
description: Navigation patterns for Flutter_Base — Modular.to.pushNamed() with arguments, back with result, refresh parent screen, named routes, and tab navigation.
---

# Skill: Navigation Patterns — Flutter_Base

## When to Use

- عند الانتقال بين شاشات
- عند تمرير بيانات (arguments) لشاشة جديدة
- عند العودة بنتيجة (back with result)
- عند الحاجة لتحديث الشاشة السابقة بعد action

---

## Navigation API — Quick Reference

| Action | Code | Notes |
|--------|------|-------|
| Push new screen | `Modular.to.pushNamed('/route')` | Or `Modular.to.push()` |
| Replace current | `Modular.to.pushReplacementNamed('/route')` | Removes current from stack |
| Clear all + push | `Modular.to.navigate('/route')` | Login → Home flow |
| Go back | `Modular.to.pop()` | Simple pop |
| Go back with result | `Modular.to.pop(result)` | Returns data to previous screen |
| Back to root | `Modular.to.popUntil((route) => route.isFirst)` | Pops to first route |
| Named route | `Modular.to.pushNamed(NamedRoutes.home)` | For registered routes |

---

## Pattern 1: Simple Navigation (No Arguments)

```dart
// Navigate to detail screen
GestureDetector(
  onTap: () => Modular.to.pushNamed('/about'),
  child: const _SettingsItem(title: LocaleKeys.about),
)
```

---

## Pattern 2: Navigation with Arguments

> **تمرير entity أو id للشاشة التالية.**

```dart
// From list → detail (pass entity as argument)
_ProductCard(
  product: product,
  onTap: () => Modular.to.pushNamed('/product-detail', arguments: product),
)

// Detail screen receives it via constructor
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<ProductDetailCubit>()..fetchProduct(product.id),
      child: DefaultScaffold(
        title: product.name,  // Show name immediately while loading full details
        body: _ProductDetailBody(product: product),
      ),
    );
  }
}
```

### What to pass as argument:

| Scenario | Pass | Why |
|----------|------|-----|
| List → Detail | Full entity OR just ID | Entity = instant title/image. ID only = lighter |
| List → Edit | Full entity | Pre-fill form fields immediately |
| Any → Create | Nothing (or parent ID) | New item, empty form |
| Filter → Result | Filter params object | Structured data |

---

## Pattern 3: Back with Result (CRITICAL)

> **لما شاشة تعمل action وتحتاج ترجع بالنتيجة للشاشة السابقة.**

### Scenario: Create screen → returns new item to list

```dart
// 1. CALLER: Navigate and await result
Future<void> _goToCreate(BuildContext context) async {
  final newProduct = await Modular.to.pushNamed<ProductEntity>('/create-product');
  if (newProduct != null) {
    // Update list locally — NEVER re-fetch
    context.read<ProductsCubit>().addProduct(newProduct);
  }
}

// 2. DESTINATION: Return result on success
// Inside CreateProductScreen's BlocListener:
BlocListener<CreateProductCubit, AsyncState<ProductEntity>>(
  listener: (context, state) {
    if (state is AsyncSuccess && state.data != null) {
      Modular.to.pop(state.data);  // ← Return the new entity to caller
    }
  },
  child: /* form body */,
)

// 3. CUBIT: Local update method in list cubit
class ProductsCubit extends AsyncCubit<List<ProductEntity>> {
  void addProduct(ProductEntity product) {
    setData([product, ...(lastData ?? const [])]);
  }
}
```

### Scenario: Edit screen → returns updated item

```dart
// CALLER
Future<void> _goToEdit(BuildContext context, ProductEntity product) async {
  final updated = await Modular.to.pushNamed<ProductEntity>('/edit-product', arguments: product);
  if (updated != null) {
    context.read<ProductsCubit>().updateProduct(updated);
  }
}

// DESTINATION: BlocListener
listener: (context, state) {
  if (state is AsyncSuccess && state.data != null) {
    Modular.to.pop(state.data);  // ← Return updated entity
  }
},

// CUBIT: Local update
void updateProduct(ProductEntity updated) {
  setData((lastData ?? const []).map((e) => e.id == updated.id ? updated : e).toList());
}
```

### Scenario: Delete from detail → notify list

```dart
// DETAIL SCREEN: After delete success
BlocListener<DeleteProductCubit, AsyncState<BaseModel?>>(
  listener: (context, state) {
    if (state is AsyncSuccess) {
      Modular.to.pop(true);  // ← Signal "item was deleted"
    }
  },
)

// CALLER: Handle delete signal
Future<void> _goToDetail(BuildContext context, ProductEntity product) async {
  final wasDeleted = await Modular.to.pushNamed<bool>('/product-detail', arguments: product);
  if (wasDeleted == true) {
    context.read<ProductsCubit>().removeProduct(product.id);
  }
}

// CUBIT
void removeProduct(String id) {
  setData((lastData ?? const []).where((e) => e.id != id).toList());
}
```

---

## Pattern 4: Refresh Parent Without Back-with-Result

> **بديل عن back with result لما الـ cubit مشترك بين الشاشات (مثلاً detail بيعدل على نفس الـ cubit).**
> **استخدم ده بس لو الـ cubit فعلاً shared عبر BlocProvider.value.**

```dart
// Parent provides cubit
BlocProvider(
  create: (_) => Modular.get<ProductsCubit>()..fetchProducts(),
  child: const ProductsScreen(),
)

// Child accesses SAME cubit instance via context
// (only works if child is under same BlocProvider tree)
context.read<ProductsCubit>().removeProduct(id);
Modular.to.pop();
```

**Warning:** This only works if both screens share the same BlocProvider ancestor.
For separate screens (pushed via `Modular.to.pushNamed`), use Pattern 3 (back with result).

---

## Pattern 5: Tab Navigation (BottomNavBar)

```dart
// Tab screens are NOT pushed — they're children of IndexedStack/PageView
class HomeTabsScreen extends StatefulWidget {
  @override
  State<HomeTabsScreen> createState() => _HomeTabsScreenState();
}

class _HomeTabsScreenState extends State<HomeTabsScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    HomeScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [/* ... */],
      ),
    );
  }
}
```

**Tab navigation rules:**
- Tab screens → `IndexedStack` (keeps state alive)
- Tab screens cubits → provide ABOVE the IndexedStack, in MultiBlocProvider
- Inner navigation (from tab screen) → normal `Modular.to.pushNamed()`

---

## Pattern 6: Replace Screen (Auth Flow)

```dart
// Login success → replace with Home (user can't go back to login)
BlocListener<LoginCubit, AsyncState<UserEntity>>(
  listener: (context, state) {
    if (state is AsyncSuccess) {
      Modular.to.navigate('/home');  // ← Clears entire stack
    }
  },
)

// Logout → replace with Login
Modular.to.navigate('/login');
```

---

## Transition Types

| Type | When to use |
|------|-------------|
| `TransitionType.slide` | Default — most navigations |
| `TransitionType.fade` | Detail screens, image preview |
| `TransitionType.scale` | Dialogs that open as full screen |
| `TransitionType.cupertino` | iOS-style back swipe needed |

---

## Navigation Checklist

- [ ] Arguments passed via constructor or route arguments `Modular.to.pushNamed('/route', arguments: arg)`
- [ ] Back-with-result used for create/edit/delete feedback
- [ ] Parent screen updates list locally (never re-fetches)
- [ ] `Modular.to.navigate` for auth transitions (login/logout)
- [ ] Tab screens use `IndexedStack` (not push/pop)
- [ ] No `Navigator.push` or `Navigator.pop` — always `Modular.to.pushNamed()` / `Modular.to.pop()`
