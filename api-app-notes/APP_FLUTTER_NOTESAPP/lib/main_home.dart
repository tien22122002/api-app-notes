import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/screens/page_bottom/calendar_page.dart';
import 'package:notes_app/screens/page_bottom/list_notes.dart';
import 'package:notes_app/screens/page_bottom/page_add_notes.dart';

import 'package:notes_app/bottom_bar/bottom_bar_matu.dart';
import 'package:notes_app/drawer/bottom_user_info.dart';
import 'package:notes_app/drawer/custom_list_tile.dart';
import 'package:notes_app/drawer/header.dart';
import 'package:notes_app/constants.dart';

import 'AES/AES.dart';
import 'drawer/page_drawer/page_setting.dart';

// ignore: must_be_immutable
class MyHomePage extends StatefulWidget {
  late int indexStar = 0;
  MyHomePage({super.key, this.indexStar = 0});
  static String id = 'home_app';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// void checkLoginStatus() {
//   FirebaseAuth.instance.authStateChanges().listen((User? user) {
//     if (user != null) {
//     } else {
//       runApp(MyApp(initialRoute: HomeScreen.id));
//     }
//   });
// }

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final PageController controller;
  bool _isCollapsed = false;
  late DocumentSnapshot documentSnapshot;
  late AES aes;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.indexStar);
    // aes = AES(widget.user!.uid);
    // _listenToExpiryChanges();
    //_fetchDataAndCheckDay();

  }

  /*Future<void> _fetchDataAndCheckDay() async {
    await _fetchData();
    await _checkDay(widget.accountDTO.expiry);
  }
// load data teacher
  Future<void> _fetchData() async {
    try {
      documentSnapshot =
          await firestore.collection('ClientUser').doc(widget.user!.email).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;
        setState(() {
          //widget.accountDTO.expiry = data?['expiry'];
          widget.accountDTO.name =
              aes.decryptData(data?['userName']) ?? widget.user!.displayName  ?? "ABC";

          widget.accountDTO.email = widget.user!.email ?? "ABC@gmail.com";
        });
        // ignore: use_build_context_synchronously
        CustomSnackBar(context, 'Xin chào ${widget.accountDTO.name}').show();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetchingg document: $e');
    }
  }
  // ignore: unused_element
  void _listenToExpiryChanges() {
    firestore
        .collection('ClientUser')
        .doc(widget.user!.email)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        // ignore: unnecessary_cast
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        setState(() {
          widget.accountDTO.expiry = data?['expiry'];
          _checkDay(widget.accountDTO.expiry);
        });
      }
    });
  }
  Future<void> _checkDay(String? expiry) async {
    if (expiry != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedDateTime = prefs.getString('formattedDateTime');
      if (storedDateTime != null && storedDateTime.isNotEmpty) {
        DateTime expiryDate = DateTime.parse(expiry);
        DateTime storedDate = DateTime.parse(storedDateTime);
        Duration difference = expiryDate.difference(storedDate);
        widget.accountDTO.numberExpiry = difference.inDays -1;
      } else {
        widget.accountDTO.numberExpiry = -1;
      }
    } else {
      widget.accountDTO.numberExpiry = -1;
    }
  }*/

  @override
  Widget build(BuildContext context) {
    // CustomSnackBar(context, 'Xin chào ${widget.accountDTO.name}').show();
    // ignore: deprecated_member_use
    return WillPopScope(
      // Sử dụng WillPopScope để bắt sự kiện khi người dùng nhấn nút "back"
      onWillPop: () async {
        SystemNavigator.pop(); // Thoát ứng dụng
        return true;
      },
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight), // Kích thước ưu tiên của AppBar
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5), // Màu đổ bóng
                    spreadRadius: 1, // Bán kính đổ bóng
                    blurRadius: 1, // Bán kính mờ
                    offset: const Offset(0, 2), // Độ dịch chuyển của đổ bóng
                  ),
                ],
              ),
              child: AppBar(
                title: const Text(
                  "Notes App",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: kTextColor,
                iconTheme: const IconThemeData(color: Colors.white),
                elevation: 0, // Tắt hiệu ứng đổ bóng cho phần thân của AppBar
              ),
            ),
          ),
          drawer: SafeArea(
            child: AnimatedContainer(
              curve: Curves.easeInOutCubic,
              duration: const Duration(milliseconds: 500),
              width: _isCollapsed ? 320 : 70,
              margin: const EdgeInsets.only(bottom: 10, top: 10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomDrawerHeader(isColapsed: _isCollapsed),
                    BottomUserInfo(
                      isCollapsed: _isCollapsed,
                      // accountDTO: widget.accountDTO,
                    ),
                    const Divider(
                      color: kTextColor,
                    ),

                    CustomListTile(
                      isCollapsed: _isCollapsed,
                      icon: Icons.home_outlined,
                      title: 'Home',
                      infoCount: 0,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          widget.indexStar = 0;
                        });
                      },
                    ),
                    const Divider(color: kTextColor),
                    CustomListTile(
                      isCollapsed: _isCollapsed,
                      icon: Icons.my_library_books,
                      title: 'List',
                      infoCount: 0,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          widget.indexStar = 1;
                        });
                      },
                    ),
                    CustomListTile(
                      isCollapsed: _isCollapsed,
                      icon: Icons.add,
                      title: 'Add Notes',
                      infoCount: 0,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          widget.indexStar = 2;
                        });
                      },
                    ),
                    CustomListTile(
                      isCollapsed: _isCollapsed,
                      icon: Icons.calendar_month,
                      title: 'Calendar',
                      infoCount: 0,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          widget.indexStar = 3;
                        });
                      },
                    ),
                    const Divider(color: kTextColor),
                    const Spacer(),
                    CustomListTile(
                      isCollapsed: _isCollapsed,
                      icon: Icons.notifications,
                      title: 'Notifications',
                      infoCount: 0,
                    ),
                    CustomListTile(
                      isCollapsed: _isCollapsed,
                      icon: Icons.share_outlined,
                      title: 'Share',
                      infoCount: 0,
                      onTap: (){

                      },
                    ),
                    CustomListTile(
                      isCollapsed: _isCollapsed,
                      icon: Icons.settings,
                      title: 'Settings',
                      infoCount: 0,
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingPage()),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    Align(
                      alignment: _isCollapsed
                          ? Alignment.bottomRight
                          : Alignment.bottomCenter,
                      child: IconButton(
                        splashColor: Colors.transparent,
                        icon: Icon(
                          _isCollapsed
                              ? Icons.arrow_back_ios
                              : Icons.arrow_forward_ios,
                          color: kTextColor,
                          size: 16,
                        ),
                        onPressed: () {
                          setState(() {
                            _isCollapsed = !_isCollapsed;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomBarBubble(
            selectedIndex: widget.indexStar,
            items: [
              BottomBarItem(
                iconData: Icons.home,
                label: 'Home',
              ),
              BottomBarItem(
                iconData: Icons.library_books,
                label: 'List',
              ),
              BottomBarItem(
                iconData: Icons.add,
                // label: 'Notification',
              ),
              BottomBarItem(
                iconData: Icons.calendar_month,
                label: 'Calendar',
              ),
              BottomBarItem(
                iconData: Icons.people_alt_outlined,
                label: 'Contacts',
              ),
            ],
            onSelect: (index) {
              setState(() {
                widget.indexStar = index;
              });
              controller.animateToPage(widget.indexStar,
                  duration: const Duration(milliseconds: 500), curve: Curves.ease);
            },
          ),
          body: PageView(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          width: 200, // Chiều rộng của hình ảnh
                          height: 200, // Chiều cao của hình ảnh
                          fit: BoxFit.fill, // Cách hiển thị hình ảnh
                        ),
                      ),
                      const Text('Notes App', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: kTextColor),),
                      const Text('Ứng dụng bảo mật ghi chú', style: TextStyle(fontSize: 25)),
                      // FutureBuilder<UserClientDTO>(
                      //   future: fetchUserByEmail('string'),
                      //   builder: (context, snapshot) {
                      //     if (snapshot.connectionState == ConnectionState.waiting) {
                      //       return CircularProgressIndicator(); // Hiển thị loading indicator trong quá trình fetch dữ liệu
                      //     } else if (snapshot.hasError) {
                      //       return Text('Error: ${snapshot.error}'); // Hiển thị thông báo lỗi nếu có lỗi xảy ra
                      //     } else {
                      //       return Text('Email: ${snapshot.data?.email}\nName: ${snapshot.data?.name}\nPhone: ${snapshot.data?.phone}\nPin: ${snapshot.data?.pin}');
                      //       // Hiển thị dữ liệu lấy được từ API
                      //     }
                      //   },
                      // ),
                    ],
                  ),

              ),
              const ListNotesPage(),
              const AddNotesPage(),
              CalendarPage(),
              const Center(
                child: Text('Contacts Page'),
              ),
            ],
          ),
        ),

    );
  }
}
