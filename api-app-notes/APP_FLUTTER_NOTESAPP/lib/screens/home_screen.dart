import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_app/class/NotesDTO.dart';
import 'package:notes_app/class/user_clientdto.dart';
import 'package:notes_app/components/components.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/screens/login_screen.dart';
import 'package:notes_app/screens/page_bottom/page_add_notes.dart';
import 'package:notes_app/screens/signup_screen.dart';
import 'package:notes_app/main_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:notes_app/AES/AES.dart';
import 'package:notes_app/screens/splash_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String id = 'home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  late AES aes;

  // Đăng xuất khỏi tài khoản Google
  bool _saving = false;

  Future<void> _handleSignIn(BuildContext context) async {

    try {
      setState(() {
        _saving = true;
      });
      if (_auth.currentUser != null) {
        googleSignIn.signOut();
        _auth.signOut(); // Đăng xuất khỏi Firebase
      }
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      // FirebaseFirestore firestore = FirebaseFirestore.instance;
      // DocumentSnapshot documentSnapshot;

      try {
        aes = AES(user!.uid);
        try {
          UserClientDTO userDTO = await fetchUserByEmail(user.uid, user.email);
          //print('Email: ${userDTO.email}, Name: ${userDTO.name}, Phone: ${userDTO.phone}, Pin: ${userDTO.pin}');
          userClientDTOMain = userDTO;
          await fetchNotesAPI();
          /*if(!(userDTO.pin == null || userDTO.pin =="")){
            runApp(PassPin(passPin: userDTO.pin));
          }else{
          }*/
          setState(() {
            _saving = false;
          });
          await Navigator.pushReplacementNamed(context, MyHomePage.id);
          CustomSnackBar(context, 'Xin chào ${userDTO.name}').show();
        } catch (error) {
          setState(() {
            _saving = false;
          });
          print('Error: $error');
          if(error == "API_no_connect"){
            runApp(const SplashScreenPage());
          }else{
            await Navigator.pushReplacementNamed(context, SignUpScreen.id,
                arguments: user.email);
          }

        }
        /*documentSnapshot =
            await firestore.collection('ClientUser').doc(user.email).get();
        if (documentSnapshot.exists) {
          setState(() {
            _saving = false;
          });
          // ignore: use_build_context_synchronously
          await Navigator.pushReplacementNamed(context, MyHomePage.id);
        } else {
          setState(() {
            _saving = false;
          });
          // ignore: use_build_context_synchronously
          await Navigator.pushReplacementNamed(context, SignUpScreen.id,
              arguments: user.email);
        }*/
      } catch (e) {
        // ignore: avoid_print
        print('Error fetching document: $e');
        // Handle error
      }
    } catch (error) {
      // ignore: avoid_print
      print(error);
    }
    setState(() {
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      // Sử dụng WillPopScope để bắt sự kiện khi người dùng nhấn nút "back"
      onWillPop: () async {
        SystemNavigator.pop(); // Thoát ứng dụng
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LoadingOverlay(
          isLoading: _saving,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TopScreenImage(screenImageName: 'home.jpg'),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          right: 15.0, left: 15, bottom: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const ScreenTitle(title: 'Hello'),
                          const Text(
                            'Welcome to Notes, where you manage your notes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Hero(
                            tag: 'login_btn',
                            child: CustomButton(
                              buttonText: 'Login',
                              onPressed: () {
                                Navigator.pushNamed(context, LoginScreen.id);
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Hero(
                            tag: 'signup_btn',
                            child: CustomButton(
                              buttonText: 'Sign Up',
                              isOutlined: true,
                              onPressed: () {
                                Navigator.pushNamed(context, SignUpScreen.id);
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          const Text(
                            'Sign up using',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: CircleAvatar(
                                  radius: 20,
                                  child: Image.asset(
                                      'assets/images/icons/facebook.png'),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  _handleSignIn(context);
                                },
                                icon: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.transparent,
                                  child: Image.asset(
                                      'assets/images/icons/google.png'),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: CircleAvatar(
                                  radius: 20,
                                  child: Image.asset(
                                      'assets/images/icons/linkedin.png'),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
