// a pretend server for workshop bookings. it waits a little, then saves to localStorage.

const bookingsKey = 'parallax:workshop-bookings';

function countConfirmed(bookings, workshopId) {
  let count = 0;
  for (const booking of bookings) {
    if (booking.workshopId === workshopId && booking.status === 'confirmed') {
      count = count + 1;
    }
  }
  return count;
}

// the workshops from data.js, with seatsTaken including confirmed bookings
async function listWorkshops() {
  await wait(400);
  const bookings = readStore(bookingsKey, []);
  const list = [];
  for (const workshop of workshops) {
    const copy = Object.assign({}, workshop);
    copy.seatsTaken = workshop.seatsTaken + countConfirmed(bookings, workshop.id);
    list.push(copy);
  }
  return list;
}

async function bookWorkshop(workshopId, name, email) {
  const workshop = workshops.find(function (item) {
    return item.id === workshopId;
  });
  if (!workshop) {
    throw new Error('That workshop does not exist.');
  }

  const bookings = readStore(bookingsKey, []);
  const cleanEmail = email.trim().toLowerCase();
  const already = bookings.find(function (item) {
    return (
      item.workshopId === workshopId &&
      item.email.toLowerCase() === cleanEmail &&
      item.status !== 'cancelled'
    );
  });
  if (already) {
    throw new Error('That email already has a booking for this workshop.');
  }

  const taken = workshop.seatsTaken + countConfirmed(bookings, workshopId);
  let status = 'waitlisted';
  if (taken < workshop.capacity) {
    status = 'confirmed';
  }

  await wait(400);

  const booking = {
    id: makeId('wsh'),
    workshopId: workshopId,
    name: name,
    email: email,
    status: status,
    createdAt: new Date().toISOString(),
  };
  const latest = readStore(bookingsKey, []);
  latest.push(booking);
  writeStore(bookingsKey, latest);
  return booking;
}

async function listBookings() {
  await wait(400);
  return readStore(bookingsKey, []);
}

// 1 for the first person waiting, 2 for the next, and so on
function getWaitlistPosition(bookings, booking) {
  let position = 0;
  for (const item of bookings) {
    if (item.workshopId === booking.workshopId && item.status === 'waitlisted') {
      position = position + 1;
    }
    if (item.id === booking.id) {
      return position;
    }
  }
  return 0;
}

async function cancelBooking(id) {
  await wait(400);

  const bookings = readStore(bookingsKey, []);
  const booking = bookings.find(function (item) {
    return item.id === id;
  });
  if (!booking) {
    throw new Error('Booking not found.');
  }
  if (booking.status === 'cancelled') {
    throw new Error('That booking is already cancelled.');
  }

  const hadSeat = booking.status === 'confirmed';
  booking.status = 'cancelled';

  if (hadSeat) {
    const next = bookings.find(function (item) {
      return item.workshopId === booking.workshopId && item.status === 'waitlisted';
    });
    if (next) {
      next.status = 'confirmed';
    }
  }

  writeStore(bookingsKey, bookings);
}
