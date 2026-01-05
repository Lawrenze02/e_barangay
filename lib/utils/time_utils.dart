import 'package:intl/intl.dart';

String formatTime(String time24) {
  try {
    // Determine the format based on input length or content
    // Assuming input is HH:mm:ss or HH:mm
    final dt = DateFormat("HH:mm").parse(time24);
    return DateFormat("h:mm a").format(dt);
  } catch (e) {
    return time24; // Fallback if parsing fails
  }
}
