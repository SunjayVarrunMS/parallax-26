// all the festival content lives here. edit this file to change what the app shows.

class Festival {
  const Festival({
    required this.name,
    required this.edition,
    required this.shortName,
    required this.tagline,
    required this.location,
    required this.dateLabel,
    required this.startsAt,
    required this.endsAt,
    required this.timezone,
  });

  final String name;
  final String edition;
  final String shortName;
  final String tagline;
  final String location;
  final String dateLabel;
  final String startsAt;
  final String endsAt;
  final String timezone;
}

class EventItem {
  const EventItem({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.day,
    required this.venueId,
    required this.startsAt,
    required this.endsAt,
    required this.fee,
    required this.maxTeamSize,
    required this.status,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final int day;
  final String venueId;
  final String startsAt;
  final String endsAt;
  final int fee;
  final int maxTeamSize;
  final String status;
}

// a workshop is an event with seats
class Workshop extends EventItem {
  const Workshop({
    required super.id,
    required super.title,
    required super.category,
    required super.description,
    required super.day,
    required super.venueId,
    required super.startsAt,
    required super.endsAt,
    required super.fee,
    required super.maxTeamSize,
    required super.status,
    required this.capacity,
    required this.seatsTaken,
  });

  final int capacity;
  final int seatsTaken;

  // the same workshop with a different number of seats taken
  Workshop withSeatsTaken(int seats) {
    return Workshop(
      id: id,
      title: title,
      category: category,
      description: description,
      day: day,
      venueId: venueId,
      startsAt: startsAt,
      endsAt: endsAt,
      fee: fee,
      maxTeamSize: maxTeamSize,
      status: status,
      capacity: capacity,
      seatsTaken: seats,
    );
  }
}

class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.description,
    required this.directionsUrl,
  });

  final String id;
  final String name;
  final String description;
  final String directionsUrl;
}

class MerchItem {
  const MerchItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.sizes,
    required this.stock,
    required this.tone,
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final int price;
  final List<String> sizes;
  final int stock;
  final String tone;

  // the same item with a different stock number
  MerchItem withStock(int newStock) {
    return MerchItem(
      id: id,
      name: name,
      category: category,
      description: description,
      price: price,
      sizes: sizes,
      stock: newStock,
      tone: tone,
    );
  }
}

class Sponsor {
  const Sponsor({required this.name, required this.mark, required this.blurb});

  final String name;
  final String mark;
  final String blurb;
}

const Festival festival = Festival(
  name: 'PARALLAX',
  edition: "PARALLAX '26",
  shortName: 'PLX',
  tagline: 'Same campus. New angle.',
  location: 'On campus',
  dateLabel: '20-22 November',
  startsAt: '2026-11-20T09:00:00+05:30',
  endsAt: '2026-11-22T22:00:00+05:30',
  timezone: 'Asia/Kolkata',
);

const List<EventItem> events = [
  EventItem(
    id: 'battle-of-the-bands',
    title: 'Battle of the bands',
    category: 'Culture',
    description: 'A borrowed amp. A very loud opinion. Your band gets the stage.',
    day: 1,
    venueId: 'main-stage',
    startsAt: '2026-11-20T17:00:00+05:30',
    endsAt: '2026-11-20T20:00:00+05:30',
    fee: 200,
    maxTeamSize: 6,
    status: 'open',
  ),
  EventItem(
    id: 'stand-up-showdown',
    title: 'Stand-up showdown',
    category: 'Culture',
    description:
        'Five minutes, one microphone. Hostel food is fair game, professors are not.',
    day: 3,
    venueId: 'open-air-theatre',
    startsAt: '2026-11-22T18:00:00+05:30',
    endsAt: '2026-11-22T20:00:00+05:30',
    fee: 0,
    maxTeamSize: 1,
    status: 'cancelled',
  ),
  EventItem(
    id: 'build-break-repeat',
    title: 'Build. Break. Repeat.',
    category: 'Tech',
    description: 'Bring a half-formed idea. Leave with something that works.',
    day: 2,
    venueId: 'tech-lab',
    startsAt: '2026-11-21T10:00:00+05:30',
    endsAt: '2026-11-21T18:00:00+05:30',
    fee: 150,
    maxTeamSize: 4,
    status: 'open',
  ),
  EventItem(
    id: 'open-mic-night',
    title: 'Open mic night',
    category: 'Culture',
    description: 'Poems, jokes, one song you only half know. Three minutes each.',
    day: 1,
    venueId: 'open-air-theatre',
    startsAt: '2026-11-20T19:00:00+05:30',
    endsAt: '2026-11-20T21:30:00+05:30',
    fee: 0,
    maxTeamSize: 1,
    status: 'open',
  ),
  EventItem(
    id: 'capture-the-flag',
    title: 'Capture the flag',
    category: 'Tech',
    description: 'Break into our practice servers. Politely. Points for style.',
    day: 1,
    venueId: 'tech-lab',
    startsAt: '2026-11-20T11:00:00+05:30',
    endsAt: '2026-11-20T16:00:00+05:30',
    fee: 100,
    maxTeamSize: 3,
    status: 'open',
  ),
  EventItem(
    id: 'street-dance-face-off',
    title: 'Street dance face-off',
    category: 'Culture',
    description: 'Two crews, one beat, no rehearsed excuses.',
    day: 2,
    venueId: 'main-stage',
    startsAt: '2026-11-21T16:00:00+05:30',
    endsAt: '2026-11-21T18:30:00+05:30',
    fee: 150,
    maxTeamSize: 6,
    status: 'full',
  ),
  EventItem(
    id: 'ten-minute-pitch',
    title: 'Ten minute pitch',
    category: 'Tech',
    description:
        'Explain your product before the timer does it for you. Judges are blunt.',
    day: 2,
    venueId: 'lecture-hall-complex',
    startsAt: '2026-11-21T11:00:00+05:30',
    endsAt: '2026-11-21T14:00:00+05:30',
    fee: 100,
    maxTeamSize: 3,
    status: 'open',
  ),
  EventItem(
    id: 'robo-soccer',
    title: 'Robo soccer',
    category: 'Tech',
    description: 'Wheels, wires and a ball. Whatever you build has to score.',
    day: 3,
    venueId: 'tech-lab',
    startsAt: '2026-11-22T10:00:00+05:30',
    endsAt: '2026-11-22T15:00:00+05:30',
    fee: 200,
    maxTeamSize: 5,
    status: 'open',
  ),
  EventItem(
    id: 'short-film-screening',
    title: 'Short film screening',
    category: 'Culture',
    description:
        'Ten student films, none longer than eight minutes. Vote on the way out.',
    day: 2,
    venueId: 'lecture-hall-complex',
    startsAt: '2026-11-21T19:00:00+05:30',
    endsAt: '2026-11-21T21:30:00+05:30',
    fee: 0,
    maxTeamSize: 2,
    status: 'open',
  ),
  EventItem(
    id: 'bake-off',
    title: 'The great campus bake-off',
    category: 'Culture',
    description:
        'Bring something edible and a good story. Judged warm, if possible.',
    day: 3,
    venueId: 'food-court',
    startsAt: '2026-11-22T13:00:00+05:30',
    endsAt: '2026-11-22T15:00:00+05:30',
    fee: 100,
    maxTeamSize: 2,
    status: 'open',
  ),
  EventItem(
    id: 'hack-the-campus',
    title: 'Hack the campus',
    category: 'Tech',
    description:
        'Six hours to fix one thing that annoys students every day. Ship it.',
    day: 3,
    venueId: 'tech-lab',
    startsAt: '2026-11-22T09:30:00+05:30',
    endsAt: '2026-11-22T15:30:00+05:30',
    fee: 150,
    maxTeamSize: 4,
    status: 'open',
  ),
  EventItem(
    id: 'closing-night-jam',
    title: 'Closing night jam',
    category: 'Culture',
    description:
        'Anyone with an instrument walks on. Nobody walks off until the lights go.',
    day: 3,
    venueId: 'main-stage',
    startsAt: '2026-11-22T19:00:00+05:30',
    endsAt: '2026-11-22T22:00:00+05:30',
    fee: 0,
    maxTeamSize: 6,
    status: 'open',
  ),
];

const List<Workshop> workshops = [
  Workshop(
    id: 'print-club',
    title: 'The print club',
    category: 'Workshop',
    description: 'Ink on your hands. A poster on your wall. Make a little mess.',
    day: 3,
    venueId: 'print-studio',
    startsAt: '2026-11-22T11:00:00+05:30',
    endsAt: '2026-11-22T13:00:00+05:30',
    fee: 0,
    maxTeamSize: 1,
    status: 'open',
    capacity: 30,
    seatsTaken: 18,
  ),
  Workshop(
    id: 'first-website',
    title: 'Your first website',
    category: 'Workshop',
    description:
        'Start with an empty file. Finish with a page you can send to your mother.',
    day: 1,
    venueId: 'tech-lab',
    startsAt: '2026-11-20T14:00:00+05:30',
    endsAt: '2026-11-20T16:30:00+05:30',
    fee: 0,
    maxTeamSize: 1,
    status: 'open',
    capacity: 30,
    seatsTaken: 29,
  ),
  Workshop(
    id: 'phone-photography',
    title: 'Phone photography',
    category: 'Workshop',
    description:
        'Light, framing and when to stop tapping the screen. Any phone works.',
    day: 1,
    venueId: 'open-air-theatre',
    startsAt: '2026-11-20T15:00:00+05:30',
    endsAt: '2026-11-20T17:00:00+05:30',
    fee: 0,
    maxTeamSize: 1,
    status: 'full',
    capacity: 30,
    seatsTaken: 30,
  ),
  Workshop(
    id: 'screen-printing',
    title: 'Screen printing basics',
    category: 'Workshop',
    description:
        'Pull your own tote bag print. Bring a bag you do not mind inking.',
    day: 2,
    venueId: 'print-studio',
    startsAt: '2026-11-21T10:00:00+05:30',
    endsAt: '2026-11-21T12:30:00+05:30',
    fee: 100,
    maxTeamSize: 1,
    status: 'open',
    capacity: 30,
    seatsTaken: 8,
  ),
  Workshop(
    id: 'speak-without-notes',
    title: 'Speak without notes',
    category: 'Workshop',
    description:
        'Stand up, say the thing, sit down. Easier than it sounds, for most people.',
    day: 2,
    venueId: 'lecture-hall-complex',
    startsAt: '2026-11-21T15:00:00+05:30',
    endsAt: '2026-11-21T17:00:00+05:30',
    fee: 0,
    maxTeamSize: 1,
    status: 'open',
    capacity: 30,
    seatsTaken: 24,
  ),
];

const String mapsSearch = 'https://www.google.com/maps/search/?api=1&query=';

const List<Venue> venues = [
  Venue(
    id: 'main-stage',
    name: 'Main Stage',
    description: 'The big one. Loud, lit and very hard to miss.',
    directionsUrl: '${mapsSearch}Main+Stage+Campus+Ground',
  ),
  Venue(
    id: 'tech-lab',
    name: 'Tech Lab',
    description: 'Long tables, plenty of sockets, questionable coffee.',
    directionsUrl: '${mapsSearch}Computer+Science+Lab+Block',
  ),
  Venue(
    id: 'print-studio',
    name: 'Print Studio',
    description: 'Ink, paper and one very tired press.',
    directionsUrl: '${mapsSearch}Design+Studio+Campus',
  ),
  Venue(
    id: 'lecture-hall-complex',
    name: 'Lecture Hall Complex',
    description: 'Tiered seats and working projectors. Mostly.',
    directionsUrl: '${mapsSearch}Lecture+Hall+Complex+Campus',
  ),
  Venue(
    id: 'open-air-theatre',
    name: 'Open Air Theatre',
    description: 'Stone steps, open sky. Bring a jacket for the evenings.',
    directionsUrl: '${mapsSearch}Open+Air+Theatre+Campus',
  ),
  Venue(
    id: 'food-court',
    name: 'Food Court',
    description: 'Where everyone ends up between events.',
    directionsUrl: '${mapsSearch}Food+Court+Campus',
  ),
];

const List<MerchItem> merch = [
  MerchItem(
    id: 'parallax-tee',
    name: 'Parallax tee',
    category: 'Apparel',
    description: 'Heavy cotton, boxy fit, one loud word on the back.',
    price: 499,
    sizes: ['S', 'M', 'L', 'XL'],
    stock: 40,
    tone: 'coral',
  ),
  MerchItem(
    id: 'night-shift-hoodie',
    name: 'Night shift hoodie',
    category: 'Apparel',
    description: 'Thick enough for the open air theatre after nine.',
    price: 1199,
    sizes: ['S', 'M', 'L', 'XL'],
    stock: 15,
    tone: 'ink',
  ),
  MerchItem(
    id: 'washed-cap',
    name: 'Washed cap',
    category: 'Accessories',
    description:
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore.',
    price: 349,
    sizes: [],
    stock: 25,
    tone: 'blue',
  ),
  MerchItem(
    id: 'canvas-tote',
    name: 'Canvas tote',
    category: 'Accessories',
    description: 'Fits a laptop, a lunch and the free things you will collect.',
    price: 299,
    sizes: [],
    stock: 30,
    tone: 'green',
  ),
  MerchItem(
    id: 'event-lanyard',
    name: 'Woven lanyard',
    category: 'Accessories',
    description: 'For your ID, your keys, or your ego.',
    price: 149,
    sizes: [],
    stock: 60,
    tone: 'coral',
  ),
  MerchItem(
    id: 'sticker-pack',
    name: 'Sticker pack',
    category: 'Stickers',
    description: 'Eight stickers for laptops, bottles and bad decisions.',
    price: 99,
    sizes: [],
    stock: 100,
    tone: 'blue',
  ),
  MerchItem(
    id: 'enamel-pin',
    name: 'Enamel pin',
    category: 'Accessories',
    description: 'Small, shiny and hard to find if you drop it.',
    price: 199,
    sizes: [],
    stock: 0,
    tone: 'green',
  ),
  MerchItem(
    id: 'festival-poster',
    name: 'Festival poster',
    category: 'Stickers',
    description: 'A2 print from the studio. Ships rolled, not folded.',
    price: 249,
    sizes: [],
    stock: 20,
    tone: 'ink',
  ),
];

const List<Sponsor> sponsors = [
  Sponsor(
    name: 'Inkwell Print Shop',
    mark: 'Iw',
    blurb: 'Posters, banners and last-minute lanyards, printed overnight.',
  ),
  Sponsor(
    name: 'Third Cup Café',
    mark: '3c',
    blurb: 'Keeping the tech lab awake with filter coffee since forever.',
  ),
  Sponsor(
    name: 'Spoke & Co. Bike Rental',
    mark: 'S&Co',
    blurb: 'Two wheels for the walk between the stage and the food court.',
  ),
  Sponsor(
    name: 'Lakeside Books',
    mark: 'Lb',
    blurb: 'Second-hand paperbacks and a very patient shopkeeper.',
  ),
  Sponsor(
    name: 'Brightwire Internet',
    mark: 'Bw',
    blurb: 'The reason the hackathon Wi-Fi has not fallen over. Yet.',
  ),
  Sponsor(
    name: 'Kiln & Clay Studio',
    mark: 'K&C',
    blurb: 'Pottery classes for people who think they have no patience.',
  ),
];
