import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/auth_state.dart';
import '../../services/api_client.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/inline_error_text.dart';

class ChildAccessCodeScreen extends StatefulWidget {
  const ChildAccessCodeScreen({super.key});

  @override
  State<ChildAccessCodeScreen> createState() => _ChildAccessCodeScreenState();
}

class _ChildAccessCodeScreenState extends State<ChildAccessCodeScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  final _apiClient = ApiClient();
  bool _isLoading = false;
  String? _errorMessage;

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
    if (_pin.length != 4 || _isLoading) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final authState = context.read<AuthState>();
    try {
      final student = await _apiClient.verifyAccessCode(_pin);
      await authState.setSelectedStudentId(student.id);
      if (!mounted) return;
      Navigator.pushNamed(context, '/child-success');
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.code == 'access_code_not_found'
            ? 'That code doesn\'t match any child on this account.'
            : e.code == 'not_authenticated'
                ? 'Please sign in as a parent on this device first.'
                : 'Something went wrong. Please try again.';
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
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                                onChanged: (v) {
                  setState(() {});
                  if (v.length == 4) _submit();
                },
                              ),
                            ),
                          ),
                        ),

                        // 4 PIN circles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (i) {
                            final filled = i < _pin.length;
                            final isActive = i == _pin.length;
                            return GestureDetector(
                              onTap: () => _focus.requestFocus(),
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
                                      ? Container(
                                          width: 18,
                                          height: 18,
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
