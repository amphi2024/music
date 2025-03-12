import UIKit
import Flutter
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {

  private var methodChannel: FlutterMethodChannel?

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

        default:
          result(FlutterMethodNotImplemented)
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

