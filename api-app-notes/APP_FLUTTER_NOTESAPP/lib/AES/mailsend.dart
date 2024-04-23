import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart'; // Hoặc SMTP server khác

// Hàm để gửi mã OTP qua email
class SendMail {
  static Future<bool> sendOtpEmail(String? email, String otp) async {
    String username = 'dangtien.4591@gmail.com'; // Thay bằng địa chỉ email của bạn
    String password = 'gcershrshjejufhc'; // Thay bằng mật khẩu email của bạn

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Notes App')
      ..recipients.add(email) // Địa chỉ email người nhận
      ..subject = 'Verification PIN' // Tiêu đề email
      ..text = 'Your verification PIN is: $otp'; // Nội dung email

    try {
      final sendReport = await send(message, smtpServer);
      // ignore: avoid_print
      print('Email sent: ${sendReport.toString()}');
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('Error sending email: $e');
      return false;
    }
  }
}
