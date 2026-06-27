import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _nameCtrl = TextEditingController();
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _billingNameCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _address1Ctrl = TextEditingController();
  final _address2Ctrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  bool _isLoading = false;

  Future<void> _onPayNow() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushReplacementNamed(context, '/payment-success');
  }

  bool get _canPay =>
      _nameCtrl.text.trim().isNotEmpty &&
      _cardCtrl.text.trim().isNotEmpty &&
      _expiryCtrl.text.trim().isNotEmpty &&
      _cvvCtrl.text.trim().isNotEmpty &&
      _billingNameCtrl.text.trim().isNotEmpty &&
      _countryCtrl.text.trim().isNotEmpty &&
      _address1Ctrl.text.trim().isNotEmpty &&
      _postalCtrl.text.trim().isNotEmpty &&
      _cityCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _nameCtrl, _cardCtrl, _expiryCtrl, _cvvCtrl,
      _billingNameCtrl, _countryCtrl, _address1Ctrl,
      _address2Ctrl, _postalCtrl, _cityCtrl,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _cardCtrl, _expiryCtrl, _cvvCtrl,
      _billingNameCtrl, _countryCtrl, _address1Ctrl,
      _address2Ctrl, _postalCtrl, _cityCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios,
                          color: AppColors.textPrimary, size: 22),
                    ),
                  ),
                  Text(
                    'Payment',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Please enter the info',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Card Holder Name
                      _FieldLabel('Card Holder Name'),
                      const SizedBox(height: 8),
                      _PayField(
                        controller: _nameCtrl,
                        hint: 'Enter card holder name',
                      ),
                      const SizedBox(height: 20),

                      // Card Number
                      _FieldLabel('Card Number'),
                      const SizedBox(height: 8),
                      _PayField(
                        controller: _cardCtrl,
                        hint: 'Enter card number',
                        keyboardType: TextInputType.number,
                        maxLength: 19,
                      ),
                      const SizedBox(height: 20),

                      // Expiry + CVV row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('Expiry Date'),
                                const SizedBox(height: 8),
                                _PayField(
                                  controller: _expiryCtrl,
                                  hint: 'Enter expiry date',
                                  keyboardType: TextInputType.number,
                                  maxLength: 5,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('CVV'),
                                const SizedBox(height: 8),
                                _PayField(
                                  controller: _cvvCtrl,
                                  hint: 'Enter cvv',
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  maxLength: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // ── Billing Address ──────────────────────────────
                      Text(
                        'Billing Address',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Full Name
                      _FieldLabel('Full Name'),
                      const SizedBox(height: 8),
                      _PayField(
                        controller: _billingNameCtrl,
                        hint: 'Enter full name',
                      ),
                      const SizedBox(height: 20),

                      // Country or Region
                      _FieldLabel('Country or Region'),
                      const SizedBox(height: 8),
                      _PayField(
                        controller: _countryCtrl,
                        hint: 'Enter country or region',
                      ),
                      const SizedBox(height: 20),

                      // Address line 1
                      _FieldLabel('Address Line 1'),
                      const SizedBox(height: 8),
                      _PayField(
                        controller: _address1Ctrl,
                        hint: 'Enter address line 1',
                      ),
                      const SizedBox(height: 20),

                      // Address line 2
                      _FieldLabel('Address Line 2'),
                      const SizedBox(height: 8),
                      _PayField(
                        controller: _address2Ctrl,
                        hint: 'Enter address line 2 (optional)',
                      ),
                      const SizedBox(height: 20),

                      // Postal code + City row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('Postal Code'),
                                const SizedBox(height: 8),
                                _PayField(
                                  controller: _postalCtrl,
                                  hint: 'Postal code',
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _FieldLabel('City'),
                                const SizedBox(height: 8),
                                _PayField(
                                  controller: _cityCtrl,
                                  hint: 'City',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Pay Now button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: (_canPay && !_isLoading) ? _onPayNow : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.35),
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side:
                          const BorderSide(color: AppColors.white, width: 2),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Pay Now',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _PayField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;

  const _PayField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
  });

  @override
  State<_PayField> createState() => _PayFieldState();
}

class _PayFieldState extends State<_PayField> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: _focused ? AppColors.primary : const Color(0xFFA8A8A8),
          width: _focused ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        maxLength: widget.maxLength,
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: GoogleFonts.poppins(
              fontSize: 14, color: const Color(0xFFA8A8A8)),
          border: InputBorder.none,
          counterText: '',
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
