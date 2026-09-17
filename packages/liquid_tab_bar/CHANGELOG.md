## 0.3.0 - Unreleased

- Consolidated outer surfaces into `LiquidBarStyle`, droplet surfaces into
  `LiquidDropletSurfaceStyle` (including `BoxShadow`), selected action fill into
  `LiquidTabActionStyle`, and badge appearance into `LiquidBadgeStyle`.
- Kept all six `DropletRefractionStyle` controls and `none`/`subtle`/`medium`/`strong`
  presets; removed obsolete droplet glass/fringe configuration.
- Internalized renderer infrastructure from the supported public barrel and
  removed redundant `foldOnScroll` aliases; use `shrinkOnScroll`.
- Added zero-configuration scrolling and folding to `LiquidTabBarScaffold`:
  automatically observes primary vertical scroll notifications when `shrinkOnScroll: true`
  is set, with object-identity deduplication for existing manual listeners.
- `LiquidTabItem.icon` now supports const construction.
- Fixed expandable search and separate action surface vertical alignment, ensuring
  the action circle and search pill share an identical visual center.
- Fixed expandable search keyboard layout and input ownership: stable reported
  height, one persistent input, unified keyboard movement, and staged close.
- Replaced old showcase screens with four focused examples, including an Arabic
  RTL preview. Overhauled README with comprehensive visuals and code samples.
- Preserved default rendering against locked deterministic visual baselines.

Breaking replacements are documented in the
[0.3.0 migration guide](doc/migration_0.3.0.md).

## 0.2.0

### New Features
- **Programmatic Search API (`LiquidTabBarController` & `LiquidTabBar`):**
  - Added `LiquidTabBarController.isSearching`, `openSearch()`, and `closeSearch({bool clearText = false})` for programmatic search morph control from external widgets (app bars, buttons, shortcuts).
  - Added static convenience helpers `LiquidTabBar.openSearch(context)`, `LiquidTabBar.closeSearch(context)`, and `LiquidTabBar.isSearching(context)`.
  - Added `LiquidTabBarSearch.clearOnClose` configuration to automatically reset the search query when closing the search view.
- **Configurable Folded Shape (`foldedShape`):**
  - Added `LiquidFoldedShape` enum (`circle` vs `oval`).
  - Added `foldedShape` property to both `LiquidTabBar` and `LiquidTabBarTheme`.
  - Implemented nullable fallback resolution: `LiquidTabBar.foldedShape` defaults to `null` to seamlessly inherit from `theme.foldedShape`, cleanly resolving to `LiquidFoldedShape.circle` (matching the separate action button) if neither is set.
- **Curated Named `GlassStyle` Presets:**
  - Promoted the example app's quick optical presets into reusable, first-class compile-time constants on `GlassStyle`:
    - `GlassStyle.frosted`: Classic Apple-style frosted glass with balanced diffusion and gentle rim specular (matches baseline `bar` parameters).
    - `GlassStyle.prismaticCaustics`: Vivid chromatic dispersion (`0.32`) with sharp specular highlights (`0.65`) and enhanced saturation (`1.60`).
    - `GlassStyle.clearCrystal`: Zero-blur glass emphasizing clean refraction, rim highlights, and edge dispersion without obscuring background content.
    - `GlassStyle.deepRefraction`: Heavy optical slab with deep displacement (`depth: 14`), thick frost diffusion (`blur: 40`), and light absorption.
- **Theming & Accessibility:**
  - Added `LiquidTabBarTheme.dark()` preset for sleek dark-mode glass styling.
  - Added `LiquidTabBarTheme.adaptive(context)` factory to automatically match ambient `Brightness`.
  - Added `badgeText` and `iconSize` support to `LiquidTabItem` for notification counts and custom sizing.
  - Added comprehensive accessibility semantics for tab items, badges, and folded state ("Expand navigation bar" button).
  - Added dynamic text scaling support in `LiquidTabBar.reservedHeight(context)`.
- **Scroll Handling & Control:**
  - Added `shrinkOnScroll` (and `foldOnScroll` alias) to `LiquidTabBar` and `LiquidTabBarController` to easily toggle bar minimization on scroll.
  - `LiquidTabBarController.handleScroll` now filters out inner nested scrollables (`depth == 0`) by default, with an `allowNested: true` option.

### Fixes & Performance Improvements
- **Dark Mode Glass Tuning:**
  - Tuned `GlassStyle` and `GlassLightPainter` for dark backgrounds, preventing washed-out white bands on dark surfaces.
  - Made `GlassLightPainter` theme-aware: dark mode renders subtle translucent white rim highlights (`0.06`–`0.20` alpha) instead of harsh dark drop-shadow edges, creating a razor-crisp chamfer bevel against dark backgrounds.
  - Boosted caustics and specular clarity in `LiquidLensChromaticPainter` for dark themes.
- **Opaque Tier Selection Pill Sync & Geometry:**
  - Replaced delayed active-color droplet with a flat neutral gray/white-gray pill (`0x14000000` light / `0x24FFFFFF` dark) that updates in immediate lockstep with the selected icon, matching native iOS 26 Segmented Control behavior.
  - Eliminated desync and lag during fast scrubbing and tab tapping on the opaque tier.
- **Split Action Placement (`LiquidTabActionPlacement.split`):**
  - Fixed geometry calculation where split placement incorrectly centered the capsule or overlapped tabs. Split placement now pins the tab capsule firmly to the leading margin and the separate action button to the trailing margin in both LTR and RTL directions.
- **Frame Governor Timing & Reset Lifecycle:**
  - Fixed governor timing delay: frame degradation now triggers immediately upon reaching the slow frame threshold (`_slow >= 6`), without lingering on dropping frames.
  - Fixed governor reset path (`LiquidTabBarController.resetGovernor()`): unwatching frames and re-arming the governor now strictly resets internal counters (`_seen = 0`, `_slow = 0`) to prevent residual dropped frame counts from triggering instant re-degradation.
- **Frost Cache Memory & LRU Eviction:**
  - Added key quantization to `_frostFilter` (`qBlur = (style.blur * 10).round() / 10`, `qSat = (style.saturation * 100).round() / 100`) to prevent micro-float key proliferation during live slider tuning.
  - Replaced unbounded cache with a bounded 24-entry LRU cache featuring access promotion and least-recently-used eviction, preventing memory leaks while retaining frequently-used presets.
- **Skia & Non-Impeller Backend Fallback:**
  - Gated shader execution on `LiquidGlass.supported` (`_hasImpeller && isShaderFilterSupported`) rather than `LiquidGlass.ready`.
  - Automatically falls back to the backdrop blur tier on Skia/OpenGL backends, preventing driver crashes and corrupted black layers on non-Impeller Android devices. *(Note: Verified on Android emulator with `EnableImpeller = false`; physical device testing recommended prior to pub.dev publication).*
- **Android Back Navigation (`PopScope`):**
  - Wrapped `LiquidTabBar` in `PopScope(canPop: !_isSearching)`: when search morph is active, pressing the Android hardware back button or predictive back gesture cleanly dismisses search without popping the route or exiting the app.
- **Lifecycle & Memory Allocations:**
  - Cached `ui.ImageFilter.shader(_shader)` as `_shaderFilter` on `_RenderGlassFilter`, eliminating per-frame native handle churn.
  - Pre-allocated `Paint` objects across `GlassLightPainter` and `ChromaticShaderCache`, eliminating GC churn in paint routines.
  - Removed wrapping `Opacity` widget from `_lensSurface` to avoid offscreen save layer creation that broke backdrop screen coordinates. Replaced with direct alpha attenuation of lens tint, specular, and dispersion.
  - Added active pointer tracking to isolate touch gestures against multi-touch contention and accidental scrubbing jumps.
  - Added assertions and safe guards against empty tab item lists and out-of-bounds `selectedIndex`.

## 0.1.0

- First release, extracted from the Orderbase courier app: the glass, blur and
  opaque tiers, the soap-bubble selection lens, finger scrubbing, fold on
  scroll, the frame governor.
