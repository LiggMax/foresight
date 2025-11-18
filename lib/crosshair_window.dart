import 'dart:ffi' as ffi;
import 'dart:io' show Platform;

typedef CrosshairShowNative = ffi.Void Function(
    ffi.Double, ffi.Double, ffi.Double);
typedef CrosshairShow = void Function(double, double, double);

typedef CrosshairHideNative = ffi.Void Function();
typedef CrosshairHide = void Function();

typedef CrosshairUpdateNative = ffi.Void Function(
    ffi.Double, ffi.Double, ffi.Double);
typedef CrosshairUpdate = void Function(double, double, double);

class CrosshairWindow {
  static ffi.DynamicLibrary? _dylib;
  static CrosshairShow? _showFunc;
  static CrosshairHide? _hideFunc;
  static CrosshairUpdate? _updateFunc;

  static void _ensureLoaded() {
    if (_dylib != null) return;

    if (Platform.isWindows) {
      // 在 Windows 上，函数在可执行文件中，不需要加载 DLL
      // 使用当前进程的句柄
      _dylib = ffi.DynamicLibrary.process();
    } else {
      throw UnsupportedError('Platform not supported');
    }

    _showFunc = _dylib!
        .lookup<ffi.NativeFunction<CrosshairShowNative>>('crosshair_show')
        .asFunction<CrosshairShow>();
    _hideFunc = _dylib!
        .lookup<ffi.NativeFunction<CrosshairHideNative>>('crosshair_hide')
        .asFunction<CrosshairHide>();
    _updateFunc = _dylib!
        .lookup<ffi.NativeFunction<CrosshairUpdateNative>>('crosshair_update')
        .asFunction<CrosshairUpdate>();
  }

  static void show(double stroke, double length, double gap) {
    _ensureLoaded();
    _showFunc!(stroke, length, gap);
  }

  static void hide() {
    _ensureLoaded();
    _hideFunc!();
  }

  static void update(double stroke, double length, double gap) {
    _ensureLoaded();
    _updateFunc!(stroke, length, gap);
  }
}
