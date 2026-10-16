import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    FlutterMethodChannel(
      name: "lumen/screen", binaryMessenger: flutterViewController.engine.binaryMessenger
    ).setMethodCallHandler { [weak self] call, result in
      guard call.method == "setPrivate", let on = call.arguments as? Bool else {
        return result(FlutterMethodNotImplemented)
      }
      self?.sharingType = on ? .none : .readOnly
      result(nil)
    }

    super.awakeFromNib()
  }
}
