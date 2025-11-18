#ifndef KEYBOARD_HOOK_H_
#define KEYBOARD_HOOK_H_

#ifdef __cplusplus
#include <windows.h>
extern "C" {
#else
// Forward declaration for C
struct tagMSG;
typedef struct tagMSG MSG;
#endif

#ifdef _WIN32
#define KEYBOARD_API __declspec(dllexport)
#else
#define KEYBOARD_API
#endif

// Register global hotkey
// Returns 1 on success, 0 on failure
KEYBOARD_API int register_hotkey(int modifiers, int vk);

// Unregister global hotkey
KEYBOARD_API void unregister_hotkey();

// Set callback function pointer (called when hotkey is pressed)
// callback: function pointer that will be called
KEYBOARD_API void set_hotkey_callback(void (*callback)());

// Check if hotkey is registered
KEYBOARD_API int is_hotkey_registered();

// Process hotkey message (should be called from message loop)
KEYBOARD_API int process_hotkey_message(MSG* msg);

#ifdef __cplusplus
}
#endif

#endif  // KEYBOARD_HOOK_H_

