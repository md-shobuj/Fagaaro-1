import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

/// Screen allowing event organizers to review their subscription order and complete payment.
class SubscriptionCheckoutScreen extends StatefulWidget {
  final String planTitle;
  final String planDuration;
  final String planPrice;
  final String discountTag;

  const SubscriptionCheckoutScreen({
    super.key,
    this.planTitle = 'Organizer Pro',
    this.planDuration = '6 Months',
    this.planPrice = '\$143.95',
    this.discountTag = 'Save 20%',
  });

  @override
  State<SubscriptionCheckoutScreen> createState() => _SubscriptionCheckoutScreenState();
}

class _SubscriptionCheckoutScreenState extends State<SubscriptionCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _cardholderController;
  late final TextEditingController _cardNumberController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;

  String _paymentMethod = 'credit_card'; // 'credit_card' or 'paypal'
  bool _saveCard = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cardholderController = TextEditingController(text: 'Sarah Jenkins');
    _cardNumberController = TextEditingController(text: '•••• •••• •••• 4289');
    _expiryController = TextEditingController(text: '09 / 28');
    _cvvController = TextEditingController(text: '384');
  }

  @override
  void dispose() {
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onPayAndActivate() {
    if (_formKey.currentState?.validate() ?? true) {
      setState(() {
        _isProcessing = true;
      });

      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });

          context.go(
            AppRouter.subscriptionActivatedPath,
            extra: <String, String>{
              'title': widget.planTitle,
              'duration': widget.planDuration,
            },
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF084DFB);
    const titleColor = Color(0xFF0F172A);
    const bodyTextColor = Color(0xFF64748B);

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
              context.go(AppRouter.subscriptionPath);
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selected Plan Summary Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xE5F5F4FF),
                            Colors.white,
                            Color(0x7FF5F4FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryBlue,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Details Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Popular Choice Pill Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: primaryBlue,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.local_fire_department_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'POPULAR CHOICE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.50,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                Text(
                                  widget.planTitle,
                                  style: const TextStyle(
                                    color: titleColor,
                                    fontSize: 18,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.45,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                Row(
                                  children: [
                                    const Text(
                                      'Plan: ',
                                      style: TextStyle(
                                        color: Color(0xFF334155),
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      widget.planDuration,
                                      style: const TextStyle(
                                        color: titleColor,
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF94A3B8),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: const Color(0xFFA7F3D0),
                                        ),
                                      ),
                                      child: Text(
                                        widget.discountTag,
                                        style: const TextStyle(
                                          color: primaryBlue,
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Right Price Details Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Billed upfront',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: bodyTextColor,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    widget.planPrice,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      color: primaryBlue,
                                      fontSize: 20,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.50,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    '/ 6 mo',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: bodyTextColor,
                                      fontSize: 11,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Payment Method Section Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Payment Method & Encrypted Tag
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Payment Method',
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Choose your preferred payment gateway',
                                    style: TextStyle(
                                      color: bodyTextColor,
                                      fontSize: 11,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(
                                    color: const Color(0xFFA7F3D0),
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.lock_rounded,
                                      size: 12,
                                      color: primaryBlue,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Encrypted',
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontSize: 11,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Payment Gateway Selector Buttons (Credit Card vs PayPal)
                          Row(
                            children: [
                              // Credit Card Option Button
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _paymentMethod = 'credit_card';
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: _paymentMethod == 'credit_card'
                                          ? const Color(0x7FF5F4FF)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _paymentMethod == 'credit_card'
                                            ? primaryBlue
                                            : const Color(0xFFE2E8F0),
                                        width: _paymentMethod == 'credit_card' ? 2 : 1,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.credit_card_rounded,
                                              size: 18,
                                              color: titleColor,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Credit Card',
                                              style: TextStyle(
                                                color: titleColor,
                                                fontSize: 12,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (_paymentMethod == 'credit_card')
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              width: 16,
                                              height: 16,
                                              decoration: const BoxDecoration(
                                                color: primaryBlue,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check_rounded,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // PayPal Option Button
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _paymentMethod = 'paypal';
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: _paymentMethod == 'paypal'
                                          ? const Color(0x7FF5F4FF)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _paymentMethod == 'paypal'
                                            ? primaryBlue
                                            : const Color(0xFFE2E8F0),
                                        width: _paymentMethod == 'paypal' ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.account_balance_wallet_outlined,
                                          size: 18,
                                          color: Color(0xFF475569),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'PayPal',
                                          style: TextStyle(
                                            color: Color(0xFF475569),
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Card Input Form Fields
                          if (_paymentMethod == 'credit_card') ...[
                            // Cardholder Name Input
                            const Text(
                              'Cardholder Name',
                              style: TextStyle(
                                color: Color(0xFF334155),
                                fontSize: 11,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _cardholderController,
                              style: const TextStyle(
                                fontSize: 13,
                                color: titleColor,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter name on card',
                                prefixIcon: const Icon(Icons.person_outline_rounded, size: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Card Number Input with VISA/MC/AMEX Badges
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Card Number',
                                  style: TextStyle(
                                    color: Color(0xFF334155),
                                    fontSize: 11,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    _buildCardBrandBadge('VISA'),
                                    const SizedBox(width: 4),
                                    _buildCardBrandBadge('MC'),
                                    const SizedBox(width: 4),
                                    _buildCardBrandBadge('AMEX'),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _cardNumberController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 13,
                                color: titleColor,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: '0000 0000 0000 0000',
                                prefixIcon: const Icon(Icons.credit_card_rounded, size: 18),
                                suffixIcon: const Icon(Icons.check_circle_rounded, color: primaryBlue, size: 18),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Row: Expiration Date & Security Code (CVV)
                            Row(
                              children: [
                                // Expiration Date Field
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Expiration Date',
                                        style: TextStyle(
                                          color: Color(0xFF334155),
                                          fontSize: 11,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _expiryController,
                                        keyboardType: TextInputType.datetime,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: titleColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'MM / YY',
                                          prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Security Code (CVV) Field
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: const [
                                          Text(
                                            'Security Code',
                                            style: TextStyle(
                                              color: Color(0xFF334155),
                                              fontSize: 11,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '3 digits',
                                            style: TextStyle(
                                              color: bodyTextColor,
                                              fontSize: 10,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      TextFormField(
                                        controller: _cvvController,
                                        keyboardType: TextInputType.number,
                                        obscureText: true,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: titleColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'CVC / CVV',
                                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Save Card Checkbox Row
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _saveCard = !_saveCard;
                                });
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      value: _saveCard,
                                      onChanged: (val) {
                                        setState(() {
                                          _saveCard = val ?? true;
                                        });
                                      },
                                      activeColor: primaryBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Save card securely for future renewals',
                                    style: TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // PayPal Guidance Container
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.account_balance_wallet_outlined, color: primaryBlue),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'You will be redirected to PayPal to authorize your subscription payment securely.',
                                      style: TextStyle(
                                        color: bodyTextColor,
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // SSL Encryption Protection Banner
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 18,
                                  color: primaryBlue,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '256-Bit SSL Protection: Your billing info is end-to-end encrypted and PCI-DSS certified.',
                                    style: TextStyle(
                                      color: bodyTextColor,
                                      fontSize: 11,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      height: 1.40,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Order Summary Invoice Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Order Summary & Invoice Number
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Order Summary',
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 14,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Invoice #EP-SUB-2024',
                                style: TextStyle(
                                  color: bodyTextColor,
                                  fontSize: 11,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Line Item: Subscription
                          _buildSummaryLine(
                            label: 'Subscription (${widget.planDuration} ${widget.planTitle})',
                            value: widget.planPrice,
                          ),
                          const SizedBox(height: 8),

                          // Line Item: Platform Service Fee (Waived)
                          _buildSummaryLine(
                            label: 'Platform Service Fee',
                            value: '\$0.00 (Waived)',
                            valueColor: primaryBlue,
                          ),
                          const SizedBox(height: 8),

                          // Line Item: Taxes & VAT
                          _buildSummaryLine(
                            label: 'Taxes & VAT',
                            value: 'Calculated',
                            valueColor: bodyTextColor,
                          ),
                          const SizedBox(height: 12),

                          const Divider(color: Color(0xFFE2E8F0)),
                          const SizedBox(height: 10),

                          // Total Amount Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Total Amount',
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Includes all plan benefits',
                                    style: TextStyle(
                                      color: bodyTextColor,
                                      fontSize: 11,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                widget.planPrice,
                                style: const TextStyle(
                                  color: primaryBlue,
                                  fontSize: 20,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.50,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary Action Button: Pay & Activate
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x47635BFF),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _onPayAndActivate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Pay & Activate',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtext Notice
                    const Center(
                      child: Text(
                        'Your subscription will become active after successful payment.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: bodyTextColor,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBrandBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 10,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.50,
        ),
      ),
    );
  }

  Widget _buildSummaryLine({
    required String label,
    required String value,
    Color valueColor = const Color(0xFF0F172A),
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
