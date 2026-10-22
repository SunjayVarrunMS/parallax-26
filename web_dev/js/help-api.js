// a pretend server for the help desk. it waits a little, then saves to localStorage.

const messagesKey = 'parallax:messages';

async function submitContact(name, email, topic, message) {
  await wait(400);

  if (message.trim().length < 20) {
    throw new Error('Tell us a little more so we can help.');
  }

  const ticketId = makeId('tkt');
  const messages = readStore(messagesKey, []);
  messages.push({
    ticketId: ticketId,
    name: name,
    email: email,
    topic: topic,
    message: message,
    createdAt: new Date().toISOString(),
  });
  writeStore(messagesKey, messages);
  return { ticketId: ticketId };
}
