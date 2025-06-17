import AVFoundation
import MediaPlayer
import Flutter

class MusicService {
    static let shared = MusicService()
    
    private var volume: Double = 0.5
    private var stream: HSTREAM = 0
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
    
    private init() {
        BASS_Init(-1, 44100, 0, nil, nil)
        
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
        BASS_ChannelPause(self.stream)
    }
    
    func resume() {
        isPlaying = true
        BASS_ChannelPlay(self.stream, 0)
    }
    
    func syncPlaylist(list: Array<Dictionary<String, Any>>) {
        itemList.removeAll()
        list.forEach { item in
            let playableItem = PlayableItem(mediaFilePath: item["media_file_path"] as! String, url: item["url"] as! String, title: item["title"] as! String, artist: item["artist"] as! String, albumCoverFilePath: item["album_cover_file_path"] as? String, songId: item["song_id"] as! String)
            itemList.append(playableItem)
        }
    }
    
    func setMediaSource(filePath: String, playNow: Bool, url: String) {
        
        BASS_StreamFree(stream)
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: filePath) && !filePath.isEmpty {
            let stream = BASS_StreamCreateFile(0, filePath, 0, 0, 0)
            self.stream = stream
            
            BASS_ChannelSetAttribute(stream, 2, Float(volume))
            if playNow {
                self.isPlaying = true
                BASS_ChannelPlay(stream, 0)
            }
        }
        else {
            let stream = BASS_StreamCreateURL("\(url)\r\nAuthorization:\(token)\r\n", 0, 0, nil , nil)
            self.stream = stream
            
            BASS_ChannelSetAttribute(stream, 2, Float(volume))
            if playNow {
                self.isPlaying = true
                BASS_ChannelPlay(stream, 0)
            }
        }
    }
    
    func applyPlaybackPosition(position: Int) {
        let timeMs = Double(position) / 1000
        let pos = BASS_ChannelSeconds2Bytes(stream, timeMs)
        BASS_ChannelSetPosition(stream, pos, 0)
    }
    
    func setVolume(volume: Double) {
        self.volume = volume
        BASS_ChannelSetAttribute(stream, 2, Float(volume))
    }
    
    func getDuration() -> Int {
        let pos = BASS_ChannelGetLength(stream, 0)
        let timeMs = BASS_ChannelBytes2Seconds(stream, pos) * 1000
        duration = Int(timeMs)
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
        let pos = BASS_ChannelGetPosition(stream, 0)
        let timeMs = BASS_ChannelBytes2Seconds(stream, pos) * 1000
        position = Int(timeMs)
        
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
