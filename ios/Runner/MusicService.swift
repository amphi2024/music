import AVFoundation
import MediaPlayer
import Flutter
import media_kit_video

class MusicService {
    static let shared = MusicService()

    private var soundLoaded: Bool = false
    var isPlaying = false
    var itemList: [PlayableItem] = []
    var index: Int = 0
    var token: String = ""
    var methodChannel: FlutterMethodChannel?
    var playMode: Int = 0
    var playlistId: String = "!SONGS"
    let avPlayer = AVPlayer()
    let mpvPlayer = MPVPlayer() // fallback
    var avPlayerUsageCount = 0
    let fileManager = FileManager.default
    
    func syncMediaSourceToFlutter() {
        self.methodChannel?.invokeMethod("sync_media_source_to_flutter", arguments: [
            "index": index,
            "is_playing": self.isPlaying,
            "list": itemList.map { $0.songId },
            "playlist_id": playlistId
        ])
    }
    
    private init() {
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
            syncMediaSourceToFlutter()
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
                  let positionInMilliseconds = Int(positionInSeconds) * 1000
                  self.applyPlaybackPosition(position: positionInMilliseconds)

                  return .success
              }
            else {
                return .commandFailed
            }
        }
    }
    
    func observePlaybackEnd() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: avPlayer.currentItem
        )
    }
    
    @objc func playerDidFinishPlaying(_ notification: Notification) {
        playNext()
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func pause() {
        avPlayer.pause()
    }
    
    func resume() {
        avPlayer.play()
    }
    
    func syncPlaylist(list: Array<Dictionary<String, Any>>) {
        itemList.removeAll()
        list.forEach { item in
            let playableItem = PlayableItem(mediaFilePath: item["media_file_path"] as! String, url: item["url"] as! String, title: item["title"] as! String, artist: item["artist"] as! String, albumCoverFilePath: item["album_cover_file_path"] as? String, songId: item["song_id"] as! String)
            itemList.append(playableItem)
        }
    }

    func isSupportedFormat(filePath: String) -> Bool {
        let format = filePath.split(separator: ".").last
        return ["flac", "mp3", "aac", "alac", "ogg", "m4a", "mp4", "mov", "wav", "aif", "aiff", "caf",].contains(format)
    }
    
    // TODO: Ensure MPV works correctly as a fallback
    func setMediaSource(filePath: String, playNow: Bool, url: String) {
        if fileManager.fileExists(atPath: filePath) && !filePath.isEmpty {
            if isSupportedFormat(filePath: filePath) {
                avPlayer.replaceCurrentItem(with: AVPlayerItem(url: URL(fileURLWithPath: filePath)))
                observePlaybackEnd()
                
                if mpvPlayer.activated {
                    avPlayerUsageCount += 1
                    if avPlayerUsageCount > 5 {
                        mpvPlayer.deactivate()
                    }
                }
            }
            else {
                mpvPlayer.loadURL(url: filePath)
                avPlayerUsageCount = 0
            }
        }
        else {
            mpvPlayer.loadURL(url: url)
            mpvPlayer.applyHTTPHeaderFields(token: token)
            avPlayerUsageCount = 0
        }
        
        if playNow {
            resume()
        }
    }
    
    func applyPlaybackPosition(position: Int) {
        if mpvPlayer.activated {
            mpvPlayer.seekTo(position: position)
        }
        else {
            avPlayer.seek(to: CMTime(seconds: Double(position) / 1000, preferredTimescale: 1000))
        }
    }
    
    func setVolume(volume: Double) {
        if mpvPlayer.activated {
            mpvPlayer.setVolume(volume: volume)
        }
    }
    
    func getDuration() -> Int {
        if mpvPlayer.activated {
            return mpvPlayer.getDuration()
        }
        
        let seconds = avPlayer.currentItem?.duration.seconds ?? 0
        return Int((seconds.isNormal ? seconds : 0) * 1000)
    }
    
    func updateNowPlayingInfo() {
        let duration = mpvPlayer.activated ? mpvPlayer.getDurationRaw() : avPlayer.currentItem?.duration.seconds ?? 0
        let position = mpvPlayer.activated ? mpvPlayer.getPlaybackPositionRaw() : avPlayer.currentTime().seconds
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true, options: [])
        } catch {
            print("AVAudioSession error: \(error)")
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: itemList[index].title,
            MPMediaItemPropertyArtist: itemList[index].artist,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: position,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0
        ]
        
        if itemList[index].albumCoverFilePath != nil , FileManager.default.fileExists(atPath: itemList[index].albumCoverFilePath!), let image = UIImage(contentsOfFile: itemList[index].albumCoverFilePath!) {
            
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }
        
        
        DispatchQueue.main.async {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        }
    }
    
    func getPlaybackPosition() -> Int {
        if mpvPlayer.activated {
            return mpvPlayer.getPlaybackPosition()
        }
        let seconds = avPlayer.currentTime().seconds
        let milliseconds = Int((seconds.isNormal ? seconds : 0) * 1000)
        return milliseconds
    }
    
    func playNext() {
        index+=1
        if index >= itemList.count {
            index = 0
        }
        
        let item = itemList[index]
        setMediaSource(filePath: item.mediaFilePath, playNow: true, url: item.url)
        syncMediaSourceToFlutter()
        updateNowPlayingInfo()
    }
    
    func playPrevious() {
        
        index -= 1
        if index < 0 {
            index = itemList.count - 1
        }
        let item = itemList[index]
        setMediaSource(filePath: item.mediaFilePath, playNow: true, url: item.url)
        syncMediaSourceToFlutter()
        updateNowPlayingInfo()
    }
}
