import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../services/supabase_service.dart';
import '../../widgets/inline_error_text.dart';

class ParentSignUpScreen extends StatefulWidget {
  const ParentSignUpScreen({super.key});

  @override
  State<ParentSignUpScreen> createState() => _ParentSignUpScreenState();
}

class _ParentSignUpScreenState extends State<ParentSignUpScreen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  final _pinFocus = FocusNode();
  final _confirmPinFocus = FocusNode();

  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _errorMessage;

  bool get _canSubmit =>
      _firstNameCtrl.text.trim().isNotEmpty &&
      _lastNameCtrl.text.trim().isNotEmpty &&
      _emailCtrl.text.trim().isNotEmpty &&
      _pinCtrl.text.length == 4 &&
      _confirmPinCtrl.text.length == 4 &&
      _pinCtrl.text == _confirmPinCtrl.text;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl.addListener(() => setState(() {}));
    _lastNameCtrl.addListener(() => setState(() {}));
    _emailCtrl.addListener(() => setState(() {}));
    _pinCtrl.addListener(() => setState(() {}));
    _confirmPinCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _pinCtrl.dispose();
    _confirmPinCtrl.dispose();
    _pinFocus.dispose();
    _confirmPinFocus.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _supabaseService.signUp(
        email: _emailCtrl.text.trim(),
        pin: _pinCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/parent-otp',
        arguments: {
          'next': '/account-created',
          'email': _emailCtrl.text.trim(),
          'firstName': _firstNameCtrl.text.trim(),
          'lastName': _lastNameCtrl.text.trim(),
          'pin': _pinCtrl.text,
        },
      );
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final l10n = context.l10n;

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
                          l10n.parentSignUp_title,
                          style: AppTextStyles.font(context,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // First name & Last name row
                        Row(
                          children: [
                            Expanded(
                              child: _AuthTextField(
                                controller: _firstNameCtrl,
                                hint: l10n.parentSignUp_hint_firstName,
                                prefixIcon: Icons.person_outline,
                                onChanged: () => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AuthTextField(
                                controller: _lastNameCtrl,
                                hint: l10n.parentSignUp_hint_lastName,
                                prefixIcon: Icons.person_outline,
                                onChanged: () => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Email
                        _AuthTextField(
                          controller: _emailCtrl,
                          hint: l10n.parentSignUp_hint_email,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 14),

                        // Access Code
                        Text(
                          l10n.parentSignUp_label_accessCode,
                          style: AppTextStyles.font(context,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.parentSignUp_hint_accessCode,
                          style: AppTextStyles.font(context,
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        _PinRow(
                          controller: _pinCtrl,
                          focusNode: _pinFocus,
                          onChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 20),

                        // Verify Access Code
                        Text(
                          l10n.parentSignUp_label_verifyCode,
                          style: AppTextStyles.font(context,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.parentSignUp_hint_verifyCode,
                          style: AppTextStyles.font(context,
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 10),
                        _PinRow(
                          controller: _confirmPinCtrl,
                          focusNode: _confirmPinFocus,
                          onChanged: () => setState(() {}),
                        ),
                        if (_confirmPinCtrl.text.isNotEmpty &&
                            _pinCtrl.text != _confirmPinCtrl.text) ...[
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsetsDirectional.only(start: 4),
                            child: Text(
                              l10n.parentSignUp_error_mismatch,
                              style: AppTextStyles.font(context,
                                  fontSize: 12, color: Colors.red),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Sign Up button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: _canSubmit && !_isLoading ? _onSubmit : null,
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
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : Text(
                                    l10n.parentSignUp_button,
                                    style: AppTextStyles.font(context,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        InlineErrorText(message: _errorMessage),
                        const SizedBox(height: 40),

                        // Already have an account? Sign In
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, '/parent-sign-in'),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: l10n.parentSignUp_link_haveAccount,
                                    style: AppTextStyles.font(context,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: l10n.parentSignUp_link_signIn,
                                    style: AppTextStyles.font(context,
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
        style: AppTextStyles.font(context, fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              AppTextStyles.font(context, fontSize: 14, color: AppColors.textHint),
          prefixIcon: Icon(prefixIcon, color: AppColors.textHint, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
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
          // Hidden input
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
                  margin: EdgeInsetsDirectional.only(end: i < 3 ? 16 : 0),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.cardBorder,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: filled
                        ? Text(
                            pin[i],
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
        ],
      ),
    );
  }
}
