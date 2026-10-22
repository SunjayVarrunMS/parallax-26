// a pretend server for registrations. it waits a little, then saves to shared_preferences.

import '../data.dart';
import '../store.dart';
import '../utils.dart';

const String registrationsKey = 'parallax:registrations';

Future<List<Json>> listRegistrations() async {
  await wait(400);
  return readList(registrationsKey);
}

Future<Json> createRegistration({
  required String eventId,
  required String participantName,
  required String email,
  required String phone,
  required List<String> teammates,
  required int fee,
}) async {
  await wait(400);

  final matches = events.where((item) => item.id == eventId);
  if (matches.isEmpty) {
    throw ApiError('That event does not exist.');
  }
  final event = matches.first;
  if (teammates.length > event.maxTeamSize) {
    throw ApiError('Teams for this event can have at most ${event.maxTeamSize} people.');
  }

  final registration = <String, dynamic>{
    'id': makeId('reg'),
    'eventId': eventId,
    'participantName': participantName,
    'email': email,
    'phone': phone,
    'teammates': teammates,
    'fee': fee,
    'status': 'confirmed',
    'createdAt': DateTime.now().toUtc().toIso8601String(),
  };

  final registrations = readList(registrationsKey);
  registrations.add(registration);
  writeStore(registrationsKey, registrations);
  return registration;
}

Future<void> cancelRegistration(String id) async {
  await wait(400);

  final registrations = readList(registrationsKey);
  final matches = registrations.where((item) => item['id'] == id);
  if (matches.isEmpty) {
    throw ApiError('Registration not found.');
  }

  matches.first['status'] = 'cancelled';
  writeStore(registrationsKey, registrations);
}
