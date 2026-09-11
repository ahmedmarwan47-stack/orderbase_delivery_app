# liquid_tab_bar

An iOS 26-style floating liquid-glass tab bar for Flutter.

- **Glass.** A refraction shader over the page: lensing at the rim, a top-left
  light with a hairline on the lit edge, frost, saturation, its own shadow.
- **A soap-bubble lens.** The selection highlight slides between tabs on a
  spring, stretches with its speed, and while it moves it disperses light —
  the glyphs and labels its rim crosses split into a warm copy and a cool one,
  and a thin-film band lies along its edge.
- **Scrub.** Press and drag along the bar and the lens is glued to your finger,
  ticking at every tab; release to choose, the lens landing with the speed you
  gave it.
- **Fold on scroll.** Scrolling down folds the bar into a pill holding the
  selected tab; scrolling up, reaching the top, or switching tabs opens it.
- **Three tiers.** Glass where Impeller runs the shader (iOS, and Android
  devices on Impeller), a backdrop-blur tier with the shader's rim light
  painted on everywhere else (the web included), and an opaque tier for high
  contrast. A frame governor steps a struggling device from glass to blur for
  the session.
- Reduce Motion jumps to the end state; RTL is handled.

## Use

```dart
import 'package:liquid_tab_bar/liquid_tab_bar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlass.load(); // the shader, once; the bar falls back to blur without it
  LiquidTabBarController.shared.armGovernor();
  runApp(const MyApp());
}
```

Put the bar in a `Scaffold(extendBody: true)` so the page passes underneath
it, and give the page `LiquidTabBar.reservedHeight(context)` of bottom
padding. One bar over every tab page (an `IndexedStack`) lets the lens slide
from the old tab to the new one.

```dart
Scaffold(
  extendBody: true,
  body: NotificationListener<ScrollNotification>(
    onNotification: LiquidTabBarController.shared.handleScroll,
    child: IndexedStack(index: _tab, children: pages),
  ),
  bottomNavigationBar: LiquidTabBar(
    items: [
      LiquidTabItem.icon(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
      LiquidTabItem.icon(label: 'Orders', icon: Icons.receipt_long_outlined, badge: true),
      LiquidTabItem.icon(label: 'Wallet', icon: Icons.account_balance_wallet_outlined),
      LiquidTabItem.icon(label: 'Me', icon: Icons.person_outline),
    ],
    selectedIndex: _tab,
    onSelected: (i) => setState(() => _tab = i),
  ),
)
```

`LiquidTabItem` takes an `iconBuilder` for custom glyphs (SVGs, say); the bar
hands it the colour and whether the tab is selected. `LiquidTabBarTheme`
carries every colour and number; `LiquidTabBarController.material` pins a
tier (`glass`, `blur`, `opaque`) or leaves it `auto`.

## Where the numbers come from

The geometry was measured off the real iOS 26 bar (Files on an iPhone 17 Pro,
pixel-scanned): 62pt tall and 21pt off the screen edge (64 and 20 here, on a
4px grid), `n × 86 + 16` wide, the lens a slot + 8 wide. The glass was tuned
against the same bar over a white page. The dispersion, the scrub and the
6pt tap slop came from frame-by-frame recordings of the bar under a finger.

## The shader contract (for anyone changing it)

`ImageFilter.shader` hands the shader the **whole screen** as its texture,
and `FlutterFragCoord()` is in screen pixels — the widget's clip only limits
which pixels are asked for. So the capsule is described by its global rect,
measured every paint. That breaks inside a save layer whose bounds are not
the screen (an `Opacity` or `ShaderMask` ancestor): never wrap the bar in
one. A backdrop is re-rendered every frame anything beneath it changes, so a
looping animation on the page turns the shader into a 60 fps render loop.

## Example

`example/` is a page of colour bands and cards with the bar over it and a
material picker — run it on an iOS simulator or device to see the glass tier.
