// a pretend server for workshop bookings. it waits a little, then saves to shared_preferences.

import '../data.dart';
import '../store.dart';
import '../utils.dart';

const String bookingsKey = 'parallax:workshop-bookings';

int countConfirmed(List<Json> bookings, String workshopId) {
  int count = 0;
  for (final booking in bookings) {
    if (booking['workshopId'] == workshopId && booking['status'] == 'confirmed') {
      count = count + 1;
    }
  }
  return count;
}

// the workshops from data.dart, with seatsTaken including confirmed bookings
Future<List<Workshop>> listWorkshops() async {
  await wait(400);
  final bookings = readList(bookingsKey);
  final list = <Workshop>[];
  for (final workshop in workshops) {
    list.add(workshop.withSeatsTaken(workshop.seatsTaken + countConfirmed(bookings, workshop.id)));
  }
  return list;
}

Future<Json> bookWorkshop(String workshopId, String name, String email) async {
  final matches = workshops.where((item) => item.id == workshopId);
  if (matches.isEmpty) {
    throw ApiError('That workshop does not exist.');
  }
  final workshop = matches.first;

  final bookings = readList(bookingsKey);
  final cleanEmail = email.trim().toLowerCase();
  final already = bookings.where((item) {
    return item['workshopId'] == workshopId &&
        (item['email'] as String).toLowerCase() == cleanEmail &&
        item['status'] != 'cancelled';
  });
  if (already.isNotEmpty) {
    throw ApiError('That email already has a booking for this workshop.');
  }

  final taken = workshop.seatsTaken + countConfirmed(bookings, workshopId);
  String status = 'waitlisted';
  if (taken < workshop.capacity) {
    status = 'confirmed';
  }

  await wait(400);

  final booking = <String, dynamic>{
    'id': makeId('wsh'),
    'workshopId': workshopId,
    'name': name,
    'email': email,
    'status': status,
    'createdAt': DateTime.now().toUtc().toIso8601String(),
  };
  final latest = readList(bookingsKey);
  latest.add(booking);
  writeStore(bookingsKey, latest);
  return booking;
}

Future<List<Json>> listBookings() async {
  await wait(400);
  return readList(bookingsKey);
}

// 1 for the first person waiting, 2 for the next, and so on
int getWaitlistPosition(List<Json> bookings, Json booking) {
  int position = 0;
  for (final item in bookings) {
    if (item['workshopId'] == booking['workshopId'] && item['status'] == 'waitlisted') {
      position = position + 1;
    }
    if (item['id'] == booking['id']) {
      return position;
    }
  }
  return 0;
}

Future<void> cancelBooking(String id) async {
  await wait(400);

  final bookings = readList(bookingsKey);
  final matches = bookings.where((item) => item['id'] == id);
  if (matches.isEmpty) {
    throw ApiError('Booking not found.');
  }
  final booking = matches.first;
  if (booking['status'] == 'cancelled') {
    throw ApiError('That booking is already cancelled.');
  }

  final hadSeat = booking['status'] == 'confirmed';
  booking['status'] = 'cancelled';

  if (hadSeat) {
    final waiting = bookings.where((item) {
      return item['workshopId'] == booking['workshopId'] && item['status'] == 'waitlisted';
    });
    if (waiting.isNotEmpty) {
      waiting.first['status'] = 'confirmed';
    }
  }

  writeStore(bookingsKey, bookings);
}
