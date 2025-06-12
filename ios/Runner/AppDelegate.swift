import UIKit
import Flutter
import AVFoundation
import MediaPlayer

@main
@objc class AppDelegate: FlutterAppDelegate {

  private var methodChannel: FlutterMethodChannel?
    
    @available(iOS 13.0, *)
    private var timerTask: Task<Void, Never>?
    
    override func applicationWillResignActive(_ application: UIApplication) {
//        BASS_StreamFree(stream)
//        BASS_Free()
//        if #available(iOS 13.0, *) {
//            timerTask?.cancel()
//        }
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        MusicService.shared.methodChannel?.invokeMethod("sync_media_source_to_flutter", arguments: [
            "index": MusicService.shared.index,
            "is_playing": MusicService.shared.isPlaying
        ])
    }
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      GeneratedPluginRegistrant.register(with: self)
      
    let flutterViewController = window?.rootViewController as! FlutterViewController

    methodChannel = FlutterMethodChannel(name: "music_method_channel", binaryMessenger: flutterViewController.engine.binaryMessenger)

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
          MusicService.shared.resume()
          result(true)
      case "pause_music":
          MusicService.shared.pause()
          result(true)
      case "is_music_playing":
          result(MusicService.shared.isPlaying)
      case "sync_playlist_state":
          if let arguments = call.arguments as? [String: Any] {
              let list = arguments["list"] as! Array<Dictionary<String, Any>>
              let playMode = arguments["play_mode"] as! Int
              let index = arguments["index"] as! Int
              MusicService.shared.playMode = playMode
              MusicService.shared.index = index
              MusicService.shared.syncPlaylist(list: list)
          }
          result(true)
      case "set_media_source":
          if let arguments = call.arguments as? [String: Any] {
 
              let path = arguments["path"]! as! String
              let playNow = arguments["play_now"]! as! Bool
              let url = arguments["url"]! as! String
              let token = arguments["token"]! as! String
              let title = arguments["title"]! as! String
              let artist = arguments["artist"]! as! String
              let albumCoverFilePath = arguments["album_cover"]! as! String
              
              MusicService.shared.title = title
              MusicService.shared.artist = artist
              MusicService.shared.albumCoverFilePath = albumCoverFilePath
              MusicService.shared.token = token
              
              MusicService.shared.setMediaSource(filePath: path, playNow: playNow, url: url)

          }
          result(true)
      case "apply_playback_position":
          if let arguments = call.arguments as? [String: Any] {
              let position = arguments["position"]! as! Int
              MusicService.shared.applyPlaybackPosition(position: position)
          }
          result(true)
      case "set_volume":
          if let arguments = call.arguments as? [String: Any] {
              let volume = arguments["volume"]! as! Double
              MusicService.shared.setVolume(volume: volume)
          }
          result(true)
      case "get_music_duration":
          let duration = MusicService.shared.getDuration()
          if duration > 0 {
              result(duration)
          }
          else {
              result(0)
          }
      case "sync_media_source_to_native":
          if let arguments = call.arguments as? [String: Any] {
              let index = arguments["index"]! as! Int
              let isPlaying = arguments["is_playing"]! as! Bool
              MusicService.shared.index = index
              MusicService.shared.isPlaying = isPlaying
          }
          result(true)
      default:
          result(FlutterMethodNotImplemented)
      
      }
    }
      
      MusicService.shared.methodChannel = methodChannel
      
      if #available(iOS 13.0, *) {
          timerTask = Task {
                     while !Task.isCancelled {
                         let position = MusicService.shared.getPlaybackPosition()
                         let duration = MusicService.shared.duration
                         
                         if position > 0 {
                             methodChannel?.invokeMethod("on_playback_changed", arguments: ["position": position])
                             MusicService.shared.updateNowPlayingInfo()
                         }
                         if(position + 50 >= duration && duration > 0) {
                             methodChannel?.invokeMethod("play_next", arguments: [])
                         }
                         try? await Task.sleep(nanoseconds: 500_000_000)
                     }
          }
      }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
        
        return metadataDict.isEmpty ? ["title": "Unknown", "artist": "Unknown"] : metadataDict
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

