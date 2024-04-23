import 'package:flutter/material.dart';
import 'package:notes_app/class/NotesDTO.dart';
import 'package:notes_app/screens/page_bottom/note_page.dart';
import 'package:notes_app/screens/page_bottom/page_add_notes.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime today;
  late CalendarFormat _calendarFormat;
  late List<NotesDTO> selectedDayEvents = [];

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    selectedDayEvents = _loadEventsForDay(today);
  }
  Future<void> deleteNote(NotesDTO note) async {
    try{
      if(await deleteNoteAPI(note.id)){
        selectedDayEvents = _loadEventsForDay(DateTime.parse(note.day));
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
  List<NotesDTO> _loadEventsForDay(DateTime day) {
    List<NotesDTO> eventsForDay = [];
    for (var event in listNotesDTO) {
      DateTime eventDate = DateTime.parse(
          event.day); // Chuyển đổi chuỗi ngày thành đối tượng DateTime
      if (isSameDay(eventDate, day)) {
        eventsForDay.add(event);
      }
    }
    return eventsForDay;
  }

  Widget _buildEventsList(List<NotesDTO> events) {
    events.sort((a, b) => a.time.compareTo(b.time));
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Column(
          children: [
            Row(
              children: [
                Text(
                  event.time,
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    if (event.pass == "") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotePage(
                                  note: event,
                                  updateNoteList: () {
                                    setState(() {
                                      selectedDayEvents =
                                          _loadEventsForDay(DateTime.parse(event.day));
                                    });
                                  },
                                )),
                      );
                    } else {
                      _enterPasswordDialog(event, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NotePage(
                                    note: event,
                                    updateNoteList: () {
                                      setState(() {
                                        selectedDayEvents =
                                            _loadEventsForDay(DateTime.parse(event.day));
                                      });
                                    },
                                  )),
                        );
                      });
                    }
                  },
                  icon: const Icon(Icons.remove_red_eye_outlined),
                  color: Colors.blue,
                  iconSize: 24.0,
                ),
                IconButton(
                  onPressed: () {
                    // Xử lý khi nhấn nút xóa
                  },
                  icon: const Icon(Icons.delete_forever_outlined),
                  color: Colors.red,
                  iconSize: 24.0,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: Text(
                        event.title,
                        maxLines: 1,
                        // Giới hạn tiêu đề chỉ hiển thị trên một dòng
                        overflow: TextOverflow.ellipsis,
                        // Hiển thị dấu ba chấm (...) khi tiêu đề quá dài
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5.0),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.0),
                      child: Text(
                        event.pass == "" ? event.content : "***********",
                        maxLines: 2,
                        // Giới hạn nội dung chỉ hiển thị trong ba dòng
                        overflow: TextOverflow.ellipsis,
                        // Hiển thị dấu ba chấm (...) khi nội dung quá dài
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1.0,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 10.0),
          ],
        );
      },
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      today = selectedDay;
      selectedDayEvents = _loadEventsForDay(selectedDay);
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      selectedDayEvents = _loadEventsForDay(today);
    });
  }

  void _enterPasswordDialog(dynamic events, Function function) {
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
                    if (events['pass'] == pass) {
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

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    String formattedDate = dateFormat.format(today);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: RefreshIndicator(
        onRefresh: () async {
          // Load lại dữ liệu khi vuốt xuống
          await _handleRefresh();
        },
        child: Column(
          children: [
            // ignore: avoid_unnecessary_containers
            Container(
              child: TableCalendar(
                locale: 'vi_VN',
                rowHeight: 43,
                selectedDayPredicate: (day) => isSameDay(day, today),
                focusedDay: today,
                firstDay: DateTime(2023),
                lastDay: DateTime(2100),
                onDaySelected: _onDaySelected,
                onPageChanged: (focusedDay) {
                  today = focusedDay;
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarFormat: _calendarFormat,
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                ),
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                eventLoader: _loadEventsForDay,
              ),
            ),
            const SizedBox(height: 8.0),
            Divider(
              height: 1.0,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 10.0),
            // ignore: unnecessary_brace_in_string_interps
            Text(
              "Ngày $formattedDate",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  fontSize: 18),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: _buildEventsList(selectedDayEvents),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
