#include "keyboard_hook.h"
#include "crosshair_window.h"
#include <windows.h>

namespace {
int g_hotkeyId = 0x0000;
int g_modifiers = 0;
int g_vk = 0;
bool g_registered = false;
void (*g_callback)() = nullptr;

constexpr int HOTKEY_ID = 0x0000;
}  // namespace

extern "C" {

int register_hotkey(int modifiers, int vk) {
  // Unregister existing hotkey if any
  if (g_registered) {
    UnregisterHotKey(nullptr, HOTKEY_ID);
    g_registered = false;
  }

  // Register new hotkey
  if (RegisterHotKey(nullptr, HOTKEY_ID, modifiers, vk)) {
    g_modifiers = modifiers;
    g_vk = vk;
    g_registered = true;
    return 1;
  }

  return 0;
}

void unregister_hotkey() {
  if (g_registered) {
    UnregisterHotKey(nullptr, HOTKEY_ID);
    g_registered = false;
  }
}

void set_hotkey_callback(void (*callback)()) {
  g_callback = callback;
}

int is_hotkey_registered() {
  return g_registered ? 1 : 0;
}

// This function should be called from the main message loop
// to process hotkey messages
int process_hotkey_message(MSG* msg) {
  if (msg->message == WM_HOTKEY && msg->wParam == HOTKEY_ID) {
    // Toggle crosshair window directly from C++ side
    crosshair_toggle();
    
    // Also call callback if set (for Dart side notification if needed)
    if (g_callback != nullptr) {
      g_callback();
    }
    return 1;
  }
  return 0;
}

}  // extern "C"

