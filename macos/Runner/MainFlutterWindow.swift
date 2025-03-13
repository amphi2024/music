import Cocoa
import FlutterMacOS
import bitsdojo_window_macos
import IOKit.ps
import AVFoundation


class MainFlutterWindow: BitsdojoWindow {
    
    private var methodChannel: FlutterMethodChannel?
    
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
      
      methodChannel = FlutterMethodChannel(name: "music_method_channel",
                                           binaryMessenger: flutterViewController.engine.binaryMessenger)
      
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

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  override func bitsdojo_window_configure() -> UInt {
    return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
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
