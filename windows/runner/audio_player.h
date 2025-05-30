#ifndef AUDIO_PLAYER_H
#define AUDIO_PLAYER_H

#include <string>
#include <mutex>
#include "bass.h"

using namespace std;

class AudioPlayer {
public:
    static AudioPlayer& GetInstance();

    bool Init();
    void SetMediaSource(const std::string& path, const string& url, const string& token, bool playNow);
    void Pause();
    void Resume();
    void Stop();
    void SeekTo(long position);
    long GetPlaybackPosition();
    long GetMusicDuration();
    void SetVolume(double volume);

    bool IsPlaying() const;

private:
    AudioPlayer();
    ~AudioPlayer();

    bool initialized_ = false;
    bool sound_loaded_ = false;
    mutable std::mutex mutex_;
    HSTREAM stream;
    float volume_ = 1.0f;
};

#endif