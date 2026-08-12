# Orderbase courier app (Flutter)

Flutter port of the screens in the Claude Design project **"Orderbase courier app project"**
(`https://claude.ai/design/p/cbf7a892-3a95-4d11-809c-fd57222729d7`). The `.dc.html` files in that
project are the source of truth for every visual and behavioral detail — not any other design
system or component library. When a mockup and a convention below disagree, the mockup wins;
update this file instead.

## 4-pixel rule (spacing & type)

Ported from the design project's own `CLAUDE.md`. Applies across the whole app.

- **Font sizes**: only multiples of 4 (…8, 12, 16, 20, 24, 28, 32, 36…). The **only** allowed
  exceptions are **14px** and **18px**.
- **Padding**: only multiples of 4 (0, 4, 8, 12, 16, 20, 24…). No 14/18 exception for spacing.
- **Gaps**: only multiples of 4. No 14/18 exception for spacing.
- No fractional pixels anywhere (no 12.5, 11.5, 10.5, etc.).

In Dart terms: `fontSize` and `SizedBox`/`EdgeInsets`/`gap` values must come from
`lib/theme/spacing.dart` / `lib/theme/typography.dart`, not hardcoded numbers.

## RTL / language

The app is Arabic-first and right-to-left. Build screens RTL by default
(`Directionality`/`MaterialApp` locale set to `ar`), matching the mockups' `dir="rtl"`.
Font: **Noto Kufi Arabic**.

## Workflow: porting a screen

Screens are pulled one at a time, in the order the user specifies — do not get ahead and
port screens that haven't been requested yet.

1. Fetch the screen's `.dc.html` from the design project (`DesignSync get_file`).
2. Read the whole file: the inline-styled markup is the layout/visual spec, and the
   `<script data-dc-script>` block at the bottom (a `class Component extends DCLogic` with a
   `state` object and a `renderVals()` method) is the view-model — port its state fields and
   derived values into the Dart screen's state almost 1:1, don't redesign the logic.
3. Note every color/size/radius/shadow used. Anything already in `lib/theme/` gets reused as-is.
   Anything new gets added there (don't inline raw hex/px values in screen widgets).
4. Note every icon used (`<use href="#i-...">`). Reuse existing entries in `lib/icons/` or add
   new ones ported from the design project's `assets/icons/icon-data.js`.
5. Build the screen in `lib/screens/<screen_name>/`, composed from `lib/widgets/` primitives
   (cards, pills, buttons, bottom nav, search bar, etc.) plus theme tokens — new shared widgets
   go in `lib/widgets/`, screen-specific one-offs stay local to the screen's folder.
6. Seed the screen with the same sample data as the mockup's `state` block so it's visually
   comparable side-by-side.
7. Run the app (simulator) and compare against the mockup screenshot/preview for the same
   screen before calling it done.

## Structure

```
lib/
  theme/       # colors.dart, spacing.dart, radius.dart, typography.dart, shadows.dart
  icons/       # ported SVG icons (one Dart file/widget per icon, from icon-data.js)
  widgets/     # shared reusable components (cross-screen)
  screens/     # one folder per screen, named after the .dc.html file
  data/        # sample/mock data mirroring each screen's mockup `state`
```
