import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    
    private var methodChannel: FlutterMethodChannel?
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

}
