// small helpers that every screen can use

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// an error with a message we can show on screen
class ApiError implements Exception {
  ApiError(this.message);

  final String message;
}

// the text to show for an error, or a fallback
String errorMessage(Object error, String fallback) {
  if (error is ApiError && error.message != '') {
    return error.message;
  }
  return fallback;
}

// pause for a moment, like waiting for a real server
Future<void> wait(int ms) {
  return Future.delayed(Duration(milliseconds: ms));
}

// the time in the festival's time zone (Asia/Kolkata = UTC+5:30)
DateTime _festivalTime(String iso) {
  return DateTime.parse(iso).toUtc().add(const Duration(hours: 5, minutes: 30));
}

// "2026-11-20T11:00:00+05:30" -> "11:00 am" (festival time)
String formatTime(String iso) {
  return DateFormat('h:mm a').format(_festivalTime(iso)).toLowerCase();
}

// "2026-11-20T11:00:00+05:30" -> "Fri, 20 Nov"
String formatDate(String iso) {
  return DateFormat('EEE, d MMM').format(_festivalTime(iso));
}

// 0 -> "Free", 1500 -> "₹1,500"
String formatPrice(int amount) {
  if (amount == 0) {
    return 'Free';
  }
  return '₹${NumberFormat.decimalPattern('en_IN').format(amount)}';
}

// open a web link in the browser
Future<void> openLink(String url) async {
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (error) {
    debugPrint(error.toString());
  }
}
