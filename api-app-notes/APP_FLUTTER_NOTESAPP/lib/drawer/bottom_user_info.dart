import 'package:flutter/material.dart';
import 'package:notes_app/class/user_clientdto.dart';
import 'package:notes_app/main.dart';
import 'package:notes_app/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notes_app/constants.dart';

// ignore: must_be_immutable
class BottomUserInfo extends StatefulWidget {
  final bool isCollapsed;
  final _auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();
  User? user = FirebaseAuth.instance.currentUser;
  // final AccountDTO accountDTO;

  BottomUserInfo({
    super.key,
    required this.isCollapsed,
    // required this.accountDTO,
  });

  @override
  State<BottomUserInfo> createState() => _BottomUserInfoState();
}

class _BottomUserInfoState extends State<BottomUserInfo> {
  @override
  void initState() {
    super.initState();
    // Gọi hàm này trong initState
  }

  @override
  void didUpdateWidget(covariant BottomUserInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kiểm tra xem accountDTO có thay đổi không
    /*if (widget.accountDTO != oldWidget.accountDTO) {
      setState(() {});
    }*/
  }

  void _logout(BuildContext context) {
    // Thực hiện các bước để đăng xuất tài khoản ở đây
    widget.googleSignIn.signOut(); // Đăng xuất khỏi tài khoản Google

    if (widget.user != null) {
      widget._auth.signOut(); // Đăng xuất khỏi Firebase
    }
    userClientDTOMain =  UserClientDTO(email: "", name: "", phone: "", pin: "");
    // Sau khi đăng xuất, chuyển hướng về màn hình HomeScreen hoặc màn hình đăng nhập khác
    Navigator.popAndPushNamed(
        context, HomeScreen.id); // Chuyển về màn hình HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    String? email = widget.user?.email ?? "abc@gmail.com";
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: widget.isCollapsed ? 80 : 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: widget.isCollapsed
          ? Center(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kTextColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          widget.user?.photoURL?.toString() ??
                              "https://th.bing.com/th/id/OIP.zyj0FFO-lfhm8uzozYdpbgHaHa?rs=1&pid=ImgDetMain",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              userClientDTOMain.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            email,
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        /*Expanded(
                          child: Text(
                            widget.accountDTO.numberExpiry < 0
                                ? "Hết hạn"
                                : "Còn lại ${widget.accountDTO.numberExpiry} ngày",
                            style: TextStyle(
                              color: widget.accountDTO.numberExpiry < 0
                                  ? Colors.red
                                  : Colors.green,
                            ),
                            maxLines: 1,
                            // overflow: TextOverflow.ellipsis,
                          ),
                        ),*/
                      ],
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                        onPressed: () {
                          _logout(context);
                        },
                        icon: const Icon(
                          Icons.logout,
                          color: kTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: kTextColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.user?.photoURL?.toString() ??
                            "https://th.bing.com/th/id/OIP.zyj0FFO-lfhm8uzozYdpbgHaHa?rs=1&pid=ImgDetMain",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () {
                      _logout(context);
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
