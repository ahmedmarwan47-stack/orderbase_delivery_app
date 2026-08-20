# Live Activity — the one step that needs Xcode

Everything in this folder, in `ios/Shared/`, in `ios/Runner/LiveActivityChannel.swift`
and under `lib/core/live_activity/` is already written. What is left is creating
the widget-extension target, which only Xcode's GUI can do.

Budget about ten minutes. No CocoaPods, no paid-account entitlement, no
App Group — iOS carries the data from the app to the island by itself.

---

## 1. Create the target

Open `ios/Runner.xcworkspace` in Xcode, then **File → New → Target… → Widget Extension**.

| Field | Value |
|---|---|
| Product Name | `OrderbaseLiveActivity` |
| Include Live Activity | ✅ **ticked** |
| Include Control / App Intent | ⬜ unticked |
| Embed in Application | `Runner` |

When Xcode offers to activate the new scheme, Activate is fine — just switch the
scheme back to **Runner** before running the app.

## 2. Delete the template code

Xcode generates a few placeholder `.swift` files in the new group. Select them
all and **Move to Trash**. Keep the generated `Info.plist` and `Assets.xcassets`.

## 3. Add the real sources

Drag these in from Finder and set **Target Membership** exactly as listed —
this is the step that goes wrong most often.

| File | Target membership |
|---|---|
| `ios/LiveActivity/OrderbaseLiveActivityBundle.swift` | OrderbaseLiveActivity |
| `ios/LiveActivity/DeliveryLiveActivity.swift` | OrderbaseLiveActivity |
| `ios/LiveActivity/OrderbaseTheme.swift` | OrderbaseLiveActivity |
| `ios/Shared/DeliveryActivityAttributes.swift` | **Runner *and* OrderbaseLiveActivity** |
| `ios/Runner/LiveActivityChannel.swift` | Runner |

`DeliveryActivityAttributes.swift` must be in **both** targets. ActivityKit pairs
an activity with its widget by that type, so the two binaries have to compile the
same source. This is the single most common cause of "the activity starts but
nothing appears".

`LiveActivityChannel.swift` is new on disk but not yet in the Xcode project —
adding it is a real step, not a formality. `AppDelegate.swift` and
`SceneDelegate.swift` were already in the project, so their edits are picked up
with no action.

## 4. Deployment targets

- **OrderbaseLiveActivity** → iOS **16.2**
- **Runner** → leave at **13.0**

Do not raise Runner. Keeping it low is what lets the app keep installing on the
older iPhones much of the fleet carries; those devices simply never see an island.

## 5. Weak-link ActivityKit in Runner

Because Runner deploys below iOS 16.1, ActivityKit must be linked *optionally* or
older devices crash at launch:

**Runner target → Build Phases → Link Binary With Libraries → `+` → ActivityKit.framework**,
then change its Status from `Required` to **`Optional`**.

## 6. Fonts (optional — skip and it still runs)

The extension cannot read Flutter's asset bundle, so the brand face has to be
bundled again. Without this the island renders in the system font.

1. Drag the four `assets/fonts/NotoKufiArabic-*.ttf` into the
   `OrderbaseLiveActivity` group; target membership: **OrderbaseLiveActivity only**.
2. Add to the extension's `Info.plist`:

```xml
<key>UIAppFonts</key>
<array>
    <string>NotoKufiArabic-Regular.ttf</string>
    <string>NotoKufiArabic-SemiBold.ttf</string>
    <string>NotoKufiArabic-Bold.ttf</string>
    <string>NotoKufiArabic-ExtraBold.ttf</string>
</array>
```

## 7. Run it

```bash
flutter build ios --simulator --debug
```

or just ⌘R on the **Runner** scheme.

The Dynamic Island itself only exists on **iPhone 14 Pro / 15 / 16 / 17 Pro**
simulators. On any other simulator the Lock Screen card still works — lock the
simulator (⌘L) to see it.

## 8. What to check

1. Sign in, then carry the batch from the branch. The activity starts the moment
   `ShiftController.accepted` flips — nothing appears before that, by design.
2. The compact island shows a red pin and `1/6`.
3. Long-press → the expanded card with the customer, area and cash.
4. Tap **اتصال بالعميل** → the app opens and the dialer comes up.
5. Deliver the stop → the activity ends and a new one starts for the next stop.

---

## If something goes wrong

**"Method does not override any method from its superclass"** in `SceneDelegate.swift`
— this Flutter version's `FlutterSceneDelegate` doesn't declare those methods.
Delete the two `override` keywords and the two `super.scene(...)` lines. Nothing
else changes.

**The activity never appears** — check Settings → Orderbase → Live Activities is
on. `LiveActivityService.isSupported()` returns false when it isn't, and the app
stays silent by design.

**It appears but is blank or generic** — `DeliveryActivityAttributes.swift` is
almost certainly in only one target. See step 3.

**Nothing happens at all and no errors** — that is the intended failure mode.
Every call in `LiveActivityService` swallows `MissingPluginException`, so an app
built before the extension existed behaves exactly like an unsupported device.

---

## What is deliberately not built yet

- **Push updates.** The island only refreshes while the app is running. Once iOS
  suspends the app it goes stale until the courier opens it again. Fixing that
  needs the activity's push token sent to the backend and APNs pushes with
  `push-type: liveactivity`.
- **A live countdown.** `Order.due` is a formatted string (`"٢:٤٥ م"`), not a
  timestamp, so the compact slot shows the stop counter instead. Give `Order` a
  real `DateTime` and it can become SwiftUI's self-updating timer text.
- **An "arrived" trigger.** `DeliveryPhase.arrived` exists but nothing sets it —
  there is no geofence and no "وصلت" button. `collecting` is wired (the COD sheet).
- **The navigate button** from the mockup. Nothing in the app launches a maps app
  yet, and a dead button is worse than none.
- **Android.** No equivalent exists there; it would be a separate build on
  ongoing notifications.
