import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class OTPPage extends StatefulWidget {
  final String verificationId;
  const OTPPage({required this.verificationId});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nhập OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: const InputDecoration(
                labelText: "OTP",
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                final credential = PhoneAuthProvider.credential(
                  verificationId: widget.verificationId,
                  smsCode: otpController.text.trim(),
                );

                try {
                  await FirebaseAuth.instance.signInWithCredential(credential);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("OTP sai!")),
                  );
                }
              },
              child: const Text("Xác minh"),
            )
          ],
        ),
      ),
    );
  }
}
