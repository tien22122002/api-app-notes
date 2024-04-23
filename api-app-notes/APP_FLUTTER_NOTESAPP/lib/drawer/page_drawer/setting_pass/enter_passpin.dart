// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/painting.dart';
// ignore: unnecessary_import
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
// ignore: unnecessary_import
import 'package:flutter/widgets.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../components/numeric_keyboard.dart';

// ignore: must_be_immutable
class EnterPinScreen extends StatefulWidget {
  late String? passPin;

  EnterPinScreen({super.key, required this.passPin});

  @override
  // ignore: library_private_types_in_public_api
  _PinScreenState createState() => _PinScreenState();
}

class _PinScreenState extends State<EnterPinScreen> {
  final TextEditingController _pinPutController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void nhapPass() {
      if (widget.passPin == _pinPutController.text) {
      } else {
        setState(() {
          _pinPutController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sai mật khẩu.')),
        );
      }
    }

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _pinPutController.clear();
                      });
                    },
                    style: TextButton.styleFrom(),
                    child: const Text(
                      "Quên mật khẩu",
                      style: TextStyle(
                        color: Colors.black45,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                height: 50, // Set your desired height here
              ),
            ],
          ),
          const SizedBox(height: 40),
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
                              .substring(0, _pinPutController.text.length - 1);
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
    );
  }
}
