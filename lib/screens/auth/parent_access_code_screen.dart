import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../l10n/l10n_extension.dart';
import '../../services/supabase_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/hidden_code_field.dart';
import '../../widgets/inline_error_text.dart';

class ParentAccessCodeScreen extends StatefulWidget {
  const ParentAccessCodeScreen({super.key});

  @override
  State<ParentAccessCodeScreen> createState() => _ParentAccessCodeScreenState();
}

class _ParentAccessCodeScreenState extends State<ParentAccessCodeScreen> {
  final _pinCtrl = TextEditingController();
  final _pinFocus = FocusNode();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pinCtrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _pinFocus.requestFocus(),
    );
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      final email = args is String ? args : '';
      await _supabaseService.signInWithPassword(
        email: email,
        pin: _pinCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/parents-view');
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final pin = _pinCtrl.text;
    final l10n = context.l10n;
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final email = routeArgs is String ? routeArgs : '';

    return Scaffold(
      backgroundColor: AppColors.background,
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
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),

              // Cream card body
              Expanded(
                child: GestureDetector(
                  onTap: () => _pinFocus.requestFocus(),
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
                          l10n.parentAccessCode_title,
                          style: AppTextStyles.font(
                            context,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.parentAccessCode_subtitle,
                          style: AppTextStyles.font(
                            context,
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Hidden input drives the PIN circles and raises the
                        // keyboard. HiddenCodeField keeps it invisible but never
                        // zero-sized (a 0x0 focused field asserts once the IME
                        // attaches).
                        HiddenCodeField(
                          controller: _pinCtrl,
                          focusNode: _pinFocus,
                          maxLength: 4,
                          onChanged: (_) => setState(() {}),
                        ),

                        // PIN circles — sized to the available width so they
                        // never overflow on narrow screens.
                        LayoutBuilder(
                          builder: (context, constraints) {
                            const gap = 16.0;
                            final box = ((constraints.maxWidth - gap * 3) / 4)
                                .clamp(40.0, 60.0);
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (i) {
                                final filled = i < pin.length;
                                final isActive = i == pin.length;
                                return GestureDetector(
                                  onTap: () => _pinFocus.requestFocus(),
                                  child: Container(
                                    margin: EdgeInsetsDirectional.only(
                                      end: i < 3 ? gap : 0,
                                    ),
                                    width: box,
                                    height: box,
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
                                          ? Container(
                                              width: box * 0.27,
                                              height: box * 0.27,
                                              decoration: const BoxDecoration(
                                                color: AppColors.textPrimary,
                                                shape: BoxShape.circle,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              }),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Forgot access code
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/parent-forgot-access-code',
                              arguments: email,
                            ),
                            child: Text(
                              l10n.parentAccessCode_forgotLink,
                              style:
                                  AppTextStyles.font(
                                    context,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ).copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary,
                                  ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Sign In button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: pin.length == 4 && !_isLoading
                                ? _onSubmit
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.primary
                                  .withValues(alpha: 0.35),
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
                                    l10n.parentAccessCode_button,
                                    style: AppTextStyles.font(
                                      context,
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
