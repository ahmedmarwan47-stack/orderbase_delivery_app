---
target: Orderbase courier app — Home & core flow
total_score: 30
max_score: 40
na_heuristics: 
p0_count: 0
p1_count: 2
timestamp: 2026-08-13T13-06-07Z
slug: orderbase-courier-app-home-core-flow
---
## Design Health Score — 30/40 (Good)

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 3 | Status pills + route progress + order timeline are strong; the KPI/queue "distrust" fear turned out to be a rendering artifact, not real. |
| 2 | Match System / Real World | 4 | Manifest metaphor + courier Arabic vocabulary (يرجع للفرع، المطلوب تحصيله نقدًا، جم) speak the user's language exactly. |
| 3 | User Control and Freedom | 3 | Back/رجوع للسبب everywhere, dismissible sheets; but the irreversible, cash-affecting return commit has no confirm. |
| 4 | Consistency and Standards | 3 | Main surfaces reconcile (share ShiftController); real seams: COD labeled 3 ways, notification time formats mixed, PostponedScreen off a separate data source. |
| 5 | Error Prevention | 3 | Mandatory note + "try once more" gate before returning; weak spot is the un-confirmed red-fill commit. |
| 6 | Recognition Rather Than Recall | 3 | Reason tags, thumbnails, persistent order #/COD banner reduce recall; the "٠ جم" KPI glyph is ambiguous out of context. |
| 7 | Flexibility and Efficiency | 2 | One-tap batch confirm is good, but no swipe-to-act, no accelerators for the one-thumb courier. |
| 8 | Aesthetic and Minimalist Design | 4 | Genuinely calm, disciplined paper/ink system; nothing decorative competes. Best dimension. |
| 9 | Error Recovery | 3 | Failure flow explains consequences superbly; but no offline/degraded-network state exists for a field app. |
| 10 | Help and Documentation | 2 | No first-run primer for the reason-tag semantics or COD accountability model. |
| **Total** | | **30/40** | **Good** |

## Design Specificity Verdict — Authored for THIS product (8/10)

**LLM assessment:** This is genuinely courier-specific, not a category-interchangeable delivery template. Cash is first-class (dark ink COD card outweighs everything on the order screen; queue cards split "المطلوب تحصيله نقدًا" onto its own divided row). The failure flow is domain-modeled: every reason is pre-tagged returns-to-branch vs retryable — the courier's accountability logic surfaced at decision time — then gated behind a mandatory "try once more + note" and reconciled pieces→branch. Glanceability and RTL are native (order numbers correctly LTR inside Arabic flow). It slips toward generic only at the edges: stock centered login, decorative placeholder map, standard 2×2 KPI grid.

**Deterministic scan:** The bundled detector (`detect.mjs`) is HTML/CSS-only — its file walker's `SCANNABLE_EXTENSIONS` set excludes `.dart`, so all 152 Dart files were silently skipped and it returned a hollow `[]`/exit 0. No `.dc.html` mockups exist on disk (they live in the remote design project). So the deterministic scan **does not apply**; code-level greps were used instead. Findings: color tokenization is essentially complete (only 2 benign literals: a transparent OTP caret and one `Colors.transparent`); zero TODO/FIXME debt in the changed dirs; off-4px spacing is widespread (~15 documented as intentional mockup-pixel exceptions in `home/`, but dozens more in `order_flow`/`settlement`/`pickup` carry no such comment).

**Where detector corrected the review:** (1) The "٦٠ vs ٦" queue-count "mismatch" is a **rendering artifact** — the middot separator "·" abutting the digit "٦" reads as "٦٠"; both header and "الكل" chip bind the same `vc.active.length` = 6, and Home reconciles (4 transit + 1 delivered + 1 failed = 6). Not a data bug. (2) The grey-text "contrast failure" is **refuted**: `textSecondary #6B6B73` measures ≈5.3:1 on white (passes AA); the only low-contrast grey (#A6A6AD ≈2.4:1) is used solely on the dark card.

**Visual overlays:** Not available — this is a native Flutter app, not a web page, so no in-browser detector overlay could be injected. Evidence is 11 real iOS-simulator screenshots instead.

## Priority Issues

**[P1] Return-to-branch CTA is a full brand-red fill — violates the One Red Rule** *(confirmed by both passes)*
- **Why it matters:** DESIGN.md is explicit — "red is never a button fill or large surface… red is a pin, not paint"; destructive variants must be "outlined or amber-tinted, never a red fill." Source confirms `_PrimaryButton(danger: true)` → `dangerAccent (#C81E1C)` as the fill. Beyond the self-contradiction, it emotionally turns a *sanctioned* outcome into an alarm at the end of an otherwise humane failure flow, and spends the app's scarcest attention color on a routine action.
- **Fix:** Make it ink-fill (standard primary) or an outlined/amber destructive variant; keep red for pin/nav/cursor only. Add a one-line confirm ("سيُرجَّع ٤ قطع للفرع") instead of relying on red to signal weight.
- **Command:** `/impeccable colorize` (+ `/impeccable clarify` for the confirm line)

**[P1] Failure-reason picker exceeds the ≤4 choice limit (7 options) at the highest-stress moment**
- **Why it matters:** 6 radio reasons + a postpone affordance = 7 choices, one-handed at a doorstep under time pressure. Worse, the postpone branch sits *below* the primary CTA, hiding a primary outcome — the thumb lands on "التالي — الإرجاع للفرع" first and may commit the wrong result.
- **Fix:** Cluster into the two labeled groups already implied by the tags (يرجع للفرع / قابل للإعادة) with subheads, or surface the top 3 reasons and fold the rest under "سبب آخر". Promote postpone to a peer branch, not a sub-CTA.
- **Command:** `/impeccable distill` (+ `/impeccable layout`)

**[P2] PostponedScreen reads a separate, static data source — the one place surfaces really can drift**
- **Why it matters:** The main Home and Queue lists share the live `ShiftController` and cannot diverge (this is what refuted the "distrust" fear). But `PostponedScreen` defaults to `sampleOrders.where(status == postponed)` — the immutable seed — while the postponed *chip* count comes from `ShiftController.postponed`. Runtime postpones never reach the list screen, so the chip and the list it opens can disagree.
- **Fix:** Point `PostponedScreen` at `ShiftController.instance` like every other list; delete the static fallback except for DevGallery previews.
- **Command:** `/impeccable audit` (then `/impeccable harden`)

**[P2] No offline / degraded-network state for a field app**
- **Why it matters:** Couriers work in stairwells, basements, and dead zones — the app's own customer note literally says "elevator broken, take the stairs." No offline queue, no degraded state, and no defined behavior for whether COD reconciles when connectivity returns. Highest-risk gap for the actual usage scene.
- **Fix:** Model an offline banner + outbound action queue; define COD/outcome reconciliation on reconnect. At minimum, a visible "changes will sync" state so the courier isn't guessing.
- **Command:** `/impeccable harden`

**[P2] Undocumented off-4px spacing spread across order_flow / settlement / pickup**
- **Why it matters:** The 4-pixel grid is a stated hard constraint. `home/` documents ~15 intentional mockup-pixel exceptions inline; the many off-grid literals elsewhere (e.g. `handoff_sheet.dart` 17/26/30/10, `order_detail_timeline.dart:37` `2.w`, `settlement_open_view.dart:124` `7.w/7.h`) carry no such note, so genuine drift is indistinguishable from deliberate exceptions.
- **Fix:** Snap undocumented values to the grid or annotate them "off-grid, matches mockup Xpx" like `home/` does. Establishes one auditable rule.
- **Command:** `/impeccable audit` (+ `/impeccable polish`)

## Persona Red Flags

**Casey (distracted, one-handed — the core persona):** The 7-option reason list demands careful tag-reading while stationary — unusable at a glance. Primary CTAs are correctly bottom-anchored, but the failure sheet buries the *postpone* branch below the primary button, so Casey's thumb may commit the wrong outcome. Faint meta (ETA/distance/address) passes WCAG AA but is still the first thing to wash out in sunlight at arm's length.

**Riley (edge cases / stress):** No offline/failed-network state — the exact basement scenario the app itself describes is unmodeled. The "٠ جم إجمالي التحصيل" start-of-day zero has no explicit empty treatment (broken, or intentional?). The postponed chip-vs-list divergence is precisely the seam Riley finds first. What happens when the day ends with unresolved "قابل للإعادة" retryables — is there a dead-end guard, given the "No dead ends" principle?

**The courier on the move:** The red-fill return button reads as danger mid-shift for a normal outcome — a beat of hesitation at the doorstep. The map is a decorative placeholder, yet "افتح على الخريطة" implies real navigation — a promise the UI can't keep. Batch pickup is one-way ("كل الطلبات تتحول إلى في الطريق") with no partial-accept if a piece is missing at the branch.

## Minor Observations

- **Route progress bar (Home):** "current" uses brand-red and "failed" uses failed-red — two reds adjacent on the same bar, ambiguous at a glance. Give current or failed a distinct treatment (e.g. an × marker for failed) and verify fill direction matches RTL reading.
- **COD is labeled three ways:** "عند الاستلام" (pickup), "الدفع عند الاستلام" (home/detail/queue), and the queue renders it in **red text** — another nibble at the One Red Rule. Unify the label and its color.
- **Notification timestamps mix formats:** bare "١٠ دقائق" for minutes vs "منذ ساعة" for hours. Route everything through one relative-time formatter → "منذ ١٠ دقائق". Also decide on a single unread signal (red dot *or* card tint, not both).
- **Queue header separator:** "· ٦" is legibly indistinguishable from "٦٠". Add a space, swap the middot, or move the count — a pure legibility fix, not a data bug.
- **KPI COD glyph** reuses the dark-card cash icon on a light tile; the "٠ جم" is the only colored number and competes with "٠١ تعذر التسليم" beside it.

## Questions to Consider

1. The failure flow is your best-authored screen — so why does it *end* on a red panic button? What's the emotional target at the end of a failed delivery: shame, or sanctioned closure?
2. A field app for basements and stairwells with no offline state — where does the outbound-action queue live, and does COD reconcile on reconnect?
3. Is the map a promise you can't keep? Either wire real navigation behind "افتح على الخريطة" or stop implying it.
4. Seven reasons at the doorstep — which three actually get tapped? Instrument it; the other four are cognitive tax on your most distracted user.
5. One COD label, one relative-time format, one unread signal — how much of the "seams" impression is just three small inconsistencies compounding?
