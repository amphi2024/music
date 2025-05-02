#define MINIAUDIO_IMPLEMENTATION
#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>

#include <memory>
#include "metadata_retriever.h"
#include "audio_player.h"

FlutterWindow::FlutterWindow(const flutter::DartProject &project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate()
{
  if (!Win32Window::OnCreate())
  {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view())
  {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  flutter::MethodChannel<> channel(
      flutter_controller_->engine()->messenger(), "music_method_channel",
      &flutter::StandardMethodCodec::GetInstance());
  channel.SetMethodCallHandler(
      [this](const flutter::MethodCall<> &call,
             std::unique_ptr<flutter::MethodResult<>> result)
      {
        // methodChannelMutex.lock();
        if (call.method_name() == "get_music_metadata")
        {
          const auto *map_arg = std::get_if<std::map<flutter::EncodableValue, flutter::EncodableValue>>(call.arguments());
          auto path_iter = map_arg->find(flutter::EncodableValue("path"));
          std::string path = std::get<std::string>(path_iter->second);
          flutter::EncodableValue data = MusicMetadata(path);

          result->Success(data);
        }
        else if (call.method_name() == "pause_music")
        {
          AudioPlayer::GetInstance().Pause();
          result->Success();
        }
        else if (call.method_name() == "resume_music")
        {
          AudioPlayer::GetInstance().Resume();
          result->Success();
        }
        else if (call.method_name() == "stop_music")
        {
          AudioPlayer::GetInstance().Stop();
          result->Success();
        }
        else if (call.method_name() == "set_media_source")
        {
          const auto *map_arg = std::get_if<std::map<flutter::EncodableValue, flutter::EncodableValue>>(call.arguments());
          auto path_iter = map_arg->find(flutter::EncodableValue("path"));
          std::string path = std::get<std::string>(path_iter->second);

          auto url_iter = map_arg->find(flutter::EncodableValue("url"));
          std::string url = std::get<std::string>(url_iter->second);

          auto token_iter = map_arg->find(flutter::EncodableValue("token"));
          std::string token = std::get<std::string>(token_iter->second);

          AudioPlayer::GetInstance().Play(path, url, token);
        }
        else if (call.method_name() == "apply_playback_position")
        {
          const auto *map_arg = std::get_if<std::map<flutter::EncodableValue, flutter::EncodableValue>>(call.arguments());
          auto position_iter = map_arg->find(flutter::EncodableValue("position"));
          if (std::holds_alternative<std::int32_t>(position_iter->second))
          {
            auto value = std::get<std::int32_t>(position_iter->second);
            AudioPlayer::GetInstance().SeekTo((long)value);
          }
          if (std::holds_alternative<std::int64_t>(position_iter->second))
          {
            auto value = std::get<std::int64_t>(position_iter->second);
            AudioPlayer::GetInstance().SeekTo((long)value);
          }
          result->Success(true);
        }
        else if (call.method_name() == "set_volume")
        {
          const auto *map_arg = std::get_if<std::map<flutter::EncodableValue, flutter::EncodableValue>>(call.arguments());
          auto iter = map_arg->find(flutter::EncodableValue("volume"));
          auto value = std::get<double>(iter->second);
          AudioPlayer::GetInstance().SetVolume(value);
          result->Success(true);
        }
        else if (call.method_name() == "get_playback_position")
        {
          result->Success(flutter::EncodableValue(AudioPlayer::GetInstance().GetPlaybackPosition()));
        }
        else if (call.method_name() == "get_music_duration")
        {
          result->Success(flutter::EncodableValue(AudioPlayer::GetInstance().GetMusicDuration()));
        }
        else if (call.method_name() == "is_music_playing")
        {
          bool playing = AudioPlayer::GetInstance().IsPlaying();
          result->Success(flutter::EncodableValue(playing));
        }
        else
        {
          result->NotImplemented();
        }
        // methodChannelMutex.unlock();
      });

  // methodChannel = &channel;

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]()
                                                      { this->Show(); });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();
  // StartPositionTracking();

  return true;
}

// void FlutterWindow::StartPositionTracking() {
//   position_thread_ = std::make_unique<std::thread>([this]() {
//       while (true) {
//           if (AudioPlayer::GetInstance().IsPlaying()) {
//             //methodChannelMutex.lock();
//               int position = AudioPlayer::GetInstance().GetPlaybackPosition();
//               std::cout << position << std::endl;

//                std::map<flutter::EncodableValue, flutter::EncodableValue> map = {};
//                map[flutter::EncodableValue("position")] = flutter::EncodableValue(position);
//                //auto args = std::make_unique<flutter::EncodableValue>(map);
//                flutter::EncodableValue data = flutter::EncodableValue(map);
//                auto args1 = make_unique<flutter::EncodableValue>(data);
//                methodChannel->InvokeMethod("on_playback_changed", 0);
//           }

//           std::this_thread::sleep_for(std::chrono::milliseconds(1500));
//       }
//   });
// }

// void FlutterWindow::StopPositionTracking() {
//   if (position_thread_ && position_thread_->joinable()) {
//       position_thread_->join();
//   }
//   position_thread_.reset();
// }

void FlutterWindow::OnDestroy()
{
  // StopPositionTracking();
  if (flutter_controller_)
  {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept
{
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_)
  {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result)
    {
      return *result;
    }
  }

  switch (message)
  {
  case WM_FONTCHANGE:
    flutter_controller_->engine()->ReloadSystemFonts();
    break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}