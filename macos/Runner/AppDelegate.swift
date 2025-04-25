import Cocoa
import FlutterMacOS
import IOKit.ps
import AVFoundation

@main
class AppDelegate: FlutterAppDelegate, AVAudioPlayerDelegate {
    
    private var methodChannel: FlutterMethodChannel?
    private var player: AVAudioPlayer?
    private var volume: Double = 0.5
    
    @available(macOS 11.0, *)
    private var timerTask: Task<Void, Never>?
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    override func applicationWillTerminate(_ aNotification: Notification) {
        if #available(macOS 11.0, *) {
            timerTask?.cancel()
        }
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
            case "resume_music":
                self?.player?.play()
                //result(true)
            case "pause_music":
                self?.player?.pause()
                //result(true)
            case "is_music_playing":
                result(self?.player?.isPlaying)
            case "set_media_source":
                if let arguments = call.arguments as? [String: Any], let volume = self?.volume as? Double {
                    let path = arguments["path"]! as! String
                    let playNow = arguments["play_now"]! as! Bool
                    let url = arguments["url"]! as! String
                    let token = arguments["token"]! as! String
                    
                    let fileURL = URL(fileURLWithPath: path)
                    do {
                        self?.player = try AVAudioPlayer(contentsOf: fileURL)
                        self?.player?.volume = Float(volume)
                        self?.player?.delegate = self
                        self?.player?.prepareToPlay()
                        if(playNow) {
                            self?.player?.play()
                        }
                    } catch {
                       // let NetworkUrl = URL(
                    }
                }
            case "apply_playback_position":
                if let arguments = call.arguments as? [String: Any] {
                    let position = arguments["position"]! as! Int
                    self?.player?.currentTime = TimeInterval(position) / 1000
                }
            case "set_volume":
                if let arguments = call.arguments as? [String: Any] {
                    self?.volume = arguments["volume"]! as! Double
                    self?.player?.volume = Float(arguments["volume"]! as! Double)
                }
            case "get_music_duration":
                let duration = self?.player?.duration ?? 0
                result(Int(duration) * 1000)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onEnterFullScreen), name: NSWindow.didEnterFullScreenNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onExitFullScreen), name: NSWindow.didExitFullScreenNotification, object: nil)
        
        if #available(macOS 11.0, *) {
            timerTask = Task {
                       while !Task.isCancelled {
                           let pos = player?.currentTime ?? 0
                           let duration = player?.duration ?? 0
                           
                           let position = Int(pos) * 1000
                           methodChannel?.invokeMethod("on_playback_changed", arguments: ["position": position])
                           
                           if(pos >= duration) {
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
          if flag {
            methodChannel?.invokeMethod("play_next", arguments: [])
          }
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
