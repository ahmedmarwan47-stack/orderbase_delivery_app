## 1.2.0

**A second bar.** The package now ships two, side by side, and nothing about
the first one changed — this release only adds.

```dart
import 'package:liquid_tab_bar/liquid_tab_bar.dart';  // the default bar
import 'package:liquid_tab_bar/droplet.dart';         // the droplet variant
```

### The droplet variant — `package:liquid_tab_bar/droplet.dart`

Contributed by **Mohammed Hafiz**
([@MohammedHafiz27](https://github.com/MohammedHafiz27)) in
[#5](https://github.com/ahmedmarwan47-stack/orderbase_delivery_app/pull/5).

Where the default bar makes its selection lens a pane of glass in its own
right — so a press can balloon it past the capsule and magnify what it holds —
the droplet keeps the lens a contained pill and refracts the icons and labels
*behind* it through a shader of its own, only while it moves. Two different
answers to the same question; neither is the other's successor, which is why
they now sit next to each other rather than one replacing the other.

It brings, on its side of the package:

- `LiquidTabBarScaffold` — sets `extendBody: true`, reserves bottom scroll
  padding, and observes primary vertical scrolling for the fold with no
  `NotificationListener` of your own. `LiquidScrollPadding`,
  `SliverLiquidScrollPadding` and `LiquidTabBar.reservedPadding(context)`
  cover the layouts it does not.
- An expandable search field (`LiquidTabAction.search`) that morphs the bar
  edge to edge and anchors above the keyboard, with `openSearch()` /
  `closeSearch()` and Android back handling.
- Separate action buttons, placed `together` or `split`.
- Badges: unread dots, count pills that fold to `99+`, text pills and custom
  widgets — refracted by the lens as it crosses them.
- `droplet_glass.frag`, the dedicated refraction shader.
- Style objects: `LiquidBarStyle`, `LiquidDropletSurfaceStyle`,
  `DropletRefractionStyle`, `LiquidTabActionStyle`, `LiquidBadgeStyle`.
- `LiquidTabBarTheme.dark()` / `.adaptive(context)`, `GlassStyle` presets
  (`frosted`, `prismaticCaustics`, `clearCrystal`, `deepRefraction`),
  `LiquidFoldedShape.circle` / `.oval`, and `LiquidGovernorConfig`.
- Accessibility semantics across tabs, badges, search and the folded state.

The two libraries deliberately share type names (`LiquidTabBar`,
`LiquidTabBarTheme`, `LiquidTabItem`, `LiquidTabBarController`). Import one,
or prefix the other:

```dart
import 'package:liquid_tab_bar/droplet.dart' as droplet;
```

### Fixed, in both bars

- **Android Impeller/OpenGLES rendered the glass mirrored.** The backdrop tap
  flipped Y under `IMPELLER_TARGET_OPENGLES`, but Flutter already hands the
  texture in `FlutterFragCoord`'s orientation, so the flip sampled the screen
  upside down. Found by Mohammed on physical Android hardware; removed from
  every shader in the package.

### Fixed, in the droplet variant

- The glass tier is gated on `LiquidGlass.supported` rather than `.ready`, so
  Skia and OpenGL backends fall back to blur instead of rendering black.
- The frost samples four rings instead of three, clearing the ring banding the
  old spacing showed on high-contrast pages.
- Split placement no longer centres the capsule or overlaps the tabs, LTR
  or RTL.
- The frame governor degrades at its threshold rather than a frame later, and
  `resetGovernor()` truly zeroes its counters.
- The frost filter cache is a bounded 24-entry LRU with quantized keys, and
  the shader `ImageFilter` is cached per render object.
- Search keeps one persistent input, a stable reported height and a staged
  close; the action circle and the search pill share a visual centre.
- Multi-touch no longer lets a second finger jump the scrub.

### Note on numbering

The contribution branch carried `0.3.0`, which would have landed underneath
the `1.0.1` on pub.dev. Because the default bar's API is untouched and the
droplet arrives as a new library beside it, this is a **minor** bump, not the
breaking one a replacement would have been.

## 1.1.0

The grab: pressing the bar now balloons the lens past the capsule — 24pt
taller, escaping the bar's top and bottom edge evenly, a tenth wider — while the glass **magnifies** the tab
it holds (a new `zoom` knob on `GlassStyle`, ×1.18 grabbed, with the channels
zooming slightly apart so the magnified glyph fringes at its own edges) and
the dispersion opens to 0.85 with the rim light brightened under it. All of
it rides one press spring, up on touch-down and home on release, replacing
the old instant 6% swell. The lens moved out of the bar's clip to make the
overflow possible; at rest and while folding it still sizes itself inside
the bar, so nothing else changed.

Off switch: `LiquidTabBarTheme(pressLens: false)` restores the old press
exactly. The blur tier keeps the swell and the fringe threads but cannot
magnify (no shader); `zoom: 1` leaves the shader's output bit-identical to
before.

## 1.0.1

The selection lens survives a fold and unfold. Three defects in one cycle of
the bar collapsing to its pill and opening again:

- **The lens parked by LTR index in an RTL app.** Its slot was seeded from
  `initState`, where the widget cannot read `Directionality`. It resolves in
  `didChangeDependencies` now — once, so a later theme or text-scale change
  never drags the lens off wherever the user last put it.
- **On unfold the lens stayed wherever it had drifted to.** `didUpdateWidget`
  never fires on the way back open, because `selectedIndex` did not change, so
  nothing re-targeted it. It re-springs to the selected tab now, snapping
  exactly when the gap is already sub-pixel.
- **Mid-fold the lens could outgrow the shrinking bar and have its glass edge
  cut by the clip.** Its width lerps toward a pill-safe width and is clamped to
  what the current bar rect — and the lens's own position in it — can hold. The
  glass surface is also skipped entirely below 2% fade, where it was invisible
  to the eye but still painting a backdrop shader inside the fold clip, which
  cut a visible seam at the boundary.

No API changes: `LiquidTabBar`, `LiquidTabItem`, `LiquidTabBarTheme`,
`LiquidTabBarController` and `LiquidGlass` are untouched. The version moves to
1.0 because that surface is now settled, not because anything in it moved.

Thanks to Yousef Sobhy for the fixes.

## 0.1.0

- First release, extracted from the Orderbase courier app: the glass, blur and
  opaque tiers, the soap-bubble selection lens, finger scrubbing, fold on
  scroll, the frame governor.
