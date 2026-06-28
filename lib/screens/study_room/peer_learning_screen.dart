import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class PeerLearningScreen extends StatefulWidget {
  const PeerLearningScreen({super.key});

  @override
  State<PeerLearningScreen> createState() => _PeerLearningScreenState();
}

class _PeerLearningScreenState extends State<PeerLearningScreen> {
  late final TextEditingController _roomNameCtrl;
  final _topicCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _codeFocus = FocusNode();
  bool _roomNameCtrlInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_roomNameCtrlInit) {
      _roomNameCtrlInit = true;
      _roomNameCtrl = TextEditingController(
          text: context.l10n.studyRoom_roomNameDefault);
    }
  }

  @override
  void dispose() {
    _roomNameCtrl.dispose();
    _topicCtrl.dispose();
    _codeCtrl.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.arrow_back,
                          color: AppColors.textPrimary, size: 22),
                    ),
                  ),
                  Text(
                    l10n.studyRoom_peerLearning,
                    style: AppTextStyles.font(context,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    // ── Start Your Own Room ──────────────────────────────
                    _Card(
                      borderColor: AppColors.pink,
                      bgColor: const Color(0xFFFFF0F3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.studyRoom_startYourOwnRoom,
                            style: AppTextStyles.font(context,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.studyRoom_createRoomSubtitle,
                            style: AppTextStyles.font(context,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: l10n.studyRoom_roomNameLabel,
                                  style: AppTextStyles.font(context,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: l10n.studyRoom_roomNameEditable,
                                  style: AppTextStyles.font(context,
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Field(
                              controller: _roomNameCtrl,
                              hint: l10n.studyRoom_roomNameFieldHint),
                          const SizedBox(height: 14),
                          Text(
                            l10n.studyRoom_roomTopicLabel,
                            style: AppTextStyles.font(context,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _Field(
                              controller: _topicCtrl,
                              hint: l10n.studyRoom_roomTopicHint),
                          const SizedBox(height: 20),
                          _OrangeButton(
                            label: l10n.studyRoom_createMyRoom,
                            onTap: () =>
                                Navigator.pushNamed(context, '/my-room'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Team Up with Friends ─────────────────────────────
                    _Card(
                      borderColor: AppColors.blue,
                      bgColor: const Color(0xFFEAF6FF),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.studyRoom_teamUpTitle,
                            style: AppTextStyles.font(context,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.studyRoom_teamUpSubtitle,
                            style: AppTextStyles.font(context,
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.studyRoom_enterCode,
                            style: AppTextStyles.font(context,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Hidden text field drives the digit circles
                          Opacity(
                            opacity: 0,
                            child: SizedBox(
                              height: 1,
                              child: TextField(
                                controller: _codeCtrl,
                                focusNode: _codeFocus,
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ),

                          // 4 digit circles
                          GestureDetector(
                            onTap: () => FocusScope.of(context).requestFocus(_codeFocus),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(4, (i) {
                                final code = _codeCtrl.text;
                                final filled = i < code.length;
                                final isActive = i == code.length;
                                return Container(
                                  margin: const EdgeInsetsDirectional.only(end: 14),
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isActive
                                          ? AppColors.primary
                                          : AppColors.cardBorder,
                                      width: isActive ? 2.5 : 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: filled
                                        ? Text(
                                            code[i],
                                            style: AppTextStyles.font(context,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          )
                                        : null,
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Team Up! outline button
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/joined-room'),
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: AppColors.primary, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.studyRoom_teamUpButton,
                                  style: AppTextStyles.font(context,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared widgets ────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Color borderColor;
  final Color bgColor;
  final Widget child;
  const _Card(
      {required this.borderColor,
      required this.bgColor,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: child,
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _Field({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        style: AppTextStyles.font(context,
            fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.font(context,
              fontSize: 14, color: AppColors.textHint),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
    );
  }
}

class _OrangeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OrangeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          border:
              const Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.font(context,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
