

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:notes_app/AES/AES.dart';
import 'package:notes_app/class/NotesDTO.dart';
import 'package:notes_app/class/user_clientdto.dart';
import 'package:notes_app/constants.dart';
import 'package:notes_app/main.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AES/mailsend.dart';
import '../components/numeric_keyboard.dart';
import '../main_home.dart';

// ignore: constant_identifier_names
enum PinScreenType { EnterPassword, CreatePassword }

// String? passPin;

class PassPin extends StatelessWidget {
  final String? passPin;

  const PassPin({super.key, required this.passPin});

  @override
  Widget build(BuildContext context) {
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
            return PinScreen(
              type: snapshot.data!,
              passPin: passPin,
            );
          }
        },
      ),
    );
  }
}

Future<PinScreenType> checkPassPin(String? pass) async {
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // passPin = prefs.getString('pinPass');
  if (pass != null && pass != "") {
    return PinScreenType.EnterPassword;
  } else {
    return PinScreenType.CreatePassword;
  }
}

// ignore: must_be_immutable
class PinScreen extends StatefulWidget {
  late PinScreenType type;
  late String? passPin;
  User? user = FirebaseAuth.instance.currentUser;

  PinScreen({super.key, required this.type, required this.passPin});

  @override
  // ignore: library_private_types_in_public_api
  _PinScreenState createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final TextEditingController _pinPutController = TextEditingController();
  late String pass;
  // late String confirmPass;
  late bool checkConfirmPass = false;
  bool isEmailSent = false;
  late bool _saving = false;
  late String passEmail;
  final user = FirebaseAuth.instance.currentUser;
  late bool isEnterPassNew = false;

  @override
  Widget build(BuildContext context) {

    Future<void> nhapPass() async {
      if (widget.type == PinScreenType.EnterPassword) {
        if (widget.passPin == _pinPutController.text) {
          if(isEnterPassNew){
            setState(() {
              widget.type = PinScreenType.CreatePassword;
              _pinPutController.clear();
            });
          } else {
            // Redirect to MyHomePage if password is correct
            await fetchNotesAPI();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          }
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
            _pinPutController.clear();
          });
        } else {
          if (pass == _pinPutController.text) {
            if(await saveUpdatePinApi(pass)){
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tạo mật khẩu mới thành công.')),
              );
              // Redirect to MyHomePage after successfully setting new password
              await fetchNotesAPI();
              Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            } else {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lỗi khi tạo mật khẩu mới.')),
              );
            }
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
                                  passEmail = generateRandomNumber();
                                  if (await SendMail.sendOtpEmail(
                                      widget.user!.email, passEmail)) {

                                    if(await saveUpdatePinApi(passEmail)){
                                      setState(() {

                                        isEnterPassNew = true;
                                        _saving = false;
                                      });
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Kiểm tra hộp thư email của bạn.'),
                                        ),
                                      );
                                    } else{
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Email đã được gửi nhưng lỗi không thể xác thực vui lòng thử lại sau.'),
                                        ),
                                      );
                                    }

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('pinPass', pin);
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PinScreen(
          type: PinScreenType.EnterPassword,
          passPin: pin,
        ),
      ),
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
  /*Future<bool> savePinFireBase(String pin) async {
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
  }*/
}
