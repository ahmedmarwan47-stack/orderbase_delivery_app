import ActivityKit
import SwiftUI
import WidgetKit

private typealias State = DeliveryActivityAttributes.ContentState

// MARK: - Widget

/// The courier's current stop, on the Dynamic Island and the Lock Screen.
///
/// Content is scoped to ONE stop — see `LiveActivityBridge` in Dart for why.
struct DeliveryLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeliveryActivityAttributes.self) { context in
            LockScreenCard(state: context.state)
                .environment(\.layoutDirection, .rightToLeft)
                .activityBackgroundTint(OB.paper)
                .activitySystemActionForegroundColor(OB.ink)
        } dynamicIsland: { context in
            DynamicIsland {
                // NOTE on RTL: which physical side `.leading` lands on follows
                // the DEVICE's language, not this app's. Both slots are
                // therefore self-contained — each reads correctly on its own,
                // whichever side it ends up on.
                DynamicIslandExpandedRegion(.leading) {
                    Text(OB.stopLabel(context.state.stopNumber, context.state.totalStops))
                        .font(OB.font(12, OB.semibold))
                        .foregroundColor(OB.muted)
                        .environment(\.layoutDirection, .rightToLeft)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    CashTag(state: context.state)
                        .environment(\.layoutDirection, .rightToLeft)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottom(state: context.state)
                        .environment(\.layoutDirection, .rightToLeft)
                }
            } compactLeading: {
                Image(systemName: context.state.phase.symbol)
                    .foregroundColor(context.state.phase.tint)
            } compactTrailing: {
                Text(compactTrailing(context.state))
                    .font(OB.font(14, OB.bold))
                    .foregroundColor(context.state.phase.trailingTint)
            } minimal: {
                Image(systemName: context.state.phase.symbol)
                    .foregroundColor(context.state.phase.tint)
            }
            .widgetURL(URL(string: "orderbase://order?num=\(context.state.orderNum)"))
            .keylineTint(OB.brand)
        }
    }

    /// Roughly four characters fit here, so this is the stop counter while
    /// driving and the cash figure once the money matters.
    ///
    /// The mockup shows a live countdown instead of the counter. That needs a
    /// real deadline on `Order` — `Order.due` is a pre-formatted label, not a
    /// timestamp. Give it a `DateTime` and this can become SwiftUI's
    /// `Text(timerInterval:)`, which ticks on its own with no updates pushed.
    private func compactTrailing(_ state: State) -> String {
        switch state.phase {
        case .arrived, .collecting:
            return state.prepaid
                ? OB.stopCounter(state.stopNumber, state.totalStops)
                : OB.money(state.codDue)
        case .enRoute, .done:
            return OB.stopCounter(state.stopNumber, state.totalStops)
        }
    }
}

// MARK: - Phase styling

private extension State.Phase {
    /// SF Symbols stand in for the app's own stroke icons: those live in the
    /// Flutter asset bundle as SVG, which the extension cannot read. Swap in an
    /// asset catalog here if the glyphs need to match exactly.
    var symbol: String {
        switch self {
        case .enRoute: return "mappin.and.ellipse"
        case .arrived, .collecting: return "banknote"
        case .done: return "checkmark.circle.fill"
        }
    }

    var tint: Color {
        switch self {
        case .enRoute: return OB.brand
        case .arrived, .collecting: return OB.amber
        case .done: return OB.green
        }
    }

    var trailingTint: Color {
        switch self {
        case .arrived, .collecting: return OB.amber
        case .enRoute, .done: return .white
        }
    }
}

private extension State {
    /// "زهراء مدينة نصر · شارع بن عبدالعزيز"
    var subtitle: String {
        guard let detail = addressDetail, !detail.isEmpty else { return area }
        return "\(area) · \(detail)"
    }

    var callURL: URL? {
        URL(string: "orderbase://call?num=\(orderNum)")
    }
}

// MARK: - Expanded

/// The cash figure, or a "paid" tag on a prepaid order.
private struct CashTag: View {
    let state: State

    var body: some View {
        Group {
            if state.prepaid {
                Text("مدفوع")
                    .font(OB.font(12, OB.semibold))
                    .foregroundColor(OB.green)
            } else {
                HStack(spacing: 4) {
                    Text(OB.money(state.codDue))
                        .font(OB.font(14, OB.bold))
                        .foregroundColor(OB.amber)
                    Text("ج.م")
                        .font(OB.font(12, OB.semibold))
                        .foregroundColor(OB.amber.opacity(0.72))
                }
            }
        }
    }
}

/// Customer identity plus the one action worth having at the door.
///
/// The mockup also had a "navigate" button; it is left out because nothing in
/// the app launches a maps app yet, and a button that does nothing is worse
/// than no button. Add it here the day that exists.
private struct ExpandedBottom: View {
    let state: State

    var body: some View {
        // The expanded island caps out at ~160pt tall, and the leading/trailing
        // row eats the top of that. Every size below is chosen so the whole
        // stack — name, address and the call button — fits inside what is
        // left; raising any of them clips the button off the bottom edge.
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                Text(state.customer)
                    .font(OB.font(18, OB.bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(state.subtitle)
                    .font(OB.font(12))
                    .foregroundColor(OB.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            if let url = state.callURL {
                Link(destination: url) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 14, weight: .semibold))
                        Text("اتصال بالعميل")
                            .font(OB.font(12, OB.bold))
                    }
                    .foregroundColor(OB.ink)
                    .frame(maxWidth: .infinity, minHeight: 36)
                    .background(Capsule().fill(Color.white))
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Lock Screen

/// The wider card shown on the Lock Screen and in Notification Centre.
///
/// The cash figure is deliberately MASKED here: unlike the island, this is
/// readable by anyone standing next to the courier.
private struct LockScreenCard: View {
    let state: State

    var body: some View {
        // A Lock Screen activity gets ~160pt of height and iOS clips the TOP
        // when the content is taller, silently eating the header row. Every
        // gap and inset below is sized to keep the whole card inside that.
        VStack(alignment: .leading, spacing: 8) {
            header
            identity
            ProgressSegments(done: max(state.stopNumber - 1, 0), total: state.totalStops)
            cashRow
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var header: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(OB.brand)
                .frame(width: 20, height: 20)
                .overlay(
                    Image(systemName: "bicycle")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                )
            Text(OB.stopLabel(state.stopNumber, state.totalStops))
                .font(OB.font(12, OB.semibold))
                .foregroundColor(OB.secondary)

            Spacer(minLength: 8)

            if let due = state.dueLabel, !due.isEmpty {
                Text(due)
                    .font(OB.font(12, OB.bold))
                    .foregroundColor(OB.ink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous).fill(OB.subtle)
                    )
            }
        }
    }

    private var identity: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(state.customer)
                .font(OB.font(18, OB.bold))
                .foregroundColor(OB.ink)
                .lineLimit(1)
            Text(state.subtitle)
                .font(OB.font(14))
                .foregroundColor(OB.warmMuted)
                .lineLimit(1)
        }
    }

    private var cashRow: some View {
        HStack(spacing: 8) {
            Image(systemName: state.prepaid ? "checkmark.seal" : "banknote")
                .font(.system(size: 14))
                .foregroundColor(OB.warmMuted)
            Text(state.prepaid ? "مدفوع مقدمًا" : "تحصيل نقدي")
                .font(OB.font(12, OB.semibold))
                .foregroundColor(OB.warmMuted)

            Spacer(minLength: 8)

            if !state.prepaid {
                HStack(spacing: 8) {
                    Text("••••")
                        .font(OB.font(16, OB.bold))
                        .foregroundColor(OB.ink)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(OB.warmMuted)
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(OB.subtle)
        )
    }
}

/// One segment per stop on the route, filled for the stops already closed.
private struct ProgressSegments: View {
    let done: Int
    let total: Int

    /// Past a dozen or so the segments stop being readable at this width.
    private var capped: Int { min(max(total, 1), 16) }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<capped, id: \.self) { index in
                Capsule()
                    .fill(index < done ? OB.green : OB.hairline)
                    .frame(height: 4)
            }
        }
    }
}
