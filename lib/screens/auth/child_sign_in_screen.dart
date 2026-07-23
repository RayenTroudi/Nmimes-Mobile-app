import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/responsive.dart';
import '../../theme/text_styles.dart';

class ChildSignInScreen extends StatefulWidget {
  const ChildSignInScreen({super.key});

  @override
  State<ChildSignInScreen> createState() => _ChildSignInScreenState();
}

class _ChildSignInScreenState extends State<ChildSignInScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

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

  void _continue() {
    final username = _ctrl.text.trim().toLowerCase();
    if (username.isEmpty) return;
    // The username identifies the student account; the next screen collects
    // the 6-digit code that completes the sign-in.
    Navigator.pushNamed(context, '/child-access-code', arguments: username);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    // When the keyboard is up, collapse the orange header so the card keeps
    // enough room and the title/subtitle don't get scrolled out of view.
    final headerHeight =
        keyboardInset > 0 ? context.hp(0.12) : context.hp(0.28);

    return Scaffold(
      backgroundColor: AppColors.primary,
      resizeToAvoidBottomInset: true,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              // Orange header — orange comes from the Scaffold background,
              // matching the "Who are you?" screen so the card's rounded top
              // corners reveal the brand orange behind them. Collapses when the
              // keyboard opens so the title/subtitle stay visible.
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
                          color: AppColors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),

              // Cream card
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
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            // Less top padding with the keyboard up: the mascot
                            // is hidden, so the title needn't clear its overlap.
                            padding: EdgeInsets.fromLTRB(
                                context.rs(24),
                                keyboardInset > 0
                                    ? context.rs(28)
                                    : context.rs(72),
                                context.rs(24),
                                context.rs(24)),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxWidth: context.isTablet
                                        ? 520
                                        : double.infinity),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.childSignIn_title,
                                      style: AppTextStyles.font(context,
                                        fontSize: context.rs(26),
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: context.rs(6)),
                                    Text(
                                      context.l10n.childSignIn_subtitle,
                                      style: AppTextStyles.font(context,
                                        fontSize: context.rs(14),
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: context.rs(32)),

                                    // Username field
                                    Container(
                                      height: context.rs(58),
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius:
                                            BorderRadius.circular(context.rs(36)),
                                        border: Border.all(
                                            color: const Color(0xFFA8A8A8)),
                                      ),
                                      child: TextField(
                                        controller: _ctrl,
                                        focusNode: _focus,
                                        autocorrect: false,
                                        enableSuggestions: false,
                                        textCapitalization:
                                            TextCapitalization.none,
                                        style: AppTextStyles.font(context,
                                            fontSize: context.rs(14),
                                            color: AppColors.textPrimary),
                                        decoration: InputDecoration(
                                          hintText: context
                                              .l10n.childSignIn_hint_username,
                                          hintStyle: AppTextStyles.font(context,
                                              fontSize: context.rs(14),
                                              color: const Color(0xFFA8A8A8)),
                                          border: InputBorder.none,
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: context.rs(20),
                                                  vertical: context.rs(18)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Continue button — pinned above keyboard
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              context.rs(24), 0, context.rs(24), context.rs(32)),
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minHeight: context.rs(58)),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _ctrl.text.trim().isNotEmpty
                                    ? _continue
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
                                child: Text(
                                  context.l10n.childSignIn_button_continue,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.font(context,
                                    fontSize: context.rs(16),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
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

          // Mascot — straddles the header/card seam. Hidden while the keyboard
          // is open, where the collapsed header leaves no room for it.
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
