// a pretend server for registrations. it waits a little, then saves to localStorage.

const registrationsKey = 'parallax:registrations';

async function listRegistrations() {
  await wait(400);
  return readStore(registrationsKey, []);
}

// data: { eventId, participantName, email, phone, teammates, fee }
async function createRegistration(data) {
  await wait(400);

  const event = events.find(function (item) {
    return item.id === data.eventId;
  });
  if (!event) {
    throw new Error('That event does not exist.');
  }
  if (data.teammates.length > event.maxTeamSize) {
    throw new Error('Teams for this event can have at most ' + event.maxTeamSize + ' people.');
  }

  const registration = {
    id: makeId('reg'),
    eventId: data.eventId,
    participantName: data.participantName,
    email: data.email,
    phone: data.phone,
    teammates: data.teammates,
    fee: data.fee,
    status: 'confirmed',
    createdAt: new Date().toISOString(),
  };

  const registrations = readStore(registrationsKey, []);
  registrations.push(registration);
  writeStore(registrationsKey, registrations);
  return registration;
}

async function cancelRegistration(id) {
  await wait(400);

  const registrations = readStore(registrationsKey, []);
  const registration = registrations.find(function (item) {
    return item.id === id;
  });
  if (!registration) {
    throw new Error('Registration not found.');
  }

  registration.status = 'cancelled';
  writeStore(registrationsKey, registrations);
}
