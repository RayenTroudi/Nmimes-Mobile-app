import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n_extension.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../providers/auth_state.dart';
import '../../services/supabase_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/inline_error_text.dart';

class ChildAccessCodeScreen extends StatefulWidget {
  const ChildAccessCodeScreen({super.key});

  @override
  State<ChildAccessCodeScreen> createState() => _ChildAccessCodeScreenState();
}

class _ChildAccessCodeScreenState extends State<ChildAccessCodeScreen> {
  static const codeLength = 6;

  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  String? _errorMessage;

  /// Username passed from the previous screen; identifies the student account.
  String get _username {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is String ? args : '';
  }

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _pin => _ctrl.text;

  Future<void> _submit() async {
    if (_pin.length != codeLength || _isLoading) return;
    final username = _username;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final authState = context.read<AuthState>();
    try {
      // A full, independent student sign-in — no parent session required.
      await _supabaseService.signInStudent(
        username: username,
        accessCode: _pin,
      );
      await authState.setSelectedStudentId(
        Supabase.instance.client.auth.currentUser?.id,
      );
      if (!mounted) return;
      Navigator.pushNamed(context, '/child-success');
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      setState(() {
        _errorMessage = msg.contains('invalid login')
            ? 'That username and code don\'t match. Please check and try again.'
            : msg.contains('failed host lookup') || msg.contains('socket')
                ? 'No internet connection. Please check your network.'
                : e.message;
        _ctrl.clear();
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
        _ctrl.clear();
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
              // Orange header
              SizedBox(
                height: screenHeight * 0.28,
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),

              // Cream card
              Expanded(
                child: GestureDetector(
                  onTap: () => _focus.requestFocus(),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.childAccessCode_title,
                          style: AppTextStyles.font(context,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.childAccessCode_subtitle,
                          style: AppTextStyles.font(context,
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Hidden text field
                        Opacity(
                          opacity: 0,
                          child: SizedBox(
                            height: 0,
                            child: OverflowBox(
                              maxHeight: 0,
                              child: TextField(
                                controller: _ctrl,
                                focusNode: _focus,
                                maxLength: codeLength,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                                onChanged: (v) {
                  setState(() {});
                  if (v.length == codeLength) _submit();
                },
                              ),
                            ),
                          ),
                        ),

                        // 6 code circles (sized to fit six across)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(codeLength, (i) {
                            final filled = i < _pin.length;
                            final isActive = i == _pin.length;
                            return GestureDetector(
                              onTap: () => _focus.requestFocus(),
                              child: Container(
                                margin: EdgeInsetsDirectional.only(
                                    end: i < codeLength - 1 ? 8 : 0),
                                width: 46,
                                height: 46,
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
                                          width: 14,
                                          height: 14,
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
                        ),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        InlineErrorText(message: _errorMessage),

                        const Spacer(),
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
