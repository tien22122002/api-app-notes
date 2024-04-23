import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes_app/class/NotesDTO.dart';
import 'package:notes_app/class/user_clientdto.dart';
import 'package:notes_app/components/components.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/screens/home_screen.dart';
import 'package:notes_app/screens/login_screen.dart';
import 'package:notes_app/main_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/constants.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/screens/page_bottom/page_add_notes.dart';
import 'package:notes_app/screens/splash_screen.dart';

import '../AES/AES.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static String id = 'signup_screen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

// Function to save user data to Firestore
Future<void> saveUserDataToFirestore( AES aes,
    String name, String email, String phone) async {
  try {
    // Reference to the Firestore collection "Teacher"
    CollectionReference teachersCollection =
        FirebaseFirestore.instance.collection('ClientUser');

    // Set the document using email as the document ID
    await teachersCollection.doc(email).set({
      'userName': aes.encryptData(name),
      'email': aes.encryptData(email),
      'phone': aes.encryptData(phone),
    });
  } catch (e) {
    // Handle errors here
    rethrow; // Rethrow the exception to handle it outside this function
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  late String _name = "";
  late String _email = "";
  late String _phone = "";
  late String _password = "";
  late String _confirmPass = "";
  bool _saving = false;
  late bool _loginUser = false;
  late AES aes;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String? emailLogin = ModalRoute.of(context)?.settings.arguments as String?;
    _email = emailLogin ?? "";
    if(emailLogin != null){
      _loginUser = true;
    }
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.popAndPushNamed(context, HomeScreen.id);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: _loginUser,
        body: LoadingOverlay(
          isLoading: _saving,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TopScreenImage(screenImageName: 'signup.png'),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const ScreenTitle(title: 'Sign Up'),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                width: 3.0,
                                color: kTextColor,
                              ),
                            ),
                            child: TextField(
                              onChanged: (value) {
                                _name = value;
                              },
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: 'Full Name',
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                width: 3.0,
                                color: kTextColor,
                              ),
                            ),
                            child: TextField(
                              onChanged: (value) {
                                _phone = value;
                              },
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: 'Phone',
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                width: 3.0,
                                color: kTextColor,
                              ),
                            ),
                            child: TextField(
                              controller: TextEditingController(text: _loginUser ? _email:""),
                              enabled: !_loginUser,
                              onChanged: (value) {
                                _email = value;
                              },
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                              decoration: kTextInputDecoration.copyWith(
                                hintText: 'Email',
                              ),
                            ),
                          ),
                          if (!_loginUser)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  width: 3.0,
                                  color: kTextColor,
                                ),
                              ),
                              child: TextField(
                                obscureText: true,
                                onChanged: (value) {
                                  _password = value;
                                },
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                                decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Password',
                                ),
                              ),
                            ),
                          if (!_loginUser)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(
                                  width: 3.0,
                                  color: kTextColor,
                                ),
                              ),
                              child: TextField(
                                obscureText: true,
                                onChanged: (value) {
                                  _confirmPass = value;
                                },
                                style: const TextStyle(
                                  fontSize: 17,
                                ),
                                decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Confirm Password',
                                ),
                              ),
                            ),
                          CustomBottomScreen(
                            textButton: 'Sign Up',
                            heroTag: 'signup_btn',
                            question: 'Have an account?',
                            buttonPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                _saving = true;
                              });
                              if (_name.isEmpty || _email.isEmpty || _phone.isEmpty) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Error"),
                                      content: const Text(
                                          "Vui lòng nập đầy đủ thông tin."),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            setState(() {
                                              _saving = false;
                                            });
                                          },
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                return;
                              }
                              if (_loginUser || _confirmPass == _password) {
                                try {
                                  if (_phone.length != 10 ||
                                      int.tryParse(_phone) == null) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Error"),
                                          content: const Text(
                                              "Phone number must be 10 digits and contain only numbers."),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                setState(() {
                                                  _saving = false;
                                                });
                                              },
                                              child: const Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    return; // Dừng thực thi tiếp theo nếu _phone không hợp lệ
                                  }
                                  String? uid;
                                  if (!_loginUser) {
                                    try {
                                       await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                        email: _email,
                                        password: _password,
                                      );
                                      await _auth.signInWithEmailAndPassword(
                                          email: _email, password: _password);
                                    } catch (e) {
                                      // Xử lý các loại lỗi cụ thể
                                      if (e is FirebaseAuthException) {
                                        if (e.code == 'weak-password') {
                                          // print('The password provided is too weak.');
                                        } else if (e.code == 'email-already-in-use') {
                                          // print('The account already exists for that email.');
                                        } else {
                                          // print('Error: ${e.message}');
                                        }
                                      } else {
                                        // print('Error: $e');
                                      }
                                    }
                                  }
                                  User? user = FirebaseAuth.instance.currentUser;
                                  uid = user?.uid;


                                  if (uid != null) {
                                    aes = AES(uid);

                                   /* await saveUserDataToFirestore(aes,
                                        _name, _email, _phone);*/
                                    try{
                                      UserClientDTO userClientDTO = UserClientDTO(email: _email, name: _name, phone: _phone, pin: "");
                                      bool check = await addUser(userClientDTO, uid);
                                      if (context.mounted && check) {
                                        userClientDTOMain = userClientDTO;
                                        await fetchNotesAPI();
                                        CustomSnackBar(context, 'Xin chào ${userClientDTO.name}').show();
                                        signUpAlert(
                                          context: context,
                                          title: 'GOOD JOB',
                                          desc: 'Bạn đã đăng ký thành công !',
                                          btnText: 'Login Now',
                                          onPressed: () {
                                            setState(() {
                                              _saving = false;
                                            });
                                            Navigator.pushReplacementNamed(
                                                context, MyHomePage.id);
                                          },
                                        ).show();
                                      }
                                    }catch (error) {
                                      print('Error: $error');
                                      setState(() {
                                        _saving = false;
                                      });
                                      if(error == "API_no_connect"){
                                        runApp(const SplashScreenPage());
                                      }else{

                                        runApp(MyApp(initialRoute: HomeScreen.id));
                                      }

                                    }

                                  } else {
                                    // Xử lý trường hợp không có UID
                                  }
                                } catch (e) {
                                  signUpAlert(
                                      // ignore: use_build_context_synchronously
                                      context: context,
                                      onPressed: () {
                                        SystemNavigator.pop();
                                      },
                                      title: 'SOMETHING WRONG',
                                      desc: 'Close the app and try again',
                                      btnText: 'Close Now');
                                }
                              } else {
                                showAlert(
                                    context: context,
                                    title: 'WRONG PASSWORD',
                                    desc:
                                        'Make sure that you write the same password twice',
                                    onPressed: () {
                                      Navigator.pop(context);
                                    }).show();
                              }
                            },
                            questionPressed: () async {
                              Navigator.pushNamed(context, LoginScreen.id);
                            },
                          ),
                        ],
                      ),
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
}
