import Flutter
import Foundation
import UIKit

#if canImport(ActivityKit)
import ActivityKit
#endif

/// Bridges `orderbase/live_activity` (Dart → native) and
/// `orderbase/deep_links` (native → Dart).
///
/// Everything here is availability-guarded down to iOS 16.1. The Runner target
/// deliberately keeps its low deployment target so the app still installs on
/// the older iPhones a lot of couriers carry — on those, every method below
/// answers "not supported" and nothing else happens.
///
/// NOTE: because Runner deploys below iOS 16.1, ActivityKit must be linked
/// **Optional** (weak) in Runner's *Link Binary With Libraries* build phase, or
/// those older devices crash at launch. See ios/OrderbaseLiveActivity/SETUP.md.
final class LiveActivityChannel: NSObject {

    static let shared = LiveActivityChannel()

    private static let methodChannelName = "orderbase/live_activity"
    private static let deepLinkChannelName = "orderbase/deep_links"

    /// The running `Activity<DeliveryActivityAttributes>`, type-erased so this
    /// property itself needs no availability annotation.
    private var activityBox: Any?

    private var deepLinkChannel: FlutterMethodChannel?

    /// A URL that arrived before Dart was listening (cold launch from a tap on
    /// the island). Handed over on the first `consumePendingLink` call.
    private var pendingLink: URL?

    // MARK: - Registration

    func register(with registry: FlutterPluginRegistry) {
        guard let registrar = registry.registrar(forPlugin: "LiveActivityChannel") else { return }
        let messenger = registrar.messenger()

        let channel = FlutterMethodChannel(name: Self.methodChannelName, binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call, result: result)
        }

        deepLinkChannel = FlutterMethodChannel(name: Self.deepLinkChannelName, binaryMessenger: messenger)
    }

    // MARK: - Deep links

    /// Called by `SceneDelegate` for every `orderbase://` URL.
    func deliverDeepLink(_ url: URL) {
        guard let channel = deepLinkChannel else {
            pendingLink = url
            return
        }
        channel.invokeMethod("open", arguments: url.absoluteString)
    }

    // MARK: - Method dispatch

    private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isSupported":
            result(isSupported)

        case "consumePendingLink":
            let link = pendingLink?.absoluteString
            pendingLink = nil
            result(link)

        case "dial":
            guard let args = call.arguments as? [String: Any],
                  let phone = args["phone"] as? String else {
                result(FlutterError(code: "bad_args", message: "dial needs a phone", details: nil))
                return
            }
            dial(phone)
            result(nil)

        case "start", "update":
            guard isSupported else { result(false); return }
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "bad_args", message: "\(call.method) needs a state map", details: nil))
                return
            }
            if #available(iOS 16.1, *) {
                if call.method == "start" {
                    result(start(args))
                } else {
                    update(args, result: result)
                }
            } else {
                result(false)
            }

        case "end":
            if #available(iOS 16.1, *) {
                end(result: result)
            } else {
                result(nil)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Capability

    private var isSupported: Bool {
        if #available(iOS 16.1, *) {
            // False when the courier has turned Live Activities off for the app
            // in Settings — which we treat exactly like an unsupported device.
            return ActivityAuthorizationInfo().areActivitiesEnabled
        }
        return false
    }

    // MARK: - ActivityKit

    #if canImport(ActivityKit)

    @available(iOS 16.1, *)
    private var activity: Activity<DeliveryActivityAttributes>? {
        activityBox as? Activity<DeliveryActivityAttributes>
    }

    @available(iOS 16.1, *)
    private func start(_ args: [String: Any]) -> Bool {
        guard let state = Self.contentState(from: args) else { return false }
        let attributes = DeliveryActivityAttributes(shiftId: args["shiftId"] as? String ?? "shift")
        do {
            if #available(iOS 16.2, *) {
                activityBox = try Activity.request(
                    attributes: attributes,
                    content: ActivityContent(state: state, staleDate: nil),
                    pushType: nil
                )
            } else {
                activityBox = try Activity.request(
                    attributes: attributes,
                    contentState: state,
                    pushType: nil
                )
            }
            return true
        } catch {
            NSLog("[live_activity] start failed: \(error.localizedDescription)")
            return false
        }
    }

    @available(iOS 16.1, *)
    private func update(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let running = activity, let state = Self.contentState(from: args) else {
            result(false)
            return
        }
        Task {
            if #available(iOS 16.2, *) {
                await running.update(ActivityContent(state: state, staleDate: nil))
            } else {
                await running.update(using: state)
            }
            await MainActor.run { result(true) }
        }
    }

    @available(iOS 16.1, *)
    private func end(result: @escaping FlutterResult) {
        guard let running = activity else {
            result(nil)
            return
        }
        activityBox = nil
        Task {
            if #available(iOS 16.2, *) {
                await running.end(nil, dismissalPolicy: .immediate)
            } else {
                await running.end(dismissalPolicy: .immediate)
            }
            await MainActor.run { result(nil) }
        }
    }

    @available(iOS 16.1, *)
    private static func contentState(from args: [String: Any]) -> DeliveryActivityAttributes.ContentState? {
        guard let orderNum = args["orderNum"] as? String,
              let customer = args["customer"] as? String,
              let area = args["area"] as? String else { return nil }

        let phaseRaw = args["phase"] as? String ?? "enRoute"
        return DeliveryActivityAttributes.ContentState(
            orderNum: orderNum,
            customer: customer,
            area: area,
            addressDetail: args["addressDetail"] as? String,
            stopNumber: args["stopNumber"] as? Int ?? 0,
            totalStops: args["totalStops"] as? Int ?? 0,
            codDue: args["codDue"] as? Int ?? 0,
            prepaid: args["prepaid"] as? Bool ?? false,
            dueLabel: args["dueLabel"] as? String,
            phase: DeliveryActivityAttributes.ContentState.Phase(rawValue: phaseRaw) ?? .enRoute
        )
    }

    #endif

    // MARK: - Dialer

    /// Opens the system dialer. iOS puts up its own "Call ...?" confirmation,
    /// so this can never place a call on its own.
    private func dial(_ phone: String) {
        let allowed = CharacterSet(charactersIn: "+0123456789")
        let cleaned = String(phone.unicodeScalars.filter { allowed.contains($0) })
        guard !cleaned.isEmpty, let url = URL(string: "tel://\(cleaned)") else { return }
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
