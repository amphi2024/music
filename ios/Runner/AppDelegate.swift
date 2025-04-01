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
          
      case "set_media_source":
          let path = arguments["path"] as String
          let fileURL = URL(fileURLWithPath: path)

                  // 해당 경로에 파일이 있는지 확인
                  if FileManager.default.fileExists(atPath: fileURL.path) {
                      do {
                          // AVAudioPlayer로 FLAC 파일 재생
                          audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                          audioPlayer?.prepareToPlay()
                          audioPlayer?.play()
                          print("🎵 FLAC 파일 재생 시작: \(fileURL.path)")
                      } catch {
                          print("❌ FLAC 파일 재생 실패: \(error.localizedDescription)")
                      }
                  } else {
                      print("⚠️ 파일을 찾을 수 없음: \(fileURL.path)")
                  }
          
//          
//          Future<void> resumeMusic() async {
//            await invokeMethod("resume_music");
//          }
//
//          Future<void> pauseMusic() async {
//            await invokeMethod("pause_music");
//          }
//
//          Future<bool> isMusicPlaying() async {
//            return await invokeMethod("is_music_playing");
//          }
//
//          Future<void> setMediaSource({required Song song, String? localeCode, bool playNow = true}) async {
//            await invokeMethod("set_media_source", {
//              "path": song.songFilePath(),
//              "play_now": playNow,
//              "title": song.title.byLocaleCode(this.localeCode ?? "default"),
//              "artist": song.artist.name.byLocaleCode(this.localeCode ?? "default"),
//              "album_cover": song.album.covers.firstOrNull
//            });
//          }
//
//          Future<void> applyPlaybackPosition(int position) async {
//            await invokeMethod("apply_playback_position", {
//              "position": position
//            });
//          }
//
//          Future<int> getMusicDuration() async {
//            return await invokeMethod("get_music_duration");
//          }
          
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

