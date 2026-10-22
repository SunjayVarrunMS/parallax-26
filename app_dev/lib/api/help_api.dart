// a pretend server for the help desk. it waits a little, then saves to shared_preferences.

import '../store.dart';
import '../utils.dart';

const String messagesKey = 'parallax:messages';

Future<Json> submitContact(String name, String email, String topic, String message) async {
  await wait(400);

  if (message.trim().length < 20) {
    throw ApiError('Tell us a little more so we can help.');
  }

  final ticketId = makeId('tkt');
  final messages = readList(messagesKey);
  messages.add({
    'ticketId': ticketId,
    'name': name,
    'email': email,
    'topic': topic,
    'message': message,
    'createdAt': DateTime.now().toUtc().toIso8601String(),
  });
  writeStore(messagesKey, messages);
  return {'ticketId': ticketId};
}
