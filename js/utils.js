// small helpers that every page can use

// pause for a moment, like waiting for a real server
function wait(ms) {
  return new Promise(function (resolve) {
    setTimeout(resolve, ms);
  });
}

// "2026-11-20T11:00:00+05:30" -> "11:00 am" (festival time)
function formatTime(iso) {
  const formatter = new Intl.DateTimeFormat('en-IN', {
    hour: 'numeric',
    minute: '2-digit',
    timeZone: festival.timezone,
  });
  return formatter.format(new Date(iso));
}

// "2026-11-20T11:00:00+05:30" -> "Fri, 20 Nov"
function formatDate(iso) {
  const formatter = new Intl.DateTimeFormat('en-IN', {
    weekday: 'short',
    day: 'numeric',
    month: 'short',
    timeZone: festival.timezone,
  });
  return formatter.format(new Date(iso));
}

// 0 -> "Free", 1500 -> "₹1,500"
function formatPrice(amount) {
  if (amount === 0) {
    return 'Free';
  }
  return '₹' + amount.toLocaleString('en-IN');
}

// read a value from the address bar, like ?event=capture-the-flag
function getParam(name) {
  const params = new URLSearchParams(window.location.search);
  return params.get(name);
}
