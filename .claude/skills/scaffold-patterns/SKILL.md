---
name: scaffold-patterns
description: Quick scaffold selection guide and status bar rules for Flutter_Base screens.
---

# Scaffold & Status Bar — Unified Rules

## The 3 Scaffold Types — Choose Correctly EVERY Time

| Screen type | Scaffold | Status bar color | Status bar icons |
|---|---|---|---|
| **Inner screens** (lists, details, settings, sub-pages) | `DefaultScaffold` | `AppColors.loginPrimary` (auto) | `Brightness.light` (auto) |
| **Auth screens** (login, register, verify, forgot password) | Plain `Scaffold` + `SafeArea` | `AppColors.scaffoldBackground` | `Brightness.dark` |
| **Home screen** (bottom nav tabs) | Custom `Scaffold` + `CustomNavigationBar` | `AppColors.loginPrimary` | `Brightness.light` |

---

## Rule 1: Inner Screens → DefaultScaffold ONLY

> **NEVER** build a custom header/appbar inside body widgets.
> `DefaultScaffold` handles: colored header, back arrow, title, trailing, SafeArea, and **status bar color**.

```dart
// ✅ CORRECT — all inner screens
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<MyCubit>()..fetchData(),
      child: DefaultScaffold(
        title: LocaleKeys.myTitle.tr(),
        body: const _MyBody(),
      ),
    );
  }
}
```

```dart
// ❌ FORBIDDEN — custom header inside body widget
Widget _buildHeader(BuildContext context) {
  return Container(
    color: AppColors.loginPrimary,
    child: SafeArea(
      bottom: false,
      child: Row(children: [backArrow, title, spacer]),
    ),
  );
}
```

---

## Rule 2: Auth Screens → Plain Scaffold + SafeArea (No AppBar)

Auth screens have no appbar — content flows from top with custom layout.

```dart
// ✅ Auth screen pattern
Scaffold(
  backgroundColor: AppColors.scaffoldBackground,
  body: SafeArea(child: _LoginBody(params: _params)),
)
```

---

## Rule 3: Status Bar Color MUST Match AppBar Color

> The status bar is the system area above the app (time, battery, signal).
> Its color MUST blend with the current screen's header — never leave it mismatched.

### Auto-handled by DefaultScaffold:
`DefaultScaffold` sets `statusBarColor: AppColors.loginPrimary` + `Brightness.light` automatically.

### Manual for other screens:
```dart
// ✅ Auth screens — set in initState
@override
void initState() {
  super.initState();
  Helpers.changeStatusbarColor(
    statusBarColor: AppColors.scaffoldBackground,
    statusBarIconBrightness: Brightness.dark,
  );
}

// ✅ Home screen — colored header
@override
void initState() {
  super.initState();
  Helpers.changeStatusbarColor(
    statusBarColor: AppColors.loginPrimary,
    statusBarIconBrightness: Brightness.light,
  );
}
```

### Quick decision:
- Header is dark/colored → `Brightness.light` (white icons)
- Header is white/light → `Brightness.dark` (black icons)

---

## Rule 4: Status Bar Restoration on Navigation

When navigating between screens with different status bar colors, each screen must set its own color in `initState` or `build`. `DefaultScaffold` does this automatically. Auth/Home screens must do it manually.

---

## Rule 5: AppBar, BottomSheet, Dialog — RTL Check (MANDATORY)

> **محتوى الـ AppBar, BottomSheet, Dialog أحياناً مبيحترمش RTL. لازم تتأكد إن المحتوى RTL صح.**

```dart
// ✅ Bottom sheet with RTL content
showDefaultBottomSheet(
  child: Directionality(
    textDirection: TextDirection.rtl,
    child: _MySheetContent(),
  ),
);

// ✅ Dialog with RTL content
showCustomDialog(
  context,
  child: Directionality(
    textDirection: TextDirection.rtl,
    child: _MyDialogContent(),
  ),
);
```

**Note:** `DefaultScaffold` handles AppBar RTL automatically. Only use `Directionality` wrapping for bottom sheets, dialogs, and modals where content appears reversed.

---

## Quick Forbidden List

```dart
// ❌ Building custom header containers in body widgets (use DefaultScaffold)
Container(color: AppColors.loginPrimary, child: SafeArea(...Row(...)))

// ❌ Forgetting status bar color (leaves previous screen's color)
// Every screen must either use DefaultScaffold or call Helpers.changeStatusbarColor

// ❌ Mismatched status bar — dark icons on dark header or light icons on white
Helpers.changeStatusbarColor(statusBarColor: AppColors.loginPrimary, statusBarIconBrightness: Brightness.dark)
```
