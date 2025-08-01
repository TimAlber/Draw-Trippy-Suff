import 'package:flutter/material.dart';

class StrokeWith extends StatefulWidget {
  const StrokeWith({super.key, required this.width, required this.update});
  final double width;
  final Function(double) update;

  @override
  State<StrokeWith> createState() => _StrokeWithState();
}

class _StrokeWithState extends State<StrokeWith> {
  double tempStrokeWidth = 0;

  @override
  void initState() {
    tempStrokeWidth = widget.width;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove, size: 36),
          onPressed: () {
            setState(() {
              if (tempStrokeWidth > 1) tempStrokeWidth -= 1;
              widget.update(tempStrokeWidth);
            });
          },
        ),
        Text(
          tempStrokeWidth.toStringAsFixed(1),
          style: const TextStyle(fontSize: 36),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 36),
          onPressed: () {
            setState(() {
              tempStrokeWidth += 1;
              widget.update(tempStrokeWidth);
            });
          },
        ),
      ],
    );
  }
}
