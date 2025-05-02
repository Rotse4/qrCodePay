import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ke_qr/ke_qr.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code/detail.dart';
import 'package:qr_code/services/build_qr.dart';
import 'package:qr_code/services/scanner.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:io';

// import 'package:scan/scan.dart';

class ScanPage extends StatefulWidget {
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  QrCode? result;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = process.processQrCode(scanData.code ?? "");
      });
    });
  }

  Future<void> _pickImageAndDecodeQR() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final MobileScannerController controller = MobileScannerController();
      final BarcodeCapture? capture =
          await controller.analyzeImage(pickedFile.path);

      if (capture != null && capture.barcodes.isNotEmpty) {
        final String qrCode = capture.barcodes.first.rawValue ?? '';
        // Process the QR code
        setState(() {
          result = process.processQrCode(qrCode);
        });
      } else {
        _showErrorDialog("No QR code found.");
      }
      await controller.dispose();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text('QR Code Scan', style: TextStyle(color: Color(0xFF0A8F69))),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: Color(0xFF0A8F69))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A8F69),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Scan QR Code",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: QRView(
                            key: qrKey,
                            onQRViewCreated: _onQRViewCreated,
                            overlay: QrScannerOverlayShape(
                              borderColor: Color(0xFF0A8F69),
                              borderRadius: 20,
                              borderLength: 30,
                              borderWidth: 10,
                              cutOutSize: 300,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickImageAndDecodeQR,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0A8F69),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Load QR from Gallery",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    if (result != null)
                    // buildBottomSheet(context),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Payment Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A8F69),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              // result?.coviniencePercentageFee?.value ?? "",
                              " Pay : ${result?.transactionAmount?.value}/= ",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(
                              // result?.coviniencePercentageFee?.value ?? "",
                              "to : ${result?.merchantName?.value}",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                            Text(
                              // result?.coviniencePercentageFee?.value ?? "",
                              "Acc : ${result?.paymentAddress?.value[0].value}",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                // Handle payment processing here
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF0A8F69),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                "Process Payment",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                     if (result == null || result?.paymentAddress==null)
                     Container(
                      child: Text("This Qr code is corrupted"),
                     ) 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
