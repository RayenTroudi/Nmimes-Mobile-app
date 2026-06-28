import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../l10n/l10n_extension.dart';

class JoinChallengeScreen extends StatefulWidget {
  const JoinChallengeScreen({super.key});

  @override
  State<JoinChallengeScreen> createState() => _JoinChallengeScreenState();
}

class _JoinChallengeScreenState extends State<JoinChallengeScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _pin => _controller.text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        context.l10n.challenge_joining_code,
                        style: AppTextStyles.font(context,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E2E2E),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, size: 20, color: Color(0xFF5A6677)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Opacity(
                  opacity: 0,
                  child: SizedBox(
                    height: 0,
                    child: OverflowBox(
                      maxHeight: 0,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final filled = i < _pin.length;
                    final isActive = i == _pin.length;
                    return GestureDetector(
                      onTap: () => _focusNode.requestFocus(),
                      child: Container(
                        margin: const EdgeInsetsDirectional.only(end: 16),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive ? AppColors.primary : AppColors.cardBorder,
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
                const SizedBox(height: 24),
                SizedBox(
                  width: 148,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _pin.length == 4
                        ? () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/start-challenge');
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: const BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    child: Text(
                      context.l10n.challenge_join_button,
                      style: AppTextStyles.font(context,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
