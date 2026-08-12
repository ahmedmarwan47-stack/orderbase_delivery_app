---
name: bloc-patterns
description: AsyncCubit templates, CRUD local updates, AsyncBlocBuilder, PaginatedCubit, and BlocListener patterns for Flutter_Base.
---

# Skill: BLoC/Cubit Patterns — Flutter_Base

## ⚠️ BlocConsumer / BlocListener — Strict Usage Rules (اقرأها أولاً)

> **القاعدة الذهبية: الافتراضي هو `BlocBuilder` / `AsyncBlocBuilder` فقط.**
> **`BlocListener` و `BlocConsumer` للضرورة القصوى — مش defaults.**
> **ده decision من Senior Flutter developer — مش style preference.**

### القاعدة العامة

| الموقف | استخدم | متى |
|--------|--------|-----|
| عرض state على UI (loading/success/error) | `AsyncBlocBuilder` / `BlocBuilder` | **الافتراضي — استخدمه دايماً** |
| Side effect مرة واحدة على state change (snackbar, dialog, navigation) | `BlocListener` | فقط لو فيه فعل خارجي عن الـ UI |
| محتاج تعرض UI **و** تعمل side effect على نفس الـ widget | `BlocListener` + `BlocBuilder` منفصلين (preferred) أو `BlocConsumer` كآخر حل | نادر — لو فعلاً مفيش طريقة تفصلهم |
| تعرض جزء صغير من state (مثلاً `data.count`) | `BlocSelector` | لو الـ rebuilds كتير وعايز تقللها |

### ❌ الـ Anti-patterns (ممنوع نهائياً)

```dart
// ❌ FORBIDDEN — لف الـ body كله في BlocConsumer "لمجرد الراحة"
BlocConsumer<MyCubit, AsyncState<MyData>>(
  listener: (ctx, state) {
    if (state is AsyncFailure) MessageUtils.showSnackBar(...);
  },
  builder: (ctx, state) => switch (state) {
    AsyncLoading() => const SkeletonView(),
    AsyncFailure() => const ErrorView(),
    AsyncSuccess(:final data) => _BodyContent(data: data),
    AsyncInitial() => const SizedBox.shrink(),
  },
)
// المشكلة: الـ AsyncBlocBuilder بيعمل نفس الـ build automatically،
// والـ BlocConsumer بيخلط بين concerns (UI + side effects)

// ❌ FORBIDDEN — BlocListener حول الـ Scaffold كله "احتياطاً"
BlocListener<UserCubit, UserState>(
  listener: (ctx, state) {
    if (state.user.isBlocked) Modular.to.navigate('/target'));
  },
  child: Scaffold(body: ...),
)
// ← لو ده محتاج، حطه في الـ root app — مش في كل screen

// ❌ FORBIDDEN — BlocListener بدون شرط على state
BlocListener<SubmitCubit, AsyncState<bool>>(
  listener: (ctx, state) {
    MessageUtils.showSnackBar(...);  // ← runs on EVERY state, including loading!
  },
  child: ...,
)
```

### ✅ الـ Patterns الصحيحة

```dart
// ✅ الافتراضي — AsyncBlocBuilder بيعمل كل حاجة
AsyncBlocBuilder<ProductsCubit, List<ProductEntity>>(
  onRetry: () => context.read<ProductsCubit>().fetchProducts(),
  loadingBuilder: (_) => const ProductsSkeleton(),                    // optional
  errorBuilder:   (_, Failure f) => _ProductsError(failure: f),       // optional
  builder: (ctx, products) => _ProductsList(products: products),
)

// ✅ BlocListener — لـ side effect واضح (navigation/snackbar/dialog)
BlocListener<SubmitCubit, AsyncState<bool>>(
  listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,    // sealed-state check
  listener: (ctx, state) {
    if (state is AsyncSuccess<bool>) {
      MessageUtils.showSnackBar(message: LocaleKeys.saved.tr(), baseStatus: BaseStatus.success);
      Modular.to.pop();
    }
    if (state is AsyncFailure<bool>) {
      MessageUtils.showSnackBar(message: state.failure.message, baseStatus: BaseStatus.error);
    }
  },
  child: LoadingButton(
    cubit: ctx.read<SubmitCubit>(),
    title: LocaleKeys.submit.tr(),
    onTap: () => ctx.read<SubmitCubit>().submit(params),
  ),
)

// ✅ BlocSelector — لو محتاج part من state بس
BlocSelector<CartCubit, AsyncState<CartEntity>, int>(
  selector: (state) => state is AsyncSuccess<CartEntity> ? state.data.itemCount : 0,
  builder: (_, count) => BadgeIconWidget(badgeCount: count, child: const _CartIcon()),
)

// ✅ Split listener + builder — أنضف من BlocConsumer
BlocListener<MyCubit, AsyncState<MyData>>(
  listenWhen: (p, c) => c is AsyncFailure && p is! AsyncFailure,       // only fire on new failures
  listener: (ctx, s) => _showError(ctx, (s as AsyncFailure).failure),
  child: AsyncBlocBuilder<MyCubit, MyData>(
    builder: (_, data) => _Body(data: data),
  ),
)
```

### Checklist قبل ما تكتب `BlocListener` / `BlocConsumer`

```
□ هل فيه side effect حقيقي (نavigation، snackbar، dialog، launch URL، analytics)؟
  - لو لا → استخدم BlocBuilder/AsyncBlocBuilder بس.
□ هل ممكن أحط الـ side effect ده في الـ cubit مباشرة؟ (mostly no — keep cubits pure)
□ هل ضفت `listenWhen` عشان مايتنفذش على كل state change؟
□ هل ممكن أستخدم LoadingButton بدلاً منه؟ (LoadingButton بيـ handle loading internally)
□ لو هتستخدم BlocConsumer — هل فعلاً محتاج الـ UI rebuild + side effect على نفس الـ widget؟
  - الأنضف غالباً: BlocListener منفصل + BlocBuilder منفصل
```

---

## Architecture Overview

All cubits that load/manage server data extend **`AsyncCubit<T>`** (from `core/state/async/async_cubit.dart`). The Cubit depends on **UseCases** (`domain/usecases/`) — **never on `BaseRemoteSource` or Repository directly**. This keeps the presentation layer testable and the dependency direction pointing inward.

```
View ── reads ──▶ Cubit ── calls ──▶ UseCase ── calls ──▶ Repository(interface) ◀── impl ── DataSource(extends BaseRemoteSource)
```

The cubit holds **server state only**. Ephemeral UI state (TextEditingControllers, ScrollControllers, ValueNotifiers, FocusNodes, selected filters, search text) lives in **`presentation/cubit/<feature>_view_controller.dart`** — never in the cubit. See `coding-standards` section 22 and `flutter-patterns`.

---

## AsyncCubit — Base Class API

```dart
abstract class AsyncCubit<T> extends Cubit<AsyncState<T>> {
  AsyncCubit() : super(const AsyncInitial());

  /// Last successful payload — kept across loading/error states so the UI can render
  /// the old data while refreshing.
  T? get lastData;

  /// Run an async call. Emits AsyncLoading(previous: lastData) → AsyncSuccess(data)
  /// or AsyncFailure(failure, previous: lastData) by folding the Either.
  /// `CancelledFailure` is silent (a newer call superseded this one).
  Future<void> execute(Future<Either<Failure, T>> Function() call);

  /// Local update without re-fetching (CRUD optimism). Emits AsyncSuccess(data).
  void setData(T data);

  /// Force a failure state (e.g. a validation error you composed locally).
  void setFailure(Failure failure);
}
```

## AsyncState<T> — Sealed (Exhaustive)

```dart
// core/state/async/async_state.dart
sealed class AsyncState<T> { const AsyncState(); }

final class AsyncInitial<T> extends AsyncState<T> { const AsyncInitial(); }

final class AsyncLoading<T> extends AsyncState<T> {
  final T? previous;       // last successful payload, for "loading while populated"
  const AsyncLoading({this.previous});
}

final class AsyncSuccess<T> extends AsyncState<T> {
  final T data;
  const AsyncSuccess(this.data);
}

final class AsyncFailure<T> extends AsyncState<T> {
  final Failure failure;
  final T? previous;       // last successful payload, for "error while populated"
  const AsyncFailure(this.failure, {this.previous});
}
```

**Pattern matching in the UI:**
```dart
final label = switch (state) {
  AsyncInitial() => '',
  AsyncLoading() => 'Loading…',
  AsyncSuccess(:final data) => 'Got ${data.length}',
  AsyncFailure(:final failure) => failure.message,
};
```

> Most of the time you don't pattern-match manually — `AsyncBlocBuilder` does it for you (see below).

---

## Standard Cubit Template

```dart
// presentation/cubit/products_cubit.dart
part of '../imports/products_imports.dart';

// Registered in Module (e.g., Bind.factory)
class ProductsCubit extends AsyncCubit<List<ProductEntity>> {
  ProductsCubit(this._getProducts, this._createProduct, this._deleteProduct);

  final GetProductsUseCase _getProducts;
  final CreateProductUseCase _createProduct;
  final DeleteProductUseCase _deleteProduct;

  // The cubit just describes WHAT to call. execute() handles loading/success/failure.
  Future<void> fetchProducts({String? search}) =>
    execute(() => _getProducts(search: search));
}
```

> **The cubit gets `UseCase`s injected — not `Dio`, not `BaseRemoteSource`, not `Repository`.** The `// Registered in Module (e.g., Bind.factory)` annotation tells `get_it`/`injectable` how to build it via `Modular.get<ProductsCubit>()`.

---

## CRUD Local Update Rule (NON-NEGOTIABLE)

**NEVER re-fetch the list after add/edit/delete.** Update state locally with `setData` — preferably **optimistically** (mutate first, then call the API, rollback on failure).

```dart
// Optimistic CREATE — show the item immediately, replace temp with server-confirmed entity
Future<Either<Failure, ProductEntity>> create({
  required String name, required String description, required double price,
}) async {
  final temp = ProductEntity(
    id: -DateTime.now().millisecondsSinceEpoch,   // negative id = temp marker
    name: name, description: description, price: price,
    status: ProductStatus.draft,
  );
  final before = lastData ?? const <ProductEntity>[];
  setData([temp, ...before]);   // optimistic insert

  final result = await _createProduct(name: name, description: description, price: price);
  return result.fold(
    (failure) {                  // rollback
      setData(before);
      return Left(failure);
    },
    (saved) {                    // replace temp with confirmed entity
      final updated = (lastData ?? before)
          .map((p) => p.id == temp.id ? saved : p)
          .toList();
      setData(updated);
      return Right(saved);
    },
  );
}

// Local EDIT (e.g. when an edit screen returns) — no API call
void updateProduct(ProductEntity updated) {
  final current = lastData ?? const <ProductEntity>[];
  setData(current.map((p) => p.id == updated.id ? updated : p).toList());
}

// Optimistic DELETE — remove first, rollback on server failure
Future<Either<Failure, Unit>> delete(int id) async {
  final before = lastData ?? const <ProductEntity>[];
  setData(before.where((p) => p.id != id).toList());

  final result = await _deleteProduct(id);
  return result.fold(
    (failure) { setData(before); return Left(failure); },
    Right.new,
  );
}
```

---

### CRUD Response Merge — Use API Response (CRITICAL)

> **بعد الـ add/edit: استخدم الـ entity من response الـ API (اللي فيه id و server-generated fields زي `created_at`، `slug`، `status`).**
> **متستخدمش الـ user input اللي كتبه المستخدم — السيرفر ممكن يضيف/يعدل fields.**

```dart
// ✅ CORRECT — replace temp with the entity returned by the server
result.fold(
  (failure) { setData(before); return Left(failure); },
  (saved) {
    final updated = (lastData ?? before)
      .map((p) => p.id == temp.id ? saved : p)   // ← saved, not the user input
      .toList();
    setData(updated);
    return Right(saved);
  },
);

// ❌ WRONG — using the user's input (missing id, created_at, server-derived fields)
result.fold(
  (failure) => ...,
  (_) => setData([ProductEntity(name: params.name, ...), ...before]),
);
```

### Paginated CRUD — Add/Delete in `PaginatedAsyncCubit`

> **`PaginatedAsyncCubit<T>` (in `core/state/paginated/`) منه list من عدة pages.** الـ CRUD يتم على الـ in-memory list مثل `AsyncCubit` بالظبط — استخدم `setData(updated)` بعد ما تـ map / filter.

```dart
// Add to paginated list — insert at index 0
final before = lastData ?? const <ItemEntity>[];
setData([newItem, ...before]);

// Delete from paginated list — remove by id
setData(before.where((e) => e.id != id).toList());
```

---

## AsyncBlocBuilder Usage

> **`AsyncBlocBuilder<C, T>` (in `core/state/async/async_bloc_builder.dart`)** يستهلك `AsyncState<T>` ويستدعي الـ builder المناسب حسب الـ case. يأخذ `loadingBuilder` (optional, has default) + `errorBuilder` (optional, has default — receives `Failure`) + `onRetry` + `builder`.

```dart
AsyncBlocBuilder<ProductsCubit, List<ProductEntity>>(
  onRetry: () => context.read<ProductsCubit>().fetchProducts(),
  // loadingBuilder: optional — defaults to a centered CircularProgressIndicator / Skeletonizer
  loadingBuilder: (_) => const ProductsSkeletonList(),
  // errorBuilder: optional — receives Failure (not String)
  errorBuilder: (ctx, Failure failure) => ErrorView(
    failure: failure,
    onRetry: () => ctx.read<ProductsCubit>().fetchProducts(),
  ),
  builder: (context, products) {
    if (products.isEmpty) return const EmptyWidget();
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, i) => ProductCard(product: products[i]),
    );
  },
)
```

### Sliver Version (if present)

If a `AsyncSliverBlocBuilder` exists in `core/state/async/`, use it inside `CustomScrollView`:
```dart
CustomScrollView(slivers: [
  const _Header().toSliver(),
  AsyncSliverBlocBuilder<ItemsCubit, List<ItemEntity>>(
    builder: (ctx, items) => SliverList.builder(
      itemCount: items.length,
      itemBuilder: (_, i) => ItemCard(item: items[i]),
    ),
  ),
])
```
> If the sliver variant isn't shipped yet, wrap `AsyncBlocBuilder` inside `SliverFillRemaining` or use `toSliver()` extension on a boxed result. Check `core/state/async/` for the exact API before assuming.

---

## Multiple Cubits — MultiBlocProvider

```dart
MultiBlocProvider(
  providers: [
    BlocProvider(create: (_) => Modular.get<BannersCubit>()..fetchBanners()),
    BlocProvider(create: (_) => Modular.get<CategoriesCubit>()..fetchCategories()),
  ],
  child: DefaultScaffold(title: LocaleKeys.home.tr(), body: const HomeBody()),
)
```

**Multi-section empty:** `SizedBox.shrink()` (not `EmptyWidget`).
**Heavy screens (4+ APIs):** Consider `compute()` for JSON parsing.

---

## BlocListener — For Actions

```dart
BlocListener<SubmitCubit, AsyncState<bool>>(
  listener: (context, state) {
    if (state is AsyncSuccess) {
      MessageUtils.showSnackBar(message: LocaleKeys.success.tr(), baseStatus: BaseStatus.success);
      Modular.to.pop();
    }
  },
  child: bodyWidget,
)
```

---

## Pagination — PaginatedCubit

### List Services = Always Paginated (MANDATORY)

> **أي endpoint بيرجع list وليه شاشة مستقلة → لازم يكون `PaginatedCubit`.**
> **`AsyncCubit<List<T>>` مسموح بس للـ dropdowns والـ sub-sections الصغيرة.**

```dart
// ❌ FORBIDDEN — standalone list screen without pagination
class ProductsCubit extends AsyncCubit<List<ProductEntity>> { ... }

// ✅ CORRECT — paginated
class ProductsCubit extends PaginatedCubit<ProductEntity> { ... }
```

**Exceptions (AsyncCubit<List<T>> is OK):**
- Dropdown data (cities, categories) — small fixed list
- Multi-section sub-lists (banners inside home) — short list
- Filter chips / tags — rarely exceeds 20 items

### PaginatedAsyncCubit Template

> **Location:** `core/state/paginated/paginated_async_cubit.dart`. Inspect the concrete API there before scaffolding (override hooks may differ from `AsyncCubit`). The cubit still depends on **UseCases** — never on `BaseRemoteSource` directly.

```dart
// Registered in Module (e.g., Bind.factory)
class ProductsCubit extends PaginatedAsyncCubit<ProductEntity> {
  ProductsCubit(this._getProductsPage);
  final GetProductsPageUseCase _getProductsPage;

  // The UseCase returns Either<Failure, PaginatedData<ProductEntity>>
  // (items + PaginationMeta).
  @override
  Future<Either<Failure, PaginatedData<ProductEntity>>> fetchPage(int page, {String? key}) =>
    _getProductsPage(page: page, search: key);
}
```

```dart
// domain/usecases/get_products_page_usecase.dart
@lazySingleton
class GetProductsPageUseCase {
  GetProductsPageUseCase(this._repo);
  final ProductsRepository _repo;
  Future<Either<Failure, PaginatedData<ProductEntity>>> call({required int page, String? search}) =>
    _repo.getProductsPage(page: page, search: search);
}
```

```dart
// data/datasources/products_remote_data_source_impl.dart
@override
Future<Either<Failure, PaginatedData<ProductEntity>>> getProductsPage({
  required int page, String? search,
}) => request<PaginatedData<ProductEntity>>(
  method: HttpMethod.get,
  endpoint: ApiEndpoints.products,
  queryParameters: {'page': page, if (search != null && search.isNotEmpty) 'search': search},
  fromJson: (j) => PaginatedData<ProductEntity>(
    items: ((j['data'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson).map((m) => m.toEntity()).toList(),
    meta: PaginationMeta.fromJson(j['meta'] as Map<String, dynamic>),
  ),
);
```

### UI Widget

```dart
PaginatedListWidget<ItemEntity>(
  cubit: context.read<ItemsCubit>(),
  itemBuilder: (item) => ItemCard(item: item),
  loadingBuilder: () => const ItemCardSkeleton(),
)
```

---

## AppDropdown with API — NO BlocBuilder Wrapper (CRITICAL)

> **AppDropdown بياخد data من API → لا تلفّه في `AsyncBlocBuilder` ولا `BlocBuilder` ولا تضيف error UI خاصة بيه.**
> **لو الـ service فشلت → الـ dropdown بيظهر فاضي (items = []). كده وخلاص. مفيش retry button، مفيش error widget.**

### Why?

الـ dropdown service صغيرة وثانوية. لو فشلت:
- المستخدم يقفل الشاشة ويفتحها تاني لو محتاج
- باقي الـ form بيكمل عادي
- إضافة error UI على dropdown = noise بصري بدون فائدة

### ✅ CORRECT — context.watch + pass items/isLoading directly

```dart
class _MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<GetCitiesCubit>()..fetchCities(),
      child: Builder(builder: (ctx) {
        final state = ctx.watch<GetCitiesCubit>().state;
        return AppDropdown<CityEntity>(
          items: state.data,                  // ← []  لو API فشلت
          label: LocaleKeys.city.tr(),
          itemAsString: (c) => c.name,
          isLoading: state is AsyncLoading,         // ← AppDropdown shows internal shimmer
          onChanged: (c) => params.city = c,
          validator: Validators.validateDropDown,
        );
      }),
    );
  }
}
```

### ❌ FORBIDDEN — wrapping in BlocBuilder / AsyncBlocBuilder

```dart
// ❌ Don't add error UI to dropdowns
AsyncBlocBuilder<GetCitiesCubit, List<CityEntity>>(
  errorBuilder: (ctx, err) => ErrorView(error: err),  // ← لا
  loadingBuilder: (_) => const _DropdownSkeleton(),
  builder: (ctx, cities) => AppDropdown(items: cities, ...),
)

// ❌ Even plain BlocBuilder is overkill — use context.watch + pass state.data
BlocBuilder<GetCitiesCubit, AsyncState<List<CityEntity>>>(
  builder: (ctx, state) => AppDropdown(items: state.data, ...),
)

// ❌ Wrapping ENTIRE screen with BlocBuilder for a single dropdown
AsyncBlocBuilder<GetCitiesCubit, List<CityEntity>>(
  builder: (ctx, cities) => Column(children: [
    _Header(), _Form(), AppDropdown(items: cities), _SubmitButton(),
  ]),
)  // ← if cities API fails, ENTIRE screen stops!
```

### Rules

- AppDropdown مع service: `BlocProvider` لتوفير الـ cubit + `context.watch` لاستهلاك state — مش `AsyncBlocBuilder`
- مفيش `errorBuilder` ولا `loadingBuilder` على الـ dropdown
- `isLoading` parameter في AppDropdown يـ handle الـ loading shimmer داخلياً
- لو فشل API → items فاضية، يكمل المستخدم باقي الـ form أو يقفل ويرجع

---

## Figma State Mapping

```
Figma "Loading"      → state is AsyncLoading  → loadingBuilder
Figma "Empty"        → state is AsyncSuccess + data.isEmpty → EmptyWidget
Figma "Error"        → state is AsyncFailure    → errorBuilder / ErrorView
Figma "Default"      → state is AsyncSuccess + data.notEmpty → builder
Figma "Loading More" → state is AsyncLoadingMore → list + loader at bottom
```

## Entity Safety

Every entity MUST have `factory initial()`, `fromJson` with `??` defaults, `tryParse` (never `parse`).
See `flutter-base-coding-standards.mdc` section 8.5 for full rules.
