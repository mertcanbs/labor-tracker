import 'package:flutter/material.dart';

enum ProcessStatus {
  idle,
  processing,
  success,
  failure,
}

extension ProcessStatusExtension on ProcessStatus {
  Color color(context) {
    switch (this) {
      case ProcessStatus.idle:
        return Colors.transparent;
      case ProcessStatus.processing:
        return Theme.of(context).primaryColor;
      case ProcessStatus.success:
        return Theme.of(context).focusColor;
      case ProcessStatus.failure:
        return Theme.of(context).errorColor;
    }
  }
}
