## 2.0.0

The package's second shape, contributed by **Mohammed Hafiz**
([@MohammedHafiz27](https://github.com/MohammedHafiz27)) in
[#5](https://github.com/ahmedmarwan47-stack/orderbase_delivery_app/pull/5).
It is a breaking release: the flat theme is gone, replaced by style objects,
and the bar gained a scaffold, a search field, actions and badges.

### Breaking

- The flat `LiquidTabBarTheme` colour fields are replaced by style objects:
  `LiquidBarStyle` (outer capsule), `LiquidDropletSurfaceStyle` (the moving
  lens), `LiquidTabActionStyle` (a separate action) and `LiquidBadgeStyle`
  (badges). `DropletRefractionStyle` carries the lens's optics.
- `LiquidTabItem`'s unnamed constructor is gone; use `LiquidTabItem.icon`,
  which is `const`-constructible. It requires an `icon` even when you pass
  your own `iconBuilder` — pass any glyph as a placeholder.
- `forceOpaque` is gone; pass `material: LiquidTabBarMaterial.opaque`.
- `foldOnScroll` is gone; use `shrinkOnScroll`.
- Renderer internals (`GlassSurface` and friends) left the public barrel.
- **The grab is gone.** 1.1.0's press — the lens ballooning past the capsule
  while the glass magnified the tab it held — does not survive this release:
  the lens is no longer a glass surface of its own, so `GlassStyle.zoom` and
  `LiquidTabBarTheme.pressLens` have no host. A press is the older 6% swell
  again. See the migration guide.

Step-by-step replacements are in the
[migration guide](doc/migration_0.3.0.md).

### Added

- `LiquidTabBarScaffold` — sets `extendBody: true`, reserves bottom scroll
  padding and observes primary vertical scrolling for the fold with no
  `NotificationListener` of your own. `LiquidScrollPadding`,
  `SliverLiquidScrollPadding` and `LiquidTabBar.reservedPadding(context)`
  cover the layouts it does not.
- An expandable search field (`LiquidTabAction.search`) that morphs the bar
  edge to edge and anchors above the keyboard, with `openSearch()` /
  `closeSearch()` on the controller and Android back handling.
- Separate action buttons, placed `together` or `split`.
- Badges: unread dots, count pills that fold to `99+`, text pills, and custom
  badge widgets — refracted by the lens as it crosses them.
- A dedicated droplet refraction shader (`droplet_glass.frag`): Snell's-law
  displacement of the icons and labels the lens holds **while it moves**,
  returning to zero at rest so nothing is bent under a resting lens.
- `LiquidTabBarTheme.dark()` and `.adaptive(context)`.
- `GlassStyle` presets: `frosted`, `prismaticCaustics`, `clearCrystal`,
  `deepRefraction`.
- `LiquidFoldedShape.circle` / `.oval` for the folded pill.
- `LiquidGovernorConfig` for custom frame-governor thresholds.
- Accessibility semantics across tabs, badges, search and the folded state.

### Fixed

- **Android Impeller/OpenGLES rendered the glass mirrored.** The backdrop tap
  flipped Y under `IMPELLER_TARGET_OPENGLES`, but Flutter already hands the
  texture in `FlutterFragCoord`'s orientation, so the flip mirrored the page
  the glass sampled. Removed from both shaders.
- The glass tier is gated on `LiquidGlass.supported` rather than `.ready`, so
  Skia and OpenGL backends fall back to blur instead of rendering black.
- The frost samples four rings instead of three, which clears the ring
  banding the old spacing showed on high-contrast pages.
- Split placement no longer centres the capsule or overlaps the tabs, in LTR
  and RTL alike.
- The frame governor degrades at its threshold rather than a frame later, and
  `resetGovernor()` truly zeroes its counters.
- The frost filter cache is a bounded 24-entry LRU with quantized keys, and
  the shader `ImageFilter` is cached per render object.
- Search keeps one persistent input, a stable reported height, and a staged
  close; the action circle and the search pill share a visual centre.
- Multi-touch no longer lets a second finger jump the scrub.

### Note on numbering

This release is **2.0.0**, not the `0.3.0` the contribution branch carried:
1.0.1 is the version on pub.dev and 1.1.0 was already tagged here, so the
breaking changes land above them rather than underneath. The entries below
are the package's real history and are unchanged.

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
