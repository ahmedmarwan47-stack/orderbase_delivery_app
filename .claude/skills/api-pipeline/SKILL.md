---
name: api-pipeline
description: Complete API integration pipeline from Postman → ApiEndpoints → Model + Mapper → Entity → DataSource (BaseRemoteSource.request) → Repository → UseCase → Cubit → UI. Step-by-step for GET/POST/PUT/DELETE endpoints.
---

# Skill: API Pipeline — Postman to Working Screen (Clean Architecture)

## When to Use

- عند ربط أي endpoint جديد (GET list, GET detail, POST/PUT, DELETE, multipart upload)
- عند قراءة Postman collection وتحويلها لكود
- عند إنشاء cubit جديد بيجيب data من API
- عند بناء feature من الصفر بـ Clean Architecture كاملة (data + domain + presentation)

---

## The Pipeline (8 Steps — Clean Architecture)

```
Postman Collection
    ↓
Step 1: Read endpoint + request shape + response shape
    ↓
Step 2: Add to lib/src/core/network/api_endpoints.dart
    ↓
Step 3: domain/entities/<entity>_entity.dart   (pure Dart — what the UI consumes)
    ↓
Step 4: data/models/<entity>_model.dart        (DTO — fromJson) + data/mappers/<entity>_mapper.dart (Model ↔ Entity)
    ↓
Step 5: domain/datasources/<feature>_remote_data_source.dart  (abstract interface)
        data/datasources/<feature>_remote_data_source_impl.dart
        — extends BaseRemoteSource, calls request<T>(...), implements interface
    ↓
Step 6: domain/repositories/<feature>_repository.dart (abstract interface)
        data/repositories/<feature>_repository_impl.dart
    ↓
Step 7: domain/usecases/<action>_usecase.dart  (single-purpose — Either<Failure, T>)
        presentation/cubit/<feature>_cubit.dart (AsyncCubit<T>, depends on UseCase only)
    ↓
Step 8: build_runner → BlocProvider + AsyncBlocBuilder → verify
```

---

## Step 1: Read Postman Collection

From Postman, extract for **each** request:

| Field | Example | Where it goes |
|-------|---------|---------------|
| URL path | `/api/v1/products` | `ApiEndpoints.products` |
| Path params | `/api/v1/products/{id}` | static String method: `productById(int id)` |
| HTTP method | `GET` / `POST` / `PUT` / `PATCH` / `DELETE` | `HttpMethod.get / .post / …` |
| Query params | `?page=1&search=shoe` | `queryParameters:` in `request<T>` |
| Body (POST/PUT) | `{"name": "...", "price": 100}` | `body:` in `request<T>` |
| Multipart? | `Content-Type: multipart/form-data` | `asFormData: true` (Map → FormData) |
| Auth header | `Bearer {{token}}` | Auto via `AuthInterceptor` (set `skipAuth: true` for login/register) |
| Response shape | `{"data": [...], "meta": {...}}` | `fromJson:` parser in the DataSource |

> If a Postman collection isn't ready, ask the user — see `feature-prompt` STEP 4 Path B for auto-generation.

---

## Step 2: Add to `ApiEndpoints`

```dart
// core/network/api_endpoints.dart
class ApiEndpoints {
  static const String baseUrl = 'https://api.example.com/v1/';

  // Products
  static const String products = 'products';
  static String productById(int id) => 'products/$id';

  // Auth
  static const String login = 'auth/login';
  static const String register = 'auth/register';

  // Uploads
  static const String upload = 'upload';
}
```

**Rules:**
- Only relative paths. `DioClient` already prepends `baseUrl`.
- No hardcoded URL strings anywhere else in the codebase.
- Path params → static method (not `'products/$id'` string interpolation at the call site).

---

## Step 3: Domain Entity (what the UI consumes)

> **Pure Dart.** No Dio, no Map, no JSON. The UI consumes Entities — it never sees Models.

```dart
// domain/entities/product_entity.dart
import '../enums/product_status.dart';

class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.status,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final ProductStatus status;

  // For Skeletonizer placeholders
  factory ProductEntity.initial() => const ProductEntity(
    id: 0, name: '', description: '', price: 0, status: ProductStatus.draft,
  );

  ProductEntity copyWith({
    int? id, String? name, String? description, double? price, ProductStatus? status,
  }) => ProductEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    price: price ?? this.price,
    status: status ?? this.status,
  );
}
```

Enum lives in `domain/enums/`:
```dart
// domain/enums/product_status.dart
enum ProductStatus { draft, published, archived }
```

---

## Step 4: Data Model + Mapper

> The Model is the **DTO** that mirrors the JSON shape. The Mapper translates Model → Entity (and back if needed). This is the only place that touches raw JSON.

```dart
// data/models/product_model.dart
class ProductModel {
  const ProductModel({
    required this.id, required this.name, required this.description,
    required this.price, required this.status,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final String status;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: int.tryParse(json['id'].toString()) ?? 0,
    name: (json['name'] ?? '') as String,
    description: (json['description'] ?? '') as String,
    price: double.tryParse(json['price'].toString()) ?? 0,
    status: (json['status'] ?? 'draft') as String,
  );
}
```

```dart
// data/mappers/product_mapper.dart
import '../../domain/entities/product_entity.dart';
import '../../domain/enums/product_status.dart';
import '../models/product_model.dart';

extension ProductModelMapper on ProductModel {
  ProductEntity toEntity() => ProductEntity(
    id: id,
    name: name,
    description: description,
    price: price,
    status: ProductStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => ProductStatus.draft,
    ),
  );
}
```

**Rules:**
- Model uses **`tryParse + ??`** for every numeric field. Never raw `parse`.
- Model uses **`?? ''`** / **`?? 0`** for every non-nullable field. Never assume the API.
- Mapper is the **only** thing that knows how Model maps to Entity. Keep it pure (no I/O).

---

## Step 5: DataSource (the only thing that touches the network)

### 5a. Domain interface
```dart
// domain/datasources/products_remote_data_source.dart
import 'package:dartz/dartz.dart';
import '../../../../core/network/error/failures.dart';
import '../entities/product_entity.dart';

abstract interface class ProductsRemoteDataSource {
  Future<Either<Failure, List<ProductEntity>>> getProducts({int page = 1, String? search});
  Future<Either<Failure, ProductEntity>> getProductById(int id);
  Future<Either<Failure, ProductEntity>> createProduct({required String name, required String description, required double price});
  Future<Either<Failure, ProductEntity>> updateProduct({required int id, required String name, required String description, required double price});
  Future<Either<Failure, Unit>> deleteProduct(int id);
}
```

### 5b. Data implementation
```dart
// data/datasources/products_remote_data_source_impl.dart
@LazySingleton(as: ProductsRemoteDataSource)
class ProductsRemoteDataSourceImpl extends BaseRemoteSource
    implements ProductsRemoteDataSource {

  ProductsRemoteDataSourceImpl();

  // GET list
  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({int page = 1, String? search}) =>
    request<List<ProductEntity>>(
      method: HttpMethod.get,
      endpoint: ApiEndpoints.products,
      queryParameters: {
        'page': page,
        if (search != null && search.isNotEmpty) 'search': search,
      },
      fromJson: _parseList,
    );

  // GET single
  @override
  Future<Either<Failure, ProductEntity>> getProductById(int id) => request<ProductEntity>(
    method: HttpMethod.get,
    endpoint: ApiEndpoints.productById(id),
    fromJson: _parseOne,
  );

  // POST create
  @override
  Future<Either<Failure, ProductEntity>> createProduct({
    required String name, required String description, required double price,
  }) => request<ProductEntity>(
    method: HttpMethod.post,
    endpoint: ApiEndpoints.products,
    body: {'name': name, 'description': description, 'price': price},
    fromJson: _parseOne,
  );

  // PUT update
  @override
  Future<Either<Failure, ProductEntity>> updateProduct({
    required int id, required String name, required String description, required double price,
  }) => request<ProductEntity>(
    method: HttpMethod.put,
    endpoint: ApiEndpoints.productById(id),
    body: {'name': name, 'description': description, 'price': price},
    fromJson: _parseOne,
  );

  // DELETE
  @override
  Future<Either<Failure, Unit>> deleteProduct(int id) => request<Unit>(
    method: HttpMethod.delete,
    endpoint: ApiEndpoints.productById(id),
    fromJson: (_) => unit,
  );

  // ── Private parsers ──────────────────────────────────────────────
  static List<ProductEntity> _parseList(dynamic j) =>
    ((j is Map ? j['data'] : j) as List? ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(ProductModel.fromJson)
      .map((m) => m.toEntity())
      .toList();

  static ProductEntity _parseOne(dynamic j) {
    final data = j is Map<String, dynamic>
      ? ((j['data'] ?? j) as Map<String, dynamic>)
      : <String, dynamic>{};
    return ProductModel.fromJson(data).toEntity();
  }
}
```

### 5c. Special request types

```dart
// Public endpoint (no Bearer)
request<AuthToken>(
  method: HttpMethod.post,
  endpoint: ApiEndpoints.login,
  body: {'email': email, 'password': password},
  skipAuth: true,
  fromJson: (j) => AuthToken.fromJson(j),
);

// Multipart upload (let asFormData wrap the Map)
request<UploadResult>(
  method: HttpMethod.post,
  endpoint: ApiEndpoints.upload,
  body: {
    'file': await MultipartFile.fromFile(path),
    'note': 'avatar',
  },
  asFormData: true,
  fromJson: (j) => UploadResult.fromJson(j),
);

// Custom cancel key (e.g. search-as-you-type)
request<List<ProductEntity>>(
  method: HttpMethod.get,
  endpoint: ApiEndpoints.products,
  queryParameters: {'search': q},
  cancelKey: 'search:products',
  cancelPrevious: true,
  fromJson: _parseList,
);
```

---

## Step 6: Repository (data → domain bridge)

```dart
// domain/repositories/products_repository.dart
abstract interface class ProductsRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({String? search});
  Future<Either<Failure, ProductEntity>> getProductById(int id);
  Future<Either<Failure, ProductEntity>> createProduct({required String name, required String description, required double price});
  Future<Either<Failure, Unit>> deleteProduct(int id);
}

// data/repositories/products_repository_impl.dart
@LazySingleton(as: ProductsRepository)
class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this._remote);
  final ProductsRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({String? search}) =>
    _remote.getProducts(search: search);

  @override
  Future<Either<Failure, ProductEntity>> getProductById(int id) =>
    _remote.getProductById(id);

  @override
  Future<Either<Failure, ProductEntity>> createProduct({
    required String name, required String description, required double price,
  }) => _remote.createProduct(name: name, description: description, price: price);

  @override
  Future<Either<Failure, Unit>> deleteProduct(int id) => _remote.deleteProduct(id);
}
```

> The Repository is where you'd add caching, offline queues, or compose multiple data sources. For simple features it's a thin pass-through — that's fine.

---

## Step 7: UseCase + Cubit

### 7a. UseCases (one per action)
```dart
// domain/usecases/get_products_usecase.dart
@lazySingleton
class GetProductsUseCase {
  GetProductsUseCase(this._repo);
  final ProductsRepository _repo;
  Future<Either<Failure, List<ProductEntity>>> call({String? search}) =>
    _repo.getProducts(search: search);
}

// domain/usecases/create_product_usecase.dart
@lazySingleton
class CreateProductUseCase {
  CreateProductUseCase(this._repo);
  final ProductsRepository _repo;
  Future<Either<Failure, ProductEntity>> call({
    required String name, required String description, required double price,
  }) => _repo.createProduct(name: name, description: description, price: price);
}

// domain/usecases/delete_product_usecase.dart
@lazySingleton
class DeleteProductUseCase {
  DeleteProductUseCase(this._repo);
  final ProductsRepository _repo;
  Future<Either<Failure, Unit>> call(int id) => _repo.deleteProduct(id);
}
```

### 7b. Cubit (presentation — depends on UseCases only)
```dart
// presentation/cubit/products_cubit.dart
part of '../imports/products_imports.dart';

// Registered in Module (e.g., Bind.factory)
class ProductsCubit extends AsyncCubit<List<ProductEntity>> {
  ProductsCubit(this._getProducts, this._createProduct, this._deleteProduct);

  final GetProductsUseCase _getProducts;
  final CreateProductUseCase _createProduct;
  final DeleteProductUseCase _deleteProduct;

  Future<void> fetchProducts({String? search}) =>
    execute(() => _getProducts(search: search));

  // CRUD: local update only — never re-fetch (see bloc-patterns)
  // create() — optimistic insert + rollback
  // delete() — optimistic remove + rollback
}
```

---

## Step 8: Wire DI, Connect UI, Verify

### 8a. Run code generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 8b. UI (Screen owns the cubit + ViewController lifecycle)
```dart
// presentation/pages/products_screen.dart
part of '../imports/products_imports.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late final ProductsCubit _cubit;
  late final ProductsViewController _vc;

  @override
  void initState() {
    super.initState();
    _cubit = Modular.get<ProductsCubit>()..fetchProducts();
    _vc = ProductsViewController(onSearch: (q) => _cubit.fetchProducts(search: q));
  }

  @override
  void dispose() {
    _vc.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider<ProductsCubit>.value(
    value: _cubit,
    child: Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.products.tr())),
      body: _ProductsBody(controller: _vc),
    ),
  );
}
```

### 8c. Body widget consumes the cubit via `AsyncBlocBuilder`
```dart
// presentation/widgets/products_body.dart
part of '../imports/products_imports.dart';

class _ProductsBody extends StatelessWidget {
  const _ProductsBody({required this.controller});
  final ProductsViewController controller;

  @override
  Widget build(BuildContext context) => Column(children: [
    _ProductsSearchField(controller: controller),
    Expanded(
      child: AsyncBlocBuilder<ProductsCubit, List<ProductEntity>>(
        onRetry: () => context.read<ProductsCubit>().fetchProducts(
          search: controller.searchController.text,
        ),
        builder: (context, products) => products.isEmpty
          ? const EmptyWidget()
          : ListView.separated(
              controller: controller.scrollController,
              itemCount: products.length,
              separatorBuilder: (_, __) => 8.szH,
              itemBuilder: (_, i) => _ProductCard(product: products[i]),
            ),
      ),
    ),
  ]);
}
```

### 8d. Verify checklist
- [ ] `build_runner` finished without errors (DI graph compiled)
- [ ] `flutter analyze` clean
- [ ] List loads on first build (`fetchProducts` called in `initState`)
- [ ] Retry button works on error
- [ ] Search debounces (350 ms) and cancels previous request
- [ ] Pull-to-refresh re-fetches
- [ ] CRUD updates are local (no re-fetch after add/delete)
- [ ] No hardcoded text/color/size/icon in the View (Strict Rule #2)
- [ ] No method in the View other than `build/initState/dispose` (Strict Rule #3)
- [ ] No `setState` (Strict Rule #4)

---

## Common Mistakes

| Mistake | Why it's wrong | Fix |
|---------|---------------|-----|
| Cubit takes `XRemoteDataSource` or `Dio` directly | Skips Repository + UseCase — couples presentation to data layer | Cubit takes **UseCases** only |
| Endpoint string hardcoded in DataSource | Drift between Postman and code | Add to `ApiEndpoints` |
| Model = Entity (single class) | Couples wire shape to UI; fromJson contaminates the domain | Separate Model (DTO) + Entity (domain) + Mapper |
| `request<T>(method: HttpMethod.get, ...)` without `fromJson` | Required param | Always provide `fromJson` (use `(_) => unit` for void) |
| Login uses normal `request` (with Bearer) | 401 because token doesn't exist yet | Add `skipAuth: true` |
| Multipart body wrapped manually as `FormData.fromMap(...)` | Verbose | Use `asFormData: true` — `request` wraps it for you |
| Re-fetch list after add/delete | UX flicker, extra API call, unnecessary load | Local update with `setData(...)` (see bloc-patterns) |
| Using user input (not API response) for the new item after POST | Missing server-generated id / timestamps / slug | Use the entity returned by the server |
| Phone digits sent as ٠١٢٣ to a backend that expects 0123 | Server rejects | `normalizeArabicDigits` is true by default — keep it on; for the rare case you actually need Arabic digits, set `false` |
| Search-as-you-type without cancelling previous request | Race conditions, jumbled results | Use a stable `cancelKey` (or default `"GET:products"`) — `cancelPrevious: true` is on by default |

---

## Quick Reference Card

```
ApiEndpoints.foo             ← URL path
HttpMethod.{get|post|put|patch|delete}  ← method
request<T>({                  ← single entry on BaseRemoteSource
  method, endpoint,
  queryParameters, body, headers,
  fromJson,                  ← required
  skipAuth, asFormData,
  normalizeArabicDigits,
  cancelKey, cancelPrevious,
  responseType,
})
                              ↓
Either<Failure, T>            ← caller .fold(failure → ..., data → ...)

Failure types in core/network/error/failures.dart
  ServerFailure, NetworkFailure, CancelledFailure, ParseFailure, UnknownFailure, …

Interceptor order (DioClient):
  LocaleInterceptor → AuthInterceptor → RetryInterceptor → AppCacheInterceptor → LoggingInterceptor (debug)
```
