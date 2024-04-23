import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:notes_app/AES/AES.dart';
import 'package:notes_app/class/NotesDTO.dart';
import 'package:notes_app/constants.dart';
import 'package:notes_app/screens/page_bottom/page_add_notes.dart';

class ListNotesPage extends StatefulWidget {
  const ListNotesPage({super.key});

  @override
  State<ListNotesPage> createState() => _ListNotesPageState();
}

class _ListNotesPageState extends State<ListNotesPage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  final PageController controller = PageController();
  late int indexPage = 0;
  late int indexNotes = 0;
  late String title = "List Notes";
  late bool saving = false;
  late bool isPinned;
  late String passPin;
  int characters = 0;
  late bool isSave = false;
  User? user;
  late AES aes;

  //late List<Note> notes = [];
  StreamSubscription? _timerSubscription;

  //Load List Note
  /*Future<void> fetchNotes(User? user) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('Notes')
          .where('email', isEqualTo: user!.email)
          .get();
      List<Note> pinnedNotes = [];
      List<Note> unpinnedNotes = [];
      for (var doc in querySnapshot.docs) {
        Note note = Note(
          docId: doc.id,
          title: aes.decryptData(doc['title']) ?? '',
          content: aes.decryptData(doc['content']) ?? '',
          day: aes.decryptData(doc['day']) ?? '',
          time: aes.decryptData(doc['time']) ?? '',
          pass: aes.decryptData(doc['pass']) ?? "",
          email: user.email ?? '',
          isPinner: doc['isPinned'] ?? false,
        );
        if (note.isPinner) {
          pinnedNotes.add(note);
        } else {
          unpinnedNotes.add(note);
        }
      }
      pinnedNotes.sort((a, b) => _compareDateTime(b.day, b.time, a.day, a.time));
      unpinnedNotes.sort((a, b) => _compareDateTime(b.day, b.time, a.day, a.time));
      setState(() {
        notes = [...pinnedNotes, ...unpinnedNotes];
      });
    } catch (e) {
      // Xử lý lỗi nếu có
      // ignore: avoid_print
      print('Error fetching notes: $e');
      rethrow;
    }
  }*/

  // int _compareDateTime(String day1, String time1, String day2, String time2) {
  //   DateTime dateTime1 = DateTime.parse('$day1 $time1');
  //   DateTime dateTime2 = DateTime.parse('$day2 $time2');
  //   return dateTime1.compareTo(dateTime2);
  // }
  //
  Future<void> updateNote(int index) async {
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
                id: listNotesDTO[indexNotes].id,
                email: user!.email,
                title: _titleController.text,
                content: _contentController.text,
                day: day,
                time: time,
                pass: passPin != "" ? passPin : "",
                isPinned: isPinned))) {
          setState(() {
            listNotesDTO[indexNotes].title = _titleController.text;
            listNotesDTO[indexNotes].content = _contentController.text;
            listNotesDTO[indexNotes].day = day;
            listNotesDTO[indexNotes].time = time;
            listNotesDTO[indexNotes].isPinned = isPinned;
            listNotesDTO[indexNotes].pass = passPin;
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

  /*Future<void> updateNote(int index) async {
    if (_contentController.text == "" || _titleController.text == "") {
      CustomSnackBar(context, 'Vui lòng nhập đủ thông tin!').show();
    } else {
      setState(() {
        saving = true;
      });
      try {
        String day = DateFormat("yyyy-MM-dd").format(DateTime.now());
        String time = DateFormat("HH:mm").format(DateTime.now());
        await FirebaseFirestore.instance
            .collection('Notes')
            .doc(notes[indexNotes].docId)
            .update({
          'title': aes.encryptData(_titleController.text),
          'content': aes.encryptData(_contentController.text),
          'day': aes.encryptData(day),
          'time': aes.encryptData(time),
          'isPinned': isPinned,
          'pass': passPin != "" ? aes.encryptData(passPin) : ""
        });
        setState(() {
          notes[indexNotes].title = _titleController.text;
          notes[indexNotes].content = _contentController.text;
          notes[indexNotes].day = day;
          notes[indexNotes].time = time;
          notes[indexNotes].isPinner = isPinned;
          notes[indexNotes].pass = passPin;
          saving = false;
          _upIconSave();
        });
        // ignore: use_build_context_synchronously
        CustomSnackBar(context, 'Đã lưu thành công!').show();
      } catch (e) {
        // ignore: use_build_context_synchronously
        CustomSnackBar(context, 'Lỗi! Vui lòng thử lại.').show();
        setState(() {
          saving = false;
        });
        rethrow;
      }
    }
  }*/

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

    controller.initialPage;
    _titleController = TextEditingController();
    _titleController.addListener(() {
      _upIconSave();
    });
    _contentController = TextEditingController();
    _contentController.addListener(_updateCharacterCount);
    isPinned = false;
    passPin = "";
    _startTimer();
    // _upIconSave();
  }

  @override
  void dispose() {
    _stopTimer();
    controller.dispose();
    _contentController.removeListener(_updateCharacterCount);
    _titleController.removeListener(() {
      _upIconSave();
    });
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timerSubscription =
        Stream.periodic(const Duration(seconds: 4)).listen((_) {
      setState(() {});
    });
  }

  void _stopTimer() {
    _timerSubscription?.cancel();
  }

  // Load icon Save
  void _upIconSave() {
    if (_contentController.text != listNotesDTO[indexNotes].content ||
        _titleController.text != listNotesDTO[indexNotes].title ||
        passPin != listNotesDTO[indexNotes].pass ||
        isPinned != listNotesDTO[indexNotes].isPinned) {
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
  void _enterPasswordDialog(int index, Function function) {
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
                    if (listNotesDTO[index].pass == pass) {
                      Navigator.of(context).pop();
                      function();
                    } else {
                      Navigator.of(context).pop();
                      CustomSnackBar(context, "Sai mật khẩu").show();
                    }
                  } else {
                    CustomSnackBar(context, "Mật khẩu không chứa khoảng trắng")
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
  Future<void> deleteNote(int id) async {
    try{
      if(await deleteNoteAPI(id)){
        // ignore: use_build_context_synchronously
        CustomSnackBar(context, "Xóa note thành công").show();
        setState(() {
          indexPage = 0;

          controller.jumpToPage(indexPage);
        });
      }else{
        // ignore: use_build_context_synchronously
        CustomSnackBar(context, "lỗi! Không xóa được note.").show();
      }
    }catch(e){
      // ignore: use_build_context_synchronously
      CustomSnackBar(context, "lỗi khi gọi api.").show();
    }
  }
// Hàm xóa note dựa trên docId
  /*void deleteNotef(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('Notes').doc(docId).delete();

      setState(() {
        indexPage = 0;

        controller.jumpToPage(indexPage);
      });
      // fetchNotes(user);
      // ignore: use_build_context_synchronously
      CustomSnackBar(context, "Xóa note thành công").show();
    } catch (e) {
      // ignore: avoid_print
      print('Lỗi khi xóa ghi chú: $e');
      // Xử lý lỗi nếu cần
    }
  }*/

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (indexPage > 0) {
          setState(() {
            indexPage = indexPage - 1;
          });
          controller.jumpToPage(indexPage);
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text(title)),
          leading: indexPage != 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    if (indexPage > 0) {
                      setState(() {
                        indexPage = indexPage - 1;
                      });
                      controller.jumpToPage(indexPage);
                    }
                  },
                )
              : null,
          actions: indexPage == 1
              ? [
                  if (isSave)
                    IconButton(
                      onPressed: () {
                        updateNote(indexNotes);
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
                          kTextColor, // Thiết lập màu sắc cho biểu tượng chấm
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
                          if (listNotesDTO[indexNotes].pass != "") {
                            _enterPasswordDialog(indexNotes, () {
                              showDeleteConfirmationDialog(context, () {
                                deleteNote(listNotesDTO[indexNotes].id);
                              });
                            });
                          } else {
                            showDeleteConfirmationDialog(context, () {
                              deleteNote(listNotesDTO[indexNotes].id);
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
                          leading: Icon(
                            isPinned ? Icons.push_pin_outlined : Icons.push_pin,
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
                          leading: Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          title: Text(
                            'Xóa',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
              : null,
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1.0), // Chiều cao của viền ngang
            child: Divider(
              height: 1, // Chiều cao của viền ngang
              color: Colors.grey, // Màu của viền ngang
            ),
          ),
        ),
        body: PageView(
            controller: controller,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              RefreshIndicator(
                onRefresh: () async {
                  await fetchNotesAPI();
                },
                child: Container(
                  color: kBackgroundColor,
                  child: listNotesDTO.isNotEmpty
                      ? ListView.builder(
                          itemCount: listNotesDTO.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              // Thêm margin cho khung ngoài của ListTile
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.white),
                                // Thiết lập viền cho khung ngoài của ListTile
                                borderRadius: BorderRadius.circular(
                                    8.0), // Bo góc cho khung ngoài của ListTile
                              ),
                              child: ListTile(
                                // ignore: sized_box_for_whitespace
                                title: Container(
                                  height: 40,
                                  child: Row(
                                    children: [
                                      if (listNotesDTO[index].pass != "")
                                        const Icon(
                                          Icons.lock,
                                          size: 20,
                                        ),
                                      Text(
                                        listNotesDTO[index].title.length <= 25
                                            ? listNotesDTO[index].title
                                            : '${listNotesDTO[index].title.substring(0, 25)}...',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
                                        ),
                                      ),
                                      if (listNotesDTO[index].isPinned)
                                        const Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Icon(Icons.push_pin_rounded),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 52, // 3 lines * 18 (font size)
                                      child: Text(
                                        listNotesDTO[index].pass != ""
                                            ? "***********"
                                            : listNotesDTO[index].content,
                                        style: const TextStyle(fontSize: 16),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(formatTimeAgo(listNotesDTO[index].day,
                                        listNotesDTO[index].time)),
                                  ],
                                ),
                                onTap: () {
                                  if (listNotesDTO[index].pass == "") {
                                    setState(() {
                                      indexNotes = index;
                                      _titleController.text =
                                          listNotesDTO[index].title;
                                      _contentController.text =
                                          listNotesDTO[index].content;
                                      indexPage = 1;
                                      isPinned = listNotesDTO[index].isPinned;
                                      passPin = listNotesDTO[index].pass;
                                      _upIconSave();
                                      controller.jumpToPage(indexPage);
                                    });
                                  } else {
                                    _enterPasswordDialog(index, () {
                                      setState(() {
                                        indexNotes = index;
                                        _titleController.text =
                                            listNotesDTO[index].title;
                                        _contentController.text =
                                            listNotesDTO[index].content;
                                        indexPage = 1;
                                        isPinned = listNotesDTO[index].isPinned;
                                        passPin = listNotesDTO[index].pass;
                                        controller.jumpToPage(indexPage);
                                      });
                                      _upIconSave();
                                    });
                                  }
                                },
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Text("No notes"),
                        ),
                ),
              ),
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
                              "${listNotesDTO.isNotEmpty ? DateFormat('MMMM dd HH:mm').format(DateTime.parse('${listNotesDTO[indexNotes].day} ${listNotesDTO[indexNotes].time}')) : ""}   |   $characters characters"),
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
            ]),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     // Thêm hàm để tạo ghi chú mới
        //   },
        //   child: Icon(Icons.add),
        // ),
      ),
    );
  }
}
