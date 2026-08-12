---
name: accessibility
description: Basic accessibility (a11y) rules for Flutter_Base — semantic labels, tap targets, and contrast.
---

## Accessibility (A11y) — Basics

> الهدف: بدون ما نعقّد الكود، نضمن أن العناصر الأساسية قابلة للاستخدام مع Screen Reader وذوي الاحتياجات الخاصة.

### 1. Minimum Tap Target Size

- أي زر رئيسي أو عنصر تفاعلي يجب أن يكون **≥ 44x44** logical pixels.
- لو الأيقونة صغيرة:
  - زد الـ padding حولها، وليس الـ icon نفسها فقط.

```dart
IconWidget(
  icon: AppAssets.svg.baseSvg.more.path,
  height: AppSize.sH20,
).paddingAll(AppPadding.pH8); // إجمالي ≈ 36–40، زوّد لو لازم
```

---

### 2. Semantic Labels للأيقونات الهامة

- للأزرار التي ليس لها نص واضح (مثل أيقونة سلة، حذف، إضافة):

```dart
Semantics(
  label: LocaleKeys.cart_addItem.tr(),
  button: true,
  child: IconWidget(
    icon: AppAssets.svg.baseSvg.cart.path,
    height: AppSize.sH20,
  ).onClick(onTap: onAddToCart),
)
```

استخدم هذا فقط للأيقونات المهمة (cart, delete, edit, close). لا تبالغ.

---

### 3. Images with Meaning

- لو الصورة purely decorative → لا تحتاج label.
- لو الصورة لها معنى (مثلاً صورة منتج):

```dart
Semantics(
  label: product.name,
  image: true,
  child: CachedImage(
    url: product.image,
    width: AppSize.sW60,
    height: AppSize.sH60,
    borderRadius: BorderRadius.circular(AppCircular.r8),
  ),
)
```

---

### 4. Contrast

- عادةً AppColors مختارة بحيث يكون الـ contrast جيد، لكن انتبه لـ:
  - نص رمادي على خلفية فاتحة جداً ⇒ تأكد من استخدام `AppColors.main` أو `AppColors.primary` للنص الرئيسي.
  - نص فوق خلفيات ملوّنة (مثل buttons) ⇒ استخدم `AppColors.buttonText` أو `AppColors.white`.

---

### 5. Checklist (Optional لكن مفيد)

- [ ] الأزرار / الأيقونات التفاعلية الرئيسية حجمها ≥ 44x44 تقريباً.
- [ ] أيقونات مهمة بدون نص معها `Semantics(label: ..., button: true)`.
- [ ] صور لها معنى (Product, Avatar) عندها label منطقي إن احتجنا.
- [ ] ألوان النص والخلفية لا تجعل النص صعب القراءة.

