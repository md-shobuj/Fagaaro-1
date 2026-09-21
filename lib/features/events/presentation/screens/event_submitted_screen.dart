import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';

const Color _primaryBlue = Color(0xFF084DFB);
const Color _ink = Color(0xFF0F172A);
const Color _muted = Color(0xFF64748B);
const Color _label = Color(0xFF94A3B8);
const Color _subtle = Color(0xFF1E293B);
const Color _cardBorder = Color(0xFFF1F5F9);

const List<String> _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const List<String> _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

/// Formatting helpers used by the event details card.
abstract class _Fmt {
  static String dateShort(DateTime d) =>
      '${_weekdayNames[d.weekday - 1].substring(0, 3)}, '
      '${_monthNames[d.month - 1].substring(0, 3)} ${d.day}, ${d.year}';

  static String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
}

/// Final page of the create-event flow, shown after the event is submitted.
class EventSubmittedScreen extends StatelessWidget {
  const EventSubmittedScreen({
    super.key,
    this.eventName = 'Global Tech Innovation Summit 2026',
    this.date,
    this.priceCents = 9900,
    this.illustrationAsset,
  });

  final String eventName;
  final DateTime? date;
  final int priceCents;

  /// Optional hero illustration. Falls back to a calendar glyph when absent.
  final String? illustrationAsset;

  void _backToDashboard(BuildContext context) => context.go(AppRouter.homePath);

  @override
  Widget build(BuildContext context) {
    final DateTime resolvedDate = date ?? DateTime.now();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
          onPressed: () => _backToDashboard(context),
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
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: _SuccessHero(illustrationAsset: illustrationAsset)),
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 20),
                    child: Column(
                      children: [
                        Text(
                          'Event Submitted Successfully',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _ink,
                            fontSize: 24,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            height: 1.38,
                            letterSpacing: -0.60,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Your event has been sent to the admin for approval.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _muted,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            height: 1.63,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _EventDetailsCard(
                    eventName: eventName,
                    date: resolvedDate,
                    priceCents: priceCents,
                  ),
                  const SizedBox(height: 16),
                  const _ApprovalNotice(),
                  const SizedBox(height: 16),
                  _DashboardButton(onPressed: () => _backToDashboard(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessHero extends StatelessWidget {
  final String? illustrationAsset;

  const _SuccessHero({required this.illustrationAsset});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 176,
      height: 176,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Color(0x3F635BFF), Color(0x59A5B4FC)],
              ),
            ),
          ),
          if (illustrationAsset != null)
            Image.asset(illustrationAsset!, width: 176, height: 176)
          else
            const _SuccessGlyph(),
        ],
      ),
    );
  }
}

/// Placeholder for the hero illustration until the real asset is added.
class _SuccessGlyph extends StatelessWidget {
  const _SuccessGlyph();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Color(0x1A0F172A), blurRadius: 16, offset: Offset(0, 8)),
            ],
          ),
          child: const Icon(Icons.calendar_month_rounded, size: 56, color: _primaryBlue),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _primaryBlue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.check_rounded, size: 20, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _EventDetailsCard extends StatelessWidget {
  final String eventName;
  final DateTime date;
  final int priceCents;

  const _EventDetailsCard({
    required this.eventName,
    required this.date,
    required this.priceCents,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EVENT DETAILS',
                style: TextStyle(
                  color: _label,
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  height: 1.50,
                  letterSpacing: 0.55,
                ),
              ),
              _PendingBadge(),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            eventName,
            style: const TextStyle(
              color: _subtle,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.38,
            ),
          ),
          const Divider(height: 24, color: _cardBorder),
          Row(
            children: [
              Expanded(
                child: _DetailItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: _Fmt.dateShort(date),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DetailItem(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Ticket Price',
                  value: '${_Fmt.money(priceCents)} ',
                  valueSuffix: '/ attendee',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0x99FDE68A)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 6,
            height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
            ),
          ),
          SizedBox(width: 6),
          Text(
            'Pending Approval',
            style: TextStyle(
              color: Color(0xFFB45309),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? valueSuffix;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueSuffix,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F3FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: _primaryBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _label,
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.50,
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: const TextStyle(
                        color: _subtle,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                        letterSpacing: -0.30,
                      ),
                    ),
                    if (valueSuffix != null)
                      TextSpan(
                        text: valueSuffix,
                        style: const TextStyle(
                          color: _label,
                          fontSize: 10,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.60,
                          letterSpacing: -0.30,
                        ),
                      ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ApprovalNotice extends StatelessWidget {
  const _ApprovalNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xB2EEF0FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x26635BFF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.info_outline_rounded, size: 16, color: _primaryBlue),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your event will appear to attendees after admin approval.',
              style: TextStyle(
                color: _subtle,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _DashboardButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33635BFF),
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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Back to Dashboard',
                style: TextStyle(fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 6),
              Icon(Icons.arrow_forward_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
