import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class ParentResetAccessCodeScreen extends StatefulWidget {
  const ParentResetAccessCodeScreen({super.key});

  @override
  State<ParentResetAccessCodeScreen> createState() =>
      _ParentResetAccessCodeScreenState();
}

class _ParentResetAccessCodeScreenState
    extends State<ParentResetAccessCodeScreen> {
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  final _newPinFocus = FocusNode();
  final _confirmPinFocus = FocusNode();

  bool get _pinMismatch =>
      _confirmPinCtrl.text.isNotEmpty &&
      _newPinCtrl.text != _confirmPinCtrl.text;

  bool get _canSubmit =>
      _newPinCtrl.text.length == 4 &&
      _confirmPinCtrl.text.length == 4 &&
      _newPinCtrl.text == _confirmPinCtrl.text;

  @override
  void initState() {
    super.initState();
    _newPinCtrl.addListener(() => setState(() {}));
    _confirmPinCtrl.addListener(() => setState(() {}));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _newPinFocus.requestFocus());
  }

  @override
  void dispose() {
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    _newPinFocus.dispose();
    _confirmPinFocus.dispose();
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

              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
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
                            'Reset Access Code',
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choose a new 4 digit access code',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 36),

                          // New access code
                          Text(
                            'New Access Code',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _PinRow(
                            controller: _newPinCtrl,
                            focusNode: _newPinFocus,
                            onChanged: () => setState(() {}),
                          ),
                          const SizedBox(height: 28),

                          // Verify access code
                          Text(
                            'Verify Access Code',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _PinRow(
                            controller: _confirmPinCtrl,
                            focusNode: _confirmPinFocus,
                            onChanged: () => setState(() {}),
                          ),

                          if (_pinMismatch) ...[
                            const SizedBox(height: 10),
                            Center(
                              child: Text(
                                'Access codes do not match',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.red),
                              ),
                            ),
                          ],

                          const SizedBox(height: 40),

                          // Confirm button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _canSubmit
                                  ? () {
                                      // Pop back to sign-in after reset
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/parent-sign-in',
                                        (route) => false,
                                      );
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
                                'Confirm',
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
              ),
            ],
          ),

          // Mascot
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

class _PinRow extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback? onChanged;

  const _PinRow({
    required this.controller,
    required this.focusNode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pin = controller.text;
    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      child: Column(
        children: [
          Opacity(
            opacity: 0,
            child: SizedBox(
              height: 0,
              child: OverflowBox(
                maxHeight: 0,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => onChanged?.call(),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              final filled = i < pin.length;
              final isActive = i == pin.length;
              return GestureDetector(
                onTap: () => focusNode.requestFocus(),
                child: Container(
                  margin: EdgeInsets.only(right: i < 3 ? 16 : 0),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isActive ? AppColors.primary : AppColors.cardBorder,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: filled
                        ? Text(
                            pin[i],
                            style: GoogleFonts.poppins(
                              fontSize: 22,
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
        ],
      ),
    );
  }
}
