import 'package:colortouch/painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
      builder: (_) => AlertDialog(
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
          )
        ],
      ),
    );
  }

  void _changeSymmetry() {
    setState(() {
      symmetry = (symmetry == 12) ? 2 : symmetry + 2;
    });
  }

  void _changeStrokeWidth(double newWidth) {
    setState(() {
      strokeWidth = newWidth;
    });
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
            child: CustomPaint(
              painter: SymmetryPainter(lines + [currentLine], symmetry, drawColor, strokeWidth),
              size: Size.infinite,
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
                    icon: Icon(Icons.color_lens, color: drawColor),
                    onPressed: _pickColor,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  IconButton(
                    icon: Icon(Icons.grid_4x4, color: Colors.white),
                    onPressed: _changeSymmetry,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.red),
                    onPressed: _clear,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  IconButton(
                    icon: Icon(Icons.brush, color: Colors.white),
                    onPressed: () => _changeStrokeWidth(5.0),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
          )
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
