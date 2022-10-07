import 'dart:ui';

class DrawnLine {
  final List<Offset> path;
  final Color color;
  final double width;

  final bool isEraser;
  DrawnLine(this.path, this.color, this.width, this.isEraser);
}