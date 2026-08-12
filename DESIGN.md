---
name: Orderbase Courier
description: A warm-paper, ink-on-manifest field tool for last-mile couriers — calm, glanceable, Arabic-first.
colors:
  paper: "#F6F5F3"
  surface: "#FFFFFF"
  surface-muted: "#F4F3F0"
  surface-subtle: "#F1F0ED"
  border-hairline: "#EEEDEA"
  border-default: "#E6E5E2"
  ink: "#1A1919"
  text-secondary: "#6B6B73"
  text-tertiary: "#52525B"
  text-muted: "#8A7A72"
  text-body: "#3F3F46"
  brand-red: "#E72B29"
  danger-accent: "#C81E1C"
  transit-blue: "#1F6FD6"
  delivered-green: "#15803D"
  delivered-bg: "#E9F6EE"
  green-accent: "#16A34A"
  failed-red: "#B8120F"
  failed-bg: "#FDECEC"
  postponed-amber: "#9A5A00"
  postponed-bg: "#FEF6E4"
  cash-bright: "#3BD07A"
  mark-bg: "#FFE9A8"
  cod-excess-amber: "#E0AC4E"
typography:
  cash-entry:
    fontFamily: "Noto Kufi Arabic, sans-serif"
    fontSize: "36px"
    fontWeight: 800
    lineHeight: 1
  display:
    fontFamily: "Noto Kufi Arabic, sans-serif"
    fontSize: "24px"
    fontWeight: 800
    lineHeight: 1.33
  headline:
    fontFamily: "Noto Kufi Arabic, sans-serif"
    fontSize: "20px"
    fontWeight: 700
    lineHeight: 1.4
  title:
    fontFamily: "Noto Kufi Arabic, sans-serif"
    fontSize: "18px"
    fontWeight: 700
    lineHeight: 1.56
  body:
    fontFamily: "Noto Kufi Arabic, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Noto Kufi Arabic, sans-serif"
    fontSize: "14px"
    fontWeight: 700
    lineHeight: 1.43
  caption:
    fontFamily: "Noto Kufi Arabic, sans-serif"
    fontSize: "12px"
    fontWeight: 700
    lineHeight: 1.67
rounded:
  badge: "8px"
  chip: "12px"
  tile: "13px"
  field: "14px"
  button: "15px"
  card: "16px"
  money: "18px"
  banner: "20px"
  sheet: "26px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
  xxl: "24px"
  xxxl: "32px"
components:
  button-primary:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.surface}"
    rounded: "{rounded.button}"
    padding: "0 24px"
    height: "56px"
  chip-selected:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.surface}"
    rounded: "{rounded.chip}"
    padding: "0 12px"
    height: "36px"
  chip-unselected:
    backgroundColor: "{colors.surface-muted}"
    textColor: "{colors.text-tertiary}"
    rounded: "{rounded.chip}"
    padding: "0 12px"
    height: "36px"
  chip-postponed:
    backgroundColor: "{colors.postponed-bg}"
    textColor: "{colors.postponed-amber}"
    rounded: "{rounded.chip}"
    height: "36px"
  input-search:
    backgroundColor: "{colors.surface-muted}"
    textColor: "{colors.ink}"
    rounded: "{rounded.field}"
    padding: "0 12px"
    height: "48px"
  card:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.card}"
    padding: "16px"
  status-pill:
    rounded: "{rounded.badge}"
    padding: "4px 8px"
  payment-card:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.surface}"
    rounded: "{rounded.money}"
    padding: "16px 20px"
---

# Design System: Orderbase Courier

## Overview

**Creative North Star: "The Courier's Manifest"**

Orderbase looks like a well-kept delivery manifest made digital: a warm off-white paper surface,
ink-black ink for the things that matter (actions, totals, names), colored status "stamps" that
speak only when they carry meaning, and cash rendered as a heavy dark card you can feel the weight
of. It is a working document for someone in motion — held one-handed, read in a glance between
stops — so it stays calm, legible, and decisive rather than expressive. Character lives in precise
details (the 2px-outlined search field, the ink-fill selected chip, the dark COD card), not in
decoration.

Depth is **softly lifted**: cards rest on gentle, low-opacity shadows and are delineated by 1px
hairline borders over a tonally layered ground (paper → white surface → muted surface). The palette
is disciplined — one warm-neutral family carries almost everything, brand red is spent sparingly,
and the four status hues (blue/green/amber/red) are the only saturated voices allowed on screen.
Type is a single Arabic-first family, Noto Kufi Arabic, weighted from regular to extra-bold to build
hierarchy without ever changing typeface.

This is deliberately **not a flashy consumer app** (no gradients, glass, mascots, or bright fills)
and **not a dense enterprise dashboard** (no tiny type or cramped tables). Every screen is sized for
the thumb and the glance.

**Key Characteristics:**
- Warm paper ground (#F6F5F3), never pure white as the page.
- Ink-black is the action color; brand red is a rare locator, not a fill.
- Status color as functional semaphore — blue in-transit, green delivered, amber postponed, red failed.
- One typeface (Noto Kufi Arabic), hierarchy by weight and size on a strict 4px grid.
- Cash is a first-class, heavyweight dark surface.
- RTL-native throughout; directional padding and mirroring are the default, not an afterthought.

## Colors

A single warm-neutral family does almost all the work; saturated color is rationed and always means something.

### Primary
- **Ink Black** (#1A1919): The action and emphasis color. Fills primary buttons and the selected filter chip, draws the dark COD payment card, and sets primary text (order numbers, customer names, totals). When something is important or actionable, it is ink.

### Secondary
- **Signal Red** (#E72B29): Brand red, spent deliberately — the active nav icon, the map location pin, the text cursor. It marks *location and attention*, never a surface. A slightly deeper **Danger Red** (#C81E1C) carries destructive/active-nav emphasis (clear-filter, active tab glyph).

### Tertiary — Status Semaphore
The only saturated fills allowed, each a paired background + text (+ optional border):
- **Transit Blue** (#1F6FD6 on white text): "In transit" badge — the live, moving state.
- **Delivered Green** (text #15803D on wash #E9F6EE): a successful handoff. A brighter **Green Accent** (#16A34A) drives progress bars, cash totals, and positive stat icons; **Cash Bright** (#3BD07A) is the green reserved for cash figures on the dark card.
- **Postponed Amber** (text #9A5A00 on wash #FEF6E4): deferred orders that will return to the queue. A brighter **COD Excess Amber** (#E0AC4E) borders the COD amount field and the "over-collected → wallet" state — the change-goes-to-wallet signal.
- **Failed Red** (text #B8120F on wash #FDECEC): a delivery that did not complete.
- **Mark** (#FFE9A8 wash, #5A4300 text): search-term highlight only.

### Neutral
- **Paper** (#F6F5F3): the page ground. The app is never bodied on pure white.
- **Surface** (#FFFFFF): cards, headers, sheets, nav — the "written-on" layer above paper.
- **Muted Surface** (#F4F3F0) / **Subtle Surface** (#F1F0ED): chips, search field, icon-button tiles, empty-state icons, dividers.
- **Text**: Primary ink #1A1919 · Secondary #6B6B73 · Tertiary #52525B · Muted #7E6E65 (address/hint lines; AA on white at 4.88:1) · Body #3F3F46 (long-form).
- **Borders**: Hairline #EEEDEA (headers, nav, item dividers) · Default #E6E5E2 (card/button outline) · plus near-transparent black card outlines (rgba(0,0,0,.05–.07)).

### Named Rules
**The One Red Rule.** Brand red (#E72B29) marks location, attention, and the active nav destination only. It is never a button fill or a large surface. The action color is ink-black; red is a pin, not paint.

**The Semaphore Rule.** Saturated color appears only as a status signal (transit/delivered/postponed/failed) or a search highlight. If a color isn't reporting state, it isn't on screen.

## Typography

**Display / Body / Label Font:** Noto Kufi Arabic (via Google Fonts), fallback `sans-serif`.

**Character:** One Arabic-first typeface carries the entire system. Hierarchy is built by size and
weight — regular (400), semi-bold (600), bold (700), extra-bold (800) — never by switching families.
Numerals use tabular figures for totals and cash so amounts align. Order numbers are set LTR inside
the RTL flow.

### Hierarchy
- **Cash entry** (800, 36px, line-height 1): the COD keypad's collected-amount readout — the one place type goes above the Display step (still on the 4px grid). Tabular figures, set LTR.
- **Display** (800, 24px, line-height 32): cash amounts and headline totals — the heaviest moment on a screen.
- **Headline** (700, 20px, line-height 28): screen/section titles.
- **Title** (700, 18px, line-height 28): customer name — the primary line of a card.
- **Body** (400/700, 16px, line-height 24): order numbers (extra-bold, LTR), primary content, button labels.
- **Label** (700, 14px, line-height 20): chip labels, addresses/hints (often regular weight), scope text.
- **Caption** (700, 12px, line-height 20): status pills, meta rows (due time, area·distance), count badges, muted labels.

### Named Rules
**The 4-Pixel Rule.** Font sizes are multiples of 4 — with **14px and 18px as the only two exceptions**. No other off-grid sizes, no fractional pixels.

**The One-Family Rule.** Never introduce a second typeface for emphasis. If you need more weight, go up the weight ladder (400 → 600 → 700 → 800), not to a new font.

## Layout

Single-column, phone-first, designed at a 368×812 reference (screenutil `.h/.w/.sp/.r`). Screens are
built as a white/paper body inside `Directionality(rtl)` with `SafeArea` for the top inset (the OS
status bar is the only one shown). A typical screen is a custom white header with a hairline bottom
border, a scrolling paper body of cards, and — where present — a sticky bottom action bar or the
shared bottom nav.

Rhythm follows the **4-Pixel Rule** for every gap and padding (0, 4, 8, 12, 16, 20, 24, 32…; no
14/18 exception for spacing). Standard card padding is 16px; screen gutters are 20px; the vertical
gap between stacked cards is 12–16px. Directional spacing APIs (`paddingOnlyDirectional`,
`marginAll`) are used so the grid mirrors correctly in RTL.

## Elevation & Depth

Softly lifted. Cards are gently raised on low-opacity shadows and separated from the paper ground by
1px hairline borders, over a tonally layered background (paper #F6F5F3 → surface #FFFFFF → muted
#F4F3F0). The lift is quiet — you register separation, not drama.

### Shadow Vocabulary
- **Card lift** (`box-shadow: 0 1px 3px rgba(0,0,0,0.05)`): the default resting elevation for list/stat cards.
- **Hero lift** (`box-shadow: 0 8px 26px -14px rgba(0,0,0,0.22)`): the next-stop hero card only — a deeper, tightly-spread lift for the single most important card on Home.
- **Pin glow** (`box-shadow: 0 4px 10px rgba(231,43,41,0.4)`): the red map pin's colored shadow — the one place a shadow carries brand color.

### Named Rules
**The Hairline-and-Whisper Rule.** Separation comes first from a 1px hairline border and tonal
contrast; shadow is the soft second layer. Never lean on a heavy drop shadow to do a border's job.

## Shapes

Rounded, calm rectangles on a graduated radius scale. Nothing is sharp-cornered; nothing is a full
pill except small count/dot badges. The corner radius scales with the element's size and weight:
small controls stay tight, large surfaces open up.

- **Badges / status pills / match tags:** 8px.
- **Chips / merchant thumbnails:** 12px.
- **Icon tiles (COD card, camera):** 13px.
- **Search field:** 14px.
- **Primary buttons:** 15px (the deliver bar).
- **Cards:** 16px.
- **COD money card:** 18px.
- **Banners (pickup/postponed):** 20px.
- **Bottom sheets:** 26px top corners.
- **Circles:** avatars/thumbnails aside, only the small notification dot, clear-search button, and count badges are fully round.

Borders are 1px hairlines by default. The one deliberate exception is the **2px ink border** on the
active search field — a rare heavy stroke that signals "you are typing here."

## Components

### Buttons
- **Shape:** rounded, full-width, 56px tall. Radius is **15px** in the Order Flow (deliver bar) and **16px** on the COD screens — the mockups differ by 1px; match the source screen rather than forcing one value.
- **Primary:** ink-black fill (#1A1919), white label (16px bold) with a leading icon, centered. This is the delivery-confirming action ("تم التسليم" / "تأكيد التسليم").
- **Disabled:** fill drops to border-default (#E6E5E2) with muted (#9A9994) label + icon — used on the COD confirm button until the full amount is collected. The label names *why* it's disabled ("اكتب المبلغ" / "المبلغ غير مكتمل").
- **Secondary/destructive:** outlined or amber-tinted variants for "لم يتم التسليم" / "تأجيل" — never a red fill (see The One Red Rule).
- **Feel:** confident but quiet — solid, weighty, no gloss, gradient, or shadow on the button itself.

### Chips (filter)
- **Shape:** 12px radius, 36px tall, 12px horizontal padding, with a trailing count badge.
- **Selected:** ink-black fill, white label; the count sits in a translucent-white rounded badge.
- **Unselected:** muted surface (#F4F3F0), tertiary text; plain count.
- **Postponed variant:** amber wash (#FEF6E4) with amber text and a soft amber border — it navigates out to the postponed list rather than filtering inline.

### Cards / Containers
- **Corner Style:** 16px.
- **Background:** white surface on the paper ground.
- **Border:** 1px hairline (rgba(0,0,0,.05) / #E6E5E2).
- **Shadow Strategy:** the soft *Card lift* (see Elevation); the Home hero card gets the deeper *Hero lift*.
- **Internal Padding:** 16px. Inner divider rows (e.g. the "cash to collect" row) are separated by a 1px item-divider hairline (#F5F4F1) with 12px spacing.

### Inputs / Fields
- **Style:** muted-surface fill (#F4F3F0), 14px radius, 48px tall, with a leading search glyph and a trailing round clear button.
- **Active/Focus:** a **2px ink border** (#1A1919) marks the active field; the cursor is brand red. Search is real and debounced (rxdart) — never a fake container.

### Navigation
- **Bottom nav:** white bar with a hairline top border, four tabs (home / orders / notifications / more), each a 23px stroke glyph over a 12px caption.
- **States:** active tab is danger-red (#C81E1C) glyph + semi-bold label; inactive is secondary-grey + regular. The notifications tab can carry a 7px brand-red dot. A home-indicator pill sits beneath.

### Status Pill (signature)
Small 8px-radius pill: paired background + foreground (+ optional border) from the status semaphore,
12px bold caption, optional leading icon, 4×8px padding. The unit that reports every order's state.

### COD Payment Card (signature)
The system's heaviest object: a full-width ink-black card (18px radius) with a muted label, a large
extra-bold tabular amount (24px) with a lighter currency suffix, and a translucent-white icon tile
(13px) holding a **cash-bright green** (#3BD07A) glyph. Cash is given more visual weight than any
other single element — the courier is accountable for money.

## Do's and Don'ts

### Do:
- **Do** body every screen on warm paper (#F6F5F3) with white surfaces layered above it.
- **Do** use ink-black (#1A1919) for primary actions, selected states, and the COD card.
- **Do** keep every gap and padding on the 4px grid, and every font size a multiple of 4 (only 14/18 excepted).
- **Do** reserve saturated color for status semaphore and search highlight only.
- **Do** give cash the heaviest treatment on its screen (dark card, 24px extra-bold tabular figures).
- **Do** build in RTL with directional spacing APIs, and set order numbers LTR within the Arabic flow.
- **Do** separate surfaces with a 1px hairline first, then the soft card shadow.

### Don't:
- **Don't** fill a button or large surface with brand red — red is a locator (pin, active nav, cursor), not paint.
- **Don't** add gradients, glassmorphism, glossy effects, or bright decorative fills — this is a work tool, not a lifestyle app.
- **Don't** shrink into a dense dashboard: no tiny type, cramped tables, or enterprise density.
- **Don't** introduce a second typeface — build hierarchy by weight (400/600/700/800) within Noto Kufi Arabic.
- **Don't** lean on heavy drop shadows to separate elements; that's the hairline border's job.
- **Don't** use pure white as the page background, and don't invent off-grid spacing (no 10/18px gaps) or fractional pixels.
