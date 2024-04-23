
import 'package:notes_app/drawer//custom_list_tile.dart';
import 'package:notes_app/drawer//header.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/constants.dart';

class CustomDrawer extends StatefulWidget {
  final VoidCallback? onHomeTap;
  const CustomDrawer({super.key, this.onHomeTap});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isCollapsed = false;


  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
              // BottomUserInfo(isCollapsed: _isCollapsed),
              const Divider(
                color: kTextColor,
              ),

              CustomListTile(
                isCollapsed: _isCollapsed,
                icon: Icons.home_outlined,
                title: 'Home',
                infoCount: 0,
                onTap: (){
                    widget.onHomeTap!.call();
                    Navigator.pop(context);
                },
              ),
              // CustomListTile(
              //   isCollapsed: _isCollapsed,
              //   icon: Icons.library_books_rounded,
              //   title: 'List ',
              //   infoCount: 0,
              // ),
              // CustomListTile(
              //   isCollapsed: _isCollapsed,
              //   icon: Icons.add,
              //   title: 'Add',
              //   infoCount: 0,
              // ),
              // CustomListTile(
              //   isCollapsed: _isCollapsed,
              //   icon: Icons.calendar_month,
              //   title: 'Calender',
              //   infoCount: 0,
              // ),
              // CustomListTile(
              //   isCollapsed: _isCollapsed,
              //   icon: Icons.attach_money,
              //   title: 'Money',
              //   infoCount: 0,
              //   // doHaveMoreOptions: Icons.arrow_forward_ios,
              // ),
              CustomListTile(
                isCollapsed: _isCollapsed,
                icon: Icons.school,
                title: 'Schools',
                infoCount: 0,
                // doHaveMoreOptions: Icons.arrow_forward_ios,
              ),
              CustomListTile(
                isCollapsed: _isCollapsed,
                icon: Icons.portrait,
                title: 'Positions',
                infoCount: 0,
                // doHaveMoreOptions: Icons.arrow_forward_ios,
              ),
              const Divider(color: kTextColor),
              const Spacer(),
              CustomListTile(
                isCollapsed: _isCollapsed,
                icon: Icons.notifications,
                title: 'Notifications',
                infoCount: 2,
              ),
              CustomListTile(
                isCollapsed: _isCollapsed,
                icon: Icons.share_outlined,
                title: 'Share',
                infoCount: 0,
              ),
              CustomListTile(
                isCollapsed: _isCollapsed,
                icon: Icons.settings,
                title: 'Settings',
                infoCount: 0,
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
    );
  }
}
