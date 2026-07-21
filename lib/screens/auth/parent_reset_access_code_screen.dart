import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../l10n/l10n_extension.dart';
import '../../services/supabase_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/inline_error_text.dart';

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
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _errorMessage;

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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _newPinFocus.requestFocus(),
    );
  }

  @override
  void dispose() {
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    _newPinFocus.dispose();
    _confirmPinFocus.dispose();
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
      await _supabaseService.updatePassword(
        email: email,
        newPin: _newPinCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/parent-sign-in',
        (route) => false,
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
                            l10n.parentResetCode_title,
                            style: AppTextStyles.font(
                              context,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.parentResetCode_subtitle,
                            style: AppTextStyles.font(
                              context,
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 36),

                          // New access code
                          Text(
                            l10n.parentResetCode_label_newCode,
                            style: AppTextStyles.font(
                              context,
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
                            l10n.parentResetCode_label_verifyCode,
                            style: AppTextStyles.font(
                              context,
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
                                l10n.parentResetCode_error_mismatch,
                                style: AppTextStyles.font(
                                  context,
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 40),

                          // Confirm button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _canSubmit && !_isLoading
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
                                      l10n.parentResetCode_button,
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
          // PIN circles — sized to the available width so they never
          // overflow on narrow screens.
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 16.0;
              final box = ((constraints.maxWidth - gap * 3) / 4).clamp(
                40.0,
                60.0,
              );
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < pin.length;
                  final isActive = i == pin.length;
                  return GestureDetector(
                    onTap: () => focusNode.requestFocus(),
                    child: Container(
                      margin: EdgeInsetsDirectional.only(end: i < 3 ? gap : 0),
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
                            ? Text(
                                pin[i],
                                style: AppTextStyles.font(
                                  context,
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
              );
            },
          ),
        ],
      ),
    );
  }
}
