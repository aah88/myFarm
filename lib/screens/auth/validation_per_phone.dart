import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../home/home_screen_farmer.dart';

class PhoneAuthPage extends StatefulWidget {
  @override
  PhoneAuthPageState createState() => PhoneAuthPageState();
}

class PhoneAuthPageState extends State<PhoneAuthPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  String? verificationId;
  String? _errorMessage;

  Future<void> sendCode() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-sign in
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          verificationId = verId;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
      },
    );
  }

  void verifyCode() async {
    if (verificationId == null) {
      setState(() {
        _errorMessage = 'Please request verification code first.';
      });
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: _codeController.text,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      _goToNextPage();
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid code. Please try again.';
      });
    }
  }

  void _goToNextPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreenFarmer(),
      ), //ProductManagementScreen()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('أدخل رقم الهاتف لتسجيل الدخول'),
            SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'رقم الهاتف'),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: sendCode, child: Text("Send Code")),
            SizedBox(height: 10),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(labelText: 'Verification code'),
            ),
            ElevatedButton(onPressed: verifyCode, child: Text("Verify Code")),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
