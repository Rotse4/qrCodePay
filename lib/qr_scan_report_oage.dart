import 'package:flutter/material.dart';
import '../services/account_service.dart';
import '../services/qr_scan_report_service.dart';

class QRScanReportsPage extends StatefulWidget {
  const QRScanReportsPage({Key? key}) : super(key: key);

  @override
  _QRScanReportsPageState createState() => _QRScanReportsPageState();
}

class _QRScanReportsPageState extends State<QRScanReportsPage> {
  final QRScanReportService _reportService = QRScanReportService();
  final AccountService _accountService = AccountService();
  List<Map<String, dynamic>> _scanReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminAndLoadReports();
  }

  Future<void> _checkAdminAndLoadReports() async {
    final currentUser = await _accountService.getCurrentUser();
    
    if (currentUser['role'] != 'admin') {
      // If not admin, show error and pop the page
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Access Denied: Admin only')),
      );
      Navigator.of(context).pop();
      return;
    }

    // Load reports
    final reports = await _reportService.getQRScanReports();
    setState(() {
      _scanReports = reports;
      _isLoading = false;
    });
  }

  void _clearReports() async {
    await _reportService.clearQRScanReports();
    setState(() {
      _scanReports = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Scan Reports Cleared')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scan Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearReports,
            tooltip: 'Clear All Reports',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _scanReports.isEmpty
              ? const Center(child: Text('No QR Scan Reports'))
              : ListView.builder(
                  itemCount: _scanReports.length,
                  itemBuilder: (context, index) {
                    final report = _scanReports[index];
                    return ListTile(
                      title: Text('QR Code: ${report['qrCodeId']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Scanned By: ${report['scannedBy']}'),
                          Text('Scan Time: ${report['scanTime']}'),
                          if (report['additionalDetails'] != null)
                            Text('Details: ${report['additionalDetails']}'),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}