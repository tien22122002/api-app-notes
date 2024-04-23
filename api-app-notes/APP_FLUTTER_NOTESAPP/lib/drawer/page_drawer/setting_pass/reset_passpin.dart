import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:notes_app/AES/AES.dart';
import 'package:notes_app/AES/mailsend.dart';
import 'package:notes_app/class/user_clientdto.dart';
import 'package:notes_app/constants.dart';
import 'package:notes_app/drawer/page_drawer/page_setting.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/screens/pass_pin.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../components/numeric_keyboard.dart';

class ResetPass extends StatelessWidget {
  final String? passPin;

  const ResetPass({super.key, required this.passPin});

  @override
  Widget build(BuildContext context) {
    // print("passsss $passPin");
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PIN Input Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<PinScreenType>(
        future: checkPassPin(passPin),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Đã xảy ra lỗi: ${snapshot.error}');
          } else {
            return ResetPinScreen(
              type: snapshot.data!,
              passPin: passPin,
            );
          }
        },
      ),
    );
  }
}

// Future<PinScreenType> checkPassPin(String? pass) async {
//   if (!(pass == null || pass == "")) {
//     return PinScreenType.EnterPassword;
//   } else {
//     return PinScreenType.CreatePassword;
//   }
// }

// ignore: must_be_immutable
class ResetPinScreen extends StatefulWidget {
  late PinScreenType type;
  late String? passPin;

  ResetPinScreen({super.key, required this.type, required this.passPin});

  @override
  // ignore: library_private_types_in_public_api
  _PinScreenState createState() => _PinScreenState();
}

class _PinScreenState extends State<ResetPinScreen> {
  final TextEditingController _pinPutController = TextEditingController();
  late String pass;
  late String confirmPass;
  late bool checkConfirmPass = false;
  bool isEmailSent = false;
  late bool _saving = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    void nhapPass() {
      if (widget.type == PinScreenType.EnterPassword) {
        if (widget.passPin == _pinPutController.text) {
          setState(() {
            _pinPutController.clear();
            widget.type = PinScreenType.CreatePassword;
          });
        } else {
          setState(() {
            _pinPutController.clear();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sai mật khẩu.')),
          );
        }
      } else {
        if (!checkConfirmPass) {
          pass = _pinPutController.text;
          setState(() {
            checkConfirmPass = true;
          });
          _pinPutController.clear();
        } else {
          if (pass == _pinPutController.text) {
            savePinPassword(_pinPutController.text);
          } else {
            _pinPutController.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Mật khẩu không khớp, vui lòng nhập lại.')),
            );
          }
        }
      }
    }

    return Scaffold(
      body: LoadingOverlay(
        isLoading: _saving,
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  if (checkConfirmPass)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          pass = "";
                          _pinPutController.clear();
                          checkConfirmPass = false;
                        });
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black38,
                      ),
                      label: const Text(
                        "Quay lại",
                        style: TextStyle(color: Colors.black38),
                      ),
                      style: TextButton.styleFrom(
                        // Màu chữ của nút
                        backgroundColor: Colors.transparent, // Màu nền trong suốt
                        elevation: 0, // Không có hiệu ứng nâng cao
                      ),
                    ),
                  // Khoảng trống linh hoạt
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.type == PinScreenType.EnterPassword
                            ? ""
                            : checkConfirmPass
                                ? "Nhập lại mã PIN"
                                : "Tạo mã PIN",
                      ),
                    ),
                  ),
                  if (checkConfirmPass) const Spacer(),
                  if (widget.type == PinScreenType.EnterPassword)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {
                              setState(() {
                                pass = "";
                                _pinPutController.clear();
                              });
                            },
                            style: TextButton.styleFrom(),
                            child: GestureDetector(
                              onTap: () async {
                                setState(() {
                                  _saving = true;
                                });
                                if (!isEmailSent) {
                                  isEmailSent = true;
                                  String passEmail = generateRandomNumber();
                                  if (await SendMail.sendOtpEmail(
                                      user!.email, passEmail)) {
                                    if(await saveUpdatePinApi(passEmail)){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Kiểm tra hộp thư email của bạn.'),
                                        ),
                                      );
                                    }else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Lỗi không cài lại pin được.'),
                                        ),
                                      );

                                    }
                                    setState(() {
                                      _saving = false;
                                    });
                                    // ignore: use_build_context_synchronously

                                  } else {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Lỗi chưa gửi email được.'),
                                      ),
                                    );
                                    setState(() {
                                      _saving = false;
                                    });
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Email đã được gửi trước đó, vui lòng kiểm tra hộp thư email của bạn.'),
                                    ),
                                  );
                                  setState(() {
                                    _saving = false;
                                  });
                                }
                              },
                              child: const Text(
                                "Quên mật khẩu",
                                style: TextStyle(
                                  color: Colors.black45,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )),
                      ),
                    ),

                  // Adding a Container with fixed height to ensure the row height remains constant
                  Container(
                    height: 50, // Set your desired height here
                  ),
                ],
              ),
              const Text("Notes App", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: kTextColor),),
              const SizedBox(height: 10),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Nhập mã PIN",
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50.0),
                        child: Column(
                          children: [
                            PinCodeTextField(
                              appContext: context,
                              length: 6,
                              obscureText: true,
                              readOnly: true,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(45),
                                fieldHeight: 50,
                                fieldWidth: 20,
                                activeFillColor: Colors.black,
                                // Màu đen khi nhập
                                inactiveFillColor: Colors.white.withOpacity(0.5),
                                activeColor: Colors.white,
                                // Đặt màu sắc viền mờ trùng với màu nền
                                inactiveColor: Colors.white,
                                // Đặt màu sắc viền mờ trùng với màu nền
                                selectedColor: Colors.white,
                                // Đặt màu sắc viền mờ trùng với màu nền
                                disabledColor: Colors.white,
                              ),
                              controller: _pinPutController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onCompleted: (pin) {
                                nhapPass();
                              },
                            ),
                            // const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      NumericKeyboard(
                          onKeyboardTap: (value) => setState(() {
                                if (_pinPutController.text.length < 6) {
                                  _pinPutController.text =
                                      _pinPutController.text + value;
                                }
                              }),
                          textColor: Colors.black38,
                          rightButtonFn: () {
                            setState(() {
                              _pinPutController.text = _pinPutController.text
                                  .substring(
                                      0, _pinPutController.text.length - 1);
                            });
                          },
                          rightIcon: const Icon(
                            Icons.backspace,
                            color: Colors.black54,
                          ),
                          leftButtonFn: () {
                            nhapPass();
                          },
                          leftIcon: const Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 40,
                          ),
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void savePinPassword(String pin) async {
    if (pin.length != 6) {
      setState(() {
        checkConfirmPass = false;
        pass = "";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lỗi khi tạo mật khẩu. Vui lòng nhập lại')),
      );
    }
    if(await saveUpdatePinApi(pin)){
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đổi mật khẩu thành công.')),
      );
    }
    // ignore: use_build_context_synchronously
    // Navigator.pop(context);
    Navigator.pushReplacement(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(builder: (context) => const SettingPage()),
    );
  }
  Future<bool> saveUpdatePinApi(String pin) async{
    if (user != null) {
      setState(() {
        _saving = true;
      });
      var userUp = UserClientDTO(email: userClientDTOMain.email, name: userClientDTOMain.name, phone: userClientDTOMain.phone, pin: pin);
      if(await updateUserPinAPI(user!.uid, userUp)){
        userClientDTOMain = userUp;
        setState(() {
          _saving = false;
          widget.passPin = pin;
        });
        return true;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đổi mật khẩu thất bại.')),
    );
    setState(() {
      _saving = false;
    });
    return false;
  }

  Future<bool> savePinFireBase(String pin) async {
    if (user != null) {
      setState(() {
        _saving = true;
      });
      AES aes = AES(user!.uid);
      final firestore = FirebaseFirestore.instance;
      try {
        await firestore.collection('ClientUser').doc(user!.email).set(
          {
            'PIN': aes.encryptData(pin),
          },
          SetOptions(merge: true),
        );
        // ignore: use_build_context_synchronously

        setState(() {
          _saving = false;
          widget.passPin = pin;
        });
        return true;
        // ignore: empty_catches
      } catch (e) {
      }
    }
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đổi mật khẩu thất bại.')),
    );
    setState(() {
      _saving = false;
    });
    return false;
  }
}
