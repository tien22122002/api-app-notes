

// ignore_for_file: file_names

class AccountDTO{
  late String _name;
  late String _email;
  late String _expiry;
  late int _numberExpiry;
  AccountDTO() {
    _name = ''; // hoặc có thể đặt giá trị mặc định khác tùy ý
    _email = '';
    _expiry = '';
    _numberExpiry = 0;
  }

  // ignore: unnecessary_getters_setters
  String get name => _name;
  set name(String value) {
    _name = value;
  }

  // ignore: unnecessary_getters_setters
  String get email => _email;
  set email(String value) {
    _email = value;
  }

  // ignore: unnecessary_getters_setters
  String get expiry => _expiry;
  set expiry(String value) {
    _expiry = value;
  }

  // ignore: unnecessary_getters_setters
  int get numberExpiry => _numberExpiry;
  set numberExpiry(int value) {
    _numberExpiry = value;
  }
  // Constructor
  // AccountDTO({
  //   required String name,
  //   required String email,
  //   required String expiry,
  //   required int numberExpiry,
  // })  : _name = name,
  //       _email = email,
  //       _expiry = expiry,
  //       _numberExpiry = numberExpiry;

}
class Note {
  final String docId;
  late  String title;
  late  String content;
  late  String day;
  late  String time;
  late  String pass;
  late  bool isPinner;
  final String email;

  Note(
      {required this.docId,
        required this.title,
        required this.content,
        required this.day,
        required this.time,
        required this.pass,
        required this.isPinner,
        required this.email});
}
