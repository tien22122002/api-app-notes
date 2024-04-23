import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:notes_app/AES/AES.dart';
import 'package:notes_app/class/user_clientdto.dart';
import 'package:notes_app/main.dart';

class NotesDTO {
  late int id;
  late String? email;
  late String title;
  late String content;
  late String day;
  late String time;
  late String pass;
  late bool isPinned;

  NotesDTO({
    required this.id,
    required this.email,
    required this.title,
    required this.content,
    required this.day,
    required this.time,
    required this.pass,
    required this.isPinned,
  });
  factory NotesDTO.fromJson(Map<String, dynamic> json, String uid) {
    AES aes = AES(uid);
    return NotesDTO(
      id: json['noteId'],
      email: json['email'],
      title: aes.decryptData(json['title']),
      content: aes.decryptData(json['content']),
      day: aes.decryptData(json['day']),
      time: aes.decryptData(json['time']),
      pass: json['pass'] != "" ? aes.decryptData(json['pass']): "" ,
      isPinned: json['isPinned'],
    );
  }
  Map<String, dynamic> toJson(String uid) {
    AES aes = AES(uid);
    return {
      'noteId': id,
      'email': email,
      'title': aes.encryptData(title),
      'content': aes.encryptData(content),
      'day': aes.encryptData(day),
      'time': aes.encryptData(time),
      'pass': pass != ""? aes.encryptData(pass): "",
      'isPinned': isPinned,
    };
  }
}
//Khởi tạo danh sách notes
late List<NotesDTO> listNotesDTO = [];
// lấy danh sách notes từ api
Future<void> fetchNotesAPI() async {
  User? user = FirebaseAuth.instance.currentUser;
  if(user != null){
    // ignore: unnecessary_null_comparison
    if(userClientDTOMain.email != null || userClientDTOMain.email != ""){
      try{

        List<NotesDTO> list = await getNotes(user.uid, userClientDTOMain.email);
        await loadListNote(list);
      } catch (e){
        print("Error: $e");
      }
    }
  }
}
// Future<void> deleteNoteInListnotes(int i) async {
//   listNotesDTO.removeAt(i);
//   loadListNote(listNotesDTO);
// }
//sắp xếp danh sách notes
Future<void> loadListNote(List<NotesDTO> list) async {
  List<NotesDTO> listIsPinned = [];
  List<NotesDTO> listIsNotPinned = [];
  for(var notes in list){
    if(notes.isPinned){
      listIsPinned.add(notes);
    }else{
      listIsNotPinned.add(notes);
    }

  }
  listIsPinned.sort((a, b) => _compareDateTime(b.day, b.time, a.day, a.time));
  listIsNotPinned.sort((a, b) => _compareDateTime(b.day, b.time, a.day, a.time));
  listNotesDTO = [...listIsPinned,...listIsNotPinned];
}
// sắp xếp giảm dần theo thời gian
int _compareDateTime(String day1, String time1, String day2, String time2) {
  DateTime dateTime1 = DateTime.parse('$day1 $time1');
  DateTime dateTime2 = DateTime.parse('$day2 $time2');
  return dateTime1.compareTo(dateTime2);
}


//API get List Notes
Future<List<NotesDTO>> getNotes(String uid,String email) async {
  final response = await http.get(Uri.parse('$URL_API/api/Notes/$email'));

  if (response.statusCode == 200) {
    Iterable jsonResponse = jsonDecode(response.body);
    List<NotesDTO> notesList = jsonResponse.map((model) => NotesDTO.fromJson(model, uid)).toList();
    return notesList;
  } else {
    throw Exception('Failed to load notes');
  }
}

Future<bool> addNote(String uid, NotesDTO note) async {
  final response = await http.post(
    Uri.parse('$URL_API/api/Notes'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(note.toJson(uid)),
  );

  if (response.statusCode == 200) {

    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to add note');
  }
}

Future<bool> updateNoteAPI(String uid, NotesDTO note) async {
  final response = await http.put(
    Uri.parse('$URL_API/api/Notes'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(note.toJson(uid)),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to update note');
  }
}

Future<bool> deleteNoteAPI(int id) async {
  final response = await http.delete(Uri.parse('$URL_API/api/Notes/$id'));

  if (response.statusCode == 200) {
    bool check = jsonDecode(response.body);
    if(check){
      listNotesDTO.removeWhere((note) => note.id == id);
      await loadListNote(listNotesDTO);
    }
    return check;
  } else {
    throw Exception('Failed to delete note');
  }
}
