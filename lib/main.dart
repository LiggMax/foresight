import 'package:flutter/material.dart';

void main() {
  runApp(const CrosshairSettingsApp());
}

class CrosshairSettingsApp extends StatelessWidget {
  const CrosshairSettingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CrosshairSettingsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CrosshairSettingsPage extends StatefulWidget {
  @override
  _CrosshairSettingsPageState createState() => _CrosshairSettingsPageState();
}

class _CrosshairSettingsPageState extends State<CrosshairSettingsPage> {
  double strokeWidth = 3;
  double lineLength = 25;
  double gap = 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("十字准心设置")),
      body: Row(
        children: [
          // ------------------------- 左侧菜单 -------------------------
          Container(
            width: 250,
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text("十字准心设置", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 20),

                // 粗细
                _buildSlider(
                  label: "线条粗细 (${strokeWidth.toStringAsFixed(1)})",
                  value: strokeWidth,
                  min: 1,
                  max: 10,
                  onChanged: (v) => setState(() => strokeWidth = v),
                ),

                // 长度
                _buildSlider(
                  label: "线条长度 (${lineLength.toStringAsFixed(0)})",
                  value: lineLength,
                  min: 5,
                  max: 80,
                  onChanged: (v) => setState(() => lineLength = v),
                ),

                // 间距
                _buildSlider(
                  label: "中心间距 (${gap.toStringAsFixed(0)})",
                  value: gap,
                  min: 0,
                  max: 30,
                  onChanged: (v) => setState(() => gap = v),
                ),
              ],
            ),
          ),

          // ------------------------- 显示准星 -------------------------
          Expanded(
            child: Center(
              child: CustomPaint(
                size: const Size(300, 300),
                painter: CrosshairPainter(
                  strokeWidth: strokeWidth,
                  lineLength: lineLength,
                  gap: gap,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required Function(double) onChanged,
    required double min,
    required double max,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
        const SizedBox(height: 10),
      ],
    );
  }
}

// ---------------------------- 准星绘制类 ----------------------------
class CrosshairPainter extends CustomPainter {
  final double strokeWidth;
  final double lineLength;
  final double gap;

  CrosshairPainter({
    required this.strokeWidth,
    required this.lineLength,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.red
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // 横向
    canvas.drawLine(
        Offset(center.dx - gap - lineLength, center.dy),
        Offset(center.dx - gap, center.dy),
        paint);

    canvas.drawLine(
        Offset(center.dx + gap, center.dy),
        Offset(center.dx + gap + lineLength, center.dy),
        paint);

    // 纵向
    canvas.drawLine(
        Offset(center.dx, center.dy - gap - lineLength),
        Offset(center.dx, center.dy - gap),
        paint);

    canvas.drawLine(
        Offset(center.dx, center.dy + gap),
        Offset(center.dx, center.dy + gap + lineLength),
        paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}