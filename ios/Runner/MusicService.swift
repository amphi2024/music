import AVFoundation
import MediaPlayer
import Flutter
import media_kit_video

class MusicService {
    static let shared = MusicService()

    private var volume: Double = 0.5
    var duration: Int = 0
    var position: Int = 0
    private var soundLoaded: Bool = false
    var title: String = ""
    var artist: String = ""
    var albumCoverFilePath: String = ""
    var isPlaying = false
    private var itemList: [PlayableItem] = []
    var index: Int = 0
    var token: String = ""
    var methodChannel: FlutterMethodChannel?
    var playMode: Int = 0
    var ctx = mpv_create()
    
    private init() {

        mpv_initialize(ctx)
        mpv_set_option_string(ctx, "ao", "audiounit")
        mpv_set_option_string(ctx, "vo", "null")
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            resume()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            pause()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            if self.isPlaying {
                pause()
            } else {
                resume()
            }
            self.methodChannel?.invokeMethod("sync_media_source_to_flutter", arguments: [
                "index": index,
                "is_playing": self.isPlaying
            ])
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.playPrevious()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            self.playNext()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self else { return .commandFailed }
            if let positionEvent = event as? MPChangePlaybackPositionCommandEvent {
                  let positionInSeconds = positionEvent.positionTime
                  let positionInMilliseconds = Int(positionInSeconds * 1000)
                  self.applyPlaybackPosition(position: positionInMilliseconds)

                  return .success
              }
            else {
                return .commandFailed
            }
        }
    }
    
    func pause() {
        isPlaying = false
        var pause: Int32 = 1
        mpv_set_property(ctx, "pause", MPV_FORMAT_FLAG, &pause)
    }
    
    func resume() {
        isPlaying = false
        var pause: Int32 = 0
        mpv_set_property(ctx, "pause", MPV_FORMAT_FLAG, &pause)
    }
    
    func stop() {
        var args: [UnsafePointer<CChar>?] = [
            UnsafePointer(strdup("stop")),
            nil
        ]

        args.withUnsafeMutableBufferPointer { buffer in
            mpv_command(ctx, buffer.baseAddress)
        }

        for arg in args {
            if let arg {
                free(UnsafeMutableRawPointer(mutating: arg))
            }
        }
    }
    
    func syncPlaylist(list: Array<Dictionary<String, Any>>) {
        itemList.removeAll()
        list.forEach { item in
            let playableItem = PlayableItem(mediaFilePath: item["media_file_path"] as! String, url: item["url"] as! String, title: item["title"] as! String, artist: item["artist"] as! String, albumCoverFilePath: item["album_cover_file_path"] as? String, songId: item["song_id"] as! String)
            itemList.append(playableItem)
        }
    }
    func applyHTTPHeaderFields() {
        var node = mpv_node()
        node.format = MPV_FORMAT_NODE_ARRAY

        let listPtr = UnsafeMutablePointer<mpv_node_list>.allocate(capacity: 1)
        node.u.list = listPtr

        let headers = ["Authorization: \(token)"]
        let count = headers.count
        listPtr.pointee.num = Int32(count)
        
        let valuesPtr = UnsafeMutablePointer<mpv_node>.allocate(capacity: count)
        listPtr.pointee.values = valuesPtr

        for (i, header) in headers.enumerated() {
            valuesPtr[i].format = MPV_FORMAT_STRING
            valuesPtr[i].u.string = strdup(header)
        }

        defer {
            for i in 0..<count {
                if let strPtr = valuesPtr[i].u.string {
                    free(strPtr)
                }
            }
            valuesPtr.deallocate()
            listPtr.deallocate()
        }

        let result = mpv_set_property(ctx, "http-header-fields", MPV_FORMAT_NODE, &node)
        
        if result < 0 {
            let errorMsg = String(cString: mpv_error_string(result))
            print("MPV Header Error: \(errorMsg)")
        }
    }
    
    func setMediaSource(filePath: String, playNow: Bool, url: String) {
        
        let fileManager = FileManager.default
        
        stop()
        pause()
        
        if fileManager.fileExists(atPath: filePath) && !filePath.isEmpty {
            
            var args: [UnsafePointer<CChar>?] = [
                UnsafePointer(strdup("loadfile")),
                UnsafePointer(strdup(filePath)),
                nil
            ]

            args.withUnsafeMutableBufferPointer { buffer in
                mpv_command(ctx, buffer.baseAddress)
            }

            for arg in args {
                if let arg = arg {
                    free(UnsafeMutableRawPointer(mutating: arg))
                }
            }
        }
        else {
            
            var args: [UnsafePointer<CChar>?] = [
                UnsafePointer(strdup("loadfile")),
                UnsafePointer(strdup(url)),
                nil
            ]

            args.withUnsafeMutableBufferPointer { buffer in
               mpv_command(ctx, buffer.baseAddress)
            }

            for arg in args {
                if let arg = arg {
                    free(UnsafeMutableRawPointer(mutating: arg))
                }
            }
            
            applyHTTPHeaderFields()
        }
        
        if playNow {
            resume()
        }
    }
    
    func applyPlaybackPosition(position: Int) {
        let timeMs = Double(position) / 1000
        
        var args: [UnsafePointer<CChar>?] = [
            UnsafePointer(strdup("seek")),
            UnsafePointer(strdup(String(timeMs))),
            UnsafePointer(strdup("absolute")),
            nil
        ]

        args.withUnsafeMutableBufferPointer { buffer in
            mpv_command(ctx, buffer.baseAddress)
        }

        for arg in args {
            if let arg = arg {
                free(UnsafeMutableRawPointer(mutating: arg))
            }
        }
    }
    
    func setVolume(volume: Double) {
        self.volume = volume * 100
        mpv_set_property(ctx, "volume", MPV_FORMAT_DOUBLE, &self.volume)
    }
    
    func getDuration() -> Int {
        var time: Double = 0
        
        if mpv_get_property(ctx, "duration", MPV_FORMAT_DOUBLE, &time) < 0 {
            return 0
        }
        
        duration = Int(time * 1000)
        
        return duration
        
    }
    
    func updateNowPlayingInfo() {
        
        let convertedDuration = Double(duration) / 1000.0
        let convertedPosition = Double(position) / 1000.0
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: [])
        } catch {
            print("AVAudioSession error: \(error)")
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: self.title,
            MPMediaItemPropertyArtist: self.artist,
            MPMediaItemPropertyPlaybackDuration: convertedDuration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: convertedPosition,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0
        ]
        
        if FileManager.default.fileExists(atPath: self.albumCoverFilePath),
           let image = UIImage(contentsOfFile: self.albumCoverFilePath) , !self.albumCoverFilePath.isEmpty {
            
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }
        
        
        DispatchQueue.main.async {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
    }
    
    func getPlaybackPosition() -> Int {
        var time: Double = 0
        
        if mpv_get_property(ctx, "time-pos", MPV_FORMAT_DOUBLE, &time) < 0 {
            return 0
        }
        position = Int(time * 1000)
        
        return position
    }
    
    func playNext() {
        index+=1
        if index >= itemList.count {
            index = 0
        }
        
        let item = itemList[index]
        title = item.title
        artist = item.artist
        albumCoverFilePath = item.albumCoverFilePath ?? ""
        setMediaSource(filePath: item.mediaFilePath, playNow: true, url: item.url)
        methodChannel?.invokeMethod("sync_media_source_to_flutter", arguments: ["index": index, "is_playing": isPlaying])
        getPlaybackPosition()
        getDuration()
        updateNowPlayingInfo()
    }
    
    func playPrevious() {
        
        index -= 1
        if index < 0 {
            index = itemList.count - 1
        }
        let item = itemList[index]
        title = item.title
        artist = item.artist
        albumCoverFilePath = item.albumCoverFilePath ?? ""
        setMediaSource(filePath: item.mediaFilePath, playNow: true, url: item.url)
        methodChannel?.invokeMethod("sync_media_source_to_flutter", arguments: ["index": index, "is_playing": isPlaying])
        getPlaybackPosition()
        getDuration()
        updateNowPlayingInfo()
    }
}
