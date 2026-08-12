---
name: di-and-architecture
description: Keep DI usage and high-level layering consistent in Flutter_Base.
---

# Skill: DI & Architecture — Flutter_Base

## When to Use

- عند إضافة Cubit جديد، UseCase، أو Repository.
- عند ملاحظة إنشاء يدوي لـ services داخل الـ UI.

## What to Do

### 1. Service Locator — `Modular.get<T>()`

```dart
// ✅ CORRECT — inside screen
return BlocProvider(
  create: (_) => Modular.get<MyFeatureCubit>()..fetchItems(),
  child: const _MyFeatureBody(),
);

// ❌ WRONG — manual construction
final cubit = MyFeatureCubit(MyRepo(Dio()));
```

- استخدم `Modular.get<T>()` أو احصل على الـ dependencies مباشرة عبر `Modular.args.data`.
- لا تنشئ instances يدوياً لـ repositories / useCases في الـ UI.

### 2. Dependency Registration (Modules)

```dart
// features/my_feature/my_feature_module.dart
class MyFeatureModule extends Module {
  @override
  void binds(Injector i) {
    i.add<MyRepo>(MyRepoImpl.new);
    i.add<GetOrdersUseCase>(GetOrdersUseCase.new);
    i.add<GetOrdersCubit>(GetOrdersCubit.new);
  }
}
```

قم دائماً بتسجيل الـ Cubits والـ UseCases في ملف الـ `Module` الخاص بالـ Feature بدلاً من الاعتماد على Code Generation مثل `injectable`.

### 3. Layers Responsibility

| Layer | مسؤول عن | يتعامل مع |
|-------|---------|-----------|
| **Presentation** | Widgets + Cubits | `Entity` فقط — لا يعرف Dio/HTTP |
| **Domain** | UseCases + Repository interfaces + Entities | Business logic |
| **Data** | RemoteDatasource + DTOs + Dio | API calls مباشرة |

**قواعد صارمة:**
- أي كلاس فيه `Dio` أو `http.get` → لازم يكون في data layer فقط
- أي كلاس فيه `BuildContext` → لازم يكون في presentation فقط

### 4. Endpoints — `ApiEndpoints` فقط

```dart
// ✅ CORRECT
api: ApiEndpoints.products,

// ❌ WRONG — hardcoded string
api: '/api/v1/products',
```

كل الـ endpoints في `core/network/api_endpoints.dart`.

### 5. Where to Put What

| الملف | المكان |
|-------|--------|
| Cubits | `features/{name}/presentation/cubit/` |
| Entities | `features/{name}/entity/` |
| Endpoints | `core/network/api_endpoints.dart` (ApiConstants) |
| Shared requests/responses | `core/base_crud` أو `core/network` |
| Service locator | `core/shared/service_locators/` |

### Checklist

- [ ] كل Cubit/UseCase جديد مسجل في الـ `Module` الخاص بالـ feature.
- [ ] كل Screen تستخدم `Modular.get<MyCubit>()` داخل `BlocProvider` (أو يتم حقنها).
- [ ] لا يوجد constructor manual لـ repos/usecases في UI
- [ ] HTTP/Dio غير مستخدم في presentation
- [ ] `ApiEndpoints` هو المصدر الوحيد للـ endpoints

## Output

بعد تشغيل هذا الـ skill:
- لخّص أي Cubits تم تعديلها لتستخدم `flutter_modular` (Modular.get).
- أماكن تم نقل `Dio` منها إلى data layer.
- أي endpoints تم نقلها لـ `ApiEndpoints`.

