import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'crosshair_window.dart';
import 'keyboard_hook.dart';

class ControlPanelPage extends StatefulWidget {
  const ControlPanelPage({super.key});

  @override
  State<ControlPanelPage> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage> {
  static const String _boxName = 'crosshairSettings';
  static const String _strokeKey = 'stroke';
  static const String _lengthKey = 'length';
  static const String _gapKey = 'gap';
  static const String _hotkeyModifiersKey = 'hotkeyModifiers';
  static const String _hotkeyVkKey = 'hotkeyVk';

  double stroke = 3;
  double length = 25;
  double gap = 8;

  bool isCrosshairVisible = false;
  bool _hiveLoaded = false;
  Box? _settingsBox;

  int _hotkeyModifiers = KeyboardHook.MOD_CONTROL;
  int _hotkeyVk = 0x48; // H key

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _settingsBox = await Hive.openBox(_boxName);
      setState(() {
        final strokeValue = _settingsBox!.get(_strokeKey, defaultValue: 3.0);
        final lengthValue = _settingsBox!.get(_lengthKey, defaultValue: 25.0);
        final gapValue = _settingsBox!.get(_gapKey, defaultValue: 8.0);
        final modifiersValue = _settingsBox!.get(_hotkeyModifiersKey, defaultValue: KeyboardHook.MOD_CONTROL);
        final vkValue = _settingsBox!.get(_hotkeyVkKey, defaultValue: 0x48);

        stroke = (strokeValue is double) ? strokeValue : 3.0;
        length = (lengthValue is double) ? lengthValue : 25.0;
        gap = (gapValue is double) ? gapValue : 8.0;
        _hotkeyModifiers = (modifiersValue is int) ? modifiersValue : KeyboardHook.MOD_CONTROL;
        _hotkeyVk = (vkValue is int) ? vkValue : 0x48;
        _hiveLoaded = true;
      });

      if (isCrosshairVisible) {
        CrosshairWindow.update(stroke, length, gap);
      }

      _registerHotkey();
    } catch (e) {
      // 如果加载失败，使用默认值
      setState(() {
        _hiveLoaded = true;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_settingsBox == null || !_hiveLoaded) return;

    try {
      await _settingsBox!.put(_strokeKey, stroke);
      await _settingsBox!.put(_lengthKey, length);
      await _settingsBox!.put(_gapKey, gap);
    } catch (e) {
      // 保存失败时静默处理
    }
  }

  Future<void> _saveHotkeySettings() async {
    if (_settingsBox == null || !_hiveLoaded) return;

    try {
      await _settingsBox!.put(_hotkeyModifiersKey, _hotkeyModifiers);
      await _settingsBox!.put(_hotkeyVkKey, _hotkeyVk);
    } catch (e) {
      // 保存失败时静默处理
    }
  }

  void _registerHotkey() {
    KeyboardHook.unregisterHotkey();
    
    // Register hotkey - the toggle will be handled in C++ side
    final result = KeyboardHook.registerHotkey(_hotkeyModifiers, _hotkeyVk);
    if (result == 0 && mounted) {
      // Registration failed, show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('快捷键注册失败，可能已被其他程序占用')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("准星控制面板"),
      ),
      body:
      Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "参数调节",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _slider(
              context,
              label: "线条粗细",
              value: stroke,
              min: 1,
              max: 10,
              onChanged: _hiveLoaded
                  ? (v) {
                      setState(() => stroke = v);
                      CrosshairWindow.update(stroke, length, gap);
                      _saveSettings();
                    }
                  : null,
            ),
            _slider(
              context,
              label: "线条长度",
              value: length,
              min: 5,
              max: 80,
              onChanged: _hiveLoaded
                  ? (v) {
                      setState(() => length = v);
                      CrosshairWindow.update(stroke, length, gap);
                      _saveSettings();
                    }
                  : null,
            ),
            _slider(
              context,
              label: "中心间距",
              value: gap,
              min: 0,
              max: 30,
              onChanged: _hiveLoaded
                  ? (v) {
                      setState(() => gap = v);
                      CrosshairWindow.update(stroke, length, gap);
                      _saveSettings();
                    }
                  : null,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "快捷键",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton(
                          onPressed: _showHotkeyDialog,
                          child: const Text("设置"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      KeyboardHook.formatKeyCombo(_hotkeyModifiers, _hotkeyVk),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _toggleCrosshair,
                child: Text(
                  isCrosshairVisible ? "隐藏准星窗口" : "显示准星窗口",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCrosshair() {
    if (isCrosshairVisible) {
      CrosshairWindow.hide();
    } else {
      CrosshairWindow.show(stroke, length, gap);
    }
    setState(() => isCrosshairVisible = !isCrosshairVisible);
  }

  void _showHotkeyDialog() {
    showDialog(
      context: context,
      builder: (context) => _HotkeyDialog(
        initialModifiers: _hotkeyModifiers,
        initialVk: _hotkeyVk,
        onSave: (modifiers, vk) {
          setState(() {
            _hotkeyModifiers = modifiers;
            _hotkeyVk = vk;
          });
          _saveHotkeySettings();
          _registerHotkey();
        },
      ),
    );
  }

  Widget _slider(
      BuildContext context, {
        required String label,
        required double value,
        required double min,
        required double max,
        ValueChanged<double>? onChanged,
      }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label：${value.toStringAsFixed(1)}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _HotkeyDialog extends StatefulWidget {
  final int initialModifiers;
  final int initialVk;
  final Function(int modifiers, int vk) onSave;

  const _HotkeyDialog({
    required this.initialModifiers,
    required this.initialVk,
    required this.onSave,
  });

  @override
  State<_HotkeyDialog> createState() => _HotkeyDialogState();
}

class _HotkeyDialogState extends State<_HotkeyDialog> {
  late int _modifiers;
  late int _vk;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _modifiers = widget.initialModifiers;
    _vk = widget.initialVk;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('设置快捷键'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('请按下您想要设置的快捷键组合：'),
          const SizedBox(height: 16),
          Focus(
            autofocus: true,
            child: RawKeyboardListener(
              focusNode: _focusNode,
              onKey: _handleKeyPress,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  KeyboardHook.formatKeyCombo(_modifiers, _vk),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Ctrl'),
                selected: (_modifiers & KeyboardHook.MOD_CONTROL) != 0,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _modifiers |= KeyboardHook.MOD_CONTROL;
                    } else {
                      _modifiers &= ~KeyboardHook.MOD_CONTROL;
                    }
                  });
                },
              ),
              FilterChip(
                label: const Text('Alt'),
                selected: (_modifiers & KeyboardHook.MOD_ALT) != 0,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _modifiers |= KeyboardHook.MOD_ALT;
                    } else {
                      _modifiers &= ~KeyboardHook.MOD_ALT;
                    }
                  });
                },
              ),
              FilterChip(
                label: const Text('Shift'),
                selected: (_modifiers & KeyboardHook.MOD_SHIFT) != 0,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _modifiers |= KeyboardHook.MOD_SHIFT;
                    } else {
                      _modifiers &= ~KeyboardHook.MOD_SHIFT;
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_modifiers != 0 && _vk != 0) {
              widget.onSave(_modifiers, _vk);
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请设置有效的快捷键组合')),
              );
            }
          },
          child: const Text('确定'),
        ),
      ],
    );
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final logicalKey = event.logicalKey;
      int vk = 0;

      // Map logical key to virtual key code
      if (logicalKey.keyLabel.length == 1) {
        final char = logicalKey.keyLabel.toUpperCase();
        if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
          vk = char.codeUnitAt(0);
        }
      } else if (logicalKey.keyLabel.startsWith('F')) {
        final fNum = int.tryParse(logicalKey.keyLabel.substring(1));
        if (fNum != null && fNum >= 1 && fNum <= 12) {
          vk = KeyboardHook.VK_F1 + fNum - 1;
        }
      }

      if (vk != 0) {
        setState(() {
          _vk = vk;
        });
      }
    }
  }
}