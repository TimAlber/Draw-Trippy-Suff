import 'dart:io';
import 'dart:ui';

import 'package:colortouch/painter.dart';
import 'package:colortouch/stroke-with.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:web/web.dart' as web;

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
  List<List<Offset>> lines = [];
  List<Offset> currentLine = [];

  int symmetry = 15;
  Color drawColor = Colors.white;
  double strokeWidth = 5.0;

  final GlobalKey _globalKey = GlobalKey();

  void _onPanStart(DragStartDetails details) {
    setState(() {
      currentLine = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      currentLine.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      lines.add(currentLine);
      currentLine = [];
    });
  }

  void _clear() {
    setState(() {
      lines.clear();
      currentLine.clear();
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

      if (kIsWeb) {
        await WebImageDownloader.downloadImageFromUInt8List(
          uInt8List: pngBytes,
          name:
              'Trippy Image from ${DateFormat('dd.MM.yyyy kk:mm').format(DateTime.now())}',
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File(
          '${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(pngBytes);
        print('Saved to ${file.path}');

        final params = ShareParams(
          text:
              'Trippy Image from ${DateFormat('dd.MM.yyyy kk:mm').format(DateTime.now())}',
          files: [XFile(file.path)],
        );

        final result = await SharePlus.instance.share(params);

        if (result.status == ShareResultStatus.success) {
          print('Thank you for sharing the picture!');
        } else if (result.status == ShareResultStatus.dismissed) {
          print('Sharing was dismissed');
        } else {
          print('Sharing went wrong');
        }
      }
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
                  lines + [currentLine],
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
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.color_lens, color: Colors.white),
                    onPressed: _pickColor,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
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
                  IconButton(
                    icon: Icon(Icons.save, color: Colors.white),
                    onPressed: _saveCanvasImage,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // bottomNavigationBar: Container(
      //   color: Colors.grey[900],
      //   padding: EdgeInsets.symmetric(horizontal: 12),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       IconButton(icon: Icon(Icons.color_lens, color: drawColor), onPressed: _pickColor),
      //       IconButton(icon: Icon(Icons.grid_4x4, color: Colors.white), onPressed: _changeSymmetry),
      //       IconButton(icon: Icon(Icons.refresh, color: Colors.red), onPressed: _clear),
      //       Slider(
      //         value: strokeWidth,
      //         min: 1.0,
      //         max: 10.0,
      //         divisions: 9,
      //         label: strokeWidth.toStringAsFixed(1),
      //         onChanged: _changeStrokeWidth,
      //         activeColor: drawColor,
      //       ),
      //     ],
      //   ),
      // )
    );
  }
}
