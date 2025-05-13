import Cocoa
import FlutterMacOS
import IOKit.ps
import AVFoundation

@main
class AppDelegate: FlutterAppDelegate {
    
    private var methodChannel: FlutterMethodChannel?
    private var volume: Double = 0.5
    private var stream: HSTREAM = 0
    private var duration: Int = 0
    private var soundLoaded: Bool = false
    
    @available(macOS 11.0, *)
    private var timerTask: Task<Void, Never>?
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    override func applicationWillTerminate(_ aNotification: Notification) {
        BASS_StreamFree(stream)
        BASS_Free()
        if #available(macOS 11.0, *) {
            timerTask?.cancel()
        }
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        BASS_Init(-1, 44100, 0, nil, nil)
        
        mainFlutterWindow?.toolbar = NSToolbar()
        if #available(macOS 11.0, *) {
            mainFlutterWindow?.toolbarStyle = .unified
        }
        
        let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
        
        methodChannel = FlutterMethodChannel(name: "music_method_channel", binaryMessenger: controller.engine.binaryMessenger)
        
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
            case "resume_music":
                BASS_ChannelPlay(self?.stream ?? 0, 0)
                result(true)
            case "pause_music":
                BASS_ChannelPause(self?.stream ?? 0)
                result(true)
            case "is_music_playing":
                result( BASS_ChannelIsActive(self?.stream ?? 0) == 1)
            case "set_media_source":
                if let arguments = call.arguments as? [String: Any], let volume = self?.volume as? Double {
                    let path = arguments["path"]! as! String
                    let playNow = arguments["play_now"]! as! Bool
                    let url = arguments["url"]! as! String
                    let token = arguments["token"]! as! String
                    
                    BASS_StreamFree(self?.stream ?? 0)
                    
                    let fileManager = FileManager.default
                    
                    if fileManager.fileExists(atPath: path) && !path.isEmpty {
                        let stream = BASS_StreamCreateFile(0, path, 0, 0, 0)
                        self?.stream = stream
                        
                        BASS_ChannelSetAttribute(stream, 2, Float(volume))
                        if playNow {
                            BASS_ChannelPlay(stream, 0)
                        }
                    }
                    else {
                        let stream = BASS_StreamCreateURL("\(url)\r\nAuthorization:\(token)\r\n", 0, 0, nil , nil)
                        self?.stream = stream
                        
                        BASS_ChannelSetAttribute(stream, 2, Float(volume))
                        if playNow {
                            BASS_ChannelPlay(stream, 0)
                        }
                    }
                }
                result(true)
            case "apply_playback_position":
                if let arguments = call.arguments as? [String: Any] , let stream = self?.stream as? HSTREAM {
                    let position = arguments["position"]! as! Int
                    let timeMs = Double(position) / 1000
                    let pos = BASS_ChannelSeconds2Bytes(stream, timeMs)
                    BASS_ChannelSetPosition(stream, pos, 0)
                }
                result(true)
            case "set_volume":
                if let arguments = call.arguments as? [String: Any], let stream = self?.stream as? HSTREAM {
                    let volume = arguments["volume"]! as! Double
                    self?.volume = volume
                    BASS_ChannelSetAttribute(stream, 2, Float(volume))
                }
                result(true)
            case "get_music_duration":
                let pos = BASS_ChannelGetLength(self?.stream ?? 0, 0)
                let timeMs = BASS_ChannelBytes2Seconds(self?.stream ?? 0, pos) * 1000
                let duration = Int(timeMs)
                if duration > 0 {
                    self?.duration = duration
                    result(duration)
                }
                else {
                    result(0)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onEnterFullScreen), name: NSWindow.didEnterFullScreenNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onExitFullScreen), name: NSWindow.didExitFullScreenNotification, object: nil)
        
        if #available(macOS 11.0, *) {
            timerTask = Task {
                       while !Task.isCancelled {
                           let pos = BASS_ChannelGetPosition(stream, 0)
                           let timeMs = BASS_ChannelBytes2Seconds(stream, pos) * 1000
                           let position = Int(timeMs)
                           
                           if position > 0 {
                               methodChannel?.invokeMethod("on_playback_changed", arguments: ["position": position])
                           }
                           if(position + 50 >= duration && duration > 0) {
                               methodChannel?.invokeMethod("play_next", arguments: [])
                           }
                           try? await Task.sleep(nanoseconds: 500_000_000)
                       }
            }
        }
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
