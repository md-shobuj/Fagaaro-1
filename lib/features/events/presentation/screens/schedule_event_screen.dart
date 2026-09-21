import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

const Color _primaryBlue = Color(0xFF084DFB);
const Color _ink = Color(0xFF0F172A);
const Color _muted = Color(0xFF64748B);
const Color _softBorder = Color(0xFFE2E8F0);
const Color _softPurple = Color(0xFFF4F3FF);
const Color _green = Color(0xFF059669);

const List<String> _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const List<String> _weekdayNames = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

/// Formatting helpers kept together so the screen and its widgets agree.
abstract class _Fmt {
  static String monthShort(int month) => _monthNames[month - 1].substring(0, 3);

  static String monthYear(DateTime d) => '${_monthNames[d.month - 1]} ${d.year}';

  static String dateLong(DateTime d) =>
      '${_weekdayNames[d.weekday - 1]}, ${_monthNames[d.month - 1]} ${d.day}, ${d.year}';

  static String dateShort(DateTime d) =>
      '${_weekdayNames[d.weekday - 1]}, ${monthShort(d.month)} ${d.day}, ${d.year}';

  /// [minutes] is minutes since midnight.
  static String time(int minutes, {bool padHour = true}) {
    final int h24 = minutes ~/ 60;
    final int m = minutes % 60;
    final int h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final String hour = padHour ? h12.toString().padLeft(2, '0') : '$h12';
    return '$hour:${m.toString().padLeft(2, '0')} ${h24 < 12 ? 'AM' : 'PM'}';
  }

  static String duration(int minutes, {bool short = false}) {
    final int h = minutes ~/ 60;
    final int m = minutes % 60;
    if (m == 0) return short ? '$h hours' : '$h ${h == 1 ? 'hr' : 'hrs'}';
    if (h == 0) return '$m min';
    return '$h ${h == 1 ? 'hr' : 'hrs'} $m min';
  }
}

/// Step 2 of event creation: date, start time and end time.
class ScheduleEventScreen extends StatefulWidget {
  const ScheduleEventScreen({super.key});

  @override
  State<ScheduleEventScreen> createState() => _ScheduleEventScreenState();
}

class _ScheduleEventScreenState extends State<ScheduleEventScreen> {
  static const int _slotMinutes = 30;
  static final List<int> _slots = List<int>.generate(48, (i) => i * _slotMinutes);

  late final DateTime _today;
  late DateTime _visibleMonth;
  late DateTime _selected;
  int _startMinutes = 9 * 60;
  int _endMinutes = 17 * 60;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _today = DateTime(now.year, now.month, now.day);
    _selected = _today;
    _visibleMonth = DateTime(_today.year, _today.month);
  }

  bool get _isEndValid => _endMinutes > _startMinutes;
  int get _durationMinutes => _endMinutes - _startMinutes;

  void _shiftMonth(int delta) {
    setState(() => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta));
  }

  void _select(DateTime date) {
    setState(() {
      _selected = date;
      _visibleMonth = DateTime(date.year, date.month);
    });
  }

  void _onCancel() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRouter.homePath);
    }
  }

  void _onNext() {
    if (!_isEndValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after the start time.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    context.push(
      AppRouter.ticketPricingPath,
      extra: <String, Object>{
        'date': _selected,
        'startMinutes': _startMinutes,
        'endMinutes': _endMinutes,
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
          onPressed: _onCancel,
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
                  const _StepHeader(),
                  const SizedBox(height: 24),
                  _DateCard(
                    visibleMonth: _visibleMonth,
                    selected: _selected,
                    today: _today,
                    onPrevMonth: () => _shiftMonth(-1),
                    onNextMonth: () => _shiftMonth(1),
                    onSelect: _select,
                    onToday: () => _select(_today),
                  ),
                  const SizedBox(height: 16),
                  _TimeCard(
                    icon: Icons.schedule_rounded,
                    label: 'START TIME',
                    value: _startMinutes,
                    slots: _slots,
                    caption: 'Doors open',
                    captionColor: _muted,
                    quickPicks: const [9 * 60, 10 * 60, 13 * 60],
                    onChanged: (v) => setState(() => _startMinutes = v),
                  ),
                  const SizedBox(height: 16),
                  _TimeCard(
                    icon: Icons.update_rounded,
                    label: 'END TIME',
                    value: _endMinutes,
                    slots: _slots,
                    caption: _isEndValid
                        ? '${_Fmt.duration(_durationMinutes)} duration'
                        : 'Must be after start time',
                    captionColor: _isEndValid ? _green : Colors.redAccent,
                    quickPicks: const [16 * 60, 17 * 60, 18 * 60],
                    onChanged: (v) => setState(() => _endMinutes = v),
                  ),
                  const SizedBox(height: 16),
                  const _TimezoneRow(),
                  const SizedBox(height: 16),
                  _SchedulePreview(
                    date: _selected,
                    startMinutes: _startMinutes,
                    endMinutes: _endMinutes,
                    isValid: _isEndValid,
                  ),
                  const SizedBox(height: 16),
                  const _StepThreeBanner(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _CancelButton(onPressed: _onCancel)),
                      const SizedBox(width: 10),
                      // Next is the primary action, so it gets twice the width.
                      Expanded(flex: 2, child: _NextButton(onPressed: _onNext)),
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
  const _StepHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Pill(icon: Icons.calendar_month_rounded, text: 'Date & Time'),
        SizedBox(height: 8),
        Text(
          'Schedule Your Event',
          style: TextStyle(
            color: _ink,
            fontSize: 24,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.33,
            letterSpacing: -0.6,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Set the exact date, timezone, and duration so attendees can plan their attendance.',
          style: TextStyle(
            color: _muted,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.63,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _softPurple,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _primaryBlue),
          const SizedBox(width: 6),
          Text(
            text,
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
    );
  }
}

/// White rounded card shared by the date, time and timezone sections.
class _SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SectionCard({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xCCE2E8F0)),
        boxShadow: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }
}

class _RequiredLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RequiredLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(
      color: _muted,
      fontSize: 11,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w700,
      height: 1.5,
      letterSpacing: 0.55,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: _primaryBlue),
        const SizedBox(width: 6),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '$text ', style: style),
              TextSpan(text: '*', style: style.copyWith(color: const Color(0xFFF43F5E))),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateCard extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selected;
  final DateTime today;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onToday;

  const _DateCard({
    required this.visibleMonth,
    required this.selected,
    required this.today,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onSelect,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final bool canGoPrev = DateTime(visibleMonth.year, visibleMonth.month).isAfter(
      DateTime(today.year, today.month),
    );

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _RequiredLabel(icon: Icons.calendar_today_outlined, text: 'EVENT DATE'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _softPurple,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _Fmt.monthYear(selected),
                  style: const TextStyle(
                    color: _primaryBlue,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    height: 1.33,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _Fmt.monthYear(visibleMonth),
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                ),
                Row(
                  children: [
                    _NavSquare(
                      icon: Icons.chevron_left_rounded,
                      onTap: canGoPrev ? onPrevMonth : null,
                    ),
                    const SizedBox(width: 4),
                    _NavSquare(icon: Icons.chevron_right_rounded, onTap: onNextMonth),
                  ],
                ),
              ],
            ),
          ),
          _CalendarGrid(
            visibleMonth: visibleMonth,
            selected: selected,
            today: today,
            onSelect: onSelect,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 18, color: _primaryBlue),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _Fmt.dateShort(selected),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onToday,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Today',
                    style: TextStyle(
                      color: _primaryBlue,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
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

class _NavSquare extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _NavSquare({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _softBorder),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  const _CalendarGrid({
    required this.visibleMonth,
    required this.selected,
    required this.today,
    required this.onSelect,
  });

  static const List<String> _headers = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  @override
  Widget build(BuildContext context) {
    final DateTime first = DateTime(visibleMonth.year, visibleMonth.month);
    final int leading = first.weekday - 1; // Monday-first grid.
    final int daysInMonth = DateTime(first.year, first.month + 1, 0).day;
    final int cellCount = ((leading + daysInMonth) / 7).ceil() * 7;

    return Column(
      children: [
        Row(
          children: [
            for (final String h in _headers)
              Expanded(
                child: Center(
                  child: Text(
                    h,
                    style: TextStyle(
                      color: h == 'Sa' ? _primaryBlue : const Color(0xFF94A3B8),
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: h == 'Sa' ? FontWeight.w600 : FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cellCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 40,
          ),
          itemBuilder: (context, index) {
            // DateTime normalizes out-of-range days into adjacent months.
            final DateTime date = DateTime(first.year, first.month, index - leading + 1);
            final bool inMonth = date.month == first.month;
            final bool isPast = date.isBefore(today);
            return _DayCell(
              date: date,
              inMonth: inMonth,
              isSelected: date == selected,
              isToday: date == today,
              enabled: inMonth && !isPast,
              onTap: () => onSelect(date),
            );
          },
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final bool inMonth;
  final bool isSelected;
  final bool isToday;
  final bool enabled;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.isSelected,
    required this.isToday,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = isSelected
        ? Colors.white
        : enabled
            ? const Color(0xFF334155)
            : const Color(0xFFCBD5E1);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected ? _primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? const [BoxShadow(color: Color(0x33084DFB), spreadRadius: 2)]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  height: 1.33,
                ),
              ),
              if (isToday)
                Container(
                  width: 3,
                  height: 3,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : _primaryBlue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final List<int> slots;
  final String caption;
  final Color captionColor;
  final List<int> quickPicks;
  final ValueChanged<int> onChanged;

  const _TimeCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.slots,
    required this.caption,
    required this.captionColor,
    required this.quickPicks,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequiredLabel(icon: icon, text: label),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _softBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                dropdownColor: Colors.white,
                menuMaxHeight: 320,
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _muted),
                // Custom selected view shows the caption under the time.
                selectedItemBuilder: (context) => [
                  for (final int _ in slots)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _Fmt.time(value),
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          caption,
                          style: TextStyle(
                            color: captionColor,
                            fontSize: 11,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
                items: [
                  for (final int slot in slots)
                    DropdownMenuItem<int>(
                      value: slot,
                      child: Text(
                        _Fmt.time(slot),
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final int q in quickPicks)
                _QuickChip(
                  text: _Fmt.time(q, padHour: false),
                  selected: q == value,
                  onTap: () => onChanged(q),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _QuickChip({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? _softPurple : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? _primaryBlue : Colors.transparent),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? _primaryBlue : const Color(0xFF475569),
            fontSize: 11,
            fontFamily: 'Inter',
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TimezoneRow extends StatelessWidget {
  const _TimezoneRow();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.public_rounded, size: 18, color: Color(0xFF475569)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timezone',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Eastern Standard Time (GMT-5)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Change',
              style: TextStyle(
                color: _primaryBlue,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SchedulePreview extends StatelessWidget {
  final DateTime date;
  final int startMinutes;
  final int endMinutes;
  final bool isValid;

  const _SchedulePreview({
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  SizedBox(
                    width: 8,
                    height: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: _green, shape: BoxShape.circle),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'SCHEDULE PREVIEW',
                    style: TextStyle(
                      color: _primaryBlue,
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.55,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _softBorder),
                ),
                child: const Text(
                  'Single Day Event',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 40,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _softBorder),
                ),
                child: Column(
                  children: [
                    Text(
                      _Fmt.monthShort(date.month).toUpperCase(),
                      style: const TextStyle(
                        color: _primaryBlue,
                        fontSize: 9,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${date.day}',
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SELECTED DATE',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      _Fmt.dateLong(date),
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PreviewTimeBox(
                  label: 'START TIME',
                  value: _Fmt.time(startMinutes),
                  icon: Icons.alarm_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PreviewTimeBox(
                  label: 'END TIME',
                  value: _Fmt.time(endMinutes),
                  icon: Icons.alarm_rounded,
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
                  const Icon(Icons.hourglass_bottom_rounded, size: 14, color: _muted),
                  const SizedBox(width: 4),
                  Text(
                    isValid
                        ? 'Total Duration: ${_Fmt.duration(endMinutes - startMinutes, short: true)}'
                        : 'Total Duration: —',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                isValid ? 'Ready for Step 3' : 'Check end time',
                style: TextStyle(
                  color: isValid ? _green : Colors.redAccent,
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewTimeBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _PreviewTimeBox({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 14, color: _primaryBlue),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 13,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepThreeBanner extends StatelessWidget {
  const _StepThreeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xB2F5F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECEAFF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF635BFF)),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: 'Next step: '),
                  TextSpan(
                    text: 'Tickets & Pricing',
                    style: TextStyle(color: Color(0xFF1E293B)),
                  ),
                  TextSpan(
                    text: ' (Step 3 of 3) to define tier prices, attendee capacity, and sales window.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CancelButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryBlue,
          side: const BorderSide(color: _primaryBlue),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NextButton({required this.onPressed});

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
                'Next',
                style: TextStyle(fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
