import 'package:flutter/material.dart';

const Color _accent = Color(0xFF493EE5);
const Color _progress = Color(0xFF635BFF);
const Color _ink = Color(0xFF191C1D);
const Color _body = Color(0xFF464555);
const Color _pending = Color(0xFF4D5C72);
const Color _icon = Color(0xFF94A3B8);
const Color _panel = Color(0xFFF3F4F5);
const Color _track = Color(0xFFEDEEEF);
const Color _pillGrey = Color(0xFFE7E8E9);
const Color _notePanel = Color(0x4CD3E4FE);

/// Lifecycle of an organizer's event, drives the card layout + status colour.
enum MyEventStatus { approved, pendingReview, completed }

/// Immutable view data for one row in the "My Events" list.
///
/// Placeholder data until the repository is wired; [ticketsSold] and [capacity]
/// drive the progress bar and percentage.
class MyEventItem {
  const MyEventItem({
    required this.title,
    required this.status,
    this.coverAsset,
    this.date = '',
    this.time = '',
    this.ticketsSold = 0,
    this.capacity = 0,
    this.registered = 0,
    this.note,
    this.subtitle,
    this.metaDate,
  });

  final String title;
  final MyEventStatus status;

  /// Optional bundled cover image; falls back to a gradient tile.
  final String? coverAsset;
  final String date;
  final String time;
  final int ticketsSold;
  final int capacity;
  final int registered;

  /// Compliance note rendered instead of the progress panel (pending review).
  final String? note;
  final String? subtitle;
  final String? metaDate;

  double get fillFraction =>
      capacity == 0 ? 0 : (ticketsSold / capacity).clamp(0.0, 1.0).toDouble();

  int get percent => (fillFraction * 100).round();
}

/// Shared cover artwork reused by every event card in this list.
const String _coverImage = 'assets/images/Global Tech Innovation Summit 2025.png';

const List<MyEventItem> kMyEvents = [
  MyEventItem(
    title: 'Global Tech Innovation Summit 2026',
    status: MyEventStatus.approved,
    coverAsset: _coverImage,
    date: 'Nov 15, 2026',
    time: '09:00 AM - 05:00 PM',
    ticketsSold: 420,
    capacity: 500,
    registered: 420,
  ),
  MyEventItem(
    title: 'Neon Horizons Music & Arts Festival',
    status: MyEventStatus.approved,
    coverAsset: _coverImage,
    date: 'Dec 02, 2026',
    time: '06:00 PM - 11:30 PM',
    ticketsSold: 420,
    capacity: 500,
    registered: 420,
  ),
  MyEventItem(
    title: 'Fintech & Web3 Leaders Masterclass',
    status: MyEventStatus.pendingReview,
    coverAsset: _coverImage,
    date: 'Dec 18, 2026',
    time: '10:00 AM - 02:00 PM',
    note: 'Awaiting standard venue compliance screening. '
        'Sales open instantly upon approval.',
  ),
  MyEventItem(
    title: 'Design Systems Conference 2024',
    status: MyEventStatus.completed,
    subtitle: 'Archive & Financial Summary Ready',
    metaDate: 'Oct 10, 2024',
  ),
];

/// Events tab body: section header plus the organizer's event cards.
class MyEventsTab extends StatelessWidget {
  final List<MyEventItem> events;
  final int totalCount;
  final VoidCallback? onSeeAll;

  const MyEventsTab({
    super.key,
    this.events = kMyEvents,
    this.totalCount = 24,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: events.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EventsHeader(total: totalCount, onSeeAll: onSeeAll),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _EventCard(item: events[index - 1]),
          );
        },
      ),
    );
  }
}

class _EventsHeader extends StatelessWidget {
  final int total;
  final VoidCallback? onSeeAll;

  const _EventsHeader({required this.total, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Events',
              style: TextStyle(
                color: _ink,
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.40,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _pillGrey,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '$total',
                style: const TextStyle(
                  color: _body,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                  letterSpacing: 0.60,
                ),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'See All',
            style: TextStyle(
              color: _accent,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.33,
              letterSpacing: 0.60,
            ),
          ),
        ),
      ],
    );
  }
}

/// Single event card, also reused by the Home tab's My Events feed.
class MyEventCard extends StatelessWidget {
  final MyEventItem item;

  const MyEventCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) => _EventCard(item: item);
}

class _EventCard extends StatelessWidget {
  final MyEventItem item;

  const _EventCard({required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.status == MyEventStatus.completed) {
      return _CompletedCard(item: item);
    }
    return _ActiveCard(item: item);
  }
}

/// Approved / pending-review card: cover, details, progress or note, footer.
class _ActiveCard extends StatelessWidget {
  final MyEventItem item;

  const _ActiveCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Cover(status: item.status, coverAsset: item.coverAsset),
          const SizedBox(height: 11),
          Text(
            item.title,
            style: const TextStyle(
              color: _ink,
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.38,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _MetaText(icon: Icons.calendar_today_rounded, text: item.date),
              const SizedBox(width: 12),
              _MetaText(icon: Icons.schedule_rounded, text: item.time),
            ],
          ),
          const SizedBox(height: 12),
          if (item.note != null)
            _NotePanel(note: item.note!)
          else
            _ProgressPanel(item: item),
          const SizedBox(height: 12),
          _CardFooter(status: item.status),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final MyEventStatus status;
  final String? coverAsset;

  const _Cover({required this.status, required this.coverAsset});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 144,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (coverAsset != null)
              Image.asset(coverAsset!, fit: BoxFit.cover, cacheWidth: 800)
            else
              const _CoverPlaceholder(),
            Positioned(
              left: 10,
              top: 10,
              child: _StatusPill(status: status),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4C3FD4), Color(0xFF14107A)],
        ),
      ),
      child: Center(
        child: Icon(Icons.celebration_rounded, size: 40, color: Color(0x66FFFFFF)),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final MyEventStatus status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool pending = status == MyEventStatus.pendingReview;
    final Color color = pending ? _pending : _accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(9999),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            pending ? 'Pending Review' : 'Approved',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.33,
              letterSpacing: 0.60,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _icon),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: _body,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.43,
          ),
        ),
      ],
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  final MyEventItem item;

  const _ProgressPanel({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Tickets Sold: ',
                      style: TextStyle(color: _ink),
                    ),
                    TextSpan(
                      text: '${item.ticketsSold}',
                      style: const TextStyle(color: _accent),
                    ),
                    TextSpan(
                      text: ' / ${item.capacity}',
                      style: const TextStyle(color: _ink),
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                    letterSpacing: 0.60,
                  ),
                ),
              ),
              Text(
                '${item.percent}%',
                style: const TextStyle(
                  color: _accent,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                  letterSpacing: 0.60,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              height: 8,
              color: _track,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: item.fillFraction,
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: _progress),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.people_alt_outlined, size: 14, color: _body),
              const SizedBox(width: 4),
              Text(
                '${item.registered} Registered',
                style: const TextStyle(
                  color: _body,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                  letterSpacing: 0.60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotePanel extends StatelessWidget {
  final String note;

  const _NotePanel({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _notePanel,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.info_outline_rounded, size: 15, color: _pending),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              note,
              style: const TextStyle(
                color: _body,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.33,
                letterSpacing: 0.60,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  final MyEventStatus status;

  const _CardFooter({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool pending = status == MyEventStatus.pendingReview;
    final Color color = pending ? _pending : _accent;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View Details',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                    letterSpacing: 0.60,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14, color: color),
              ],
            ),
          ),
        ),
        Row(
          children: [
            _CircleIconButton(icon: Icons.ios_share_rounded, onTap: () {}),
            if (!pending) ...[
              const SizedBox(width: 8),
              _CircleIconButton(icon: Icons.more_vert_rounded, onTap: () {}),
            ],
          ],
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _pillGrey,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 16, color: _body),
        ),
      ),
    );
  }
}

/// Compact card for a finished event: status + date, title, report action.
class _CompletedCard extends StatelessWidget {
  final MyEventItem item;

  const _CompletedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.90,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _pillGrey,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      color: _body,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.33,
                      letterSpacing: 0.60,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item.metaDate ?? '',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.40,
                        ),
                      ),
                      if (item.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle!,
                          style: const TextStyle(
                            color: _body,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  color: _track,
                  borderRadius: BorderRadius.circular(9999),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Report',
                            style: TextStyle(
                              color: _body,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 1.33,
                              letterSpacing: 0.60,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded, size: 16, color: _body),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x07000000),
          blurRadius: 20,
          offset: Offset(0, 4),
        ),
      ],
    );
