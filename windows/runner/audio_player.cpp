#include "audio_player.h"
#include "miniaudio.h"
#include <string>
#include <mutex>
#include <iostream>

AudioPlayer::AudioPlayer() {}
AudioPlayer::~AudioPlayer() {
    Stop();
    if (initialized_) {
        ma_engine_uninit(&engine_);
    }
}

AudioPlayer& AudioPlayer::GetInstance() {
    static AudioPlayer instance;
    return instance;
}

bool AudioPlayer::Init() {
    std::lock_guard<std::mutex> lock(mutex_);
    if (!initialized_) {
        if (ma_engine_init(NULL, &engine_) != MA_SUCCESS) {
            return false;
        }
        initialized_ = true;
    }
    return true;
}

void AudioPlayer::Play(const string& path, const string& url, const string& token) {
    if (!initialized_) Init();

    if (sound_loaded_) {
        ma_sound_uninit(&sound_);
    }

    if (ma_sound_init_from_file(&engine_, path.c_str(), 0, NULL, NULL, &sound_) != MA_SUCCESS) {

    }

    sound_loaded_ = true;

    ma_sound_start(&sound_);
}

void AudioPlayer::Pause() {
    std::lock_guard<std::mutex> lock(mutex_);
    if (sound_loaded_) ma_sound_stop(&sound_);
}

void AudioPlayer::Resume() {
    std::lock_guard<std::mutex> lock(mutex_);
    if (sound_loaded_) ma_sound_start(&sound_);
}

void AudioPlayer::Stop() {
    std::lock_guard<std::mutex> lock(mutex_);
    if (sound_loaded_) {
        ma_sound_uninit(&sound_);
        sound_loaded_ = false;
    }
}

bool AudioPlayer::IsPlaying() const {
    std::lock_guard<std::mutex> lock(mutex_);
    return sound_loaded_ && ma_sound_is_playing(&sound_);
}

long AudioPlayer::GetPlaybackPosition() {
    std::lock_guard<std::mutex> lock(mutex_);
    float cursor = 0.0f;
    if (sound_loaded_) {
        ma_sound_get_cursor_in_seconds(&sound_, &cursor);
        cursor = cursor * 1000;
        return static_cast<long>(cursor);
    }
    return 0;
}

long AudioPlayer::GetMusicDuration() {
    std::lock_guard<std::mutex> lock(mutex_);
    float duration = 0.0f;
    if (sound_loaded_) {
        ma_sound_get_length_in_seconds(&sound_, &duration);
        duration = duration * 1000;
        return static_cast<long>(duration);
    }
    return 0;
}