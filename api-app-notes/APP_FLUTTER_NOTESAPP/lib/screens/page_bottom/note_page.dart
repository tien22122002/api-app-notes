import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:notes_app/AES/AES.dart';
import 'package:notes_app/class/NotesDTO.dart';
import 'package:notes_app/constants.dart';
import 'package:notes_app/screens/page_bottom/page_add_notes.dart';


typedef UpdateNoteList = void Function();
// ignore: must_be_immutable
class NotePage extends StatefulWidget {
  NotesDTO note;
  final UpdateNoteList? updateNoteList;
  NotePage({super.key, required this.note, this.updateNoteList});

  @override
  State<NotePage> createState() => _ListNotesPageState();
}

class _ListNotesPageState extends State<NotePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String title = "Note";
  late bool saving = false;
  late bool isPinned;
  late String passPin;
  int characters = 0;
  late bool isSave = false;
  User? user;
  late AES aes;
  StreamSubscription? _timerSubscription;

  Future<void> updateNote() async {
    if (_contentController.text == "" || _titleController.text == "") {
      CustomSnackBar(context, 'Vui lòng nhập đủ thông tin!').show();
    } else {
      setState(() {
        saving = true;
      });
      String day = DateFormat("yyyy-MM-dd").format(DateTime.now());
      String time = DateFormat("HH:mm").format(DateTime.now());
      try {
        if (await updateNoteAPI(
            user!.uid,
            NotesDTO(
                id: widget.note.id,
                email: user!.email,
                title: _titleController.text,
                content: _contentController.text,
                day: day,
                time: time,
                pass: passPin != "" ? passPin : "",
                isPinned: isPinned))) {
          setState(() {
            widget.note.title = _titleController.text;
            widget.note.content = _contentController.text;
            widget.note.day = day;
            widget.note.time = time;
            widget.note.isPinned = isPinned;
            widget.note.pass = passPin;
            loadListNote(listNotesDTO);
            saving = false;
            _upIconSave();
            // ignore: use_build_context_synchronously
            CustomSnackBar(context, 'Đã lưu thành công!').show();
          });
        }else{
          // ignore: use_build_context_synchronously
          CustomSnackBar(context, 'Lỗi khi gọi API!').show();
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
        rethrow;
      }
    }
  }

  String formatTimeAgo(String day, String time) {
    DateTime dateTime = DateTime.parse('$day $time');
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays >= 7) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'vừa xong';
    }
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    aes = AES(user!.uid);
    _titleController = TextEditingController();
    _titleController.addListener(() {
      _upIconSave();
    });
    _contentController = TextEditingController();
    _contentController.addListener(_updateCharacterCount);
    isPinned = widget.note.isPinned;
    passPin = widget.note.pass;
    _titleController.text = widget.note.title;
    _contentController.text = widget.note.content;
    _startTimer();
    // _upIconSave();
  }

  @override
  void dispose() {
    _stopTimer();
    _contentController.removeListener(_updateCharacterCount);
    _titleController.removeListener(() {
      _upIconSave();
    });
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  void _startTimer() {
    _timerSubscription = Stream.periodic(const Duration(seconds: 4)).listen((_) {
      setState(() {
      });
    });
  }
  void _stopTimer() {
    _timerSubscription?.cancel();
  }
  // Load icon Save
  void _upIconSave() {
    if (_contentController.text != widget.note.content ||
        _titleController.text != widget.note.title ||
        passPin != widget.note.pass ||
        isPinned != widget.note.isPinned) {
      setState(() {
        isSave = true;
      });
    } else {
      setState(() {
        isSave = false;
      });
    }
  }
  // Update số lượng chữ trong content
  void _updateCharacterCount() {
    setState(() {
      _upIconSave();
      characters = _contentController.text.length; // Cập nhật số ký tự
    });
  }
  // Hiện màn hình nhập mật khẩu
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
                    _upIconSave();
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
  //Nhập mật khẩu cho note
  void _enterPasswordDialog( Function function) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String pass = "";
        return AlertDialog(
          title: const Text('Nhập mật khẩu'),
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
                    if (widget.note.pass == pass) {
                      Navigator.of(context).pop();
                      function();
                    } else {
                      Navigator.of(context).pop();
                      CustomSnackBar(context, "Sai mật khẩu").show();
                    }
                  } else {
                    CustomSnackBar(context, "Mật khẩu không chứa khoảng trắng").show();
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
  void showDeleteConfirmationDialog(BuildContext context, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                onConfirm(); // Gọi hàm xóa nếu người dùng xác nhận
                Navigator.of(context).pop();
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
  // Hàm xóa note dựa trên docId
  Future<void> deleteNote(int id) async {
    try{
      if(await deleteNoteAPI(id)){
        if (widget.updateNoteList != null) {
          widget.updateNoteList!();
        }
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
        // ignore: use_build_context_synchronously
        CustomSnackBar(context, "Xóa note thành công").show();
      }else{
        // ignore: use_build_context_synchronously
        CustomSnackBar(context, "lỗi! Không xóa được note.").show();
      }
    }catch(e){
      // ignore: use_build_context_synchronously
      CustomSnackBar(context, "lỗi khi gọi api.").show();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (widget.updateNoteList != null) {
          widget.updateNoteList!();
        }
        Navigator.of(context).pop();
        return true;
      },

      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text(title)),
          leading:IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (widget.updateNoteList != null) {
                      widget.updateNoteList!();
                    }
                    Navigator.of(context).pop();
                  },
                ),
          actions: [
                  if (isSave)
                    IconButton(
                      onPressed: () {
                        updateNote();
                      },
                      icon: const Icon(
                        Icons.save,

                        size: 30,
                      ),
                      color: kTextColor,
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color:
                          kTextColor,
                    ),
                    onSelected: (String value) {
                      switch (value) {
                        case 'Ghim':
                          isPinned = !isPinned;
                          CustomSnackBar(context,
                                  isPinned ? 'Đã ghim!' : 'Đã bỏ ghim!')
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
                        case 'deleteNote':
                          if(widget.note.pass != ""){
                            _enterPasswordDialog(() {
                              showDeleteConfirmationDialog(context, () {
                                deleteNote(widget.note.id);
                              });
                            });
                          }else{
                            showDeleteConfirmationDialog(context, () {
                              deleteNote(widget.note.id);
                            });
                          }
                          break;
                      }
                      _upIconSave();
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'Ghim',
                        child: ListTile(
                          leading: Icon(isPinned
                              ? Icons.push_pin_outlined
                              : Icons.push_pin,
                          ),
                          title: Text(isPinned ? 'Bỏ Ghim' : 'Ghim'),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'setPass',
                        child: ListTile(
                          leading: Icon(
                              passPin == "" ? Icons.lock : Icons.lock_open),
                          title: Text(
                              passPin == "" ? 'Cài mật khẩu' : 'Gỡ mật khẩu'),
                        ),
                      ),
                          const PopupMenuItem<String>(
                            value: 'deleteNote',
                            child: ListTile(
                              leading: Icon(Icons.delete_forever, color: Colors.red,),
                              title: Text('Xóa', style: TextStyle(color: Colors.red),),
                            ),
                          ),
                    ],
                  ),
                ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Divider(
              height: 1,
              color: Colors.grey,
            ),
          ),
        ),
        body:
              LoadingOverlay(
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
                              "${DateFormat('MMMM dd HH:mm').format(DateTime.parse('${widget.note.day} ${widget.note.time}'))}   |   $characters characters"),
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
      ),
    );
  }
}
