---
name: notifications
description: FCM push notifications via awesome_notifications — NotificationManager singleton + NotificationRouter (sealed actions) + NotificationController (FCM handlers) + foreground/background/terminated isolate plumbing. Read this any time the feature touches push notifications, deep links from a notification tap, in-app local notifications, FCM token retrieval, or notification channels.
---

# Notifications — FCM via awesome_notifications

> **Module location:** `lib/src/core/notifications/`
> **Forbidden packages:** `firebase_messaging`, `flutter_local_notifications` — they conflict with `awesome_notifications`. Do **not** add them to `pubspec.yaml`.

---

## 1. Architecture in one breath

```
FCM data message ──▶ awesome_notifications_fcm ──▶ NotificationController.mySilentDataHandle
                                                           │
                                                           ▼
                                                  NotificationPayload.fromMap(data)
                                                           │
                                                           ▼
                                              AwesomeNotifications().createNotification(...)
                                                           │
              user taps notification ─────────────────────▶│
                                                           ▼
                                              NotificationController.onActionReceivedMethod
                                                           │
                                       background isolate? ── yes ──▶ IsolateNameServer SendPort ──▶ main isolate
                                                           │ no
                                                           ▼
                                                  routeAction(receivedAction)
                                                           │
                                                  _parseAction(data) → NotificationAction (sealed)
                                                           │
                                                           ▼
                                              AppNotificationRouter.route(action)
                                                           │
                                                           ▼
                                              Modular.routerDelegate.navigatorKey.currentState!.pushNamed(...)
```

**Files:**
| File | Role |
|---|---|
| `notification_manager.dart` | Singleton entry point — `initialize`, `requestToken`, `requestPermissions`, `dispose`. Hosts the `ReceivePort` for the main isolate. |
| `notification_router.dart` | `sealed class NotificationAction` + concrete actions (`NavigateToChat`, `NavigateToScreen`, `OpenUrl`, `DismissAction`) + `abstract interface class NotificationRouter` + `AppNotificationRouter` implementation (uses `Modular.routerDelegate.navigatorKey`). |
| `notification_controller.dart` | Static FCM handlers (`@pragma('vm:entry-point')`), channel registration, content/buttons builders, isolate bridging. |
| `models/notification_payload.dart` | `final class NotificationPayload` — value object built from FCM `data` map. |
| `models/notification_enums.dart` | `NotificationType` (message/media/call/alert) + `NotificationChannel` (messaging/general/system). |
| `EXPLANATION.md` | Line-by-line Arabic walkthrough of the whole system (for beginners). |

---

## 2. Bootstrap (in `main.dart` — already wired)

```dart
// 1. Firebase must come first
await Firebase.initializeApp();

// 2. Initialize notifications (registers channels, FCM handlers, isolate port)
await NotificationManager.instance.initialize(
  router: const AppNotificationRouter(),   // routes via Modular.routerDelegate.navigatorKey (shared with the app)
  debug: kDebugMode,
);

// 3. Inside MyApp.initState (after UI is up so the permission dialog shows correctly)
NotificationManager.instance.requestPermissions();
NotificationManager.instance.requestToken();
```

**Initialization order matters:**
```
1. Save the router               (so subsequent steps can use it)
2. Local channels                (Messaging / General / System — registered before FCM hooks fire)
3. FCM handlers                  (data, token, native token)
4. Isolate ReceivePort           (so background-isolate taps can reach the main isolate)
5. Start listening to events     (action taps, dismissals)
6. _getInitialNotificationAction (handles "app was terminated, user tapped, app is opening now")
```

---

## 3. Sealed `NotificationAction` — single source of truth for taps

```dart
// notification_router.dart
sealed class NotificationAction { const NotificationAction(); }

final class NavigateToChat extends NotificationAction {
  final String chatId;
  const NavigateToChat(this.chatId);
}

final class NavigateToScreen extends NotificationAction {
  final String route;
  const NavigateToScreen(this.route);
}

final class OpenUrl extends NotificationAction {
  final Uri url;
  const OpenUrl(this.url);
}

final class DismissAction extends NotificationAction {
  const DismissAction();
}

abstract interface class NotificationRouter {
  Future<void> route(NotificationAction action);
}

final class AppNotificationRouter implements NotificationRouter {
  const AppNotificationRouter();

  @override
  Future<void> route(NotificationAction action) async {
    final nav = Modular.routerDelegate.navigatorKey.currentState;
    switch (action) {
      case NavigateToChat(:final chatId):
        await nav?.pushNamed('/chat', arguments: chatId);
      case NavigateToScreen(:final route):
        await nav?.pushNamed(route);
      case OpenUrl(:final url):
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      case DismissAction():
        break;   // no-op — exhaustiveness enforced by the compiler
    }
  }
}
```

**Why sealed?** The `switch` is exhaustive — adding a new case in `NotificationAction` immediately surfaces every place that needs to handle it. No string-comparison routing, no silent fallbacks.

---

## 4. Adding a new notification type — 5-step recipe

When the backend introduces a new notification (e.g. "order shipped"):

### Step 1 — Extend the enum
```dart
// models/notification_enums.dart
enum NotificationType { message, media, call, alert, orderUpdate /* ← new */ }
```

### Step 2 — Tell the content builder how to render it
```dart
// notification_controller.dart  →  _buildContent
final layout = switch (payload.type) {
  app_enums.NotificationType.media       => NotificationLayout.BigPicture,
  app_enums.NotificationType.message     => NotificationLayout.BigText,
  app_enums.NotificationType.call        => NotificationLayout.Default,
  app_enums.NotificationType.alert       => NotificationLayout.Default,
  app_enums.NotificationType.orderUpdate => NotificationLayout.BigText, // ← new
};
```

### Step 3 — (Optional) Action buttons
```dart
// notification_controller.dart  →  _buildActionButtons
return switch (payload.type) {
  app_enums.NotificationType.call => [/* accept / reject */],
  app_enums.NotificationType.orderUpdate => [
    NotificationActionButton(key: 'TRACK', label: 'تتبع الطلب'),
  ],
  _ => null,
};
```

### Step 4 — Add the routing target (if tapping should navigate somewhere new)
```dart
// notification_router.dart
final class NavigateToOrder extends NotificationAction {
  final int orderId;
  const NavigateToOrder(this.orderId);
}
```

### Step 5 — Parse it from the FCM data payload
```dart
// notification_controller.dart  →  _parseAction
return switch (data['action_type']) {
  'navigate_chat'   => NavigateToChat(data['chat_id'] ?? ''),
  'navigate_screen' => NavigateToScreen(data['route'] ?? '/'),
  'open_url'        => OpenUrl(Uri.parse(data['url'] ?? '')),
  'navigate_order'  => NavigateToOrder(int.tryParse(data['order_id'] ?? '') ?? 0),
  _                 => const DismissAction(),
};
```

The router's `switch (action)` will now refuse to compile until you add `case NavigateToOrder(...)`. That's the point.

---

## 5. Sending an in-app local notification

Use `AwesomeNotifications().createNotification(...)` directly. Same channel keys you registered in `initialize`:

```dart
await AwesomeNotifications().createNotification(
  content: NotificationContent(
    id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
    channelKey: NotificationChannel.general.name,
    title: 'تم الحفظ',
    body: 'تم حفظ التغييرات بنجاح.',
    notificationLayout: NotificationLayout.Default,
  ),
);
```

---

## 6. Golden rules (لازم تعرفها)

| الـ Rule | السبب |
|---------|------|
| كل static method بتتنادى من native لازم `@pragma('vm:entry-point')` | الـ tree-shaker بيمسحها في release build لو مش mentioned |
| `channelKey` في `NotificationContent` لازم يتطابق مع المسجل في `initialize` | لو غلط، الإشعار silently مش هيظهر |
| الـ `id` في `NotificationContent` لازم `int` | استخدم `payload.id.hashCode` لو الـ id جاي String |
| ممنوع `BuildContext` في static handlers | استخدم `Modular.routerDelegate.navigatorKey` (`GlobalKey<NavigatorState>` shared with MaterialApp) |
| `IsolateNameServer` هو الطريقة الوحيدة لتواصل background → main | الـ isolates مفيهاش shared memory — `ReceivePort.sendPort` المسجل بـ name هو الـ bridge |
| **ممنوع `firebase_messaging`** | يتعارض مع `awesome_notifications` |
| **ممنوع `flutter_local_notifications`** | يتعارض مع `awesome_notifications` |
| السيرفر يبعت **data-only** messages (`data` بدون `notification`) | عشان نتحكم في الـ layout/buttons من الموبايل |
| `removeFromActionEvents: true` في `getInitialNotificationAction` | عشان الـ action ما تتاخدش مرتين |

---

## 7. Permissions & tokens

```dart
// Ask the user (iOS + Android 13+ — required)
final granted = await NotificationManager.instance.requestPermissions();

// Get FCM token to send to your backend
await NotificationManager.instance.requestToken();
// The token arrives via NotificationController.myFcmTokenHandle (registered in initializeRemoteNotifications)
```

**Backend stores `(userId, fcmToken)` and sends to that token via FCM HTTP v1 API.**

---

## 8. Native configuration (already wired — don't re-do)

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>       <!-- Android 13+ -->
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>   <!-- scheduled notifs survive reboot -->
<uses-permission android:name="android.permission.WAKE_LOCK"/>                <!-- light up the screen -->
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>   <!-- incoming-call UI -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>     <!-- Android 12+ scheduled -->
```

### Android Gradle
- `settings.gradle.kts` → `id("com.google.gms.google-services") version "4.4.2" apply false`
- `app/build.gradle.kts` → `id("com.google.gms.google-services")`

### iOS
- `Podfile` → `platform :ios, '15.0'` (minimum for awesome_notifications)
- Xcode Capabilities:
  - **Push Notifications**
  - **Background Modes → Remote notifications** (data messages in background)
  - **Background Modes → Background fetch** (background isolate)
  - **App Groups** (awesome_notifications shared storage)

---

## 9. Debugging checklist

- [ ] الإشعار مش بيظهر؟ → `channelKey` غلط أو القناة مش مسجلة.
- [ ] الإشعار يظهر في foreground بس مش في background/terminated؟ → `@pragma('vm:entry-point')` ناقصة على `mySilentDataHandle` أو `onActionReceivedMethod`.
- [ ] التطبيق بيعمل crash لما المستخدم يدوس على الإشعار وهو terminated؟ → `Modular.routerDelegate.navigatorKey` مش مرتبط بـ `MaterialApp.navigatorKey`، أو الـ `_getInitialNotificationAction` ما تستدعاش في `initialize`.
- [ ] الإشعار يجي مكرّر؟ → `removeFromActionEvents: true` ناقص.
- [ ] iOS مش بيستلم؟ → APNs certificate مش مرفوع في Firebase Console، أو Capabilities ناقصة.
- [ ] Android 13 مش بيظهر إشعارات؟ → `POST_NOTIFICATIONS` permission مش مطلوبة من المستخدم — `NotificationManager.instance.requestPermissions()` لازم يتستدعى.

---

## 10. Quick links

- **Code:** `lib/src/core/notifications/`
- **Line-by-line walkthrough (Arabic):** `lib/src/core/notifications/EXPLANATION.md`
- **Bootstrap:** `lib/main.dart` (search `NotificationManager.instance.initialize`)
- **Routing target convention:** `Modular.routerDelegate.navigatorKey` — same key used by `MaterialApp.navigatorKey`
