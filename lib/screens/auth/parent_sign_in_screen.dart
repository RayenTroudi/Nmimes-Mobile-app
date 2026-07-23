import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/responsive.dart';
import '../../theme/text_styles.dart';

class ParentSignInScreen extends StatefulWidget {
  const ParentSignInScreen({super.key});

  @override
  State<ParentSignInScreen> createState() => _ParentSignInScreenState();
}

class _ParentSignInScreenState extends State<ParentSignInScreen> {
  final _emailCtrl = TextEditingController();

  bool get _canSubmit => _emailCtrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    // When the keyboard is up, collapse the orange header so the card keeps
    // enough room and the title/field don't get scrolled out of view.
    final headerHeight =
        keyboardInset > 0 ? context.hp(0.12) : context.hp(0.28);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.primary,
      resizeToAvoidBottomInset: true,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              // Orange header area — orange comes from the Scaffold
              // background, matching the "Who are you?" screen so the card's
              // rounded top corners reveal the brand orange behind them.
              // Collapses when the keyboard opens so the title/field stay
              // visible.
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: headerHeight,
                child: SafeArea(
                  bottom: false,
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
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(context.rs(32)),
                        topRight: Radius.circular(context.rs(32)),
                      ),
                    ),
                    child: SingleChildScrollView(
                      // Less top padding with the keyboard up: the mascot is
                      // hidden, so the title needn't clear its overlap.
                      padding: EdgeInsets.fromLTRB(
                          context.rs(20),
                          keyboardInset > 0 ? context.rs(28) : context.rs(80),
                          context.rs(20),
                          context.rs(32)),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth:
                                  context.isTablet ? 520 : double.infinity),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.parentSignIn_title,
                                style: AppTextStyles.font(context,
                                  fontSize: context.rs(28),
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: context.rs(24)),

                              // Email
                              Container(
                                height: context.rs(52),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius:
                                      BorderRadius.circular(context.rs(30)),
                                ),
                                child: TextField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (_) => setState(() {}),
                                  style: AppTextStyles.font(context,
                                      fontSize: context.rs(14),
                                      color: AppColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: l10n.parentSignIn_hint_email,
                                    hintStyle: AppTextStyles.font(context,
                                        fontSize: context.rs(14),
                                        color: AppColors.textHint),
                                    prefixIcon: Icon(Icons.email_outlined,
                                        color: AppColors.textHint,
                                        size: context.rs(20)),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: context.rs(16),
                                        vertical: context.rs(14)),
                                  ),
                                ),
                              ),
                              SizedBox(height: context.rs(32)),

                              // Continue button
                              ConstrainedBox(
                                constraints:
                                    BoxConstraints(minHeight: context.rs(60)),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _canSubmit
                                        ? () => Navigator.pushNamed(
                                            context, '/parent-access-code',
                                            arguments:
                                                _emailCtrl.text.trim())
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      disabledBackgroundColor: AppColors
                                          .primary
                                          .withValues(alpha: 0.35),
                                      foregroundColor: AppColors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.parentSignIn_button_continue,
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.font(context,
                                        fontSize: context.rs(16),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: context.rs(40)),

                              // Don't have an account? Sign Up
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/parent-sign-up'),
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: l10n
                                              .parentSignIn_link_noAccount,
                                          style: AppTextStyles.font(context,
                                            fontSize: context.rs(13),
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              l10n.parentSignIn_link_signUp,
                                          style: AppTextStyles.font(context,
                                            fontSize: context.rs(13),
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
                  ),
                ),
              ),
            ],
          ),

          // Mascot overlapping the card seam. Hidden while the keyboard is
          // open, where the collapsed header leaves no room for it.
          if (keyboardInset == 0)
            Positioned(
              top: headerHeight - context.rs(110),
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/char_auth.png',
                  width: context.rs(160),
                  height: context.rs(160),
                  fit: BoxFit.contain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
