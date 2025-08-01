import 'package:flutter/material.dart';

class ChangePopup extends StatefulWidget {
  const ChangePopup({super.key, required this.width, required this.update});
  final double width;
  final Function(double) update;

  @override
  State<ChangePopup> createState() => _ChangePopupState();
}

class _ChangePopupState extends State<ChangePopup> {
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
