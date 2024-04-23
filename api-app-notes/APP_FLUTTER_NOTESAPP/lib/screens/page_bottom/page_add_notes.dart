import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:notes_app/class/NotesDTO.dart';
import 'package:notes_app/constants.dart';

import '../../AES/AES.dart';

class AddNotesPage extends StatefulWidget {
  const AddNotesPage({super.key});

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late bool saved;
  late bool saving;
  late bool isPinned;
  late String passPin;
  int characters = 0;
  User? user;
  late AES aes;
  StreamSubscription? _timerSubscription;

  // bool _obscureText = true;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _contentController.addListener(_updateCharacterCount);
    _startTimer();
    // _contentController.text = " ";
    user = FirebaseAuth.instance.currentUser;
    aes = AES(user!.uid);
    saved = false;
    saving = false;
    isPinned = false;
    passPin = "";
  }

  @override
  void dispose() {
    _stopTimer();
    _contentController.removeListener(_updateCharacterCount);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timerSubscription =
        Stream.periodic(const Duration(minutes: 1)).listen((_) {
      setState(() {
        // Gọi setState để cập nhật giao diện khi thời gian thay đổi
      });
    });
  }

  void _stopTimer() {
    _timerSubscription?.cancel();
  }

  void _updateCharacterCount() {
    setState(() {
      characters = _contentController.text.length; // Cập nhật số ký tự
    });
  }

  void addNoteAPI() async {
    if (_contentController.text == "" || _titleController.text == "") {
      CustomSnackBar(context, 'Vui lòng nhập đủ thông tin!').show();
    } else {
      setState(() {
        saving = true;
      });
      try {
        NotesDTO noteDTO = NotesDTO(
            id: 0,
            email: user!.email,
            title: _titleController.text,
            content: _contentController.text,
            day: DateFormat("yyyy-MM-dd").format(DateTime.now()),
            time: DateFormat("HH:mm").format(DateTime.now()),
            pass: passPin != "" ? passPin : "",
            isPinned: isPinned);
        if(await addNote(user!.uid, noteDTO)){
          setState(() {

            _contentController.text = "";
            _titleController.text = "";
            isPinned = false;
            passPin = "";
            saving = false;
          });
          // ignore: use_build_context_synchronously
          CustomSnackBar(context, 'Đã lưu thành công!').show();
          await fetchNotesAPI();
        }else{
          // ignore: use_build_context_synchronously
          CustomSnackBar(context, 'Lỗi khi lưu! Vui lòng thử lại.').show();
          setState(() {
            saving = false;
          });
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        CustomSnackBar(context, 'Lỗi! Vui lòng thử lại.').show();
        setState(() {
          saving = false;
        });
      }
    }
  }

  void saveUserDataToFirestore() async {
    if (_contentController.text == "" || _titleController.text == "") {
      CustomSnackBar(context, 'Vui lòng nhập đủ thông tin!').show();
    } else {
      setState(() {
        saving = true;
      });
      try {
        CollectionReference notesCollection =
            FirebaseFirestore.instance.collection('Notes');
        DocumentReference documentReference = await notesCollection.add({
          'email': user!.email,
          'title': aes.encryptData(_titleController.text),
          'content': aes.encryptData(_contentController.text),
          'day':
              aes.encryptData(DateFormat("yyyy-MM-dd").format(DateTime.now())),
          'time': aes.encryptData(DateFormat("HH:mm").format(DateTime.now())),
          'isPinned': isPinned,
          'pass': passPin != "" ? aes.encryptData(passPin) : ""
        });
        setState(() {
          _contentController.text = "";
          _titleController.text = "";
          isPinned = false;
          passPin = "";
          saving = false;
        });
        // ignore: use_build_context_synchronously
        CustomSnackBar(context, 'Đã lưu thành công!').show();
        // ignore: avoid_print
        print('Document ID: ${documentReference.id}');
      } catch (e) {
        // ignore: avoid_print
        print('Error saving user data: $e');
        // ignore: use_build_context_synchronously
        CustomSnackBar(context, 'Lỗi! Vui lòng thử lại.').show();
        setState(() {
          saving = false;
        });
        rethrow; // Rethrow the exception to handle it outside this function
      }
    }
  }

  void _showSetPasswordDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String pass = "";
        return AlertDialog(
          title: const Text('Cài mật khẩu'),
          content: TextField(
            onChanged: (value) {
              pass = value;
            },
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Nhập mật khẩu',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                if (pass != "") {
                  if (!pass.contains(" ")) {
                    passPin = pass;
                    Navigator.of(context).pop();
                  } else {
                    CustomSnackBar(
                            context, "Mật khẩu không được chứa khoảng trắng")
                        .show();
                  }
                } else {
                  CustomSnackBar(context, "Chưa nhập mật khẩu").show();
                }
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ' Add notes',
          style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xB8D4DEF7),
        actions: [
          IconButton(
            onPressed: () {
              addNoteAPI();
            },
            icon: const Icon(
              Icons.check,
              size: 30,
            ),
            color: kTextColor,
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: kTextColor, // Thiết lập màu sắc cho biểu tượng chấm
            ),
            onSelected: (String value) {
              switch (value) {
                case 'Ghim':
                  isPinned = !isPinned;
                  CustomSnackBar(context, isPinned ? 'Đã ghim!' : 'Đã bỏ ghim!')
                      .show();
                  break;
                case 'setPass':
                  if (passPin == "") {
                    _showSetPasswordDialog();
                    // CustomSnackBar(context, passPin ==""?"Chưa cài mật khẩu":"Đã cài mật khẩu").show();
                  } else {
                    passPin = "";
                    CustomSnackBar(context, 'Đã gỡ mật khẩu!').show();
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Ghim',
                child: ListTile(
                  leading:
                      Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin),
                  title: Text(isPinned ? 'Bỏ Ghim' : 'Ghim'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'setPass',
                child: ListTile(
                  leading: Icon(passPin == "" ? Icons.lock : Icons.lock_open),
                  title: Text(passPin == "" ? 'Cài mật khẩu' : 'Gỡ mật khẩu'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: saving,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontSize: 20.0),
                  ),
                ),
                const SizedBox(height: 18.0),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                      "${DateFormat('MMMM dd HH:mm').format(DateTime.now())}   |   $characters characters"),
                ),
                const SizedBox(height: 18.0),
                TextFormField(
                  controller: _contentController,
                  maxLines: 20,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    labelStyle: TextStyle(fontSize: 26.0),
                    border: OutlineInputBorder(),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomSnackBar {
  final BuildContext context;
  final String message;

  CustomSnackBar(this.context, this.message);

  void show() {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.11,
        left: MediaQuery.of(context).size.width * 0.5 - message.length * 6,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: SizedBox(
              width: message.length * 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}
