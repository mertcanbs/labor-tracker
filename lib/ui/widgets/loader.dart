import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final Color? color;
  final double strokeWidth;
  final double? size;

  const Loader({
    Key? key,
    this.color,
    this.strokeWidth = 4.0,
    this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 36,
      height: size ?? 36,
      child: FittedBox(
        child: Center(
          child: CircularProgressIndicator(
            color: color ?? Colors.grey[400],
            strokeWidth: strokeWidth,
          ),
        ),
      ),
    );
  }
}
