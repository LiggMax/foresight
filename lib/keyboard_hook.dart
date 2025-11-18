import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

typedef RegisterHotkeyNative = ffi.Int32 Function(ffi.Int32, ffi.Int32);
typedef RegisterHotkey = int Function(int, int);

typedef UnregisterHotkeyNative = ffi.Void Function();
typedef UnregisterHotkey = void Function();

typedef SetHotkeyCallbackNative = ffi.Void Function(ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>>);
typedef SetHotkeyCallback = void Function(ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>>);

typedef IsHotkeyRegisteredNative = ffi.Int32 Function();
typedef IsHotkeyRegistered = int Function();

class KeyboardHook {
  static ffi.DynamicLibrary? _dylib;
  static RegisterHotkey? _registerHotkey;
  static UnregisterHotkey? _unregisterHotkey;
  static SetHotkeyCallback? _setHotkeyCallback;
  static IsHotkeyRegistered? _isHotkeyRegistered;
  static ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>>? _callbackPtr;

  // Windows modifier flags
  static const int MOD_ALT = 0x0001;
  static const int MOD_CONTROL = 0x0002;
  static const int MOD_SHIFT = 0x0004;
  static const int MOD_WIN = 0x0008;

  // Virtual key codes (common ones)
  static const int VK_F1 = 0x70;
  static const int VK_F2 = 0x71;
  static const int VK_F3 = 0x72;
  static const int VK_F4 = 0x73;
  static const int VK_F5 = 0x74;
  static const int VK_F6 = 0x75;
  static const int VK_F7 = 0x76;
  static const int VK_F8 = 0x77;
  static const int VK_F9 = 0x78;
  static const int VK_F10 = 0x79;
  static const int VK_F11 = 0x7A;
  static const int VK_F12 = 0x7B;

  static void _ensureLoaded() {
    if (_dylib != null) return;

    if (Platform.isWindows) {
      _dylib = ffi.DynamicLibrary.process();
    } else {
      throw UnsupportedError('Platform not supported');
    }

    _registerHotkey = _dylib!
        .lookup<ffi.NativeFunction<RegisterHotkeyNative>>('register_hotkey')
        .asFunction<RegisterHotkey>();
    _unregisterHotkey = _dylib!
        .lookup<ffi.NativeFunction<UnregisterHotkeyNative>>('unregister_hotkey')
        .asFunction<UnregisterHotkey>();
    _setHotkeyCallback = _dylib!
        .lookup<ffi.NativeFunction<SetHotkeyCallbackNative>>('set_hotkey_callback')
        .asFunction<SetHotkeyCallback>();
    _isHotkeyRegistered = _dylib!
        .lookup<ffi.NativeFunction<IsHotkeyRegisteredNative>>('is_hotkey_registered')
        .asFunction<IsHotkeyRegistered>();
  }

  static int registerHotkey(int modifiers, int vk) {
    _ensureLoaded();
    return _registerHotkey!(modifiers, vk);
  }

  static void unregisterHotkey() {
    _ensureLoaded();
    _unregisterHotkey!();
    if (_callbackPtr != null) {
      _callbackPtr = null;
    }
  }

  static void setCallback(ffi.Pointer<ffi.NativeFunction<ffi.Void Function()>> callback) {
    _ensureLoaded();
    _setHotkeyCallback!(callback);
    _callbackPtr = callback;
  }

  static bool isRegistered() {
    _ensureLoaded();
    return _isHotkeyRegistered!() != 0;
  }

  // Helper: Get virtual key code from key name
  static int getVkFromKeyName(String keyName) {
    final upper = keyName.toUpperCase();
    switch (upper) {
      case 'F1': return VK_F1;
      case 'F2': return VK_F2;
      case 'F3': return VK_F3;
      case 'F4': return VK_F4;
      case 'F5': return VK_F5;
      case 'F6': return VK_F6;
      case 'F7': return VK_F7;
      case 'F8': return VK_F8;
      case 'F9': return VK_F9;
      case 'F10': return VK_F10;
      case 'F11': return VK_F11;
      case 'F12': return VK_F12;
      default:
        if (upper.length == 1 && upper.codeUnitAt(0) >= 65 && upper.codeUnitAt(0) <= 90) {
          // A-Z
          return upper.codeUnitAt(0);
        }
        return 0;
    }
  }

  // Helper: Format key combination string
  static String formatKeyCombo(int modifiers, int vk) {
    if (vk == 0) {
      return '未设置';
    }

    final parts = <String>[];
    if ((modifiers & MOD_CONTROL) != 0) parts.add('Ctrl');
    if ((modifiers & MOD_ALT) != 0) parts.add('Alt');
    if ((modifiers & MOD_SHIFT) != 0) parts.add('Shift');
    if ((modifiers & MOD_WIN) != 0) parts.add('Win');

    String keyName = '';
    if (vk >= VK_F1 && vk <= VK_F12) {
      keyName = 'F${vk - VK_F1 + 1}';
    } else if (vk >= 65 && vk <= 90) {
      keyName = String.fromCharCode(vk);
    } else {
      keyName = 'Key$vk';
    }

    // If no modifiers, just return the key name
    if (parts.isEmpty) {
      return keyName;
    }

    parts.add(keyName);
    return parts.join(' + ');
  }
}

