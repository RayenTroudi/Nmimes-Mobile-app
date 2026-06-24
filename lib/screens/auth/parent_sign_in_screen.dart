import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';
import '../../widgets/country_picker.dart';

class ParentSignInScreen extends StatefulWidget {
  const ParentSignInScreen({super.key});

  @override
  State<ParentSignInScreen> createState() => _ParentSignInScreenState();
}

class _ParentSignInScreenState extends State<ParentSignInScreen> {
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  Country _selectedCountry = kCountries.first; // Tunisia is first

  bool get _canSubmit =>
      _emailCtrl.text.trim().isNotEmpty || _phoneCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(() => setState(() {}));
    _phoneCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              // Orange header area
              SizedBox(
                height: screenHeight * 0.28,
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),

              // Cream card body
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SIGN IN',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email section
                        Text(
                          'Continue with Email Address',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _AuthTextField(
                          controller: _emailCtrl,
                          hint: 'Enter email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: () => setState(() {}),
                        ),

                        // "or" divider
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'or',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        // Phone section
                        Text(
                          'Continue with Phone Number',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CountryPickerButton(
                              selected: _selectedCountry,
                              onChanged: (c) =>
                                  setState(() => _selectedCountry = c),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _AuthTextField(
                                controller: _phoneCtrl,
                                hint: 'Enter phone number',
                                prefixIcon: Icons.phone_outlined,
                                onChanged: () => setState(() {}),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Sign In button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _canSubmit
                                ? () => Navigator.pushNamed(
                                    context, '/parent-otp',
                                    arguments: '/parent-success')
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                                side: const BorderSide(
                                    color: AppColors.white, width: 2),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 160),

                        // Don't have an account? Sign Up
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, '/parent-sign-up'),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Don't have an account? ",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Sign Up',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Fox mascot overlapping the card seam
          Positioned(
            top: screenHeight * 0.28 - 110,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/char_auth.png',
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final VoidCallback? onChanged;
  const _AuthTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: (_) => onChanged?.call(),
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textHint,
          ),
          prefixIcon: Icon(prefixIcon,
              color: AppColors.textHint, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
