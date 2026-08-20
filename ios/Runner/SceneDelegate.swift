import Flutter
import UIKit

/// Receives the `orderbase://` URLs the Live Activity opens and hands them to
/// `LiveActivityChannel`, which forwards them to Dart.
///
/// If Xcode reports "method does not override any method from its superclass"
/// on either method below, this Flutter version's `FlutterSceneDelegate` does
/// not declare them: delete the two `override` keywords and the two matching
/// `super.` lines. Nothing else changes.
class SceneDelegate: FlutterSceneDelegate {

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    // Cold launch: the app was not running when the island was tapped.
    forward(connectionOptions.urlContexts)
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    super.scene(scene, openURLContexts: URLContexts)
    // Warm launch: the app was already in the background.
    forward(URLContexts)
  }

  private func forward(_ contexts: Set<UIOpenURLContext>) {
    for context in contexts where context.url.scheme == "orderbase" {
      LiveActivityChannel.shared.deliverDeepLink(context.url)
    }
  }
}
