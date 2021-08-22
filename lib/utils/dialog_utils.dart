import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

showMWDialog<T>({
  required Widget dialog,
  required BuildContext context,
  void Function(T)? onPop,
  bool barrierDismissible = true,
}) async {
  T result = await showCupertinoDialog(
    context: context,
    builder: (context) => dialog,
    barrierDismissible: barrierDismissible,
  );

  if (onPop != null) onPop(result);
}
