import Flutter
import UIKit
import WidgetKit

public class SwiftHomeWidgetPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    private static var groupId : String?
    
    private var initialUrl : URL?
    private var latestUrl : URL? {
        didSet {
            if(latestUrl != nil) {
                eventSink?.self(latestUrl?.absoluteString)
            }
        }
    }
    
    private var eventSink : FlutterEventSink?
    
    private let notInitializedError = FlutterError(
    code: "-7", message: "AppGroupId not set. Call setAppGroupId first", details: nil)
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = SwiftHomeWidgetPlugin()
        
        let channel = FlutterMethodChannel(name: "home_widget", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "home_widget/updates", binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)
        
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "setAppGroupId" {
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let groupId = myArgs["groupId"] as? String{
                SwiftHomeWidgetPlugin.groupId = groupId
                result(true)
            } else {
                result(FlutterError(code: "-6", message: "InvalidArguments setAppGroupId must be called with a group id", details: nil))
            }
        }else if call.method == "saveWidgetData" {
            if (SwiftHomeWidgetPlugin.groupId == nil) {
                result(notInitializedError)
                return
            }
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let id = myArgs["id"] as? String,
               let data = myArgs["data"] {
                let preferences = UserDefaults.init(suiteName: SwiftHomeWidgetPlugin.groupId)
                preferences?.setValue(data, forKey: id)
                result(preferences?.synchronize() == true)
            } else {
                result(FlutterError(code: "-1", message: "InvalidArguments saveWidgetData must be called with id and data", details: nil))
            }
        } else if call.method == "getWidgetData" {
            if (SwiftHomeWidgetPlugin.groupId == nil) {
                result(notInitializedError)
                return
            }
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let id = myArgs["id"] as? String,
               let defaultValue = myArgs["defaultValue"] {
                let preferences = UserDefaults.init(suiteName: SwiftHomeWidgetPlugin.groupId)
                result(preferences?.value(forKey: id) ?? defaultValue)
            } else {
                result(FlutterError(code: "-2", message: "InvalidArguments getWidgetData must be called with id", details: nil))
            }
        } else if call.method == "updateWidget" {

            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let name = (myArgs["ios"] ?? myArgs["name"]) as? String{
                if #available(iOS 14.0, *) {
                    #if arch(arm64) || arch(i386) || arch(x86_64)
                        WidgetCenter.shared.reloadTimelines(ofKind:name)
                    #endif
                } else {
                    result(FlutterError(code: "-4", message: "Widgets are only available on iOS 14.0 and above", details: nil))
                }
            } else {
                result(FlutterError(code: "-3", message: "InvalidArguments updateWidget must be called with name", details: nil))
            }
        } else if call.method == "initiallyLaunchedFromHomeWidget" {
            if (SwiftHomeWidgetPlugin.groupId == nil) {
                result(notInitializedError)
                return
            }
            if(initialUrl != nil) {
                result(initialUrl?.absoluteString)
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }

    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        let launchUrl = launchOptions[UIApplication.LaunchOptionsKey.url] as? NSURL
        initialUrl = launchUrl?.absoluteURL
        latestUrl = initialUrl
        return true
    }
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        latestUrl = url
        return true
    }
}
