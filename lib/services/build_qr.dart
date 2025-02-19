import 'package:ke_qr/ke_qr.dart';

QrBuild qrBuild = QrBuild();
Process process = Process();

String generateQrData(String account, String amount, String name) {
  Map<String, String> buildingData = {
    "00": "01", // Don't change this
    "01": "11", // switch beween static and dynamic 11/12
    // "02": "12345678", // global PSPs visa mastercard etc
    "28": account, //paymentAddress
    // "52": "4900",
    "53": "404",
    "54": amount,
    // "55": "",
    // "56": "",
    // "57": "",
    "58": "KE",
    "59": name,
    "60": "NAIROBI",

    "82": DateTime.now().toString(),
  };
  return qrBuild.generateQr(buildingData, "46");
}

QrCode processQr(String data) {
  return process.processQrCode(data);
}
