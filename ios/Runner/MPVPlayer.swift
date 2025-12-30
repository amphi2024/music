import media_kit_video

class MPVPlayer {
    private var ctx: OpaquePointer?
    var isPlaying = false
    
    var activated: Bool {
        return ctx != nil
    }

    func activate() {
        guard ctx == nil else { return }
        ctx = mpv_create()
        mpv_initialize(ctx)
        mpv_set_option_string(ctx, "ao", "audiounit")
        mpv_set_option_string(ctx, "vo", "null")
    }

    func deactivate() {
        guard let ctx = ctx else { return }
        mpv_terminate_destroy(ctx)
        self.ctx = nil
    }
    
    func setVolume(volume: Double) {
        var volume = volume * 100
        mpv_set_property(ctx, "volume", MPV_FORMAT_DOUBLE, &volume)
    }
    
    func seekTo(position: Int) {
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
    
    func getPlaybackPositionRaw() -> Double {
        var time: Double = 0
        
        if mpv_get_property(ctx, "time-pos", MPV_FORMAT_DOUBLE, &time) < 0 {
            return 0
        }
        
        return time
    }
    
    func getPlaybackPosition() -> Int {
        Int(getPlaybackPositionRaw() * 1000)
    }
    
    func getDurationRaw() -> Double {
        var time: Double = 0
        
        if mpv_get_property(ctx, "duration", MPV_FORMAT_DOUBLE, &time) < 0 {
            return 0
        }
        
        return time
        
    }
    
    func getDuration() -> Int {
        return Int(getDurationRaw() * 1000)
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

    func applyHTTPHeaderFields(token: String) {
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
    func loadURL(url: String) {
        activate()
        stop()
        pause()
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
    }
}
