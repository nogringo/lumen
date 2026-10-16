import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var screenPrivacy: ScreenPrivacy?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    screenPrivacy = ScreenPrivacy(messenger: engineBridge.applicationRegistrar.messenger())
  }
}

/// Covers the window while private screens are shown and the app is not
/// active, so the app switcher snapshot does not show them. iOS offers no
/// way to keep them out of screenshots.
final class ScreenPrivacy: NSObject {
  private let channel: FlutterMethodChannel
  private var isPrivate = false
  private var isActive = true
  private var cover: UIView?

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "lumen/screen", binaryMessenger: messenger)
    super.init()
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "setPrivate", let on = call.arguments as? Bool else {
        return result(FlutterMethodNotImplemented)
      }
      self?.isPrivate = on
      self?.update()
      result(nil)
    }
    let center = NotificationCenter.default
    center.addObserver(
      self, selector: #selector(willDeactivate), name: UIScene.willDeactivateNotification,
      object: nil)
    center.addObserver(
      self, selector: #selector(didActivate), name: UIScene.didActivateNotification, object: nil)
  }

  @objc private func willDeactivate() {
    isActive = false
    update()
  }

  @objc private func didActivate() {
    isActive = true
    update()
  }

  private func update() {
    guard isPrivate && !isActive else {
      cover?.removeFromSuperview()
      cover = nil
      return
    }
    guard cover == nil, let window = keyWindow else { return }
    let view = UIView(frame: window.bounds)
    view.backgroundColor = .systemBackground
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    window.addSubview(view)
    cover = view
  }

  private var keyWindow: UIWindow? {
    UIApplication.shared.connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.keyWindow }
      .first
  }
}
