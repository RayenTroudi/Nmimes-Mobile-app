import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../l10n/l10n_extension.dart';
import '../../services/supabase_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/inline_error_text.dart';

class ParentForgotAccessCodeScreen extends StatefulWidget {
  const ParentForgotAccessCodeScreen({super.key});

  @override
  State<ParentForgotAccessCodeScreen> createState() =>
      _ParentForgotAccessCodeScreenState();
}

class _ParentForgotAccessCodeScreenState
    extends State<ParentForgotAccessCodeScreen> {
  final _otpCtrl = TextEditingController();
  final _otpFocus = FocusNode();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSentOtp = false;

  Timer? _timer;
  int _secondsLeft = 49;
  bool get _canResend => _secondsLeft == 0;

  @override
  void initState() {
    super.initState();
    _otpCtrl.addListener(() => setState(() {}));
    _startTimer();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _otpFocus.requestFocus());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasSentOtp) {
      _hasSentOtp = true;
      _sendOtp();
    }
  }

  String _emailFromRoute() {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is String ? args : '';
  }

  Future<void> _sendOtp() async {
    final email = _emailFromRoute();
    try {
      await _supabaseService.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    }
  }

  Future<void> _onVerify() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final email = _emailFromRoute();
      await _supabaseService.verifyOtp(
        email: email,
        token: _otpCtrl.text,
        type: OtpType.recovery,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/parent-reset-access-code',
        arguments: email,
      );
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 49);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _resend() {
    if (!_canResend) return;
    _otpCtrl.clear();
    _startTimer();
  }

  String _timerLabel(BuildContext context) {
    if (_secondsLeft == 0) return context.l10n.parentForgotCode_resendOtp;
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final otp = _otpCtrl.text;
    final l10n = context.l10n;

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
                  onTap: () => _otpFocus.requestFocus(),
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
                          l10n.parentForgotCode_title,
                          style: AppTextStyles.font(context,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.parentForgotCode_subtitle,
                          style: AppTextStyles.font(context,
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Hidden OTP input
                        Opacity(
                          opacity: 0,
                          child: SizedBox(
                            height: 0,
                            child: OverflowBox(
                              maxHeight: 0,
                              child: TextField(
                                controller: _otpCtrl,
                                focusNode: _otpFocus,
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

                        // OTP circles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (i) {
                            final filled = i < otp.length;
                            final isActive = i == otp.length;
                            return GestureDetector(
                              onTap: () => _otpFocus.requestFocus(),
                              child: Container(
                                margin: EdgeInsetsDirectional.only(end: i < 3 ? 16 : 0),
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: isActive ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: filled
                                      ? Text(
                                          otp[i],
                                          style: AppTextStyles.font(context,
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
                        const SizedBox(height: 20),

                        // Resend timer
                        Center(
                          child: GestureDetector(
                            onTap: _canResend ? _resend : null,
                            child: Text(
                              _timerLabel(context),
                              style: AppTextStyles.font(context,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _canResend
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ).copyWith(
                                decoration: _canResend
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                                decorationColor: AppColors.primary,
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Verify button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: otp.length == 4 && !_isLoading
                                ? _onVerify
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor:
                                  AppColors.primary.withValues(alpha: 0.35),
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: AppColors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    l10n.parentForgotCode_button,
                                    style: AppTextStyles.font(context,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                          ),
                        ),
                        InlineErrorText(message: _errorMessage),
                      ],
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
