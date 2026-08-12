# Product

<!-- impeccable:product-schema 1 -->

## Platform

Mobile — Flutter, ships to **iOS + Android** with a single, non-native design language
(the custom Arabic-first look from the `.dc.html` mockups renders identically on both OSes).
Deliberately **not** adaptive/Cupertino/Material-native: the mockups are the source of visual
truth, not any per-OS design system. (iOS Simulator is the primary verification surface.)

## Users

Primary user: a **last-mile courier on the move** — a delivery driver/rider working outdoors,
frequently one-handed and time-pressured, glancing at the phone between stops. Their job is to
run each order through its outcome: pick up the batch, find the next order, hand it off
(delivered), record a failure, or postpone it — and collect cash on delivery when required.

## Product Purpose

The Orderbase courier app is the field tool that drives a courier's day: it turns an assigned
batch of orders into a fast, low-error delivery loop. Success is the courier closing out every
order with the correct outcome and the correct cash reconciled, with the fewest taps and the
least ambiguity possible while on the move.

## Positioning

Two things a generic delivery-driver app would not get right and that future work must preserve:

- **COD cash handling is first-class, not an afterthought.** Cash-to-collect amounts, collection,
  and end-of-day settlement are core parts of the flow — the courier is accountable for money,
  and the design treats that with the same weight as delivery itself.
- **A glanceable, one-hand delivery flow.** The whole delivery state machine
  (pickup → orders queue → order detail → handoff / fail / postpone → result) is optimized for
  fast, low-error decisions made in seconds, on the move.

## Operating Context

- Last-mile field delivery, **Arabic-first / RTL**, currency in **EGP** (Egypt).
- The delivery state machine: **pickup** (accept the batch) → **orders** (today's queue, with
  search and filters) → **order** detail → outcome via one of three sheets
  (**handoff** = delivered, **fail** = not delivered, **postpone**) → **result**.
- **Postponed** orders return to the active queue automatically at their scheduled time.
- End-of-day **settlement** and **COD collection** are distinct rituals in the courier's day.
- The queue is scoped to *today's* orders assigned to this courier (including postponed and
  delivered), excluding previous days.

## Capabilities and Constraints

- **Built today:** Home, Orders queue (list, search across order number / customer / street /
  area, filters, postponed sub-list, empty & no-results states), Order detail, delivery outcomes
  (delivered / failed / postponed) via bottom sheets, Result screen, Pickup.
- **Not yet built:** Settlement, COD Collection, Failure States, Auth, and remaining Home
  variants (1b / 1c / 2a).
- **Terminology to keep consistent:** handoff, postpone, settlement, COD / "cash to collect".
- **Hard constraints (from the mockups + house rules):** Arabic-first RTL on every screen;
  Noto Kufi Arabic type; the **4-pixel spacing rule** (font sizes and gaps in multiples of 4,
  only 14/18 exceptions for type); the `.dc.html` mockups are the source of truth — when a
  mockup and a convention disagree, the mockup wins.
- Arabic-keyboard digits are normalized to Western digits in search.

## Brand Commitments

- Name: **Orderbase** (courier app).
- Arabic-first voice; **Noto Kufi Arabic** typeface.
- The Claude Design project **"Orderbase courier app project"** `.dc.html` mockups are binding
  visual authority (project id `6bbc0e73-b279-4e8d-affc-ae79997f2cf8`), not the unrelated
  `~/Orderbase` React/Tailwind design-system repo, which is explicitly out of scope.

## Evidence on Hand

- Real, mockup-faithful sample data under `lib/data/` (`order.dart`, `flow_order.dart`) mirroring
  each screen's `state` so screens stay comparable to their `.dc.html` source.
- The `.dc.html` mockups themselves (fetched via the DesignSync MCP tool) are the ground-truth
  reference for every visual and behavioral detail.
- **No real customers, testimonials, benchmarks, pricing, or partner claims exist yet** — future
  work must not fabricate them.

## Product Principles

- **The mockup is the contract.** Every visual and behavioral detail traces to a `.dc.html`
  source of truth; deviations are deliberate and documented, never incidental.
- **Design for the thumb and the glance.** Assume one hand, motion, glare, and seconds of
  attention — outcomes must be reachable and unambiguous without stopping.
- **Money is a first-class outcome.** COD amounts and settlement carry the same design weight and
  clarity as the delivery itself; the courier is accountable for cash.
- **No dead ends.** Every order reaches a clear outcome (delivered / failed / postponed), and the
  flow always shows the courier what happens next.
- **Arabic-first, not Arabic-translated.** RTL and Arabic type are the native design substrate,
  never a retrofit.

## Accessibility & Inclusion

No formal standard has been fixed, but two confirmed user needs govern design decisions: the
courier is **one-handed and on the move** (generous tap targets, reachable primary actions,
high-glance legibility for outdoor/glare conditions) and **RTL-native** (correct directional
mirroring, no LTR leakage).
