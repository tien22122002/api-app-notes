import 'package:flutter/material.dart';
import 'package:notes_app/class/NotesDTO.dart';
import 'package:notes_app/class/user_clientdto.dart';
import 'package:notes_app/components/components.dart';
import 'package:notes_app/constants.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/main_home.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:notes_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/screens/splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String _email;
  late String _password;
  bool _saving = false;
  bool canPressReset = true;
  int resetCountdown = 0; // Biến đếm thời gian đợi

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.popAndPushNamed(context, HomeScreen.id);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LoadingOverlay(
          isLoading: _saving,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  const TopScreenImage(screenImageName: 'welcome.png'),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ScreenTitle(title: 'Login'),
                        CustomTextField(
                          textField: TextField(
                              onChanged: (value) {
                                _email = value;
                              },
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Email')),
                        ),
                        CustomTextField(
                          textField: TextField(
                            obscureText: true,
                            onChanged: (value) {
                              _password = value;
                            },
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                            decoration: kTextInputDecoration.copyWith(
                                hintText: 'Password'),
                          ),
                        ),
                        CustomBottomScreen(
                          textButton: 'Login',
                          heroTag: 'login_btn',
                          question:
                          'Forgot password? ${resetCountdown > 0 ? '($resetCountdown)' : ''}', // Hiển thị số giây đang đợi
                          buttonPressed: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              _saving = true;
                            });
                            try {
                              UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: _email,
                                password: _password,
                              );
                              UserClientDTO userDTO = await fetchUserByEmail(userCredential.user!.uid, userCredential.user!.email!);
                              userClientDTOMain = userDTO;
                              await fetchNotesAPI();

                              if (context.mounted) {
                                setState(() {
                                  _saving = false;
                                  Navigator.popAndPushNamed(
                                      context, LoginScreen.id);
                                });
                                Navigator.pushReplacementNamed(context, MyHomePage.id);
                              }
                            } catch (e) {
                              if(e =="API_no_connect"){
                                setState(() {
                                  _saving = false;
                                });
                                runApp(const SplashScreenPage());
                              }
                              else{
                                signUpAlert(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  onPressed: () {
                                    setState(() {
                                      _saving = false;
                                    });
                                    Navigator.popAndPushNamed(
                                        context, LoginScreen.id);
                                  },
                                  title: 'WRONG PASSWORD OR EMAIL',
                                  desc:
                                  'Confirm your email and password and try again',
                                  btnText: 'Try Now',
                                ).show();
                              }
                            }
                          },
                          questionPressed: () async {
                            if (!canPressReset) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Thông báo'),
                                    content: const Text(
                                        'Vui lòng đợi 60 giây trước khi nhấn lại.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }

                            if (_email.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Thông báo'),
                                    content: const Text('Vui lòng nhập địa chỉ email.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }

                            // Kiểm tra xem email có tồn tại không
                            try {
                              final List<String> signInMethods =
                              await FirebaseAuth.instance
                                  // ignore: deprecated_member_use
                                  .fetchSignInMethodsForEmail(_email);

                              if (signInMethods.isEmpty) {
                                showDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Thông báo'),
                                      content: const Text(
                                          'Địa chỉ email không tồn tại.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return;
                              }
                            } catch (error) {
                              // ignore: avoid_print
                              print('Error: $error');
                              showDialog(
                                // ignore: use_build_context_synchronously
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Lỗi'),
                                    content: const Text(
                                        'Đã xảy ra lỗi khi kiểm tra email. Vui lòng thử lại sau.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              return;
                            }

                            showDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Thông báo'),
                                  content: const Text(
                                      'Một email đã được gửi để đặt lại mật khẩu.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );

                            FirebaseAuth.instance
                                .sendPasswordResetEmail(email: _email);

                            canPressReset = false;
                            Future.delayed(const Duration(seconds: 60), () {
                              canPressReset = true;
                            });

                            // Bắt đầu đếm ngược
                            resetCountdown = 60;
                            startCountdown();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm đếm ngược
  void startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        resetCountdown--;
      });
      if (resetCountdown > 0) {
        startCountdown();
      }
    });
  }
}
