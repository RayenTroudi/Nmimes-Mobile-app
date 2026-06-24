import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class ParentOtpScreen extends StatefulWidget {
  const ParentOtpScreen({super.key});

  @override
  State<ParentOtpScreen> createState() => _ParentOtpScreenState();
}

class _ParentOtpScreenState extends State<ParentOtpScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _pin => _controller.text;

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
                child: GestureDetector(
                  onTap: () => _focusNode.requestFocus(),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
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
                        const SizedBox(height: 16),
                        Text(
                          'Please enter your access code',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Hidden text input
                        Opacity(
                          opacity: 0,
                          child: SizedBox(
                            height: 0,
                            child: OverflowBox(
                              maxHeight: 0,
                              child: TextField(
                                controller: _controller,
                                focusNode: _focusNode,
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ),
                        ),

                        // 4 OTP circles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (i) {
                            final filled = i < _pin.length;
                            final isActive = i == _pin.length;
                            return GestureDetector(
                              onTap: () => _focusNode.requestFocus(),
                              child: Container(
                                margin: EdgeInsets.only(right: i < 3 ? 16 : 0),
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.cardBorder,
                                    width: isActive ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: filled
                                      ? Text(
                                          _pin[i],
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }),
                        ),

                        const Spacer(),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _pin.length == 4
                                ? () {
                                    final next = ModalRoute.of(context)
                                            ?.settings.arguments as String? ??
                                        '/account-created';
                                    Navigator.pushNamed(context, next);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor:
                                  AppColors.primary.withValues(alpha: 0.35),
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                                side: const BorderSide(
                                    color: AppColors.white, width: 2),
                              ),
                            ),
                            child: Text(
                              (ModalRoute.of(context)?.settings.arguments
                                          as String?) ==
                                      '/parent-success'
                                  ? 'Sign In'
                                  : 'Sign Up',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
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
