import 'package:flutter/material.dart';

import 'my_events_tab.dart';

const Color _primaryBlue = Color(0xFF084DFB);
const Color _titleColor = Color(0xFF191C1D);
const Color _bodyColor = Color(0xFF464555);
const Color _headingColor = Color(0xFF111827);

/// Total events shown in the section pills (placeholder until data is wired).
const int _totalEvents = 24;

/// Home tab: greeting, subscription card, primary action, stats and events.
class HomeDashboardTab extends StatelessWidget {
  final VoidCallback onManageSubscription;
  final VoidCallback onCreateEvent;
  final VoidCallback onSeeAllEvents;

  const HomeDashboardTab({
    super.key,
    required this.onManageSubscription,
    required this.onCreateEvent,
    required this.onSeeAllEvents,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _GreetingHeader(),
                const SizedBox(height: 20),
                _SubscriptionCard(onManage: onManageSubscription),
                const SizedBox(height: 20),
                _CreateEventButton(onPressed: onCreateEvent),
                const SizedBox(height: 24),
                const _SectionTitleRow(
                  title: 'Overview Performance',
                  trailing: 'Past 30 Days',
                ),
                const SizedBox(height: 8),
                const _StatsRow(),
                const SizedBox(height: 24),
                _MyEventsHeader(count: _totalEvents, onSeeAll: onSeeAllEvents),
                const SizedBox(height: 12),
                for (int i = 0; i < kMyEvents.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  MyEventCard(item: kMyEvents[i]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Evening, Mr. Rahman 👋',
                style: TextStyle(
                  color: _headingColor,
                  fontSize: 24,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: _bodyColor),
                  SizedBox(width: 4),
                  Text(
                    'New York, NY',
                    style: TextStyle(
                      color: _titleColor,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                      letterSpacing: -0.35,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(Icons.notifications_none_rounded, size: 24, color: _titleColor),
        ),
      ],
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final VoidCallback onManage;

  const _SubscriptionCard({required this.onManage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 8,
                          height: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _primaryBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'SUBSCRIPTION ACTIVE',
                          style: TextStyle(
                            color: _primaryBlue,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 1.33,
                            letterSpacing: 0.30,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Organizer Pro (6 Months)',
                      style: TextStyle(
                        color: _titleColor,
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Renews Apr 24, 2025',
                      style: TextStyle(
                        color: _bodyColor,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Material(
                color: _primaryBlue,
                borderRadius: BorderRadius.circular(9999),
                child: InkWell(
                  onTap: onManage,
                  borderRadius: BorderRadius.circular(9999),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Manage',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 1.33,
                            letterSpacing: 0.6,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(Icons.verified_outlined, size: 16, color: _primaryBlue),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Unlimited event creation & instant payouts active',
                  style: TextStyle(
                    color: _bodyColor,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateEventButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateEventButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F635BFF),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
          label: const Text(
            'Create New Event',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitleRow extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionTitleRow({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _titleColor,
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          trailing,
          style: const TextStyle(
            color: _bodyColor,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1.33,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _StatCard(label: 'Total Events', value: '24')),
        SizedBox(width: 10),
        Expanded(child: _StatCard(label: 'Running', value: '3')),
        SizedBox(width: 10),
        Expanded(child: _StatCard(label: 'Pending', value: '2')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _bodyColor,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.33,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: _titleColor,
              fontSize: 28,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.21,
              letterSpacing: -0.28,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyEventsHeader extends StatelessWidget {
  final int count;
  final VoidCallback onSeeAll;

  const _MyEventsHeader({required this.count, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'My Events',
              style: TextStyle(
                color: _titleColor,
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE7E8E9),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: _bodyColor,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                  letterSpacing: 0.6,
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
              color: _primaryBlue,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.33,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}
