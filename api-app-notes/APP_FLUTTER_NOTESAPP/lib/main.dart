
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:notes_app/AES/AES.dart';
import 'package:notes_app/screens/home_screen.dart';
import 'package:notes_app/screens/login_screen.dart';
import 'package:notes_app/screens/pass_pin.dart';
import 'package:notes_app/screens/signup_screen.dart';
import 'package:notes_app/screens/splash_screen.dart';
import 'package:notes_app/screens/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/main_home.dart';
import 'class/user_clientdto.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:package_info/package_info.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Kiểm tra trạng thái đăng nhập trước khi runApp()
  // getAppVersion();
  checkLoginStatusAPI();
  // checkDateTime();
  //checkPinPass();
}
late UserClientDTO userClientDTOMain = UserClientDTO(email: "", name: "", phone: "", pin: "");
void getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentSnapshot documentSnapshot;

  try {
    documentSnapshot = await firestore.collection('Admin').doc('admin').get();
    if (documentSnapshot.exists) {
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;
      String? versionFlutter = data?['versionFlutter'];
      if (version != versionFlutter) {
        // Mở trang dẫn đến đường link cập nhật ứng dụng.
        // ignore: avoid_print
        print(
            "Vui lòng cập nhập ứng dụng .............................................................");
      }
    }
  } catch (e) {
    // ignore: avoid_print
    print('Error fetching document: $e');
    // Handle error
  }
}
String generateRandomNumber() {
  Random random = Random();
  String randomNumber = '';

  for (int i = 0; i < 6; i++) {
    randomNumber += random.nextInt(10).toString(); // Số ngẫu nhiên từ 0 đến 9
  }

  return randomNumber;
}
void checkLoginStatus() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      AES aes = AES(user.uid);
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      try {
        DocumentSnapshot documentSnapshot = await firestore.collection('ClientUser').doc(user.email).get();
        if (documentSnapshot.exists) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool? onPin = prefs.getBool('onPin');
          if(onPin != null && onPin){
            if (documentSnapshot.data() is Map<String, dynamic>) {
              Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
              if (data.containsKey('PIN')) {
                String? passPin = data['PIN'];
                if (!(passPin == null || passPin == "")) {
                  passPin = aes.decryptData(passPin);
                  runApp(PassPin(passPin: passPin));
                  return;
                }
              }
            }
          }
          runApp(MyApp(initialRoute: MyHomePage.id));
          return;
        } else {
          runApp(MyApp(initialRoute: HomeScreen.id));
          return;
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error fetching document: $e');
      }
    } else {
      runApp(MyApp(initialRoute: HomeScreen.id));
      return;
    }
  });
}
void checkLoginStatusAPI() {
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      try {
        UserClientDTO userDTO = await fetchUserByEmail(user.uid, user.email);
        //print('Email: ${userDTO.email}, Name: ${userDTO.name}, Phone: ${userDTO.phone}, Pin: ${userDTO.pin}');
        userClientDTOMain = userDTO;
        if(!(userDTO.pin =="")){
          runApp(PassPin(passPin: userDTO.pin));
        }else{
          runApp(MyApp(initialRoute: MyHomePage.id));
        }
      } catch (error) {
        print('Error: $error');
        if(error == "API_no_connect"){
          runApp(const SplashScreenPage());
        }else{
          runApp(MyApp(initialRoute: HomeScreen.id));
        }
      }
    } else {
      runApp(MyApp(initialRoute: HomeScreen.id));
      return;
    }
  });
}
void checkDateTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // String? storedDateTime = prefs.getString('formattedDateTime');
  // Gọi API và lấy dữ liệu từ trang web worldtimeapi.org
  var response = await http
      .get(Uri.parse('http://worldtimeapi.org/api/timezone/Asia/Ho_Chi_Minh'));

  // Kiểm tra xem yêu cầu đã thành công không
  if (response.statusCode == 200) {
    // Phân tích dữ liệu JSON từ phản hồi
    var responseData = jsonDecode(response.body);

    // Trích xuất giá trị datetime từ dữ liệu JSON
    String? datetimeString = responseData['datetime'];

    // Chuyển chuỗi datetime thành đối tượng DateTime
    DateTime datetime = DateTime.parse(datetimeString!);

    // Sử dụng định dạng ngày tháng năm để chỉ lấy ra ngày tháng năm
    String formattedDateTime = DateFormat('yyyy-MM-dd').format(datetime);
    prefs.setString('formattedDateTime', formattedDateTime);
  } else {
    // ignore: avoid_print
    print('Failed to fetch data: ${response.statusCode}');
  }
}
class MyApp extends StatelessWidget {
  final String initialRoute;

  // ignore: use_super_parameters
  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            fontFamily: 'Ubuntu',
          ),
        ),
      ),
      initialRoute: initialRoute,
      routes: {
        HomeScreen.id: (context) => const HomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        SignUpScreen.id: (context) => const SignUpScreen(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        MyHomePage.id: (context) => MyHomePage(),

      },
    );
  }
}
