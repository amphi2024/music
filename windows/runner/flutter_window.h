#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <memory>

#include "win32_window.h"
#include <thread>

using namespace std;

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

  // std::unique_ptr<flutter::EventSink<flutter::EncodableValue>> event_sink_;
  // std::unique_ptr<std::thread> position_thread_;
  // std::atomic<bool> tracking_position_ = false;
  // flutter::MethodChannel<> *methodChannel;
  // mutex methodChannelMutex;
  // void StartPositionTracking();
  // void StopPositionTracking();
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
