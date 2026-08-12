---
name: logging-and-debugging
description: Safe logging and debugging practices for Flutter_Base.
---

## Logging & Debugging

### 1. No `print` in Final Code

- **ممنوع** ترك `print()` أو `debugPrint()` في الكود النهائي (إلا في logger مركزي).
- لو احتجت logging:
  - استخدم `AppBlocObserver` أو logger موحد (عبر DI) وليس `print` في كل مكان.

---

### 2. Bloc / Cubit Observability

- المشروع يحتوي على `AppBlocObserver` في `core/shared/bloc_observer.dart`.
- استخدمه لـ:
  - تتبع transitions.
  - تتبع errors الصادرة من bloc/cubit.

لا تضف logging داخل كل cubit إلا لو:
- مؤقتة أثناء debug.
- و يتم حذفها قبل الدمج.

---

### 3. Debug Utilities

- أثناء التطوير:
  - مسموح استخدام `debugPrint` مع `kDebugMode`.

```dart
if (kDebugMode) {
  debugPrint('OrdersCubit.fetchOrders → page=$page, search=$search');
}
```

- قبل التسليم:
  - [ ] تأكد أن كل الـ debugPrint محذوف أو موضوع خلف flag واضح يمكن تعطيله.

---

### 4. Error Logging

- أخطاء الـ API:
  - يتم تسجيلها في `LoggingInterceptor` (debug only) داخل `DioClient` — هو آخر interceptor في الـ stack عشان يشوف الـ final request/response shape.
  - الـ `BaseRemoteSource.request<T>` بيلتقط الـ DioException ويحوّلها لـ `Failure` عبر `ResponseParser` — مفيش حاجة لـ logger إضافي في الـ cubit.
  - لا تكرر نفس الرسالة في كل cubit — `MessageUtils.showSnackBar` في الـ View كافية.
- Exceptions غير متوقعة:
  - التقطها في مكان واحد مركزي إن أمكن (runZonedGuarded / FlutterError.onError).

---

### 5. Checklist

- [ ] لا يوجد `print()` في أي ملف.
- [ ] لا يوجد `debugPrint()` غير محمي بـ `kDebugMode` أو مستخدم في مكان مركزي فقط.
- [ ] أخطاء الـ bloc/cubit يمكن تتبعها عبر `AppBlocObserver`.
- [ ] لا يوجد logging مكرر في كل cubit لنفس المعلومة.
