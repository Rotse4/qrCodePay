import 'package:flutter/material.dart';
import 'package:qr_code/scanqr.dart';
import 'package:qr_code/services/build_qr.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code/account/login.dart';
import 'package:qr_code/services/account_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'account/admin_dashboard.dart';
import 'account/feedback_page.dart';
// import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage({super.key, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AccountService _accountService = AccountService();
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = await _accountService.getCurrentUser();
    setState(() {
      _userRole = user['role'];
    });
  }

  void _logout() async {
    await _accountService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginPage()),
    );
  }

  // Method to launch phone call
  Future<void> _launchPhoneCall(String phoneNumber) async {
    // Remove any non-digit characters and ensure it starts with the country code
    final cleanedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final formattedPhoneNumber = cleanedPhoneNumber.startsWith('254') 
      ? '+$cleanedPhoneNumber' 
      : '+254$cleanedPhoneNumber';

    try {
      final Uri phoneUri = Uri.parse('tel:$formattedPhoneNumber');
      
      // Detailed logging
      print('Attempting to launch phone call to: $phoneUri');
      
      // Fallback method with explicit error handling
      if (await canLaunchUrl(phoneUri)) {
        final bool launched = await launchUrl(
          phoneUri, 
          mode: LaunchMode.externalApplication,
        );
        
        print('Phone call launch result: $launched');
        
        if (!launched) {
          _showErrorSnackbar('Could not launch phone call');
        }
      } else {
        _showErrorSnackbar('Phone call is not supported on this device');
      }
    } catch (e) {
      // Comprehensive error logging
      print('Phone call launch error: $e');
      _showErrorSnackbar('Error initiating phone call: $e');
    }
  }

  // Method to launch email
  Future<void> _launchEmail(String emailAddress) async {
    try {
      final Uri emailUri = Uri.parse('mailto:$emailAddress');
      
      // Detailed logging
      print('Attempting to launch email to: $emailUri');
      
      // Fallback method with explicit error handling
      if (await canLaunchUrl(emailUri)) {
        final bool launched = await launchUrl(
          emailUri, 
          mode: LaunchMode.externalApplication,
        );
        
        print('Email launch result: $launched');
        
        if (!launched) {
          _showErrorSnackbar('Could not launch email app');
        }
      } else {
        _showErrorSnackbar('Email app is not supported on this device');
      }
    } catch (e) {
      // Comprehensive error logging
      print('Email launch error: $e');
      _showErrorSnackbar('Error launching email: $e');
    }
  }

  // Helper method to show error snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Logout',
                onPressed: _logout,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0A8F69),
                      Color(0xFF2EC4B6),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome,",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    widget.username,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_userRole == 'admin') ...[
                  _buildActionCard(
                    context,
                    title: 'Scan QR Code',
                    subtitle: 'Quick and secure payment',
                    icon: Icons.qr_code_scanner_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScanPage()),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildActionCard(
                    context,
                    title: 'Generate Payment QR',
                    subtitle: 'Create payment QR codes',
                    icon: Icons.qr_code_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PaymentPage(username: widget.username)),
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildActionCard(
                    context,
                    title: 'Admin Dashboard',
                    subtitle: 'Access admin features',
                    icon: Icons.admin_panel_settings,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminDashboard(username: widget.username)),
                    ),
                  ),
                ] else ...[
                  _buildActionCard(
                    context,
                    title: 'Scan QR Code',
                    subtitle: 'Quick and secure payment',
                    icon: Icons.qr_code_scanner_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScanPage()),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackPage(username: widget.username),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Submit Feedback',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Color(0xFFF0F4F8),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.support_agent, 
                          color: Color(0xFF0A8F69),
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Customer Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A8F69),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.phone, 
                          color: Colors.black54,
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _launchPhoneCall('+254708868931'),
                          child: Text(
                            'Helpline: +254 708 868 931',
                            style: TextStyle(
                              fontSize: 16, 
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.email, 
                          color: Colors.black54,
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => _launchEmail('support@qrcodepay.com'),
                          child: Text(
                            'support@qrcodepay.com',
                            style: TextStyle(
                              fontSize: 16, 
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.chat, 
                          color: Colors.black54,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Live Chat: Available 24/7',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF0A8F69).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(12),
                child: Icon(
                  icon,
                  color: Color(0xFF0A8F69),
                  size: 30,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  final String username;

  PaymentPage({required this.username});
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _payeeController = TextEditingController();
  String? _qrData;

  void _generateQRCode() async{

    if (_payeeController.text.isNotEmpty && _amountController.text.isNotEmpty) {
      setState(() {
        // _qrData = "${_payeeController.text}: ${_amountController.text}";
        _qrData = generateQrData(_payeeController.text,_amountController.text, widget.username);
      });
    }
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
                    "Generate Payment QR",
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Payment Details",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        child: TextField(
                          controller: _payeeController,
                          decoration: InputDecoration(
                            labelText: "Recipient Account",
                            border: InputBorder.none,
                            labelStyle: TextStyle(color: Color(0xFF0A8F69)),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Amount",
                            prefixText: "\Kes ",
                            border: InputBorder.none,
                            labelStyle: TextStyle(color: Color(0xFF0A8F69)),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _generateQRCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0A8F69),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          "Generate QR Code",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 30),
                      if (_qrData != null) ...[
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Scan to Pay",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0A8F69),
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: QrImageView(
                                  data: _qrData!,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}