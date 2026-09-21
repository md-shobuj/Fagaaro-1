import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';

const Color _primaryBlue = Color(0xFF084DFB);
const Color _ink = Color(0xFF0F172A);
const Color _muted = Color(0xFF64748B);
const Color _label = Color(0xFF94A3B8);
const Color _cardBorder = Color(0xFFF1F5F9);
const Color _softGrey = Color(0xFFF1F5F9);
const Color _purple = Color(0xFF8B34FA);

const List<String> _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const List<String> _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

/// Formatting helpers shared by the review sections.
abstract class _Fmt {
  static String weekday(DateTime d) => _weekdayNames[d.weekday - 1];

  static String dateShort(DateTime d) =>
      '${_monthNames[d.month - 1].substring(0, 3)} ${d.day}, ${d.year}';

  /// [minutes] is minutes since midnight.
  static String time(int minutes) {
    final int h24 = minutes ~/ 60;
    final int m = minutes % 60;
    final int h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} '
        '${h24 < 12 ? 'AM' : 'PM'}';
  }

  static String duration(int minutes) {
    final int h = minutes ~/ 60;
    final int m = minutes % 60;
    if (m == 0) return '$h ${h == 1 ? 'hr' : 'hrs'}';
    if (h == 0) return '$m min';
    return '$h hr $m min';
  }

  static String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';
}

/// Step 4 of event creation: the final review before submitting for approval.
class ReviewEventScreen extends StatelessWidget {
  const ReviewEventScreen({
    super.key,
    this.eventName = 'Global Tech Innovation Summit 2026',
    this.category = 'Technology & Innovation',
    this.description =
        'The Global Tech Innovation Summit 2026 gathers top visionary engineers, '
        'venture capitalists, and product leaders to explore breakthrough trends in '
        'generative AI, cloud infrastructure, and cybersecurity. Includes executive '
        'networking lounges and panels.',
    this.coverPath,
    this.coverAsset = 'assets/images/Global Tech Innovation Summit 2025.png',
    this.avatarPath,
    this.priceCents = 9900,
    this.capacity = 500,
    this.date,
    this.startMinutes = 9 * 60,
    this.endMinutes = 17 * 60,
    this.organizerName = 'Sarah Jenkins',
  });

  final String eventName;
  final String category;
  final String description;
  final String? coverPath;
  final String coverAsset;
  final String? avatarPath;
  final int priceCents;
  final int capacity;
  final DateTime? date;
  final int startMinutes;
  final int endMinutes;
  final String organizerName;

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.homePath);
    }
  }

  void _onEdit(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.createEventPath);
    }
  }

  void _onSubmit(BuildContext context) {
    context.push(
      AppRouter.eventSubmittedPath,
      extra: <String, Object>{
        'eventName': eventName,
        'date': date ?? DateTime.now(),
        'priceCents': priceCents,
      },
    );
  }

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
          onPressed: () => _onBack(context),
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _EventPreviewCard(
                    eventName: eventName,
                    category: category,
                    description: description,
                    coverPath: coverPath,
                    coverAsset: coverAsset,
                    priceCents: priceCents,
                    capacity: capacity,
                    date: resolvedDate,
                    startMinutes: startMinutes,
                    endMinutes: endMinutes,
                  ),
                  const SizedBox(height: 14),
                  _OrganizerCard(
                    organizerName: organizerName,
                    avatarPath: avatarPath,
                  ),
                  const SizedBox(height: 14),
                  const _ApprovalNotice(),
                  const SizedBox(height: 14),
                  _EditButton(onPressed: () => _onEdit(context)),
                  const SizedBox(height: 10),
                  _SubmitButton(onPressed: () => _onSubmit(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// White card with the border + soft shadow used across this step.
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Clip clipBehavior;

  const _Card({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.clipBehavior = Clip.none,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _EventPreviewCard extends StatelessWidget {
  final String eventName;
  final String category;
  final String description;
  final String? coverPath;
  final String coverAsset;
  final int priceCents;
  final int capacity;
  final DateTime date;
  final int startMinutes;
  final int endMinutes;

  const _EventPreviewCard({
    required this.eventName,
    required this.category,
    required this.description,
    required this.coverPath,
    required this.coverAsset,
    required this.priceCents,
    required this.capacity,
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CoverHeader(
            eventName: eventName,
            category: category,
            coverPath: coverPath,
            coverAsset: coverAsset,
            priceCents: priceCents,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.calendar_today_rounded,
                        label: 'DATE',
                        value: _Fmt.weekday(date),
                        caption: _Fmt.dateShort(date),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.schedule_rounded,
                        label: 'TIMING',
                        value: '${_Fmt.time(startMinutes)} -\n${_Fmt.time(endMinutes)}',
                        caption: '${_Fmt.duration(endMinutes - startMinutes)} (EST)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _SectionLabel(
                  icon: Icons.description_outlined,
                  text: 'ABOUT EVENT',
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.63,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: _cardBorder),
                const SizedBox(height: 12),
                _TicketRow(priceCents: priceCents, capacity: capacity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverHeader extends StatelessWidget {
  final String eventName;
  final String category;
  final String? coverPath;
  final String coverAsset;
  final int priceCents;

  const _CoverHeader({
    required this.eventName,
    required this.category,
    required this.coverPath,
    required this.coverAsset,
    required this.priceCents,
  });

  @override
  Widget build(BuildContext context) {
    final Widget cover = coverPath != null
        ? Image.file(File(coverPath!), fit: BoxFit.cover, cacheWidth: 800)
        : Image.asset(coverAsset, fit: BoxFit.cover, cacheWidth: 800);

    return SizedBox(
      height: 192,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFF0F172A)),
          Opacity(opacity: 0.90, child: cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xCC020617), Color(0x33020617), Color(0x00020617)],
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: _OverlayPill(
              background: Colors.white.withValues(alpha: 0.90),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_offer_rounded, size: 12, color: _primaryBlue),
                  const SizedBox(width: 6),
                  Text(
                    category,
                    style: const TextStyle(
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
          ),
          Positioned(
            right: 12,
            top: 12,
            child: _OverlayPill(
              background: _primaryBlue,
              child: Text(
                '${_Fmt.money(priceCents)} / ticket',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'IN-PERSON & VIRTUAL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                      letterSpacing: 0.50,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  eventName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.25,
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

class _OverlayPill extends StatelessWidget {
  final Color background;
  final Widget child;

  const _OverlayPill({required this.background, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9999),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String caption;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4FF),
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
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.38,
                  ),
                ),
                Text(
                  caption,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
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

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SectionLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: _label),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: _label,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.33,
            letterSpacing: 0.60,
          ),
        ),
      ],
    );
  }
}

class _TicketRow extends StatelessWidget {
  final int priceCents;
  final int capacity;

  const _TicketRow({required this.priceCents, required this.capacity});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.confirmation_number_outlined, size: 15, color: Color(0xFF059669)),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Standard Ticket',
                  style: TextStyle(
                    color: _label,
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
                Text(
                  '${_Fmt.money(priceCents)} USD',
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Availability',
              style: TextStyle(
                color: _label,
                fontSize: 11,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: _softGrey,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '$capacity seats max',
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrganizerCard extends StatelessWidget {
  final String organizerName;
  final String? avatarPath;

  const _OrganizerCard({required this.organizerName, required this.avatarPath});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.badge_outlined, size: 14, color: _label),
              SizedBox(width: 6),
              Text(
                'ORGANIZER INFORMATION',
                style: TextStyle(
                  color: _label,
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                  letterSpacing: 0.55,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _OrganizerAvatar(path: avatarPath),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            organizerName,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 1.43,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, size: 15, color: _primaryBlue),
                        ],
                      ),
                      const Text(
                        'Verified Organizer',
                        style: TextStyle(
                          color: _label,
                          fontSize: 11,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _softGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Host',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.50,
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

class _OrganizerAvatar extends StatelessWidget {
  final String? path;

  const _OrganizerAvatar({required this.path});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F4FF),
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: const Color(0xFFEBE9FE)),
            ),
            child: path == null
                ? const Icon(Icons.person_rounded, size: 24, color: Color(0xFF94A3B8))
                : Image.file(File(path!), fit: BoxFit.cover, cacheWidth: 144),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(width: 2, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalNotice extends StatelessWidget {
  const _ApprovalNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xE5FFFBEB), Color(0x7FFFF7ED)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xCCFDE68A)),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0x19F59E0B),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFB45309)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Approval Notice',
                  style: TextStyle(
                    color: Color(0xFF78350F),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                    letterSpacing: -0.30,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your event will be submitted to the admin for approval. '
                  'It will become visible to attendees after approval.',
                  style: TextStyle(
                    color: Color(0xE592400E),
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

class _EditButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EditButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF334155),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.edit_outlined, size: 16),
        label: const Text(
          'Edit',
          style: TextStyle(fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SubmitButton({required this.onPressed});

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
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Submit for Approval',
                style: TextStyle(fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 6),
              Icon(Icons.send_rounded, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
