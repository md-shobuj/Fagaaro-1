import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

/// Confirmation screen shown after a subscription payment succeeds.
class SubscriptionActivatedScreen extends StatelessWidget {
  final String planTitle;
  final String planDuration;

  const SubscriptionActivatedScreen({
    super.key,
    this.planTitle = 'Organizer Pro',
    this.planDuration = '6 Months',
  });

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatToday() {
    final DateTime now = DateTime.now();
    return 'Today, ${_months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Subscription',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const _VipCardHero(),
                  const SizedBox(height: 4),
                  const _PaymentConfirmedPill(),
                  const SizedBox(height: 12),
                  const Text(
                    'Subscription Activated',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Your organizer subscription is now active.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.63,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SubscriptionDetailsCard(
                    plan: '$planTitle ($planDuration)',
                    startDate: _formatToday(),
                  ),
                  const SizedBox(height: 16),
                  const _NextStepBanner(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
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
                        onPressed: () => context.go(AppRouter.homePath),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF084DFB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Go to Dashboard',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Illustration tile: confetti, verified shield badge and a VIP membership card.
class _VipCardHero extends StatelessWidget {
  const _VipCardHero();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: 192,
        height: 192,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF1F0FF), Color(0xFFF8FAFC), Color(0xFFEDEDF3)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _ConfettiPainter()),
            ),
            // Soft floor shadow under the card.
            Positioned(
              bottom: 26,
              child: Container(
                width: 110,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(color: Color(0x26635BFF), blurRadius: 14),
                  ],
                ),
              ),
            ),
            const Positioned(top: 22, child: _ShieldBadge()),
            const Positioned(bottom: 40, child: _VipCard()),
          ],
        ),
      ),
    );
  }
}

class _ShieldBadge extends StatelessWidget {
  const _ShieldBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCD8FF), width: 3),
        boxShadow: const [
          BoxShadow(color: Color(0x33635BFF), blurRadius: 12),
        ],
      ),
      child: const Center(
        child: Icon(Icons.verified_rounded, color: Color(0xFF635BFF), size: 26),
      ),
    );
  }
}

class _VipCard extends StatelessWidget {
  const _VipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 124,
      height: 78,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C74FF), Color(0xFF4B43E0)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40635BFF),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'VIP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD66B),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Gold chip.
          Container(
            width: 20,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD66B),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'SARAH JENKINS',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 6,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Static confetti dots scattered around the shield and card.
class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter();

  // Positions are fractions of the canvas; colors cycle through the palette.
  static const List<Offset> _dots = [
    Offset(0.14, 0.22), Offset(0.24, 0.12), Offset(0.34, 0.30),
    Offset(0.72, 0.14), Offset(0.84, 0.26), Offset(0.78, 0.40),
    Offset(0.10, 0.46), Offset(0.90, 0.52), Offset(0.20, 0.62),
    Offset(0.82, 0.66), Offset(0.60, 0.10), Offset(0.42, 0.08),
    Offset(0.06, 0.32), Offset(0.94, 0.38), Offset(0.30, 0.50),
    Offset(0.70, 0.52),
  ];
  static const List<Color> _colors = [
    Color(0xFF635BFF),
    Color(0xFF8B85FF),
    Color(0xFFFFB84D),
    Color(0xFFB9B5FF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    for (int i = 0; i < _dots.length; i++) {
      paint.color = _colors[i % _colors.length];
      final double radius = i.isEven ? 2.5 : 1.8;
      canvas.drawCircle(
        Offset(_dots[i].dx * size.width, _dots[i].dy * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => false;
}

class _PaymentConfirmedPill extends StatelessWidget {
  const _PaymentConfirmedPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0xCCA7F3D0)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusDot(),
          SizedBox(width: 6),
          Text(
            'Payment Confirmed',
            style: TextStyle(
              color: Color(0xFF047857),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.33,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 6,
      height: 6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFF10B981),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _SubscriptionDetailsCard extends StatelessWidget {
  final String plan;
  final String startDate;

  const _SubscriptionDetailsCard({required this.plan, required this.startDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _DetailRow(
            label: 'PLAN',
            value: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F3FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    size: 10,
                    color: Color(0xFF084DFB),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(child: _ValueText(plan, weight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: 'START DATE', value: _ValueText(startDate)),
          const SizedBox(height: 12),
          const _DetailRow(label: 'STATUS', value: _ActiveBadge()),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final Widget value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            height: 1.33,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(width: 12),
        // Flexible so long plan names shrink instead of overflowing.
        Flexible(child: value),
      ],
    );
  }
}

class _ValueText extends StatelessWidget {
  final String text;
  final FontWeight weight;

  const _ValueText(this.text, {this.weight = FontWeight.w500});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.right,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: weight == FontWeight.w600
            ? const Color(0xFF1E293B)
            : const Color(0xFF334155),
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight: weight,
        height: 1.43,
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StatusDot(),
          SizedBox(width: 6),
          Text(
            'Active',
            style: TextStyle(
              color: Color(0xFF047857),
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

class _NextStepBanner extends StatelessWidget {
  const _NextStepBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x99F4F3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xB2EBE9FE)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0x19635BFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.rocket_launch_outlined,
              size: 16,
              color: Color(0xFF635BFF),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'You can now create and manage your events.',
              style: TextStyle(
                color: Color(0xFF334155),
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 1.38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
