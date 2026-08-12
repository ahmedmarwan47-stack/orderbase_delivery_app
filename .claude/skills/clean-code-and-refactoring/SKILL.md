---
name: clean-code-and-refactoring
description: Keep Flutter_Base features clean, modular, and easy to change.
---

# Skill: Clean Code & Refactoring — Flutter_Base

## When to Use

- قبل توسيع feature قديم.
- عندما:
  - widgets كتير في ملف واحد (body file كبير بـ _build methods).
  - نفس الكارد / الـ section مكرر في أكثر من مكان.
  - Cubit يحمل أكثر من مسؤولية.

## What to Do

1. **Widget File Splitting (أولوية عالية):**
   - افحص كل body widget:
     - لو فيه `_buildXxx()` methods ترجع widgets أكثر من 10 أسطر → استخرجها لملفات منفصلة.
     - كل section / card / component → ملف خاص في `widgets/`.
     - الـ body widget = layout فقط (يجمع الـ sections).
   - أضف كل ملف جديد كـ `part` في `<feature>_imports.dart`.

2. **Widget Deduplication (أولوية عالية جداً):**
   - **قبل إنشاء أي widget جديد** — ابحث عن مثيل موجود:
     - `app_shared/widgets/` — الـ widgets المشتركة.
     - الـ features الحالية — خصوصاً اللي اتبنت في نفس الـ session.
   - لو نفس التصميم 100% → استخدمه مباشرة.
   - لو فروقات بسيطة → أضف optional params للـ widget الموجود.
   - لو widget موجود في feature واحدة ومحتاجه في تانية → انقله لـ `app_shared/widgets/`.

3. **تحليل الحجم:**
   - لو `build()` > 50 سطر → استخرج Widgets فرعية لملفات منفصلة.
   - لو Cubit مع منطق متداخل جداً → فكّر تفصله أو تنظفه.

4. **تحسين الأسماء:**
   - غيّر:
     - `data`, `item`, `temp` → أسماء تعبر عن الدور (`orders`, `selectedCity`, ...).

5. **تنظيف التعليقات:**
   - احذف التعليقات التي تشرح "ماذا" يفعل الكود.
   - اترك فقط التعليقات التي تشرح "لماذا" أو قيود خاصة.

6. **Section Sub-Folders for Complex Screens:**
   - لما الشاشة فيها widgets كتير (4+ sections)، اعمل sub-folder لكل مجموعة مرتبطة.
   - كل folder يعبر عن الـ section (header/, categories/, products/).
   - الـ body يفضل في `widgets/` مباشرة.
   - ده بيخلي الكود أقرأ وأسهل في الصيانة.

```
widgets/
├── feature_body.dart          ← layout only (stays at root)
├── header/                    ← header group
│   ├── header_widget.dart
│   └── search_bar.dart
├── products/                  ← products group
│   ├── products_section.dart
│   └── product_card.dart
```

7. **Remove Unused Imports & Parameters (إلزامي):**
   - شغّل `flutter analyze` وشيل كل unused imports.
   - لو optional parameter مش بيتبعت من أي caller → شيله.
   - Warning "A value for optional parameter 'X' isn't ever given" → شيل الـ parameter.

8. **`const` Everywhere (إلزامي — NON-NEGOTIABLE):**
   - **كل widget يقدر يكون `const` → لازم يكون `const`.**
   - **كل constructor يقدر يكون `const` → لازم يكون `const`.**
   - ده مش تحسين اختياري — ده performance requirement. Flutter بيعمل skip لـ rebuild لأي widget مع `const`.

   ```dart
   // ✅ CORRECT — const on every eligible widget
   const _MyHeader();
   const SizedBox(height: 8);
   const EdgeInsetsDirectional.only(start: 16);
   const TextStyle().setMainTextColor.s14.bold;

   // ✅ CORRECT — const constructor
   class _FeatureHeader extends StatelessWidget {
     const _FeatureHeader();  // ← const constructor
     @override
     Widget build(BuildContext context) => ...;
   }

   // ❌ WRONG — missing const on eligible widget
   SizedBox(height: 8);           // ← should be const SizedBox(height: 8)
   _MyHeader();                    // ← should be const _MyHeader()
   EdgeInsets.all(16);            // ← should be const EdgeInsets.all(16)

   // ❌ WRONG — missing const constructor
   class _FeatureHeader extends StatelessWidget {
     _FeatureHeader();            // ← should be const _FeatureHeader()
   }
   ```

   **Checklist for const:**
   - [ ] كل StatelessWidget constructor → `const`
   - [ ] كل `SizedBox`, `EdgeInsets`, `BorderRadius`, `BoxDecoration` بـ literal values → `const`
   - [ ] كل widget call لـ private widgets → `const _WidgetName()`
   - [ ] كل `TextStyle()` → `const TextStyle()`
   - [ ] لو flutter analyze بيقول "Prefer const" → صلحه

9. **Helper Methods → Entity/Model NOT Widget (إلزامي):**
   - أي function بتحول data (status → color, status → label, type → icon) → حطها في model/entity class.
   - Widget class = UI rendering فقط. يستدعي الـ model ويعرض النتيجة.
   - لو عندك switch/map بيحول status لـ color/text → اعمله class في `entity/` folder.
   - ممنوع functions زي `_statusColor()`, `_statusLabel()` جوا widget.

## Output

عند استخدام هذا الـ skill، اعرض:
- قائمة بالـ widgets التي تم استخراجها لملفات منفصلة.
- قائمة بالـ widgets المكررة اللي تم توحيدها.
- أي إعادة تسمية مهمة (قبل/بعد) إن كانت مفيدة للمراجعة. 

