import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng nhập ứng viên")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Số điện thoại",
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.verifyPhoneNumber(
                  phoneNumber: "+84${phoneController.text.substring(1)}",
                  verificationCompleted: (credential) {},
                  verificationFailed: (error) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(error.message!)));
                  },
                  codeSent: (id, token) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OTPPage(verificationId: id),
                      ),
                    );
                  },
                  codeAutoRetrievalTimeout: (_) {},
                );
              },
              child: const Text("Gửi OTP"),
            )
          ],
        ),
      ),
    );
  }
}
