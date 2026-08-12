---
name: form-api-pipeline
description: Complete form-to-API pipeline — FormMixin, ViewController, Params, validation, LoadingButton, file upload, and success handling in Flutter_Base.
---

# Skill: Form → API Complete Pipeline

## When to Use

- عند بناء أي form بيعمل submit لـ API (POST/PUT/PATCH)
- عند إنشاء create/edit screen
- عند رفع صور أو ملفات مع form data

---

## ⚠️ Field-Specific Validation & Formatting (اقرأها قبل أي form)

> **كل field في الـ form لازم له `validator` + `inputFormatters` يعبروا عن نوع محتواه.**
> **مفيش form يطلع بفيلد عام بدون قواعد. ده senior code review red flag.**

### Field Rules Matrix (لكل نوع field)

| Field | Validator | InputFormatters | Cleanup قبل API |
|-------|-----------|----------------|----------------|
| Saudi Phone | `Validators.validateSaudiPhone` | `[SaudiPhoneFormatter(), ArabicNumbersFormatter(), LengthLimitingTextInputFormatter(13)]` | `Helpers.normalizeSaudiPhone(text.toEnglishNumbers())` |
| Price | `Validators.validatePrice` | `[CurrencyFormatter(maxValue: 999_999_999), ArabicNumbersFormatter()]` | `text.replaceAll(',', '').toEnglishNumbers()` then `double.tryParse` |
| Quantity | `Validators.validateEmpty` | `[IntegerNumberFormatter(maxValue: 999), ArabicNumbersFormatter()]` | `text.toEnglishNumbers()` then `int.tryParse` |
| Commercial Reg | `Validators.validateCommercialReg` | `[NumberOnlyFormatter(), LengthLimitingTextInputFormatter(10)]` | `text.toEnglishNumbers()` |
| National ID | `Validators.validateNationalId` | `[NumberOnlyFormatter(), LengthLimitingTextInputFormatter(10)]` | `text.toEnglishNumbers()` |
| IBAN | `Validators.validateIban` | `[IbanFormatter(), LengthLimitingTextInputFormatter(24)]` | `text.replaceAll(' ', '').toUpperCase()` |
| Email | `Validators.validateEmail` | `[EmailFormatter()]` | `text.trim().toLowerCase()` |
| Password | `Validators.validatePassword` | — | `text` (as-is) |
| OTP | `Validators.validateEmpty` | `[NumberOnlyFormatter(), ArabicNumbersFormatter(), LengthLimitingTextInputFormatter(6)]` | `text.toEnglishNumbers()` |
| Date | `Validators.validateEmpty` | `[DateTimeFormatter()]` | parse `dd/MM/yyyy` → ISO `yyyy-MM-dd` |
| Name | `Validators.validateEmpty` | `[TextOnlyFormatter(allowArabic: true)]` | `text.trim()` |

> **Numeric fields بدون `maxValue` = ممنوع. ده hard rule.**

### Currency / Price — Display vs API (CRITICAL)

```dart
// ✅ Display: 3,000,000 (thousand separators for readability)
CustomTextFiled(
  controller: params.priceController,
  validator: Validators.validatePrice,
  inputFormatters: [
    CurrencyFormatter(maxValue: 999_999_999),
    ArabicNumbersFormatter(),
  ],
  textInputType: const TextInputType.numberWithOptions(decimal: false),
)

// ✅ API call: send plain number (no commas)
if (params.validateAndScroll()) {
  final amount = double.tryParse(
    params.priceController.text.replaceAll(',', '').toEnglishNumbers(),
  ) ?? 0;
  await cubit.submit({'amount': amount, ...});
}
```

### Saudi Phone — Always Normalize Before API

```dart
// ✅ Accept user-friendly formats, send canonical
CustomTextFiled(
  controller: params.phoneController,
  validator: Validators.validateSaudiPhone,
  inputFormatters: [
    SaudiPhoneFormatter(),
    ArabicNumbersFormatter(),
    LengthLimitingTextInputFormatter(13),
  ],
  textInputType: TextInputType.phone,
)

// Before API:
final phone = Helpers.normalizeSaudiPhone(
  params.phoneController.text.toEnglishNumbers(),
);
// "05xxxxxxxx"   → "9665xxxxxxxx"
// "+9665xxxxxxxx" → "9665xxxxxxxx"
```

### Anti-patterns (Form Field Red Flags)

```dart
// ❌ Generic field without specific validator
CustomTextFiled(
  controller: params.iban,
  validator: Validators.validateEmpty,  // ← IBAN needs IBAN validator!
)

// ❌ Numeric field without maxValue
CustomTextFiled(
  controller: params.price,
  inputFormatters: [DecimalNumberFormatter()],  // ← unbounded!
)

// ❌ Price sent with commas
'amount': params.priceController.text,  // → "3,000,000" → server error!

// ❌ Arabic numbers sent to API
'phone': params.phoneController.text,  // → "٠٥٠١٢٣٤٥٦٧" → server can't parse!

// ❌ Phone without normalization
'phone': params.phoneController.text,  // → "05123..." but server expects "9665123..."
```

### Field Checklist (run for EVERY field in EVERY form)

```
□ Validator مطابق لنوع المحتوى (مش validateEmpty لكل حاجة)
□ InputFormatters صح + ArabicNumbersFormatter للـ numeric/phone/date
□ Max value للـ numeric fields (إلزامي)
□ Length limit للـ fixed-length (OTP, CR, NID, IBAN, Phone)
□ Display format للـ price/date/IBAN (CurrencyFormatter / DateTimeFormatter / IbanFormatter)
□ Cleanup قبل API call (strip commas/spaces + toEnglishNumbers)
□ textInputType صح (.phone / .number / .emailAddress)
□ textInputAction (.next للـ middle fields، .done للـ آخر)
```

---

---

## The Pipeline (8 Steps)

```
Figma Form Design
    ↓
Step 1: Create ViewController (controllers + toParams)
    ↓
Step 2: Create Params class (toJson / toFormData)
    ↓
Step 3: Create Submit Cubit (execute + POST/PUT)
    ↓
Step 4: Build Form widget (CustomTextFiled + validators)
    ↓
Step 5: Build Screen (BlocProvider + BlocListener + FormMixin)
    ↓
Step 6: Connect LoadingButton (validateAndScroll + submit)
    ↓
Step 7: Handle Success (Modular.to.pop(result) or successDialog)
    ↓
Step 8: Handle Error (toast auto-handled by execute)
```

---

## Step 1: ViewController

> **كل الـ controllers والـ UI logic في ViewController class — ممنوع في الـ View مباشرة.**

```dart
class CreateProductViewController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ValueNotifier<CategoryEntity?> selectedCategory = ValueNotifier(null);
  final ValueNotifier<File?> selectedImage = ValueNotifier(null);

  ProductParams toParams() => ProductParams(
    name: nameController.text.trim(),
    price: double.tryParse(priceController.text) ?? 0,
    description: descriptionController.text.trim(),
    categoryId: selectedCategory.value?.id ?? '',
    image: selectedImage.value,
  );

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    selectedCategory.dispose();
    selectedImage.dispose();
  }
}

// For EDIT — pre-fill from existing entity
class EditProductViewController extends CreateProductViewController {
  EditProductViewController.fromEntity(ProductEntity entity) {
    nameController.text = entity.name;
    priceController.text = entity.price.toString();
    descriptionController.text = entity.description;
    selectedCategory.value = entity.category;
  }
}
```

---

## Step 2: Params Class

### Standard JSON Body:

```dart
class ProductParams {
  final String name;
  final double price;
  final String description;
  final String categoryId;
  final File? image;

  const ProductParams({
    required this.name,
    required this.price,
    required this.description,
    required this.categoryId,
    this.image,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'description': description,
    'category_id': categoryId,
  };
}
```

### FormData (with file upload):

```dart
class ProductParams {
  // ... same fields ...

  Future<FormData> toFormData() async {
    final map = <String, dynamic>{
      'name': name,
      'price': price,
      'description': description,
      'category_id': categoryId,
    };

    if (image != null) {
      map['image'] = await MultipartFile.fromFile(
        image!.path,
        filename: image!.path.split('/').last,
      );
    }

    return FormData.fromMap(map);
  }
}
```

---

## Step 3: Submit Cubit

> **The Cubit takes UseCases — not `BaseRemoteSource` directly.** UseCases live in `domain/usecases/` and call `Repository` which delegates to the DataSource. The DataSource is the only thing that touches `BaseRemoteSource.request<T>(...)`. See `api-pipeline` skill for the full pipeline.

### POST (Create):

```dart
// domain/usecases/create_product_usecase.dart
@lazySingleton
class CreateProductUseCase {
  CreateProductUseCase(this._repo);
  final ProductsRepository _repo;
  Future<Either<Failure, ProductEntity>> call(ProductParams p) =>
    _repo.createProduct(name: p.name, description: p.description, price: p.price);
}

// data/datasources/products_remote_data_source_impl.dart
@override
Future<Either<Failure, ProductEntity>> createProduct({
  required String name, required String description, required double price,
}) => request<ProductEntity>(
  method: HttpMethod.post,
  endpoint: ApiEndpoints.products,
  body: {'name': name, 'description': description, 'price': price},
  fromJson: (j) => ProductModel.fromJson((j['data'] ?? j) as Map<String, dynamic>).toEntity(),
);

// presentation/cubit/create_product_cubit.dart
// Registered in Module (e.g., Bind.factory)
class CreateProductCubit extends AsyncCubit<ProductEntity> {
  CreateProductCubit(this._createProduct);
  final CreateProductUseCase _createProduct;

  Future<void> submit(ProductParams params) =>
    execute(() => _createProduct(params));
}
```

### PUT (Edit):

```dart
// Registered in Module (e.g., Bind.factory)
class EditProductCubit extends AsyncCubit<ProductEntity> {
  EditProductCubit(this._editProduct);
  final EditProductUseCase _editProduct;

  Future<void> submit(int id, ProductParams params) =>
    execute(() => _editProduct(id: id, params: params));
}

// UseCase + DataSource follow the same pattern as POST, with HttpMethod.put + ApiEndpoints.productById(id).
```

### Action-only (no entity returned — return Unit):

```dart
// domain/usecases/send_contact_usecase.dart
@lazySingleton
class SendContactUseCase {
  SendContactUseCase(this._repo);
  final ContactRepository _repo;
  Future<Either<Failure, Unit>> call(ContactUsParams p) => _repo.send(p);
}

// data/datasources/contact_remote_data_source_impl.dart
Future<Either<Failure, Unit>> send(ContactUsParams p) => request<Unit>(
  method: HttpMethod.post,
  endpoint: ApiEndpoints.contactUs,
  body: p.toJson(),
  fromJson: (_) => unit,
);

// presentation/cubit/contact_us_cubit.dart
// Registered in Module (e.g., Bind.factory)
class ContactUsCubit extends AsyncCubit<Unit> {
  ContactUsCubit(this._send);
  final SendContactUseCase _send;
  Future<void> submit(ContactUsParams p) => execute(() => _send(p));
}
```

**Side effects (snackbar / navigation) — handle in the View via `BlocListener` with a sealed-state check:**
```dart
BlocListener<ContactUsCubit, AsyncState<Unit>>(
  listenWhen: (p, c) => p.runtimeType != c.runtimeType,
  listener: (ctx, s) {
    if (s is AsyncSuccess<Unit>) {
      Modular.to.pop();
      successDialog(context: ctx, title: LocaleKeys.messageSentSuccessfully.tr());
    }
  },
  // LoadingButton drives its spinner purely from the awaited `onTap` Future
  // (there is no `cubit:` param). Return the cubit call so it can be awaited.
  child: LoadingButton(title: LocaleKeys.send.tr(), onTap: () async => ctx.read<ContactUsCubit>().submit(params)),
)
```

---

## Step 4: Form Widget

```dart
class _ProductFormWidget extends StatelessWidget {
  const _ProductFormWidget({required this.vc, required this.formKey});
  final CreateProductViewController vc;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextFiled(
            title: LocaleKeys.productName.tr(),
            hint: LocaleKeys.enterProductName.tr(),
            controller: vc.nameController,
            validator: (v) => v?.isEmpty == true ? LocaleKeys.required.tr() : null,
          ),
          12.szH,
          CustomTextFiled(
            title: LocaleKeys.price.tr(),
            controller: vc.priceController,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v?.isEmpty == true) return LocaleKeys.required.tr();
              if (double.tryParse(v!) == null) return LocaleKeys.invalidNumber.tr();
              return null;
            },
          ),
          12.szH,
          CustomTextFiled(
            title: LocaleKeys.description.tr(),
            controller: vc.descriptionController,
            maxLines: 4,
          ),
          12.szH,
          _CategoryDropdown(
            selectedCategory: vc.selectedCategory,
            onChanged: (cat) => vc.selectedCategory.value = cat,
          ),
          12.szH,
          ValueListenableBuilder<File?>(
            valueListenable: vc.selectedImage,
            builder: (_, file, __) => _ImagePickerWidget(
              file: file,
              onPicked: (f) => vc.selectedImage.value = f,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Step 5: Screen with FormMixin

```dart
class _CreateProductBodyState extends State<_CreateProductBody> with FormMixin {
  late final CreateProductViewController _vc = CreateProductViewController();

  @override
  void dispose() {
    _vc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateProductCubit, AsyncState<ProductEntity>>(
      listener: (context, state) {
        if (state is AsyncSuccess && state.data != null) {
          Modular.to.pop(state.data);
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            _ProductFormWidget(vc: _vc, formKey: formKey),
            24.szH,
            LoadingButton(
              title: LocaleKeys.create.tr(),
              cubit: context.read<CreateProductCubit>(),
              onTap: () {
                if (!params.validateAndScroll()) return;
                context.read<CreateProductCubit>().createProduct(_vc.toParams());
              },
            ),
          ],
        ).paddingAll(AppPadding.p16),
      ),
    );
  }
}
```

---

## Step 6: LoadingButton Connection

```dart
LoadingButton(
  title: LocaleKeys.submit.tr(),
  cubit: context.read<SubmitCubit>(),
  onTap: () {
    if (!params.validateAndScroll()) return;
    final params = _vc.toParams();
    context.read<SubmitCubit>().submit(params);
  },
)
```

---

## Validation Patterns

```dart
// Required field
validator: (v) => v?.isEmpty == true ? LocaleKeys.required.tr() : null,

// Email
validator: (v) {
  if (v?.isEmpty == true) return LocaleKeys.required.tr();
  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) return LocaleKeys.invalidEmail.tr();
  return null;
},

// Phone
validator: (v) {
  if (v?.isEmpty == true) return LocaleKeys.required.tr();
  if (v!.length < 9) return LocaleKeys.invalidPhone.tr();
  return null;
},

// Password confirmation
validator: (v) {
  if (v?.isEmpty == true) return LocaleKeys.required.tr();
  if (v != _vc.passwordController.text) return LocaleKeys.passwordMismatch.tr();
  return null;
},
```

---

## Success & Error Handling

| Scenario | Pattern |
|----------|---------|
| Create → return to list | `Modular.to.pop(state.data)` in BlocListener |
| Edit → return to detail | `Modular.to.pop(state.data)` in BlocListener |
| Contact/feedback → success popup | `successDialog(context, title)` + `Modular.to.pop()` in successEmitter |
| Action → just show toast | `MessageUtils.showSnackBar(message, baseStatus: BaseStatus.success)` |

Error: `execute` automatically shows error toast. LoadingButton automatically stops loading on error.

---

## Form Pipeline Checklist

- [ ] ViewController created with all controllers + `toParams()` + `dispose()`
- [ ] Params class created with `toJson()` (or `toFormData()` for files)
- [ ] Submit cubit is `// Registered in Module (e.g., Bind.factory)` + `execute` + correct HTTP method
- [ ] `build_runner` ran after adding `// Registered in Module (e.g., Bind.factory)`
- [ ] Form widget uses `CustomTextFiled` with validators
- [ ] Screen has `FormMixin` + `formKey`
- [ ] `BlocListener` handles success → `Modular.to.pop(result)` or `successDialog`
- [ ] `LoadingButton` linked to cubit (not `DefaultButton`)
- [ ] `params.validateAndScroll()` called before submit
- [ ] All text/labels use `LocaleKeys`
- [ ] Edit form pre-fills from entity via `ViewController.fromEntity()`
- [ ] `_vc.dispose()` called in `dispose()`
