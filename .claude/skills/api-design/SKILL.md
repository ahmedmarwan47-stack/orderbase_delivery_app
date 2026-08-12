---
name: api-design
description: Auto-generate API contracts (Postman Collection JSON) from Figma screens — unified entities, pagination, multi-step forms, file upload.
---

# Skill: API Design — Figma Screen → Postman Collection + Flutter Integration

## When to Use

- عند قراءة أي شاشة من Figma وتحتاج تصمم الـ API ليها
- عند إضافة endpoints جديدة لأي feature
- عند إنشاء Postman Collection للـ backend team
- عند ربط الـ API بالـ Flutter code (cubits + entities + ApiConstants)

---

## The Pipeline (6 Steps)

```
Figma Screen
    ↓
Step 1: Analyze UI → identify required services
    ↓
Step 2: Design endpoints (naming, method, pagination, entities)
    ↓
Step 3: Generate ONE Postman Collection JSON (with internal folders per section)
    ↓
Step 4: Add to ApiConstants
    ↓
Step 5: Create Entity + Cubit
    ↓
Step 6: Connect to UI
```

---

## Step 1: Analyze UI — Service Extraction Rules

> **لكل شاشة من Figma، حلل الـ UI واستخرج الـ services المطلوبة بالقواعد دي:**

### Rule 1: Multi-Section Screen → Separate Service Per Section

```
شاشة فيها: Banners + Categories + Products
    ↓
GET /banners          ← service 1
GET /categories       ← service 2
GET /products         ← service 3

❌ FORBIDDEN: GET /home-data (كل حاجة في service واحدة)
```

**استثناء:** ممكن يكون عند الباك اند endpoint واحد زي `GET /home` بيرجع كل الـ sections مع بعض — ده مقبول لو الباك اند قرر كده.

### Rule 2: List Screens → Pagination Required

```
أي شاشة فيها list
    ↓
GET /resource?page=1&per_page=15
    ↓
Response يشمل: data[] + meta object
```

### Rule 3: Multi-Step Forms → Validate Per Step + Final Create

```
فورم على 3 صفحات:
    ↓
POST /resource/validate-step-1    ← validates page 1 fields
POST /resource/validate-step-2    ← validates page 2 fields
POST /resource/validate-step-3    ← validates page 3 fields
POST /resource                    ← final create (all data)
```

### Rule 4: File Uploads → Inline with Form-Data

> **الفايلات تتبعت inline مع باقي الداتا في نفس الـ request عبر form-data.**

```
POST /api/v1/{app}/resource
Content-Type: multipart/form-data

Fields:
  name: "..."
  email: "..."
  image: [FILE]              ← single file
  images[]: [FILE, FILE]     ← multiple files (array notation)

✅ CORRECT: فايل + داتا في نفس الـ request (form-data)
```

**قواعد رفع الملفات:**
- **Accepted formats**: `jpeg, jpg, png, pdf`
- **Max size**: 5MB (5120 KB) per file
- **Single file**: field name عادي (e.g., `image`, `cover_image`, `logo`)
- **Multiple files**: array notation `images[]`
- **File + text**: كلهم في نفس الـ form-data body

### Rule 5: CRUD Operations → 5 Standard Services

```
GET    /api/v1/{app}/resource              ← list (paginated)
GET    /api/v1/{app}/resource/{id}         ← detail
POST   /api/v1/{app}/resource              ← create
PUT    /api/v1/{app}/resource/{id}         ← update
DELETE /api/v1/{app}/resource/{id}         ← delete
```

### Rule 6: Toggle/Switch Endpoints

> **أي زرار toggle (تفعيل/إلغاء تفعيل) → PUT بدون body**

```
PUT /api/v1/{app}/switch-{field-name}
PUT /api/v1/{app}/resource/{id}/switch-{field-name}

Response: { "status": "success", "code": 200, "message": "..." }
```

### Rule 7: Status Change Endpoints

> **أي تغيير حالة → PUT مع الـ status في الـ URL**

```
PUT /api/v1/{app}/resource/{id}/change-status-to-{new_status}
PUT /api/v1/{app}/resource/{id}/accept
PUT /api/v1/{app}/resource/{id}/reject

Response: { "status": "success", "code": 200, "message": "..." }
```

### Rule 8: Unified Entities (CRITICAL)

> **الـ Entity واحدة في كل مكان. الـ entity في list = نفسها في detail = نفسها جوا parent entity.**

```json
// ❌ FORBIDDEN: Different response shapes for same entity
```

---

## Step 2: Endpoint Naming Convention

### URL Structure

```
{{base_url}}/api/v1/{app}/{resource}                    ← list/create
{{base_url}}/api/v1/{app}/{resource}/{id}               ← detail/update/delete
{{base_url}}/api/v1/{app}/{resource}/{id}/{action}      ← custom action on item
{{base_url}}/api/v1/{app}/{resource}/{action}            ← custom action on resource
{{base_url}}/api/v1/{resource}                           ← shared/public endpoints

app: user/ | supplier/ | admin/ | (none for shared)
```

### Naming Rules

| Rule | Example ✅ | Example ❌ |
|------|-----------|-----------|
| Kebab-case ALWAYS | `/login-with-password` | `/loginWithPassword` |
| Plural for collections | `/products` | `/product` |
| Action in URL (status change) | `/change-status-to-delivered` | body: `{"status": "delivered"}` |
| Switch prefix for toggles | `/switch-notification-status` | `/toggle-notifications` |
| Send/check/resend for OTP | `/forget-password-send-code` | `/forget-password-otp` |
| Short, descriptive | `/products` | `/get-all-products-list` |

### OTP Flow Naming Pattern

```
{action}-send-code      ← initiate (sends OTP)
{action}-check-code     ← verify OTP code
{action}-resend-code    ← resend OTP

Examples:
  forget-password-send-code / forget-password-check-code / forget-password-resend-code
  change-phone-send-code / change-phone-check-code / change-phone-resend-code
  check-code / resend-code (for registration verification)
```

---

## Step 3: Postman Collection JSON Structure

### File Location — SINGLE Collection File (MANDATORY)

```
postman/
├── app_name.postman_collection.json          ← ONE FILE — all endpoints
```

### Collection Description Standard (MANDATORY)

> **الـ Collection description لازم يكون فيه كل القواعد العامة للـ API — الباك اند والفرونت اند بيرجعوله كمرجع:**

```markdown
**Global Headers:**
- `Accept: application/json` (required)
- `Accept-Language: {{lang}}` (required — ar/en)
- `Authorization: Bearer {{token}}` (authenticated endpoints)

**Response Standard:**
- Success: `{ "status": "success", "code": 200, "message": "string", "data": {} }`
- Validation: `{ "status": "fail", "code": 422, "message": "string", "data": { "items": {} } }`
- Auth Error: `{ "status": "fail", "code": 401, "message": "string" }`

**HTTP Status Code Mapping:**
- `success` → 200 (all success operations)
- `fail` → 400/422 (validation/business error)
- `unauthenticated` → 401
- `not_found` → 404
- `needActive` → 203 (account not verified — if applicable)
- `blocked` → 423 (account blocked — if applicable)

**Pagination:**
- Query: `?page=1&per_page=15`
- Response: `data.pagination` object with `total_items`, `count_items`, `per_page`, `total_pages`, `current_page`, `next_page_url`, `prev_page_url`

**Enum/Status Values:**
(list all status enums and their possible values here)

**Notification Types:**
(list all notification types if applicable)
```

> **⚠️ الـ description ده بيتعرض في أول صفحة لما الباك اند يفتح الـ Collection — فلازم يكون شامل ومنظم**

### Collection Internal Structure (Multi-App with Nested Folders)

> **لو التطبيق فيه أكتر من app (user + supplier) → folder لكل app، جواه folders للـ features:**

```json
{
  "info": {
    "name": "App Name",
    "description": "**Response Standard:**\n\n- Success: `{ \"status\": \"success\", \"code\": 200, \"message\": \"string\", \"data\": {} }`\n- Error: `{ \"status\": \"fail\", \"code\": 422, \"message\": \"string\", \"data\": { \"items\": {} } }`\n- Pagination: `meta` object in `data` with `current_page`, `per_page`, `total`, `last_page`, `from`, `to`",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "User App",
      "item": [
        { "name": "Auth", "item": [] },
        { "name": "Account", "item": [] },
        { "name": "Logic", "item": [] }
      ]
    },
    {
      "name": "Common",
      "item": []
    },
    {
      "name": "Settings",
      "item": []
    }
  ],
  "variable": [
    { "key": "base_url", "value": "http://localhost:8000" },
    { "key": "lang", "value": "ar" },
    { "key": "user_phone", "value": "" },
    { "key": "user_token", "value": "" }
  ]
}
```

### Folder Naming Convention

| Folder | Contents |
|--------|----------|
| `{App}/Auth` | register, login, check-code, resend-code, forget-password-*, logout |
| `{App}/Account` | profile, update-profile, switch-notification-status, change-language, wallet, change-phone-* |
| `{App}/Logic` | CRUD endpoints for business logic |
| `Common` | shared endpoints across apps (categories, countries, regions, cities) |
| `Settings` | about, terms, static-options, contact-us |

### Rules

```
❌ FORBIDDEN: ملف لكل feature (auth.postman_collection.json, products.postman_collection.json)
❌ FORBIDDEN: flat list بدون folders
✅ CORRECT: ملف واحد + nested folders (App → Feature → Endpoints)
```

---

## Unified Response Format (CRITICAL — Must Match Backend Style)

### Success (no data)
```json
{
  "status": "success",
  "code": 200,
  "message": "تمت العملية بنجاح"
}
```

### Success (with data object)
```json
{
  "status": "success",
  "code": 200,
  "message": "تم الاسترجاع بنجاح.",
  "data": { ... }
}
```

### Success (paginated list)
```json
{
  "status": "success",
  "code": 200,
  "message": "تم العرض بنجاح.",
  "data": {
    "data": [ ... ],
    "pagination": {
      "total_items": 100,
      "count_items": 15,
      "per_page": 15,
      "total_pages": 7,
      "current_page": 1,
      "next_page_url": "/api/v1/resource?page=2",
      "prev_page_url": null
    }
  }
}
```

> **⚠️ الـ pagination key ممكن يكون `pagination` أو `meta` حسب الباك اند — شوف الـ Postman Collection الموجود أو اسأل الباك اند**

### Validation Error (422) — USES `data.items` NOT `errors`
```json
{
  "status": "fail",
  "code": 422,
  "message": "فشل التحقق من البيانات.",
  "data": {
    "items": {
      "field_name": ["رسالة الخطأ بالعربي"],
      "other_field": ["خطأ 1", "خطأ 2"]
    }
  }
}
```

> **⚠️ الأخطاء في `data.items.{field}` — مش `errors.{field}` — ده الباترن الحقيقي**

### Error — auth (401)
```json
{
  "status": "fail",
  "code": 401,
  "message": "بيانات الدخول غير صحيحة"
}
```

### Error — not found (404)
```json
{
  "status": "fail",
  "code": 404,
  "message": "العنصر غير موجود"
}
```

### HTTP Status Codes — ONLY THESE

| Code | When |
|------|------|
| 200 | ALL success operations (create, update, delete, get) — لا يوجد 201 أو 204 |
| 401 | Invalid credentials, expired/missing token |
| 404 | Resource not found |
| 422 | Validation errors |

> **مفيش 201 (Created) أو 204 (No Content) أو 429 أو 500 — كل success = 200**

### Status Field Values

```
"status": "success"  → عملية ناجحة
"status": "fail"     → خطأ (validation, auth, not found)
```

---

## Request Body Format (CRITICAL)

### Body Mode Decision Table

| Scenario | Body Mode |
|----------|-----------|
| Text-only POST/PUT (login, verify code, simple create) | `urlencoded` |
| POST/PUT with files (register with image, update profile) | `formdata` |
| Complex nested data (registration with objects, arrays) | `raw` JSON |
| GET requests | no body |
| DELETE requests | no body |

### When to Use Each Mode

```
✅ urlencoded — الحالة الأساسية: fields بسيطة بدون فايلات
✅ formdata — لما يكون في files أو step-based forms
✅ raw JSON — لما يكون في nested objects أو arrays معقدة (مثلاً: registration فيه location object, languages array, nested addresses)
```

### Raw JSON Body Standard (Emoji-Commented Sections)

> **لما نستخدم raw JSON → لازم نقسم الـ body بـ emoji comments عشان الباك اند يفهمه بسرعة:**

```json
{
    // 👤 Basic user info
    "image": 1,                              // id from temp files
    "name": "أحمد محمد",                     // required|string|max:50|min:2
    "email": "user@example.com",             // required|email|max:255|unique

    // 📱 Phone & auth
    "country_code": "+966",                  // required|string
    "phone": "501234567",                    // required|string|min:9|max:15|unique
    "password": "Pa$$w0rd",                  // required|string|min:8
    "password_confirmation": "Pa$$w0rd",     // required|same:password

    // 🎂 Personal info
    "date_of_birth": "1995-03-12",           // nullable|date_format:Y-m-d
    "gender": "male",                        // required|in:male,female

    // 🌍 Location info
    "country_id": 1,                         // required|exists:countries,id
    "city_id": 2,                            // required|exists:cities,id
    "lat": "24.7136",                        // nullable|numeric
    "lng": "46.6753",                        // nullable|numeric

    // 🗣️ Languages & specializations
    "languages": [1, 3],                     // required|array — from get-register-data
    "specializations": [5, 7],               // nullable|array — from get-register-data

    // 📱 Device info
    "device_id": "abc123",                   // nullable|string
    "device_type": "android",                // nullable|in:ios,android,web

    // ✅ Terms
    "is_terms": true                         // required|accepted
}
```

**قواعد الـ emoji comments:**
- `👤` Basic user info (name, email, image)
- `📱` Phone & auth (phone, password, device)
- `🎂` Personal info (DOB, gender)
- `🌍` Location (country, city, lat/lng, address)
- `🗣️` Languages & skills
- `🏦` Banking info (bank name, IBAN, account)
- `📄` Documents & files (license, certifications)
- `🔐` Password & security
- `✅` Terms & acceptance

### URL-Encoded Example
```json
{
  "body": {
    "mode": "urlencoded",
    "urlencoded": [
      { "key": "phone", "value": "501234567", "type": "text", "description": "required, string, max:20" },
      { "key": "password", "value": "Pa$$w0rd", "type": "text", "description": "required, string, min:8" }
    ]
  }
}
```

### Form-Data Example (with files)
```json
{
  "body": {
    "mode": "formdata",
    "formdata": [
      { "key": "name", "value": "أحمد", "type": "text", "description": "required, string, max:255" },
      { "key": "image", "type": "file", "description": "required, file, mimes:jpeg,jpg,png,pdf, max:5120 (5MB)" },
      { "key": "images[]", "type": "file", "description": "nullable, array of files, mimes:jpeg,jpg,png, max:5120" }
    ]
  }
}
```

### Field Description Convention (MANDATORY — Laravel Validation Format)

> **كل field لازم يكون ليه `description` بقواعد الـ validation بصيغة Laravel (pipe-separated):**

**Format: pipe-separated** `required|string|max:255|min:2`

```
"description": "required|string|max:255"
"description": "required|email|max:255|unique"
"description": "nullable|string|max:500"
"description": "required|file|mimes:jpeg,jpg,png,pdf|max:5120"
"description": "nullable|numeric|between:-90,90"
"description": "nullable|string|max:10|default:+966"
"description": "required|exists:countries,id"
"description": "required|in:first,second,third"
"description": "required|min:8|same:password"
"description": "required|array"
"description": "required|accepted"
```

**Validation keywords**: `required`, `nullable`, `string`, `numeric`, `email`, `file`, `image`, `array`, `boolean`, `integer`, `max:N`, `min:N`, `between:N,M`, `mimes:...`, `unique`, `exists:table,column`, `in:val1,val2,val3`, `regex:pattern`, `default:VALUE`, `same:field`, `accepted`, `date`, `date_format:Y-m-d`

**Relationship descriptions** (عند الحاجة):
```
"description": "required|integer — id from temp files upload"
"description": "required|array — from spoken languages at get-register-data"
"description": "required|exists:categories,id"
```

### Boolean Values — Integer 1/0

```json
// Response:
"is_active": 1,
"is_notify": 1

// Request (form-data/urlencoded):
"has_customization": "1"   ← string "1" not boolean true
"is_active": "0"           ← string "0" not boolean false
```

---

## Headers (MANDATORY — Every Request)

```json
[
  { "key": "Accept", "value": "application/json" },
  { "key": "Accept-Language", "value": "{{lang}}" }
]
```

**Authenticated endpoints add:**
```json
{ "key": "Authorization", "value": "Bearer {{user_token}}" }
```

> **مفيش `Content-Type` header يدوي — Postman/Dio بتحدده تلقائياً**

---

## Endpoint Documentation Standard (MANDATORY)

> **كل endpoint لازم يكون فيه documentation عالية الجودة — الباك اند والفرونت اند بيعتمدوا عليها.**

### Level 1: Simple Endpoints (GET list, GET detail, DELETE)

```
description: "[mobile figma design](https://figma.com/...)\n[web figma design](https://figma.com/...)\n\nجلب قائمة المنتجات مع pagination وفلترة حسب الفئة"
```

**المطلوب:**
- لينك Figma للموبايل (لو موجود)
- لينك Figma للويب (لو موجود)
- سطر وصف عربي مختصر

### Level 2: Complex Endpoints (POST/PUT create, register, multi-step)

```markdown
[mobile figma design](https://figma.com/...)
[web figma design](https://figma.com/...)

### POST /api/v1/{app}/resource

إنشاء عنصر جديد مع رفع صور وملفات.

**Auth:** Bearer Token
**Headers:** Accept, Accept-Language, Authorization

### Request body (formdata/urlencoded)
- `name`: string (required, 2-50 chars)
- `email`: string (required, email, max:255, unique)
- `phone`: string (required, 9-15 digits, unique)
- `image`: file (nullable, mimes:jpeg,jpg,png, max:5MB)
- `category_id`: integer (required, exists:categories)

### Success Response (200)
{ "status": "success", "code": 200, "message": "تم الإنشاء بنجاح", "data": { ... } }

### Error Responses
- 422: Validation errors (data.items.{field})
- 401: Unauthorized

### Notes
- الصور تترفع inline مع الـ form-data
- الـ phone لازم يكون unique
```

### Figma Links Rule (MANDATORY for every endpoint)

> **كل endpoint لازم يكون فيه لينك الـ Figma الخاص بالشاشة:**

```json
"description": "[mobile figma design](https://figma.com/proto/...?node-id=XX-YYYY)\n[web figma design](https://figma.com/proto/...?node-id=XX-ZZZZ)\n\nوصف الـ endpoint"
```

- لو مفيش Figma link → اكتب `[figma: pending]`
- لو في موبايل بس → اكتب لينك الموبايل بس
- الـ node-id لازم يكون specific للشاشة

---

## Collection Item Template

```json
{
  "name": "endpoint-name",
  "event": [
    {
      "listen": "prerequest",
      "script": {
        "exec": ["// pre-request script if needed"],
        "type": "text/javascript"
      }
    },
    {
      "listen": "test",
      "script": {
        "exec": ["// test script — e.g. save token"],
        "type": "text/javascript"
      }
    }
  ],
  "request": {
    "method": "POST",
    "header": [
      { "key": "Accept", "value": "application/json" },
      { "key": "Accept-Language", "value": "{{lang}}" }
    ],
    "body": {
      "mode": "urlencoded",
      "urlencoded": [
        { "key": "field", "value": "value", "type": "text", "description": "required|string|max:255" }
      ]
    },
    "url": {
      "raw": "{{base_url}}/api/v1/{app}/resource",
      "host": ["{{base_url}}"],
      "path": ["api", "v1", "{app}", "resource"]
    },
    "description": "[mobile figma design](https://figma.com/...)\n[web figma design](https://figma.com/...)\n\nوصف عربي مفصل للـ endpoint."
  },
  "response": [
    {
      "name": "success",
      "status": "OK",
      "code": 200,
      "body": "{\"status\":\"success\",\"code\":200,\"message\":\"...\",\"data\":{...}}"
    },
    {
      "name": "fail validation",
      "status": "Unprocessable Content",
      "code": 422,
      "body": "{\"status\":\"fail\",\"code\":422,\"message\":\"فشل التحقق من البيانات.\",\"data\":{\"items\":{...}}}"
    }
  ]
}
```

### Response Example Naming Convention (MANDATORY)

> **أسماء الـ response examples لازم تكون وصفية (scenario-based) — مش بس success/error:**

| Example Name Pattern | When to Use |
|---------------------|-------------|
| `success` | Standard success |
| `fail validation` | Validation error (422) |
| `fail unauthorized` | Auth error (401) |
| `fail not found` | Resource not found (404) |
| `success first step` | Success for step 1 in multi-step form |
| `validation first step` | Validation error for step 1 |
| `success {account_type}` | Success for specific account type/role |
| `empty response` | No data available |
| `fail {specific_reason}` | Specific error condition |

**قاعدة:** لو الـ endpoint فيه أكتر من سيناريو (multi-step, multi-type) → response example لكل سيناريو

### Pre-Request Script Pattern (Auto-save phone from request)
```javascript
let phone = null;
if (pm.request.body?.mode === "formdata") {
    phone = pm.request.body.formdata.find(x => x.key === "phone")?.value;
}
if (pm.request.body?.mode === "urlencoded") {
    phone = pm.request.body.urlencoded.find(x => x.key === "phone")?.value;
}
if (phone) {
    pm.collectionVariables.set("user_phone", phone);
}
```

### Test Script Pattern (Auto-save token from response)
```javascript
const res = pm.response.json();

// Pattern 1: token inside data.user.token
if (res?.data?.user?.token) {
    pm.collectionVariables.set("user_token", res.data.user.token);
    pm.environment.set("user_token", res.data.user.token);
}

// Pattern 2: token inside data.token
if (res?.data?.token) {
    pm.collectionVariables.set("user_token", res.data.token);
    pm.environment.set("user_token", res.data.token);
}

// Also save phone and country_code if present
if (res?.data?.phone) {
    pm.collectionVariables.set("user_phone", res.data.phone);
    pm.environment.set("user_phone", res.data.phone);
}
if (res?.data?.country_code) {
    pm.collectionVariables.set("user_country_code", res.data.country_code);
    pm.environment.set("user_country_code", res.data.country_code);
}
```

> **⚠️ دايماً save في الاتنين: `pm.collectionVariables` + `pm.environment` — عشان يشتغل في أي بيئة**

---

## Status Object Pattern (Rich Status/Enum Fields)

> **الباك اند بيرجع الـ status/enum fields كـ object فيه value + text_ar + text_en + tag_color:**

```json
"status": {
  "value": "pending_review",
  "text_ar": "قيد المراجعة",
  "text_en": "Pending Review",
  "tag_color": "yellow"
}

"payment_method": {
  "value": "wallet",
  "text_ar": "المحفظة",
  "text_en": "Wallet"
}
```

**Entity pattern:**
```dart
class StatusEntity {
  final String value;
  final String textAr;
  final String textEn;
  final String tagColor;

  factory StatusEntity.fromJson(Map<String, dynamic> json) => StatusEntity(
    value: json['value']?.toString() ?? '',
    textAr: json['text_ar']?.toString() ?? '',
    textEn: json['text_en']?.toString() ?? '',
    tagColor: json['tag_color']?.toString() ?? '',
  );
}
```

**Tag color mapping:**
```dart
Color get color => switch (tagColor) {
  'yellow' => AppColors.warning,
  'green' => AppColors.success,
  'red' => AppColors.error,
  'blue' => AppColors.info,
  _ => AppColors.grey,
};
```

---

## Nested Entity / Lookup Pattern

> **الباك اند بيرجع foreign keys كـ objects مش IDs فقط:**

```json
"category": { "id": 1, "slug": "...", "name": "..." }
"supplier": { "id": 1, "name": "...", "image": "..." }
```

---

## Computed/Label Fields Pattern

> **الباك اند بيرجع labels جاهزة للعرض:**

```json
"delivery_time_min": 1,
"delivery_time_max": 3,
"delivery_time_label": "1-3 أيام",

"min_order_amount": 500,
"min_order_label": "500 ريال",

"distance_km": 12.5,
"distance": "12.5 كم"
```

> **استخدم الـ label fields في الـ UI مباشرة — أسهل وأضمن للترجمة.**

---

## Additional Tags Pattern

```json
"additional_tags": [
  { "text_ar": "مخصص", "text_en": "Custom", "icon": "pencil_edit" }
]
```

---

## Step 4: Add to ApiConstants

```dart
class ApiConstants {
  // Naming: match URL kebab-case as camelCase
  // Static const for fixed endpoints
  // Static method for dynamic endpoints (with ID)

  static const String resource = '{app}/resource';
  static String resourceDetail(String id) => '{app}/resource/$id';
  static String resourceChangeStatus(String id, String status) => '{app}/resource/$id/change-status-to-$status';
  static String switchResourceField(String id) => '{app}/resource/$id/switch-activation-status';
}
```

---

## Step 5: Entity + Cubit

### Entity — with Rich Status Object

```dart
class SomeEntity {
  final String id;
  final String name;
  final StatusEntity status;     // ← rich object, NOT string
  final CategoryEntity category; // ← nested object, NOT ID
  final String deliveryLabel;    // ← pre-computed label from backend

  factory SomeEntity.fromJson(Map<String, dynamic> json) => SomeEntity(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    status: json['status'] is Map
        ? StatusEntity.fromJson(json['status'])
        : StatusEntity.initial(),
    category: json['category'] is Map
        ? CategoryEntity.fromJson(json['category'])
        : CategoryEntity.initial(),
    deliveryLabel: json['delivery_time_label']?.toString() ?? '',
  );
}
```

---

## Postman Collection Generation Checklist

### Structure & Organization
- [ ] **ملف واحد فقط** `postman/app_name.postman_collection.json`
- [ ] **Collection description** شامل: Response Standard + Status Codes + Pagination rules + Enums
- [ ] Nested folders: App → Feature → Sub-feature → Endpoints
- [ ] Endpoint names: **kebab-case**
- [ ] URL: `{{base_url}}/api/v1/{app}/{resource}`

### Documentation Quality
- [ ] كل endpoint فيه **Figma link** (mobile + web) في الـ description
- [ ] Endpoints المعقدة فيها **full markdown docs** (method, auth, headers, fields, examples, notes)
- [ ] وصف عربي لكل endpoint
- [ ] **Response examples بأسماء وصفية** (scenario-based) — مش بس success/error

### Request Format
- [ ] **Body mode**: `urlencoded` for text, `formdata` for files, `raw JSON` for complex nested only
- [ ] Every field has **description** with Laravel validation rules (pipe-separated: `required|string|max:255`)
- [ ] Relationship fields documented: `required|integer — id from temp files`
- [ ] Array fields use `[]` notation: `images[]`, `languages[]`

### Response Format
- [ ] All success = 200 (no 201, 204)
- [ ] Pagination: `pagination` object (default — confirm with backend if `meta`)
- [ ] **422 format**: `data.items.{field}: [errors]` — NOT `errors.{field}`
- [ ] Status/enum fields: rich objects `{ value, text_ar, text_en, tag_color }`
- [ ] Booleans: integer 1/0 in responses, string "1"/"0" in requests
- [ ] Response examples لكل حالة: success, fail validation, fail unauthorized, specific scenarios

### Headers & Variables
- [ ] Headers: `Accept` + `Accept-Language` always, `Authorization` for auth endpoints
- [ ] Collection variables: `base_url`, `lang`, tokens, phones, country_codes
- [ ] Pre-request scripts: capture phone from body
- [ ] Test scripts: extract token + phone + country_code from response — save to both environment AND collection variables

### Special Patterns
- [ ] Forms with dropdowns → `get-{form}-data` endpoint
- [ ] File uploads: inline with form-data (or temp upload if backend supports)
- [ ] Multi-step forms: response example per step + per account type
- [ ] OTP flows: send-code / check-code / resend-code pattern

---

## Registration Form Data Endpoint Pattern (get-register-data)

> **أي فورم فيه dropdowns (countries, cities, categories, languages) → لازم يكون في endpoint يرجع الـ data المطلوبة:**

```
GET /api/v1/{app}/auth/get-register-data

Response:
{
  "status": "success",
  "data": {
    "countries": [{ "id": 1, "name": "السعودية", "code": "+966" }],
    "cities": [{ "id": 1, "name": "الرياض", "country_id": 1 }],
    "categories": [{ "id": 1, "name": "..." }],
    "languages": [{ "id": 1, "name": "العربية" }],
    "specializations": [{ "id": 1, "name": "..." }]
  }
}
```

**القاعدة:** أي form فيه dropdown بيعتمد على داتا من الباك اند → endpoint `get-{form-name}-data` يرجع كل الـ lookup lists المطلوبة.

---

## Temporary File Upload Pattern (اختياري — لو الباك اند بيدعمه)

> **بعض الباك اندات بتقبل رفع مؤقت أولاً → أخد IDs → استخدامها في الفورم الرئيسي:**

```
1. POST /api/v1/upload-temp-files
   Body (formdata): temp_files[] = [FILE1, FILE2]
   Response: [{ "id": 1, "file": "https://..." }, { "id": 2, "file": "https://..." }]

2. POST /api/v1/{app}/resource
   Body: { "image": 1, "certifications": [1, 2] }  ← IDs from step 1
```

**متى نستخدمه:**
- Forms معقدة فيها أكتر من فايل
- عشان الـ user يرفع قبل ما يبعت الفورم كله
- لو الـ form fail → الفايلات مرفوعة ومش محتاج يرفع تاني

**متى ما نستخدمهوش (الباترن الأساسي):**
- الفايل بيتبعت inline مع الـ form-data في نفس الـ request
- ده الباترن الأبسط والأشهر

---

## Auth Flow Pattern

```
1. POST register (formdata — may include file)
   → { "status": "success", "message": "تم إرسال كود التفعيل بنجاح" }

2. POST check-code (urlencoded: phone, code)
   → { "status": "success", "data": { "user": { ..., "token": "N|xxxxx" } } }

3. POST login-with-password (urlencoded: phone, password, device_token, device_type)
   → { "status": "success", "data": { "user": { ..., "token": "N|xxxxx" } } }

Token location: data.user.token
Token format: Bearer {token} in Authorization header
Token type: Laravel Sanctum (format: "N|alphanumeric_string")
```

---

## Query Parameters Pattern

```
page=1                      # Page number (1-indexed)
per_page=15                 # Items per page (default 15)
search=                     # Search string (full text)
q=                          # Alternative search (short form)
sort=all                    # Sort option
category_id=1               # Filter by FK
status=                     # Filter by status value
type=                       # Filter by type
```
