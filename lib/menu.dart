import 'package:flutter/material.dart';
import 'crosshair_window.dart';

class ControlPanelPage extends StatefulWidget {
  const ControlPanelPage({super.key});

  @override
  State<ControlPanelPage> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends State<ControlPanelPage> {
  double stroke = 3;
  double length = 25;
  double gap = 8;

  bool isCrosshairVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("准星控制面板"),
      ),
      body: Padding(
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
              onChanged: (v) {
                setState(() => stroke = v);
                CrosshairWindow.update(stroke, length, gap);
              },
            ),
            _slider(
              context,
              label: "线条长度",
              value: length,
              min: 5,
              max: 80,
              onChanged: (v) {
                setState(() => length = v);
                CrosshairWindow.update(stroke, length, gap);
              },
            ),
            _slider(
              context,
              label: "中心间距",
              value: gap,
              min: 0,
              max: 30,
              onChanged: (v) {
                setState(() => gap = v);
                CrosshairWindow.update(stroke, length, gap);
              },
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
        required ValueChanged<double> onChanged,
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