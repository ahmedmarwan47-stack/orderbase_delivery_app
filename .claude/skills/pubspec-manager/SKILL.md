---
name: pubspec-manager
description: Package detection, platform configuration, method channels, and dependency management for Flutter_Base.
---

# Skill: pubspec.yaml Package Manager

## Purpose
When a Figma design requires a package not already in pubspec.yaml, automatically add it and run flutter pub get.

---

## Step 1: Check What's Already Installed

**Already in Flutter_Base pubspec.yaml — DO NOT re-add these:**

```yaml
# Networks & Firebase
dio, firebase_core, firebase_messaging, flutter_local_notifications,
pretty_dio_logger, firebase_remote_config

# Localization
intl, easy_localization, easy_logger

# Tools
image_picker, file_picker, image_cropper, flutter_html, video_player,
cached_network_image, carousel_slider, dropdown_search,
flutter_screenutil, flutter_secure_storage, flutter_offline, pinput

# State Management
equatable, flutter_bloc, hydrated_bloc, get_it, multiple_result, injectable

# UI & Animations
flutter_spinkit, flutter_svg, lottie, skeletonizer, flutter_animate

# Storage
shared_preferences, path_provider

# Sharing
share_plus, url_launcher, rxdart
```

---

## Step 2: Detect Required Packages from Figma Design

When reading a Figma node, detect these visual patterns and map to packages:

| Figma Element | Required Package | Already Installed? |
|---------------|-----------------|-------------------|
| Map/location pin icon | `google_maps_flutter` | ❌ Need to add |
| QR code component | `qr_flutter` or `mobile_scanner` | ❌ Need to add |
| Video player frame | `video_player` | ✅ Already there |
| Image carousel/slider | `carousel_slider` | ✅ Already there |
| Rating stars | `flutter_rating_bar` | ❌ Need to add |
| Chart/graph | `fl_chart` | ❌ Need to add |
| WebView frame | `webview_flutter` | ❌ Need to add |
| OTP/PIN input | `pinput` | ✅ Already there |
| Signature pad | `signature` | ❌ Need to add |
| Barcode component | `mobile_scanner` | ❌ Need to add |
| Rich text editor | `flutter_quill` | ❌ Need to add |
| Date/time picker special | already in Flutter | ✅ Built-in |
| Shimmer loading | `skeletonizer` | ✅ Already there |
| Lottie animation | `lottie` | ✅ Already there |
| SVG image | `flutter_svg` | ✅ Already there |
| Network image | `cached_network_image` | ✅ Already there |
| Dropdown search | `dropdown_search` | ✅ Already there |
| HTML content | `flutter_html` | ✅ Already there |

---

## Step 3: Add Missing Package

When a package is NOT in pubspec.yaml and is needed:

### 3a. Find latest stable version
```
Search: "package_name pub.dev" to find current version
Or use: https://pub.dev/packages/{package_name}
```

### 3b. Add to correct section in pubspec.yaml
```yaml
# UI & Animations section
  flutter_rating_bar: ^4.0.1
  fl_chart: ^0.69.0
  google_maps_flutter: ^2.10.0
```

### 3c. Run flutter pub get
```bash
cd /path/to/project && flutter pub get
```

### 3d. Verify installation
```bash
flutter pub deps | grep package_name
```

---

## Step 4: Platform-Specific Setup Reminders

If adding these packages, remind the user of platform setup needed:

| Package | Platform Setup Required |
|---------|------------------------|
| `google_maps_flutter` | Add API key to AndroidManifest.xml and AppDelegate.swift/Info.plist |
| `webview_flutter` | iOS: add NSAppTransportSecurity to Info.plist |
| `mobile_scanner` | Add camera permission to AndroidManifest + Info.plist |
| `image_picker` | Already configured in base (image_picker is installed) |
| `firebase_*` | Already configured (firebase_core is installed) |

---

## Step 5: Import in Dart File

After adding to pubspec, add the correct import:

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
```

---

## Step 6: Platform Configuration — Android & iOS (MANDATORY)

> **أي feature تحتاج access لـ gallery, camera, microphone, location, maps — لازم تضيف الـ configuration files للـ Android و iOS.**

### Android — `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Camera -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Gallery / Storage -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Microphone / Audio -->
<uses-permission android:name="android.permission.RECORD_AUDIO" />

<!-- Location / Maps -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<!-- Google Maps API Key (inside <application>) -->
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

### iOS — `ios/Runner/Info.plist`

```xml
<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>يحتاج التطبيق للوصول إلى الكاميرا</string>

<!-- Gallery -->
<key>NSPhotoLibraryUsageDescription</key>
<string>يحتاج التطبيق للوصول إلى الصور</string>

<!-- Microphone -->
<key>NSMicrophoneUsageDescription</key>
<string>يحتاج التطبيق للوصول إلى الميكروفون</string>

<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>يحتاج التطبيق للوصول إلى موقعك</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>يحتاج التطبيق للوصول إلى موقعك في الخلفية</string>
```

### iOS — Google Maps Setup (`ios/Runner/AppDelegate.swift`)
```swift
import GoogleMaps

GMSServices.provideAPIKey("YOUR_API_KEY")
```

---

## Step 7: Method Channels over permission_handler (PREFERRED)

> **لو محتاج permission لـ camera, gallery, microphone, location — استخدم method channels بدل `permission_handler` package.**

**لماذا:**
- أقل dependencies
- تحكم أكبر في الـ native behavior
- أسهل في التحديث والصيانة

**الاستثناء:**
- لو الـ feature معقدة وتحتاج multiple permissions في وقت واحد مع UI management → يمكن استخدام package

---

## Step 8: Use Packages When Available (DON'T Build from Scratch)

> **لو فيه حاجة ممكن تتعمل بـ package موجود ومستقر → استخدم الـ package بدل ما تبنيها من الصفر.**

| Feature | Use Package | Don't Build |
|---------|-------------|-------------|
| Rating stars | `flutter_rating_bar` | ❌ Custom star widget |
| Charts/graphs | `fl_chart` | ❌ Custom canvas drawing |
| QR code | `qr_flutter` / `mobile_scanner` | ❌ Custom QR renderer |
| Maps | `google_maps_flutter` | ❌ Custom map widget |
| HTML content | `flutter_html` (already installed) | ❌ Custom HTML parser |
| Signature | `signature` | ❌ Custom gesture drawing |
| WebView | `webview_flutter` | ❌ Custom browser |

**قبل ما تبني أي حاجة من الصفر:**
1. ابحث على pub.dev عن package مناسب
2. تأكد إنه مستقر (likes كتير، maintained)
3. تأكد إنه compatible مع الـ Flutter version الحالية
4. أضفه للـ pubspec.yaml وشغل `flutter pub get`

---

## Workflow for AI Agent

```
1. Read Figma design node
2. Identify all UI components that need packages
3. Check list above for what's already in base pubspec
4. For missing packages:
   a. Find latest version on pub.dev
   b. Add to pubspec.yaml in correct category section
   c. Run: flutter pub get
   d. Show user any platform-specific setup needed
5. Then generate Flutter code using the new package
```
