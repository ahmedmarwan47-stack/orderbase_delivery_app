---
target: the whole app UX
total_score: 29
max_score: 40
na_heuristics: 
p0_count: 1
p1_count: 2
timestamp: 2026-08-18T09-01-47Z
slug: lib-app-app-shell-dart
---
Method: dual-agent (isolated parallel sub-agents — A: design review, B: deterministic evidence). Surface mode: **Operate**. DESIGN.md treated as partly stale (heavy edits this session).

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 3 | Rich live status everywhere, but the day never visibly *closes* (settlement P0) |
| 2 | Match System / Real World | 4 | EGP, Arabic-first RTL, real courier idiom (الفكة, الإرجاع للفرع, تسوية) — nothing to fix |
| 3 | User Control & Freedom | 3 | Good edit/recapture/clear paths, but logging a non-delivery is irreversible |
| 4 | Consistency & Standards | 3 | Two different back controls; primary-button radius drifts 15/16 |
| 5 | Error Prevention | 4 | Best trait: photo-required, COD-must-match, custody-confirm, carry-confirm |
| 6 | Recognition Rather Than Recall | 4 | Order context carried into every sheet; math restated before commit |
| 7 | Flexibility & Efficiency | 2 | KPI deep-links help, but no card-level accelerators (no swipe-to-call/navigate) |
| 8 | Aesthetic & Minimalist | 3 | Calm and disciplined — but the recent quieting overshot for a field tool |
| 9 | Error Recovery | 2 | COD short/excess hints exemplary; but partial-cash and post-fail undo have no path |
| 10 | Help & Documentation | 1 | Essentially none; failure branches only revealed after you commit to one |
| **Total** | | **29/40** | **Strong domain design, undercut by a broken core flow + a glance regression** |

## Design Specificity Verdict

**LLM assessment: authored for a courier, not category-interchangeable.** The specificity is load-bearing, not skin-deep: the Home progress bar orders its segments by *actual route sequence* and fills RTL-correctly; the COD flow does live excess→wallet math with the amount field re-tinting per keystroke and "in your custody until settlement" framing; pickup makes you confirm you *physically carried the batch* before the queue flips to in-transit; the failure state machine encodes which reasons return-to-branch vs. stay retryable. Motion and haptics are wired as feedback with Reduce-Motion fallbacks, not decoration. A courier PM would recognize this domain model. That bar is cleared — the problems are execution regressions, not a generic template.

**Deterministic scan:** the bundled markup detector ran clean (exit 0) but is **not applicable** — it scanned **0 of 157 Dart files** (it targets HTML/JSX/Vue, not Flutter), so "no findings" means "nothing to scan," not a clean bill. Applicable Dart evidence: `flutter analyze` **clean (0 issues)**; **0** hardcoded `Colors.black/white` (strong token discipline, corroborating the "disciplined tokens" read); raw `fontSize:` bypassing the size tokens appears **10×** but almost all are dev/legacy files (`lib/dev/*`, unused `status_bar.dart`) or commented "no token" one-offs. One real gap the scan surfaces that the eye can miss: **a11y coverage is thin — only 13 of 121 feature files** reference `Semantics`/labels, concentrated in auth + a few sheets; the delivery loop screens are largely unlabelled.

**Visual overlays:** N/A — native iOS app, no DOM/localhost page to inject into.

## Overall Impression

This is a genuinely well-authored courier tool with two of the hardest things already right: a correct money model and real error-prevention gates. But the daily loop **dead-ends at settlement** (there is no button to actually settle), and this session's "calm/quiet" pass quietly traded away the one thing an Operate tool can't lose — glanceable identifiers at arm's length in sunlight. Biggest single opportunity: **make the day closeable, then put the volume back on the things a courier reads first.**

## What's Working

1. **The COD money moment** (`cod_entry_sheet` / `cod_confirm_sheet`) — a live-retinting amount field with *named* short/excess amounts, then a staged custody reveal with count-up and a cash-tile pulse. This is the app at its best and exactly where the stakes are highest.
2. **Route-truth progress bar** (`home_next_stop_card`) — segments ordered by real delivery sequence, per-segment color keyed by stop id, RTL-correct. Authored, not decorative.
3. **Error-prevention gating** — proof-photo required, COD-must-match-due, custody checkbox, carry-confirmation sheet. The safeguards a cash-handling field tool actually needs, and `flutter analyze` + zero hardcoded colors say the implementation discipline matches.

## Priority Issues

- **[P0] Settlement has no "settle" action — the core loop dead-ends.** `_SettlementOpenView` renders cash card → collections → locked note → nav, with **no CTA**. `SettlementController.settle()` and the string `settlementSettleCta` both exist but are unwired; the settled state is only reachable via DevGallery. In the running app the courier can never close the day — and settlement is the highest-trust, peak-end moment (handing cash to the cashier). *Fix:* add a sticky ink CTA mirroring the pickup confirm bar, calling `vc.settle()`. Everything needed already exists. → **/impeccable harden** (or a direct wire-up).

- **[P1] Order detail stacks two bottom bars and buries the failure outcome.** The pushed detail screen renders the sticky `_DeliverBar` *and* the full 5-tab `BottomNav` beneath it, while "لم يتم التسليم" is an inline button far down the scroll. So the primary CTA sits one fat-finger above a tab that drops you out of the handoff, and the two delivery outcomes have wildly asymmetric reach (deliver sticky, fail buried). Showing tab roots on a screen pushed *over* the shell is also odd IA. *Fix:* drop the tab bar on detail; bottom-anchor both outcomes (deliver primary + secondary outline "لم يتم التسليم"). → **/impeccable layout**

- **[P1] Transparent headers + 16px title floor weaken the glance.** The scroll-reactive headers are fully transparent until scrolled, so at rest the order number, status pill, and back tile float on bare paper with no figure-ground — exactly when a courier takes a 2-second look. Combined with titles dropped to 16px and 12px meta, the primary identifiers are now the *quietest* things on screen. (Both are this session's changes.) *Fix:* give the at-rest header a faint surface/hairline and fade the *shadow* on scroll rather than the fill; bump order #/customer/status up one step. → **/impeccable typeset** / **/impeccable adapt**

- **[P2] No undo after logging a non-delivery.** `failure_flow` commits immediately; the interim countdown was removed. The undo pattern already exists (the returned-to-queue snackbar). *Fix:* snackbar-with-undo after the failed Result, or a short pre-persist countdown. → **/impeccable harden**

- **[P2] Cash-card green collides with "delivered" green.** `paymentCardBg` (#4E6B60) now carries the two most important money objects, but a desaturated green puts *money* in the same hue family as the *delivered* status — a semantic collision on the highest-stakes surface. *Fix:* give money a distinct deep neutral/teal outside the four status hues; keep green strictly for delivered. → **/impeccable colorize**

## Persona Red Flags

**Courier on the move (one-handed, gloved/wet, glare, seconds of attention):**
- Transparent headers + 16px titles = weakest contrast on the exact identifiers (order #, customer, status) glanced at first.
- Order cards are tappable only on the top row; no glove-sized call/navigate on the list — everything is a drill-in.
- Deliver bar sits directly above the 5-tab nav → a mis-tap drops the handoff mid-flow.
- The always-on red notification dot (`notificationsBadge: true` hardcoded on nearly every `BottomNav` + the Home bell) cries wolf — it can never signal a *real* unread.

**First-time courier:**
- Help/onboarding ≈ absent (heuristic 10 = 1); the failure branches (which reason returns-to-branch vs. stays retryable) are only revealed by the tag *after* selection.
- The settlement dead-end (P0) reads as "I broke something."
- Partial-cash COD leaves them at a disabled button with no explanation of the alternative.

## Minor Observations
- `OrderDetailScreen.build()` constructs a fresh `OrderFlowController` every rebuild — move to state.
- Two back controls (`HeaderBackButton` tile vs. queue search `_SquareIconButton`) — unify.
- Primary-button radius drifts 15/16 across identical CTAs.
- Home's neutral "المحطة 2 من 5" stop-count pill uses `failedBg` (red-family) — off-semantic for a non-error element.
- `_MoreTab` still passes `notificationsBadge: true` though the notifications tab is gone — dead prop.
- a11y: only 13/121 feature files carry `Semantics`/labels — the delivery-loop screens are largely unlabelled for screen readers.
- Pickup + notifications empty states are genuinely nice — reassuring and on-token.

## Questions to Consider
1. The day *begins* (pickup) and *ends* (settlement) as first-class flows — so why is settlement the one screen with no completion button? Decide whether closing the day is even the courier's action here; right now it's neither, and that ambiguity is the P0.
2. Every outcome is a bottom-sheet stack you tap forward through. On a real doorstep in 8 seconds, is reason→confirm the right cost for the 80% case ("customer not present") — or should the single most common failure be one tap from the card?
3. You reduced every title to 16px for calm. Are you designing for how it looks in review — elegant, screenshot-ready — or how it reads on a scooter at noon? An Operate tool needs to shout its identifiers, not whisper them.
