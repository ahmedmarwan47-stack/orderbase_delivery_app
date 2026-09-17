# Migrating to 0.3.0

Version 0.3.0 intentionally removes public styling APIs that no longer
controlled `LiquidTabBar` after the droplet refraction redesign. This is a
breaking source change, but the default rendering is unchanged.

## Removed API and replacements

| Removed API | Replacement |
|---|---|
| `LiquidTabBarTheme.dropletGlassStyle` | `LiquidTabBarTheme.dropletRefraction` or `LiquidTabBar.dropletRefraction` |
| `LiquidTabBarTheme.defaultDropletGlass` | Use `DropletRefractionStyle` or one of its presets according to the desired optical strength; this is not an exact preset mapping |
| `LiquidTabBarTheme.defaultDarkDropletGlass` | Use `DropletRefractionStyle` or one of its presets according to the desired optical strength; this is not an exact preset mapping |
| `LiquidTabBarTheme.dropletFringeWarm` | No direct replacement. The old field did not affect the active selection droplet pipeline. `DropletRefractionStyle.dispersion` may control RGB separation, but is not a replacement for an explicit warm fringe color. |
| `LiquidTabBarTheme.dropletFringeCool` | No direct replacement. The old field did not affect the active selection droplet pipeline. `DropletRefractionStyle.dispersion` may control RGB separation, but is not a replacement for an explicit cool fringe color. |
| `GlassStyle.droplet` | Optical behavior: `DropletRefractionStyle`. Surface appearance: `LiquidDropletSurfaceStyle`. These are separate concepts, not interchangeable replacements. |
| `GlassStyle.refractiveIndex` | `DropletRefractionStyle.refractiveIndex` |
| `GlassStyle.baseHeight` | `DropletRefractionStyle.baseHeight` |
| `GlassStyle.dropletRefraction` | Pass `DropletRefractionStyle` through `LiquidTabBarTheme.dropletRefraction` or `LiquidTabBar.dropletRefraction` |
| `LiquidDropletChromaticPainter.style` | Remove the argument; it was never read while painting |
| `LiquidTabBar.foldOnScroll` | `LiquidTabBar.shrinkOnScroll` |
| `LiquidTabBarController.foldOnScroll` | `LiquidTabBarController.shrinkOnScroll` |
| `LiquidTabBarTheme.dropletMarkerTint` | `LiquidTabBarTheme.actionStyle.selectedFill` |

## Droplet optics

For a simple strength adjustment:

```dart
const DropletRefractionStyle(
  refractionStrength: 1.3,
)
```

All advanced optical controls remain public and optional:

```dart
const DropletRefractionStyle(
  thickness: 15,
  refractiveIndex: 1.55,
  baseHeight: 22,
  dispersion: 0.08,
  specularStrength: 0.2,
  refractionStrength: 1.4,
)
```

The `none()`, `subtle()`, `medium()`, and `strong()` presets are unchanged.

The old `dropletMarkerTint` name was misleading: it never styled the main
selection droplet. It controlled only the inset circular fill behind a
selected separate action. Use:

```dart
// Before 0.3.0
LiquidTabBarTheme(
  dropletMarkerTint: const Color(0x33FF375F),
)
```

```dart
// 0.3.0
LiquidTabBarTheme(
  actionStyle: const LiquidTabActionStyle(
    selectedFill: Color(0x33FF375F),
  ),
)
```

## Before and after

Replace the former inactive droplet-glass configuration:

```dart
// Before 0.3.0
LiquidTabBarTheme(
  dropletGlassStyle: GlassStyle.droplet.copyWith(
    dispersion: 0.08,
    specular: 0.2,
  ),
)
```

with the active refraction model:

```dart
// 0.3.0
LiquidTabBarTheme(
  dropletRefraction: const DropletRefractionStyle(
    dispersion: 0.08,
    specularStrength: 0.2,
  ),
)
```

Replace folding aliases directly:

```dart
LiquidTabBar(shrinkOnScroll: false, /* ... */)
controller.shrinkOnScroll = false;
```

In 0.3.0, `LiquidTabBarScaffold` automatically observes primary vertical scroll notifications from `body` when `shrinkOnScroll: true` is set on `LiquidTabBar`. Manual `NotificationListener` configuration is no longer required for the standard use case:

```dart
// 0.3.0 Recommended:
LiquidTabBarScaffold(
  tabBar: LiquidTabBar(
    shrinkOnScroll: true,
    selectedIndex: _selectedIndex,
    onSelected: (i) => setState(() => _selectedIndex = i),
    items: [ /* ... */ ],
  ),
  body: ListView.builder( /* ... */ ),
)
```

Manual integration via `NotificationListener<ScrollNotification>(onNotification: controller.handleScroll, child: ...)` remains fully supported as an intentional escape hatch for custom `Scaffold` layouts, choosing a specific scroll source, or complex nested scrolling hierarchies.

`GlassStyle.depth` remains an outer-bar shader control. It is not a replacement
for droplet `baseHeight`.

Keep the three styling concepts separate:

- `LiquidBarStyle` is outer bar surface/material styling across glass, blur,
  and opaque tiers.
- `LiquidDropletSurfaceStyle` is the selection droplet's visible surface
  appearance (gradient, border, fill, and shadow).
- `DropletRefractionStyle` is the selection droplet's optical/refraction
  behavior.

## Droplet surface shadow consolidation

The droplet surface shadow is now represented by one public `BoxShadow`.
Only `color`, `blurRadius`, and `offset` are consumed by the renderer.
`spreadRadius` and `blurStyle` are accepted by `BoxShadow` itself but are not
currently consumed by droplet rendering.

```dart
// Before 0.3.0
LiquidDropletSurfaceStyle(
  gradientTop: top,
  gradientBottom: bottom,
  borderColor: border,
  shadowColor: shadowColor,
  shadowBlur: 10,
  shadowOffset: const Offset(0, 3),
  opaqueFill: fill,
)
```

```dart
// 0.3.0
LiquidDropletSurfaceStyle(
  gradientTop: top,
  gradientBottom: bottom,
  borderColor: border,
  shadow: BoxShadow(
    color: shadowColor,
    blurRadius: 10,
    offset: const Offset(0, 3),
  ),
  opaqueFill: fill,
)
```

## Bar surface style consolidation

Bar surface fields are grouped under `LiquidBarStyle`. The tier-specific
rendering remains unchanged.

```dart
// Before 0.3.0
LiquidTabBarTheme(
  barGlassStyle: GlassStyle.frosted,
  glassTint: Colors.white24,
  opaqueSurface: Colors.white,
  opaqueEdge: Colors.black12,
  shadow: customShadows,
)
```

```dart
// 0.3.0
LiquidTabBarTheme(
  barStyle: LiquidBarStyle(
    glass: GlassStyle.frosted,
    blurTint: Colors.white24,
    opaqueFill: Colors.white,
    opaqueEdge: Colors.black12,
    shadow: customShadows,
  ),
)
```

The direct field mapping is:

| Before | 0.3.0 |
|---|---|
| `barGlassStyle` | `barStyle.glass` |
| `glassTint` | `barStyle.blurTint` |
| `sheenTop` | `barStyle.blurSheenTop` |
| `sheenBottom` | `barStyle.blurSheenBottom` |
| `glassEdge` | `barStyle.blurEdge` |
| `opaqueSurface` | `barStyle.opaqueFill` |
| `opaqueEdge` | `barStyle.opaqueEdge` |
| `shadow` | `barStyle.shadow` |

## Badge shortcut consolidation

Per-item badge appearance shortcuts are removed in favor of the canonical
`LiquidBadgeStyle`. The theme convenience getters `badgeColor` and
`badgeBorder` are also no longer public; their red-fill and white-border
fallbacks remain internal so default visuals are unchanged.

```dart
// Before 0.3.0
LiquidTabItem.icon(
  icon: Icons.mail,
  label: 'Mail',
  badge: true,
  badgeColor: Colors.red,
  badgeTextColor: Colors.white,
  badgeBorderColor: Colors.white,
  badgeTextStyle: const TextStyle(fontWeight: FontWeight.bold),
)
```

```dart
// 0.3.0
LiquidTabItem.icon(
  icon: Icons.mail,
  label: 'Mail',
  badge: true,
  badgeStyle: const LiquidBadgeStyle(
    color: Colors.red,
    textColor: Colors.white,
    borderColor: Colors.white,
    textStyle: TextStyle(fontWeight: FontWeight.bold),
  ),
)
```

Use `LiquidBarStyle.light` and `LiquidBarStyle.dark` for the canonical
light/dark presets. The former `defaultBarGlass`, `defaultDarkBarGlass`,
`defaultShadow`, and `defaultDarkShadow` constants are now owned by those
presets.

## Renderer internals

`GlassSurface`, `DropletGlassSurface`, `GlassLightPainter`,
`LiquidDropletChromaticPainter`, and `ChromaticShaderCache` are renderer
implementation details and are no longer exported from
`package:liquid_tab_bar/liquid_tab_bar.dart`. Applications should use
`LiquidTabBar` and the supported theme/refraction styles. The package keeps
`LiquidGlass.load()`, `ready`, `dropletReady`, `supported`, and
`dropletSupported` public for initialization and capability checks; direct
shader access and program replacement hooks are removed.

`LiquidGovernorConfig` and `armGovernor()` remain public because applications
can legitimately tune and explicitly arm the automatic glass-to-blur
performance policy. Test-only renderer overrides live in an unexported
implementation library and are not supported application API.
