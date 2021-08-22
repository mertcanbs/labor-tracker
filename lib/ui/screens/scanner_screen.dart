import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mware/ui/widgets/app_bar.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  late QRViewController controller;

  bool flash = false;
  bool hasPopped = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MWAppBar(
        backgroundColor: Colors.black54,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                controller.toggleFlash();
                bool _flash = await controller.getFlashStatus() ?? false;
                setState(() => flash = _flash);
              } catch (_) {}
            },
            icon: Icon(
              flash ? Icons.flash_off : Icons.flash_on,
            ),
          ),
          IconButton(
            onPressed: () async {
              try {
                controller.toggleFlash();
                bool _flash = await controller.getFlashStatus() ?? false;
                setState(() => flash = _flash);
              } catch (_) {}
            },
            icon: const Icon(Icons.flip_camera_ios),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          Expanded(
            child: _buildQrView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea =
        MediaQuery.of(context).size.width < 400 || MediaQuery.of(context).size.height < 400
            ? 250.0
            : 350.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      formatsAllowed: const [BarcodeFormat.code128, BarcodeFormat.code39],
      overlay: QrScannerOverlayShape(
        borderColor: Theme.of(context).primaryColor,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 5,
        cutOutSize: scanArea,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });

      if (result != null && !hasPopped) {
        HapticFeedback.heavyImpact();
        Navigator.of(context).pop(result);
        hasPopped = true;
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
