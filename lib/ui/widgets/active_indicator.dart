import 'package:flutter/material.dart';

const activeColor = Colors.green;

class ActiveIndicator extends StatelessWidget {
  final bool active;
  const ActiveIndicator({
    Key? key,
    required this.active,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? activeColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade400),
      ),
    );
  }
}
