import Cocoa
import FlutterMacOS
import IOKit.ps
import AVFoundation

@main
class AppDelegate: FlutterAppDelegate {
    
    private var methodChannel: FlutterMethodChannel?
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        mainFlutterWindow?.toolbar = NSToolbar()
        if #available(macOS 11.0, *) {
            mainFlutterWindow?.toolbarStyle = .unified
        }
        
        let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
        
        methodChannel = FlutterMethodChannel(name: "music_method_channel",
                                             binaryMessenger: controller.engine.binaryMessenger)
        
        methodChannel?.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "get_music_metadata":
                if let arguments = call.arguments as? [String: Any],
                   let path = arguments["path"] as? String {
                    result(self?.getMusicMetadata(filePath: path))
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing path argument", details: nil))
                }
            case "get_album_cover":
                if let arguments = call.arguments as? [String: Any],
                   let path = arguments["path"] as? String {
                    result(self?.getMusicAlbumCover(filePath: path))
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing path argument", details: nil))
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onEnterFullScreen), name: NSWindow.didEnterFullScreenNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onExitFullScreen), name: NSWindow.didExitFullScreenNotification, object: nil)
    }
    
    @objc func onEnterFullScreen(notification: Notification) {
        mainFlutterWindow?.toolbar = nil
        methodChannel?.invokeMethod("on_enter_fullscreen", arguments: nil)
    }

    @objc func onExitFullScreen(notification: Notification) {
        mainFlutterWindow?.toolbar = NSToolbar()
        if #available(macOS 11.0, *) {
            mainFlutterWindow?.toolbarStyle = .unified
        }
       methodChannel?.invokeMethod("on_exit_fullscreen", arguments: nil)
    }
    
    private func getMusicMetadata(filePath: String) -> [String: Any] {
        let fileURL = URL(fileURLWithPath: filePath)
        let asset = AVAsset(url: fileURL)
        
        var metadataDict: [String: Any] = [:]
        
        let metadata = asset.commonMetadata
        
        for item in metadata {
            if let commonKey = item.commonKey {
                switch commonKey {
                case .commonKeyTitle:
                    if let title = item.value as? String {
                        metadataDict["title"] = title
                    }
                case .commonKeyArtist:
                    if let artist = item.value as? String {
                        metadataDict["artist"] = artist
                    }
                case .commonKeyAlbumName:
                    if let album = item.value as? String {
                        metadataDict["album"] = album
                    }
                default:
                    break
                }
            }
        }
        
        return metadataDict
    }
    
    private func getMusicAlbumCover(filePath: String ) -> [UInt8] {
        
        let fileURL = URL(fileURLWithPath: filePath)
        let asset = AVAsset(url: fileURL)
        let metadata = asset.commonMetadata
        if let artworkItem = metadata.first(where: { $0.commonKey == .commonKeyArtwork }),
           let imageData = artworkItem.value as? Data {
            
            let byteArray = [UInt8](imageData)
            return byteArray
        }
        else {
            return []
        }
        
    }

}
