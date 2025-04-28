#ifndef AUDIO_PLAYER_H
#define AUDIO_PLAYER_H

#include "miniaudio.h"
#include <string>
#include <mutex>

using namespace std;

class AudioPlayer {
public:
    static AudioPlayer& GetInstance();

    bool Init();
    void Play(const std::string& path, const string& url, const string& token);
    void Pause();
    void Resume();
    void Stop();
    long GetPlaybackPosition();
    long GetMusicDuration();

    bool IsPlaying() const;

private:
    AudioPlayer();
    ~AudioPlayer();

    ma_engine engine_;
    ma_sound sound_;
    bool initialized_ = false;
    bool sound_loaded_ = false;
    mutable std::mutex mutex_;
};

#endif