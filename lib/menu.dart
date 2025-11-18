import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'crosshair_window.dart';

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

  double stroke = 3;
  double length = 25;
  double gap = 8;

  bool isCrosshairVisible = false;
  bool _hiveLoaded = false;
  Box? _settingsBox;

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

        stroke = (strokeValue is double) ? strokeValue : 3.0;
        length = (lengthValue is double) ? lengthValue : 25.0;
        gap = (gapValue is double) ? gapValue : 8.0;
        _hiveLoaded = true;
      });

      if (isCrosshairVisible) {
        CrosshairWindow.update(stroke, length, gap);
      }
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