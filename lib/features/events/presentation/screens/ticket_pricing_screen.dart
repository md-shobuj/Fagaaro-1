import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';

const Color _primaryBlue = Color(0xFF084DFB);
const Color _ink = Color(0xFF0F172A);
const Color _muted = Color(0xFF64748B);
const Color _softGrey = Color(0xFFF3F4F5);
const Color _softPurple = Color(0xFFF4F3FF);
const Color _chipGrey = Color(0xFFEDEEEF);
const Color _infoBlue = Color(0x66DAE2FD);

const List<String> _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const List<String> _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

/// Formatting helpers shared by the summary tiles on this step.
abstract class _Fmt {
  static String monthShort(int month) => _monthNames[month - 1].substring(0, 3);

  static String dateLong(DateTime d) =>
      '${_weekdayNames[d.weekday - 1]}, ${_monthNames[d.month - 1]} ${d.day}, ${d.year}';

  static String dateShortYear(DateTime d) =>
      '${monthShort(d.month)} ${d.day}, ${d.year}';

  /// [minutes] is minutes since midnight.
  static String time(int minutes) {
    final int h24 = minutes ~/ 60;
    final int m = minutes % 60;
    final int h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} '
        '${h24 < 12 ? 'AM' : 'PM'}';
  }

  static String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
}

/// Step 3 of event creation: ticket price, capacity and the sales window.
class TicketPricingScreen extends StatefulWidget {
  const TicketPricingScreen({
    super.key,
    this.eventName = 'Global Tech Innovation Summit 2025',
    this.date,
    this.startMinutes = 9 * 60,
    this.endMinutes = 17 * 60,
  });

  final String eventName;
  final DateTime? date;
  final int startMinutes;
  final int endMinutes;

  @override
  State<TicketPricingScreen> createState() => _TicketPricingScreenState();
}

class _TicketPricingScreenState extends State<TicketPricingScreen> {
  static const int _capacityStep = 50;
  static const int _minCapacity = 0;
  static const List<int> _priceCentsOptions = [0, 4900, 9900, 14900, 19900];
  static const double _platformFeeRate = 0.05;

  late final DateTime _date;
  int _priceCents = 9900;
  int _capacity = 500;

  @override
  void initState() {
    super.initState();
    final DateTime now = widget.date ?? DateTime.now();
    _date = DateTime(now.year, now.month, now.day);
  }

  int get _feeCents => (_priceCents * _platformFeeRate).round();
  int get _organizerCents => _priceCents - _feeCents;
  DateTime get _salesWindowEnd => DateTime(_date.year + 1, _date.month, _date.day);

  void _shiftCapacity(int delta) {
    final int next = _capacity + delta;
    if (next < _minCapacity) return;
    setState(() => _capacity = next);
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.homePath);
    }
  }

  void _onReview() {
    context.push(
      AppRouter.reviewEventPath,
      extra: <String, Object>{
        'priceCents': _priceCents,
        'capacity': _capacity,
        'date': _date,
        'startMinutes': widget.startMinutes,
        'endMinutes': widget.endMinutes,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
          onPressed: _onBack,
        ),
        title: const Text(
          'Create Event',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StepHeader(eventName: widget.eventName),
                  const SizedBox(height: 24),
                  _PriceCard(
                    priceCents: _priceCents,
                    organizerCents: _organizerCents,
                    feeCents: _feeCents,
                    options: _priceCentsOptions,
                    onSelect: (c) => setState(() => _priceCents = c),
                  ),
                  const SizedBox(height: 16),
                  _CapacityCard(
                    capacity: _capacity,
                    salesWindowEnd: _salesWindowEnd,
                    startMinutes: widget.startMinutes,
                    onMinus: () => _shiftCapacity(-_capacityStep),
                    onPlus: () => _shiftCapacity(_capacityStep),
                  ),
                  const SizedBox(height: 16),
                  const _DigitalEntryCard(),
                  const SizedBox(height: 16),
                  _SummaryCard(
                    priceCents: _priceCents,
                    capacity: _capacity,
                    date: _date,
                    startMinutes: widget.startMinutes,
                    endMinutes: widget.endMinutes,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _BackButton(onPressed: _onBack),
                      const SizedBox(width: 12),
                      // Review Event is the primary action, so it takes the rest.
                      Expanded(child: _ReviewButton(onPressed: _onReview)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String eventName;

  const _StepHeader({required this.eventName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _softPurple,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_offer_rounded, size: 12, color: _primaryBlue),
              SizedBox(width: 6),
              Text(
                'Tickets & Pricing',
                style: TextStyle(
                  color: _primaryBlue,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ticket & Pricing',
          style: TextStyle(
            color: _ink,
            fontSize: 28,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.21,
            letterSpacing: -0.70,
          ),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              color: _muted,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.63,
            ),
            children: [
              const TextSpan(
                text: 'Set your event ticket price, currency, and attendee capacity for ',
              ),
              TextSpan(
                text: eventName,
                style: const TextStyle(color: _ink),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ],
    );
  }
}

/// White rounded card shared by the sections on this step.
class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }
}

/// Muted fill used for the grouped rows inside a card.
class _Inset extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _Inset({required this.child, this.padding = const EdgeInsets.all(12)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _softGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _muted,
        fontSize: 12,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.60,
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final int priceCents;
  final int organizerCents;
  final int feeCents;
  final List<int> options;
  final ValueChanged<int> onSelect;

  const _PriceCard({
    required this.priceCents,
    required this.organizerCents,
    required this.feeCents,
    required this.options,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel('BASE TICKET PRICE'),
              _InstantPayoutsBadge(),
            ],
          ),
          const SizedBox(height: 12),
          _Inset(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '\$',
                      style: TextStyle(
                        color: _primaryBlue,
                        fontSize: 32,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        letterSpacing: -0.80,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (priceCents / 100).toStringAsFixed(2),
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 48,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.17,
                        letterSpacing: -1.20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'per attendee ticket',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                    letterSpacing: 0.60,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final int cents in options)
                _PriceChip(
                  label: cents == 0 ? 'Free' : '\$${cents ~/ 100}',
                  selected: cents == priceCents,
                  onTap: () => onSelect(cents),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _Inset(
            child: Column(
              children: [
                _BreakdownRow(
                  label: 'Organizer receives',
                  value: _Fmt.money(organizerCents),
                  valueColor: _ink,
                  valueWeight: FontWeight.w600,
                ),
                const SizedBox(height: 6),
                _BreakdownRow(
                  label: 'Platform fee (5%)',
                  value: _Fmt.money(feeCents),
                  valueColor: _muted,
                  valueWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstantPayoutsBadge extends StatelessWidget {
  const _InstantPayoutsBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _softPurple,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 12, color: _primaryBlue),
          SizedBox(width: 4),
          Text(
            'Instant Payouts',
            style: TextStyle(
              color: _primaryBlue,
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.82,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PriceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _primaryBlue : _softGrey,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.white : _ink,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            height: 1.33,
            letterSpacing: 0.60,
          ),
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final FontWeight valueWeight;

  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.33,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: valueWeight,
            height: 1.33,
          ),
        ),
      ],
    );
  }
}

class _CapacityCard extends StatelessWidget {
  final int capacity;
  final DateTime salesWindowEnd;
  final int startMinutes;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _CapacityCard({
    required this.capacity,
    required this.salesWindowEnd,
    required this.startMinutes,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.grid_view_rounded, size: 16, color: _primaryBlue),
              ),
              const SizedBox(width: 8),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Capacity & Limits',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      height: 1.40,
                    ),
                  ),
                  Text(
                    'Manage venue thresholds',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Inset(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Available Tickets',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                        letterSpacing: 0.60,
                      ),
                    ),
                    Text(
                      'Maximum audience size',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                  ],
                ),
                _CapacityStepper(
                  value: capacity,
                  onMinus: onMinus,
                  onPlus: onPlus,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Inset(
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 20, color: _primaryBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sales Availability Window',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.33,
                        ),
                      ),
                      Text(
                        'Instant availability until ${_Fmt.dateShortYear(salesWindowEnd)} '
                        '(${_Fmt.time(startMinutes)} EST)',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CapacityStepper extends StatelessWidget {
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _CapacityStepper({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            background: _chipGrey,
            foreground: _ink,
            onTap: onMinus,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 52),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink,
                fontSize: 20,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                height: 1.40,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            background: _primaryBlue,
            foreground: Colors.white,
            onTap: onPlus,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _StepButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: foreground),
      ),
    );
  }
}

class _DigitalEntryCard extends StatelessWidget {
  const _DigitalEntryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _infoBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShieldBadge(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Digital Entry Protocol',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                    letterSpacing: 0.60,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Attendees must purchase a ticket to join this event. Tickets will be issued as dynamic digital QR passes immediately upon checkout with anti-screenshot protection.',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.63,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShieldBadge extends StatelessWidget {
  const _ShieldBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(color: _primaryBlue, shape: BoxShape.circle),
      child: const Icon(Icons.verified_user_rounded, size: 18, color: Colors.white),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int priceCents;
  final int capacity;
  final DateTime date;
  final int startMinutes;
  final int endMinutes;

  const _SummaryCard({
    required this.priceCents,
    required this.capacity,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionLabel('CONFIGURATION SUMMARY'),
              _ReadyBadge(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SummaryTile(
                  label: 'Ticket Price',
                  value: '${_Fmt.money(priceCents)} / attendee',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryTile(
                  label: 'Max Capacity',
                  value: '$capacity attendees',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _IconTextRow(
            icon: Icons.calendar_today_rounded,
            text: _Fmt.dateLong(date),
          ),
          const SizedBox(height: 6),
          _IconTextRow(
            icon: Icons.schedule_rounded,
            text: '${_Fmt.time(startMinutes)} – ${_Fmt.time(endMinutes)} EST',
          ),
        ],
      ),
    );
  }
}

class _ReadyBadge extends StatelessWidget {
  const _ReadyBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _chipGrey,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Ready',
        style: TextStyle(
          color: Color(0xFF565E74),
          fontSize: 11,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          height: 1.82,
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _softGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.82,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconTextRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconTextRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _muted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.33,
            ),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: _chipGrey,
          foregroundColor: _ink,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_rounded, size: 18),
            SizedBox(width: 4),
            Text(
              'Back',
              style: TextStyle(fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ReviewButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F635BFF),
              blurRadius: 6,
              offset: Offset(0, 4),
              spreadRadius: -1,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'Review Event',
            style: TextStyle(fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
