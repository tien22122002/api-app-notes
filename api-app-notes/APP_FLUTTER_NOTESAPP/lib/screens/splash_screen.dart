import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_app/constants.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  late int seconds;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    seconds = 5; // Đặt thời gian ban đầu
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        if (seconds == 0) {
          // Khi hết thời gian, thoát ứng dụng
          timer.cancel(); // Hủy timer
          SystemNavigator.pop();
        } else {
          seconds--;
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Hủy timer khi widget bị huỷ
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Màu nền của màn hình splash
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Notes App',
              style: TextStyle(fontSize: 24, color: kTextColor),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              // Indicator loading
              valueColor: AlwaysStoppedAnimation<Color>(kTextColor),
            ),
            const SizedBox(height: 16),
            const Text(
              'Web API chưa được bật !',
              style: TextStyle(fontSize: 19, color: kTextColor),
            ),
            Text(
              'Ứng dụng sẽ thoát sau... $seconds giây',
              style: const TextStyle(fontSize: 18, color: kTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
