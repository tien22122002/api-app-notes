import 'package:notes_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_app/components/components.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});
  static String id = 'welcome_screen';
  final _auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  // Hàm xử lý logout
  void _logout(BuildContext context) {
    // Thực hiện các bước để đăng xuất tài khoản ở đây
    googleSignIn.signOut(); // Đăng xuất khỏi tài khoản Google
    final User? user = _auth.currentUser;
    if (user != null) {
      _auth.signOut(); // Đăng xuất khỏi Firebase
    }

    // Sau khi đăng xuất, chuyển hướng về màn hình HomeScreen hoặc màn hình đăng nhập khác
    Navigator.popAndPushNamed(context, HomeScreen.id); // Chuyển về màn hình HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      // ignore: deprecated_member_use
      body: WillPopScope(
        onWillPop: () async {
          SystemNavigator.pop();
          return false;
        },
        child: const Center(
          child: ScreenTitle(
            title: 'Welcome',
          ),
        ),
      ),
    );
  }
}
