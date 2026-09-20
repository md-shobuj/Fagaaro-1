import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

/// Representation of a subscription plan option.
class SubscriptionPlanItem {
  final String id;
  final String title;
  final String tagText;
  final String price;
  final String billingPeriod;
  final String billingSubtext;
  final List<String> features;
  final String? badgeText;
  final IconData? badgeIcon;
  final Color? badgeColor;

  const SubscriptionPlanItem({
    required this.id,
    required this.title,
    required this.tagText,
    required this.price,
    required this.billingPeriod,
    required this.billingSubtext,
    required this.features,
    this.badgeText,
    this.badgeIcon,
    this.badgeColor,
  });
}

/// Screen allowing event organizers to pick and purchase a subscription plan.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedPlanId = '6_months'; // Default selected plan: 6 Months (Popular)

  static const List<SubscriptionPlanItem> _plans = [
    SubscriptionPlanItem(
      id: '1_month',
      title: '1 Month',
      tagText: 'Flexible',
      price: '\$29.99',
      billingPeriod: '/ month',
      billingSubtext: 'Standard monthly billing',
      features: [
        'Unlimited event creation',
        'Standard ticket analytics',
        'Instant payout support',
      ],
    ),
    SubscriptionPlanItem(
      id: '6_months',
      title: '6 Months',
      tagText: 'Save 20%',
      price: '\$143.95',
      billingPeriod: '/ 6 months',
      billingSubtext: 'Billed every 6 months',
      features: [
        'Everything in 1 Month plan',
        'Custom branded digital tickets',
        'Instant payout support',
      ],
      badgeText: 'POPULAR',
      badgeIcon: Icons.local_fire_department_rounded,
      badgeColor: Color(0xFF084DFB),
    ),
    SubscriptionPlanItem(
      id: '1_year',
      title: '1 Year',
      tagText: 'Save 35%',
      price: '\$233.90',
      billingPeriod: '/ year',
      billingSubtext: 'Annual billed upfront',
      features: [
        'Priority 24/7 dedicated account manager',
        'Custom branded digital tickets',
        'Instant payout support',
      ],
      badgeText: 'BEST VALUE',
      badgeIcon: Icons.workspace_premium_rounded,
      badgeColor: Color(0xFF334155),
    ),
  ];

  void _selectPlan(String planId) {
    setState(() {
      _selectedPlanId = planId;
    });
  }

  void _onConfirmSubscription() {
    final selectedPlan = _plans.firstWhere((p) => p.id == _selectedPlanId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${selectedPlan.title} plan (${selectedPlan.price})!'),
        backgroundColor: const Color(0xFF059669),
        duration: const Duration(seconds: 2),
      ),
    );

    context.go(AppRouter.subscriptionCheckoutPath, extra: {
      'title': selectedPlan.title == '6 Months' ? 'Organizer Pro' : selectedPlan.title,
      'duration': selectedPlan.title,
      'price': selectedPlan.price,
      'discountTag': selectedPlan.tagText,
    });
  }

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF191C1D);
    const bodyTextColor = Color(0xFF464555);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRouter.verificationSubmittedPath);
            }
          },
        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header
                  const Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 28,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      height: 1.21,
                      letterSpacing: -0.70,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtitle Description
                  const Text(
                    'Select a subscription plan to start creating and\nmanaging your events.',
                    style: TextStyle(
                      color: bodyTextColor,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Plan Options List
                  ..._plans.map((plan) {
                    final isSelected = _selectedPlanId == plan.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _SubscriptionPlanCard(
                        plan: plan,
                        isSelected: isSelected,
                        onTap: () => _selectPlan(plan.id),
                        onConfirm: _onConfirmSubscription,
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  // Bottom Active Subscription Notice Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: Color(0xFF084DFB),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'An active subscription is required to publish and sell tickets for your events on EventPass.',
                            style: TextStyle(
                              color: bodyTextColor,
                              fontSize: 13,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.43,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Card component rendering an individual subscription plan option.
class _SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlanItem plan;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onConfirm;

  const _SubscriptionPlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF084DFB);
    const titleColor = Color(0xFF191C1D);
    const bodyTextColor = Color(0xFF464555);

    final cardBgColor = isSelected ? const Color(0x4CE2DFFF) : Colors.white;
    final cardBorderColor = isSelected ? primaryBlue : Colors.transparent;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Card Container
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: cardBorderColor,
                width: isSelected ? 1.5 : 0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? const Color(0x1E635BFF) : const Color(0x07000000),
                  blurRadius: isSelected ? 24 : 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upper Section: Radio + Title + Price
                Padding(
                  padding: const EdgeInsets.only(top: 18, left: 16, right: 16, bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Side: Radio Button & Plan Details
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Radio Circle Indicator
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: isSelected ? primaryBlue : const Color(0xFFEDEEEF),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Plan Title, Tag, and Subtext
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        plan.title,
                                        style: const TextStyle(
                                          color: titleColor,
                                          fontSize: 17,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          height: 1.38,
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Savings / Type Tag
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0x26493EE5)
                                              : const Color(0xFFE7E8E9),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          plan.tagText,
                                          style: TextStyle(
                                            color: isSelected ? primaryBlue : bodyTextColor,
                                            fontSize: 11,
                                            fontFamily: 'Inter',
                                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                            height: 1.82,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    plan.billingSubtext,
                                    style: const TextStyle(
                                      color: bodyTextColor,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.43,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right Side: Price & Billing Period
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            plan.price,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: isSelected ? primaryBlue : titleColor,
                              fontSize: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 1.40,
                            ),
                          ),
                          Text(
                            plan.billingPeriod,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              color: bodyTextColor,
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
                ),

                // Lower Section: Features List & Action Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.90) : const Color(0x99F3F4F5),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Features Items
                      ...plan.features.map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: primaryBlue,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: TextStyle(
                                    color: isSelected ? titleColor : bodyTextColor,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                    height: 1.54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Action Selection Button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: isSelected ? onConfirm : onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected ? primaryBlue : const Color(0xFFEDEEEF),
                            foregroundColor: isSelected ? Colors.white : primaryBlue,
                            elevation: isSelected ? 2 : 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isSelected ? 'Current Selection' : 'Select ${plan.title}',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : primaryBlue,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.40,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Optional Top Right Badge (e.g. POPULAR / BEST VALUE)
        if (plan.badgeText != null)
          Positioned(
            top: -10,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: plan.badgeColor ?? primaryBlue,
                borderRadius: BorderRadius.circular(9999),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x29000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (plan.badgeIcon != null) ...[
                    Icon(
                      plan.badgeIcon,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    plan.badgeText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.60,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
