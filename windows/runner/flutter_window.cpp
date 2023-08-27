#include "flutter_window.h"

#include <optional>
#include "flutter/generated_plugin_registrant.h"

#include <direct.h>
#include <stdlib.h>
#include "flutter/method_channel.h"
#include "flutter/standard_method_codec.h"
#include <wchar.h>
#include <atlstr.h>  

FlutterWindow::FlutterWindow(const flutter::DartProject& project): project_(project) {}

FlutterWindow::~FlutterWindow() {}

std::string applicationPath;

LPWSTR StringToLPWSTR(const std::string& instr)
{
    CString cs(instr.c_str());
    LPWSTR  lpstr = (LPWSTR)cs.AllocSysString();
    return lpstr;

}
std::string LPWSTRToString(LPWSTR lpwstr) {
    CString cs(lpwstr);
    return (LPCSTR)(CStringA)(cs);
}

STARTUPINFO si;
PROCESS_INFORMATION temp;
PROCESS_INFORMATION *pi;

void CreateMethodChannel(flutter::FlutterEngine* engine) {
    const std::string test_channel("com.yessvpn.flutter/channel");
    const flutter::StandardMethodCodec& codec = flutter::StandardMethodCodec::GetInstance();
    flutter::MethodChannel method_channel_(engine->messenger(), test_channel, &codec);
    method_channel_.SetMethodCallHandler([](const auto& caller, auto result) {
        if (caller.method_name().compare("Connect") == 0) {
            const flutter::EncodableValue* ev = caller.arguments();
            const flutter::EncodableValue v = *ev;
            if (std::holds_alternative<std::string>(v)) {
                if (pi != NULL) {
                    std::cout << "[FlutterWindow] Try terminate process:" << pi->dwProcessId << std::endl;
                    //HANDLE hProcessHandle = OpenProcess(PROCESS_TERMINATE, false, pi->dwProcessId);
                    if (!TerminateProcess(pi->hProcess, 0)) {
                        std::cout << "[FlutterWindow] TerminateProcess failed, error code: " << GetLastError() << std::endl;
                        result->Success(0);
                    }
                    else {
                        std::cout << "[FlutterWindow] TerminateProcess success " << std::endl;
                        //CloseHandle(pi->hProcess);
                        //CloseHandle(pi->hThread);
                        pi = NULL;
                        result->Success(1);
                    }
                    return;
                }
                pi = &temp;
                ZeroMemory(&si, sizeof(si));
                ZeroMemory(pi, sizeof(temp));

                si.cb = sizeof(si);
                si.wShowWindow = SW_HIDE;
                si.dwFlags = STARTF_USESHOWWINDOW;
                std::string json = std::get<std::string>(v);
                size_t index = applicationPath.find_last_of("/");
                if (index == -1) {
                    index = applicationPath.find_last_of("\\");
                }
                std::string container = "";
                std::string exePath = applicationPath.substr(0, index) + "\\lib\\v2ray.exe run -c ";
                std::string strCmd = (container + exePath + json).c_str();
                LPWSTR lpwStr = StringToLPWSTR(strCmd);
                std::cout << "[FlutterWindow] Command line:" << strCmd << std::endl;
                if (!CreateProcess(NULL,   // No module name (use command line)
                    lpwStr,        // Command line
                    NULL,           // Process handle not inheritable
                    NULL,           // Thread handle not inheritable
                    FALSE,          // Set handle inheritance to FALSE
                    0,              // No creation flags
                    NULL,           // Use parent's environment block
                    NULL,           // Use parent's starting directory 
                    &si,            // Pointer to STARTUPINFO structure
                    pi)           // Pointer to PROCESS_INFORMATION structure
                    ) {
                    std::cout << "[FlutterWindow] CreateProcess failed "<< GetLastError() << std::endl;
                    pi = NULL;
                    result->Success(0);
                    return;
                }
                std::cout << "[FlutterWindow] CreateProcess success" << std::endl;
                result->Success(1);
                return;
            }

            std::cout << "[FlutterWindow] Param parse failed" << std::endl;
            result->Success(0);
        }
        else if (caller.method_name().compare("ApplicationPath") == 0) {
            const flutter::EncodableValue* ev = caller.arguments();
            const flutter::EncodableValue v = *ev;
            if (std::holds_alternative<std::string>(v)) {
                applicationPath = std::get<std::string>(v);
                std::cout << "[FlutterWindow] Application path: " << applicationPath << std::endl;
                result->Success(1);
                return;
            }
            result->Success(0);
        }
        else {
            std::cout << "[FlutterWindow] Method "<< caller.method_name() << " not found" << std::endl;
            result->Success(0);
            return;
        }
    });
}


bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  //ZeroMemory(&si, sizeof(si));
  pi = NULL;
  CreateMethodChannel(flutter_controller_->engine());
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
