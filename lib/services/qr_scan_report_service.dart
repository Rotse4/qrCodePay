import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QRScanReportService {
  static const String _qrScanReportKey = 'qr_scan_reports';

  // Record a QR code scan activity
  Future<void> recordQRScan({
    required String scannedBy,
    required String qrCodeId,
    required DateTime scanTime,
    String? additionalDetails,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Retrieve existing scan reports
      final reportsJson = prefs.getString(_qrScanReportKey) ?? '[]';
      final List<dynamic> reports = json.decode(reportsJson);

      // Create new scan report
      final scanReport = {
        'scannedBy': scannedBy,
        'qrCodeId': qrCodeId,
        'scanTime': scanTime.toIso8601String(),
        'additionalDetails': additionalDetails,
      };

      // Add new report to the list
      reports.add(scanReport);

      // Save updated reports list
      await prefs.setString(_qrScanReportKey, json.encode(reports));
    } catch (e) {
      print('Error recording QR scan report: $e');
    }
  }

  // Retrieve QR scan reports (only accessible by admin)
  Future<List<Map<String, dynamic>>> getQRScanReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsJson = prefs.getString(_qrScanReportKey) ?? '[]';
      final List<dynamic> reports = json.decode(reportsJson);
      return reports.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error retrieving QR scan reports: $e');
      return [];
    }
  }

  // Clear all QR scan reports (admin-only)
  Future<void> clearQRScanReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_qrScanReportKey);
    } catch (e) {
      print('Error clearing QR scan reports: $e');
    }
  }
}