import 'package:flutter/material.dart';

import '../models/draw_line.dart';

class PainterPlate extends CustomPainter {
  final List<DrawnLine> lines;

  bool isEraser = false;

  PainterPlate({required this.lines,required this.isEraser});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..blendMode = BlendMode.srcOver
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    for (int i = 0; i < lines.length; ++i) {
      if (lines[i] == null) continue;
      for (int j = 0; j < lines[i].path.length - 1; ++j) {
        print("ROCIO ${i} : ${j}");
        if (lines[i].path[j] != null && lines[i].path[j + 1] != null) {
          paint.color = lines[i].color;
          paint.strokeWidth = lines[i].width;
          if (lines[i].isEraser) {
            canvas.drawLine(lines[i].path[j], lines[i].path[j + 1], Paint()..color=Colors.red..strokeWidth = lines[i].width..blendMode=BlendMode.clear);
          } else {
            canvas.drawLine(lines[i].path[j], lines[i].path[j + 1], paint);
          }
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PainterPlate oldDelegate) {
    return true;
  }
}