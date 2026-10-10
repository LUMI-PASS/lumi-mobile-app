/// What can be laid between two runs of "Near you" cards on the home feed.
///
/// The order here is the order they are dealt in — see [layoutNearYou].
enum HomeInsert {
  inviteBanner,
  categoryTiles,
  trialBand,
  coinBanner,
  centres,
  discountBand,
  savedBanner,
  ad,
}

/// One row of the "Near you" part of the feed: a card, or something that
/// interrupts the cards.
sealed class HomeFeedSlot {
  const HomeFeedSlot();
}

/// The [index]-th entry of the near list.
class HomeNearSlot extends HomeFeedSlot {
  const HomeNearSlot(this.index);

  final int index;
}

/// An interruption.
class HomeInsertSlot extends HomeFeedSlot {
  const HomeInsertSlot(this.insert);

  final HomeInsert insert;
}

/// How many cards run before the next interruption, in turn. Never more than
/// three while there is still something to interrupt with.
const List<int> homeNearRunLengths = [3, 3, 2];

/// "Near you" cut into short runs with one of [available] after each.
///
/// A pure function of its two arguments, so the feed is the same on every
/// build and a page of cards arriving at the bottom never moves what is
/// already above it — the rows it adds are strictly appended.
///
/// Each insert is dealt ONCE, in order. When they run out the rest of the
/// list is plain cards: the same three banners coming round again every few
/// rows read as nagging, not as variety. Empty, and the result is simply the
/// cards.
///
/// An insert follows a FULL run only, and never the last card: either more
/// cards are about to land, or the list is over and an insert there would be
/// a banner selling to nobody.
List<HomeFeedSlot> layoutNearYou(int nearCount, List<HomeInsert> available) {
  final slots = <HomeFeedSlot>[];
  var run = 0;
  var inRun = 0;
  var next = 0;
  for (var i = 0; i < nearCount; i++) {
    slots.add(HomeNearSlot(i));
    if (next >= available.length) continue;
    inRun++;
    if (inRun < homeNearRunLengths[run % homeNearRunLengths.length]) continue;
    inRun = 0;
    run++;
    if (i == nearCount - 1) continue;
    slots.add(HomeInsertSlot(available[next]));
    next++;
  }
  return slots;
}
