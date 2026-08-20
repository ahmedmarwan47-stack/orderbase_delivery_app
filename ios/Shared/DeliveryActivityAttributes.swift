import Foundation

#if canImport(ActivityKit)
import ActivityKit

/// The contract between the Flutter app and the Live Activity widget.
///
/// **This file belongs to BOTH targets** (Runner and OrderbaseLiveActivity) —
/// ActivityKit matches an activity to its widget by this type, so the two must
/// compile the same source. If you add a field here, add it to
/// `DeliveryActivityState` in `lib/core/live_activity/live_activity_service.dart`
/// and to the decoder in `LiveActivityChannel.swift` as well.
@available(iOS 16.1, *)
struct DeliveryActivityAttributes: ActivityAttributes {

    /// Everything that changes while one stop is in progress.
    public struct ContentState: Codable, Hashable {

        /// Which moment of the stop we are showing. Raw values match the Dart
        /// `DeliveryPhase` enum names exactly.
        public enum Phase: String, Codable, Hashable {
            case enRoute
            case arrived
            case collecting
            case done
        }

        /// Order number without '#', so it can ride in the deep-link URL.
        public var orderNum: String
        public var customer: String
        public var area: String
        public var addressDetail: String?
        public var stopNumber: Int
        public var totalStops: Int

        /// Cash still to collect on this order; 0 when prepaid.
        public var codDue: Int
        public var prepaid: Bool

        /// Promised-delivery label as the order carries it, e.g. "٢:٤٥ م".
        public var dueLabel: String?

        public var phase: Phase
    }

    /// Identifies the shift the activity belongs to. Carried so a stale
    /// activity left over from a previous run is recognisable.
    public var shiftId: String
}
#endif
