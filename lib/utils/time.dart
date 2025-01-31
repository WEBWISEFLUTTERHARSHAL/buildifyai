import "package:intl/intl.dart";

String timeAgo(String dateTime) {
  final time = DateTime.parse(dateTime);
  final Duration diff = DateTime.now().difference(time);

  if (diff.inSeconds < 60) {
    return 'just now';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
  } else if (diff.inHours < 24) {
    return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  } else if (diff.inDays < 7) {
    return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  } else {
    return DateFormat.yMMMd().format(time); // Example: 'Sep 5, 2024'
  }
}

String formatDateTimeToTime(DateTime dateTime) {
  return DateFormat('HH:mm').format(dateTime);
}
