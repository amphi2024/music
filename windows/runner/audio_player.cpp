#include "audio_player.h"
#include <string>
#include <mutex>
#include <iostream>
#include <filesystem>

AudioPlayer::AudioPlayer() {}
AudioPlayer::~AudioPlayer()
{
    Stop();
    if (initialized_)
    {
        BASS_Free();
    }
}

AudioPlayer &AudioPlayer::GetInstance()
{
    static AudioPlayer instance;
    return instance;
}

bool AudioPlayer::Init()
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (!initialized_)
    {
        if (!BASS_Init(-1, 44100, 0, 0, NULL))
        {
            return false;
        }
        initialized_ = true;
    }
    return true;
}

void AudioPlayer::SetMediaSource(const string &path, const string &url, const string &token, bool playNow)
{

    Stop();

    if (!initialized_)
        Init();

    if (std::filesystem::exists(path) && path.length() > 0)
    {
        stream = BASS_StreamCreateFile(FALSE, path.c_str(), 0, 0, 0);
        if (stream != NULL)
        {
            BASS_ChannelSetAttribute(stream, BASS_ATTRIB_VOL, volume_);
            sound_loaded_ = true;
            if(playNow) {
              BASS_ChannelPlay(stream, FALSE);
            }
        }
    }
    else
    {
        std::string combined = url;
        combined.append("\r\nAuthorization:");
        combined.append(token);
        combined.append("\r\n");
        stream = BASS_StreamCreateURL(combined.c_str(), 0, 0, NULL, 0);
        if (stream != NULL)
        {
            BASS_ChannelSetAttribute(stream, BASS_ATTRIB_VOL, volume_);
            sound_loaded_ = true;
            if(playNow) {
              BASS_ChannelPlay(stream, FALSE);
            }
        }
    }
}

void AudioPlayer::Pause()
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (sound_loaded_)
        BASS_ChannelPause(stream);
}

void AudioPlayer::Resume()
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (sound_loaded_)
        BASS_ChannelPlay(stream, FALSE);
}

void AudioPlayer::Stop()
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (sound_loaded_)
    {
        BASS_StreamFree(stream);
        sound_loaded_ = false;
    }
}

void AudioPlayer::SeekTo(long position)
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (sound_loaded_)
    {
        double timeMs = position / 1000;
        QWORD pos = BASS_ChannelSeconds2Bytes(stream, timeMs);
        BASS_ChannelSetPosition(stream, pos, BASS_POS_BYTE);
    }
}

void AudioPlayer::SetVolume(double volume)
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (sound_loaded_)
    {
        this->volume_ = (float)volume;
        BASS_ChannelSetAttribute(stream, BASS_ATTRIB_VOL, this->volume_);
    }
}

bool AudioPlayer::IsPlaying() const
{
    std::lock_guard<std::mutex> lock(mutex_);
    return sound_loaded_ && BASS_ChannelIsActive(stream);
}

long AudioPlayer::GetPlaybackPosition()
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (sound_loaded_)
    {
        QWORD pos = BASS_ChannelGetPosition(stream, BASS_POS_BYTE);
        double timeMs = BASS_ChannelBytes2Seconds(stream, pos) * 1000;
        return (long)timeMs;
    }
    return 0;
}

long AudioPlayer::GetMusicDuration()
{
    std::lock_guard<std::mutex> lock(mutex_);
    if (sound_loaded_)
    {
        QWORD pos = BASS_ChannelGetLength(stream, BASS_POS_BYTE);
        double timeMs = BASS_ChannelBytes2Seconds(stream, pos) * 1000;
        return (long)timeMs;
    }
    return 0;
}