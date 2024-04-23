
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:notes_app/drawer/page_drawer/setting_pass/reset_passpin.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/main_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';


class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool fingerprintAuthEnabled = false;
  bool pinAuthenticationEnabled = false;
  String? pinPass = userClientDTOMain.pin;

  @override
  void initState() {
    super.initState();
    pinPass = userClientDTOMain.pin;
    loadOnPin();

    // loadPin();
  }
  Future<bool> checkBiometrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    return canCheckBiometrics;
  }
  Future<void> loadOnPin() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool onPin = prefs.getBool('onPin') ?? false;
    // onPin ??= false;
    if(pinPass != ""){
      setState(() {
        pinAuthenticationEnabled = onPin;
      });
    }else{
      setState(() {
        pinAuthenticationEnabled = false;
      });
    }
    
  }
  /*Future<void> loadPin() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      AES aes = AES(user.uid);
      DocumentSnapshot documentSnapshot;
      try {
        documentSnapshot =
        await firestore.collection('ClientUser').doc(user.email).get();
        if (documentSnapshot.exists) {
          Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
          if (data.containsKey('PIN')) {
            String? pin = data['PIN'];
            setState(() {
              pinPass = aes.decryptData(pin);
            });
          }
          // print('aaaaaaaaaaaa $pinPass');
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error fetching document: $e');
      }
    }
  }*/

  @override
  Widget build(BuildContext context) {
    // loadOnPin();
    Future<void> checkOnPin(bool on) async {
      if(on){
        if(pinPass == ""){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>const ResetPass(passPin: "")),
          );
        }
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('onPin', on);
      setState(() {
        pinAuthenticationEnabled = on;
      });
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kTextColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          },
        ),
        title: const Text(
          'Setting',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text(
              'Xác thực mã PIN',
              style: TextStyle(color: Colors.black87),
            ),
            trailing: Switch(
              value: pinAuthenticationEnabled,
              onChanged: (value) {
                setState(() {
                  checkOnPin(value);
                });
                // Thực hiện hành động khi thay đổi giá trị của Switch
              },
              activeColor: kTextColor, // Màu của Switch khi nó được bật
              inactiveTrackColor: Colors.grey.withOpacity(0.5), // Màu của nền khi Switch không được bật
            ),
            onTap: () {
              checkOnPin(!pinAuthenticationEnabled);
            },
          ),

          const Divider(
            color: kTextColor,
          ),
          ListTile(
            title: const Text(
              'Đặt lại mã PIN',
              style: TextStyle(color: Colors.black87),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>ResetPass(passPin: pinPass)),
              );
            },
          ),
          const Divider(
            color: kTextColor,
          ),
          ListTile(
            title: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Xác thực vân tay',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                Switch(
                  value: fingerprintAuthEnabled,
                  onChanged: (value) {
                    setState(() {
                      fingerprintAuthEnabled = value;
                    });
                    // Thực hiện hành động khi thay đổi giá trị của Switch
                  },
                  activeColor: kTextColor, // Màu của Switch khi nó được bật
                  inactiveTrackColor: Colors.grey.withOpacity(0.5),
                ),
              ],
            ),
            onTap: () {
              // Thực hiện hành động khi nhấn vào mục "Xác thực vân tay"
            },

          ),
          const Divider(
            color: kTextColor,
          ),
          // Thêm các mục khác tương tự ở đây
        ],
      ),
    );
  }
}
