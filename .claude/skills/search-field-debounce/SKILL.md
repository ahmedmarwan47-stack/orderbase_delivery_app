---
name: search-field-debounce
description: Real search field with rxdart debounce pattern — never use fake Container+Text search bars.
---

# Skill: Search Field with Debounce

## When to Use

- عند وجود search bar في أي شاشة (header search, filter search, etc.).
- عند ملاحظة fake search bar (static Container + Text بدل TextField حقيقي).

## What to Do

### الـ Search Field Widget
```dart
// ✅ CORRECT — real TextField
DefaultTextField(
  title: LocaleKeys.searchHint.tr(),
  controller: _searchController,
  fillColor: AppColors.fill,
  hasBorderColor: false,
  borderRadius: BorderRadius.circular(AppCircular.r12),
  action: TextInputAction.search,
  prefixIcon: IconWidget(
    icon: AppAssets.svg.baseSvg.search.path,
    color: AppColors.hintText,
    height: AppSize.sH20,
  ).paddingAll(AppPadding.pH12),
  onChanged: _onSearchChanged,
)

// ❌ FORBIDDEN — fake search bar
Container(
  decoration: BoxDecoration(color: AppColors.fill),
  child: Row(children: [Text(LocaleKeys.searchHint.tr()), Icon(...)]),
)
```

### ViewController (recommended — keeps widget clean)
```dart
class MySearchViewController {
  final searchController = TextEditingController();
  final _searchSubject = PublishSubject<String>();
  late final StreamSubscription<String> _searchSubscription;

  void init(void Function(String) onSearch) {
    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 500))
        .distinct()
        .listen(onSearch);
  }

  void onSearchChanged(String? query) => _searchSubject.add(query ?? '');

  void dispose() {
    searchController.dispose();
    _searchSubscription.cancel();
    _searchSubject.close();
  }
}
```

### Widget Usage (StatefulWidget)
```dart
late final _vc = MySearchViewController();

@override
void initState() {
  super.initState();
  _vc.init((query) => context.read<MyCubit>().search(query));
}

@override
void dispose() {
  _vc.dispose();
  super.dispose();
}

// In build:
DefaultTextField(
  controller: _vc.searchController,
  onChanged: _vc.onSearchChanged,
  // ...
)
```

### Cubit Search Support

**PaginatedCubit:**
```dart
String _searchQuery = '';

void search(String query) {
  _searchQuery = query.trim();
  fetchInitialData();
}
```

**AsyncCubit (delegates to UseCase — see `api-pipeline`):**
```dart
// Registered in Module (e.g., Bind.factory)
class MyItemsCubit extends AsyncCubit<List<MyEntity>> {
  MyItemsCubit(this._getItems);
  final GetMyItemsUseCase _getItems;

  Future<void> fetchItems({String search = ''}) =>
    execute(() => _getItems(search: search.isEmpty ? null : search));
}

// DataSource (only thing that touches the network):
@override
Future<Either<Failure, List<MyEntity>>> getItems({String? search}) =>
  request<List<MyEntity>>(
    method: HttpMethod.get,
    endpoint: ApiEndpoints.myEndpoint,
    queryParameters: {if (search != null && search.isNotEmpty) 'search': search},
    cancelKey: 'search:myItems',     // dedupe — cancels previous search
    fromJson: (j) => ((j['data'] as List?) ?? const [])
      .whereType<Map<String, dynamic>>().map(MyModel.fromJson).map((m) => m.toEntity()).toList(),
  );
```

### Required Imports (in `<feature>_imports.dart`)
```dart
import 'dart:async';
import 'package:rxdart/rxdart.dart';
```

### Checklist
- [ ] Search bar = `DefaultTextField` (NOT Container + Text)
- [ ] `PublishSubject` + `debounceTime(500ms)` + `.distinct()`
- [ ] Screen = `StatefulWidget` (lifecycle management)
- [ ] Dispose: controller + subscription + subject
- [ ] Cubit has `search()` method
- [ ] `dart:async` و `rxdart` imported

## Output

- أي search bars تم تحويلها من fake لـ real TextField.
- أي debounce patterns تم إضافتها أو إصلاحها.
