import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../services/supabase_service.dart';
import '../../services/api_client.dart';
import '../../widgets/inline_error_text.dart';

class ParentOtpScreen extends StatefulWidget {
  const ParentOtpScreen({super.key});

  @override
  State<ParentOtpScreen> createState() => _ParentOtpScreenState();
}

class _ParentOtpScreenState extends State<ParentOtpScreen> {
  int _secondsLeft = 49;
  Timer? _timer;

  final _supabaseService = SupabaseService();
  final _apiClient = ApiClient();
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<AuthState>? _authSub;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null && !_confirmed) {
        _onConfirmed();
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final args = _args;
      await _supabaseService.signUp(
        email: args['email'] as String,
        pin: args['pin'] as String,
      );
      setState(() => _secondsLeft = 49);
      _startTimer();
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  Map<String, dynamic> get _args {
    final raw = ModalRoute.of(context)?.settings.arguments;
    if (raw is Map<String, dynamic>) return raw;
    return {'next': '/account-created'};
  }

  Future<void> _onConfirmed() async {
    _confirmed = true;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final args = _args;
      await _apiClient.upsertParent(
        firstName: args['firstName'] as String,
        lastName: args['lastName'] as String,
      );
      if (!mounted) return;
      Navigator.pushNamed(context, args['next'] as String);
    } on ApiException catch (_) {
      _confirmed = false;
      setState(() => _errorMessage = 'Something went wrong finishing your sign-up. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final canResend = _secondsLeft == 0;
    final mm = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final ss = (_secondsLeft % 60).toString().padLeft(2, '0');
    final l10n = context.l10n;
    final email = _args['email'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              // Orange header
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

              // Cream card
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
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.parentOtp_labelSignUp,
                        style: AppTextStyles.font(context,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'Check your email',
                        style: AppTextStyles.font(context,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        email.isEmpty
                            ? 'We sent you a confirmation link. Click it to finish signing up — this screen will update automatically.'
                            : 'We sent a confirmation link to $email. Click it to finish signing up — this screen will update automatically.',
                        style: AppTextStyles.font(context,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),

                      Center(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Icon(Icons.mark_email_unread_outlined,
                                size: 64, color: AppColors.primary),
                      ),
                      const SizedBox(height: 24),

                      // Resend timer
                      Center(
                        child: GestureDetector(
                          onTap: canResend ? _resend : null,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: canResend
                                      ? l10n.parentOtp_resendOtp
                                      : l10n.parentOtp_resendIn,
                                  style: AppTextStyles.font(context,
                                    fontSize: 14,
                                    color: canResend
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight: canResend
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                                if (!canResend)
                                  TextSpan(
                                    text: '$mm:$ss',
                                    style: AppTextStyles.font(context,
                                      fontSize: 14,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),
                      InlineErrorText(message: _errorMessage),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Mascot overlapping the card seam
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
