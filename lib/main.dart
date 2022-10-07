import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:noa_app/views/painter_plate.dart';
import 'helper/simple_stack.dart';
import 'models/draw_line.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _currentSliderValue = 5;
  DrawnLine? line;
  List<DrawnLine> lines = <DrawnLine>[];

  SimpleStack<DrawnLine> commandsForRedo = SimpleStack();
  StreamController<List<DrawnLine>> linesStreamController = StreamController<List<DrawnLine>>.broadcast();
  StreamController<DrawnLine> currentLineStreamController = StreamController<DrawnLine>.broadcast();

  bool isEraser = false;
  Color currentColor = Colors.amber;
  List<Color> currentColors = [Colors.yellow, Colors.green];
  List<Color> colorHistory = [];

  void changeColor(Color color) => setState(() => currentColor = color);
  void changeEraser() => setState(() { isEraser = true; });
  void pencilTapped() => setState(() { isEraser = false; });

  Future<void> undo() async {
    setState(() {
      if (lines.isNotEmpty) {
        commandsForRedo.push(lines.last);
        lines = List.from(lines)
          ..removeLast();
        linesStreamController.add(lines);
      }
    });
  }
  Future<void> redo() async {
    setState(() {
      if (commandsForRedo.size() > 0) {
        lines = List.from(lines)
          ..add(commandsForRedo.pop());
        linesStreamController.add(lines);
      }
    });
  }
  Future<void> clear() async {
    setState(() {
      lines = [];
      commandsForRedo.clear();
      line = null;
    });
  }

  void onPanStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.localPosition);
    setState(() {
      line = DrawnLine([point], currentColor, _currentSliderValue/2,isEraser);
    });
  }
  void onPanUpdate(DragUpdateDetails details) {
    RenderBox? box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.localPosition);
    if (line != null) {
      List<Offset> path = List.from(line!.path)..add(point);
      line = DrawnLine(path, currentColor, _currentSliderValue/2,isEraser);
      currentLineStreamController.add(line!);
    }
  }
  void onPanEnd(DragEndDetails details) {
    if (line != null) {
      lines = List.from(lines)..add(line!);
    }
    linesStreamController.add(lines);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/cloth.png"),
                    fit: BoxFit.contain,
                  ),
                ),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 150,
                child:const SizedBox(),
              ),
              Row(
                mainAxisAlignment:MainAxisAlignment.center,
                children: [
                  Container(height: 242,width: 2,color: Colors.transparent,
                    child: Column(
                      children: List.generate(20, (index) =>
                          Expanded(
                              child: Container(color: index%2==0 ? Colors.transparent : Colors.grey[700],height: 200,)
                          )
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 2,width: 150,color: Colors.transparent,
                        child: Row(
                          children: List.generate(20, (index) =>
                              Expanded(
                                  child: Container(color: index%2==0 ? Colors.transparent : Colors.grey[700],height: 2,)
                              )
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 240,
                        width: 150,
                        child:  GestureDetector(
                          onPanStart: onPanStart,
                          onPanUpdate: onPanUpdate,
                          onPanEnd: onPanEnd,
                          child: StreamBuilder<List<DrawnLine>>(
                            stream: linesStreamController.stream,
                            builder: (context, snapshot) {
                              return (line == null) ? Container(width: 100,height: 40,color: Colors.transparent,) : CustomPaint(
                                painter: PainterPlate(
                                    lines: lines,
                                    isEraser: isEraser
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(height: 2,width: 150,color: Colors.transparent,
                        child: Row(
                          children: List.generate(20, (index) =>
                               Expanded(
                                   child: Container(color: index%2==0 ? Colors.transparent : Colors.grey[700],height: 2,)
                              )
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(height: 242,width: 2,color: Colors.transparent,
                    child: Column(
                      children: List.generate(20, (index) =>
                          Expanded(
                              child: Container(color: index%2==0 ? Colors.transparent : Colors.grey[700],height: 200,)
                          )
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
          Slider(
            value: _currentSliderValue,
            max: 100,
            //divisions: 100,
            label: _currentSliderValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
              });
            },
          ),
          SizedBox(
            height: 50,
            child: Row(
              children: [
                IconButton(
                  iconSize: 40,
                  icon: const ImageIcon(
                    AssetImage('assets/redo.png'),
                    //color: Color(0xFF3A5A98),
                  ),
                  onPressed: () => redo(),
                  color: Colors.blue,
                ),
                IconButton(
                  iconSize: 40,
                  icon: const ImageIcon(
                    AssetImage('assets/undo.png'),
                    //color: Color(0xFF3A5A98),
                  ),
                  onPressed: () => undo(),
                  color: Colors.blue,
                ),
                const Spacer(),
                IconButton(
                  iconSize: 40,
                  icon: Image.asset('assets/pen.png'),
                  onPressed: () => pencilTapped(),
                  color: Colors.blue,
                ),
                IconButton(
                  iconSize: 40,
                  icon: Image.asset('assets/color_plattle.png'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          titlePadding: const EdgeInsets.all(0),
                          contentPadding: const EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius: MediaQuery.of(context).orientation == Orientation.portrait
                                ? const BorderRadius.vertical(
                              top: Radius.circular(500),
                              bottom: Radius.circular(100),
                            )
                                : const BorderRadius.horizontal(right: Radius.circular(500)),
                          ),
                          content: SingleChildScrollView(
                            child: HueRingPicker(
                              pickerColor: currentColor,
                              onColorChanged: changeColor,
                              //enableAlpha: _enableAlpha2,
                              //displayThumbColor: _displayThumbColor2,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  color: Colors.blue,
                ),
                IconButton(
                  iconSize: 40,
                  icon: Image.asset('assets/eraser.png'),
                  onPressed: () => changeEraser(),
                  color: Colors.blue,
                ),
                IconButton(
                  iconSize: 40,
                  icon: const Icon(
                    Icons.clear,
                  ),
                  onPressed: () => clear(),
                  color: Colors.blue,
                ),
                const SizedBox(width: 12,),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 9, dashSpace = 5, startX = 0;
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}





/*
class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()..strokeWidth = 10;

    canvas.drawLine(Offset(50, 150), Offset(150, 220), linePaint);
    canvas.drawLine(
        Offset(size.width - 50, 150), Offset(size.width - 150, 220), linePaint);

    Paint circlePaint = Paint();
    canvas.drawCircle(Offset(100, 250), 20, circlePaint);
    canvas.drawCircle(Offset(size.width - 100, 250), 20, circlePaint);

    Paint arcPaint = Paint()
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke;
    Rect rect = Rect.fromLTWH(80, 350, 220, 300);
    canvas.drawArc(rect, math.pi, math.pi, true, arcPaint);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}



 */

// Future<void> save() async {
//   try {
//     final boundary = _globalKey.currentContext.findRenderObject() as RenderRepaintBoundary;
//     final image = await boundary.toImage();
//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     final pngBytes = byteData.buffer.asUint8List();
//     final saved = await ImageGallerySaver.saveImage(
//       pngBytes,
//       quality: 100,
//       name: DateTime.now().toIso8601String() + ".png",
//       isReturnImagePathOfIOS: true,
//     );
//   } catch (e) {
//     print(e);
//   }
// }