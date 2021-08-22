import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerUtils {
  static Future<String?> scanBarcode(BuildContext context) async {
    try {
      Barcode barcode = await Navigator.of(context).pushNamed('/scanner') as Barcode;
      return Future.value(barcode.code);
    } catch (e) {
      return null;
    }
  }
}
