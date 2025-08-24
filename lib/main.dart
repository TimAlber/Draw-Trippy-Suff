
import 'dart:ui';

import 'package:colortouch/drawline.dart';
import 'package:colortouch/painter.dart';
import 'package:colortouch/stroke-with.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'imagesaver/image_saver_stub.dart'
  if (dart.library.html) 'imagesaver/image_saver_web.dart'
  if (dart.library.io) 'imagesaver/image_saver_io.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draw Trippy Suff',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DrawnLine> lines = [];
  List<Offset> currentPoints = [];

  int symmetry = 15;
  Color drawColor = Colors.white;
  double strokeWidth = 5.0;

  final GlobalKey _globalKey = GlobalKey();

  void _onPanStart(DragStartDetails details) {
    setState(() {
      currentPoints = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      currentPoints.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      lines.add(DrawnLine(
        points: List.from(currentPoints),
        color: drawColor,
        strokeWidth: strokeWidth,
      ));
      currentPoints.clear();
    });
  }

  void _clear() {
    setState(() {
      lines.clear();
      currentPoints.clear();
    });
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Pick a color'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: drawColor,
                onColorChanged: (color) {
                  setState(() => drawColor = color);
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  void _changeWidth() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Pick a Width'),
            content: SingleChildScrollView(
              child: ChangePopup(
                width: strokeWidth,
                update: (width) {
                  setState(() {
                    strokeWidth = width;
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  void _changeSymmetry() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Pick a Symmetry'),
            content: SingleChildScrollView(
              child: ChangePopup(
                width: symmetry.toDouble(),
                update: (newSymmetry) {
                  setState(() {
                    symmetry = newSymmetry.toInt();
                  });
                },
              ),
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  Future<void> _saveCanvasImage() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      await saveImage(pngBytes);
    } catch (e) {
      print('Error saving image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: RepaintBoundary(
              key: _globalKey,
              child: CustomPaint(
                painter: SymmetryPainter(
                  lines,
                  currentPoints,
                  symmetry,
                  drawColor,
                  strokeWidth,
                ),
                size: Size.infinite,
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey[900],
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: IconButton(
                      icon: Icon(Icons.color_lens, color: Colors.white),
                      onPressed: _pickColor,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.brush, color: Colors.white),
                    onPressed: _changeWidth,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  IconButton(
                    icon: Icon(Icons.grid_4x4, color: Colors.white),
                    onPressed: () => _changeSymmetry(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    onPressed: _clear,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 25),
                    child: IconButton(
                      icon: Icon(Icons.save, color: Colors.white),
                      onPressed: _saveCanvasImage,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
