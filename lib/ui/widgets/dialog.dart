import 'package:flutter/material.dart';
import 'package:mware/utils/process_utils.dart';

class MWDialog extends StatefulWidget {
  final Widget? title;
  final List<Widget>? children;

  const MWDialog({Key? key, this.title, this.children}) : super(key: key);

  @override
  _MWDialogState createState() => _MWDialogState();
}

class _MWDialogState extends State<MWDialog> with Processable {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: widget.title,
      children: widget.children,
    );
  }
}
