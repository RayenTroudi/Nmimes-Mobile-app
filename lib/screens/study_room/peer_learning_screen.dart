import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import '../../widgets/stagger_in.dart';

/// Peer learning hub — create a room, or join one with a 4-digit code.
///
/// Same two-card concept as before; the interaction is what changed. The code
/// entry now reacts per digit (pop, cursor pulse, shake on a short code) and
/// the join button stays disabled until four digits are in, so the screen
/// tells the child where they are instead of silently accepting anything.
class PeerLearningScreen extends StatefulWidget {
  const PeerLearningScreen({super.key});

  @override
  State<PeerLearningScreen> createState() => _PeerLearningScreenState();
}

class _PeerLearningScreenState extends State<PeerLearningScreen>
    with TickerProviderStateMixin {
  static const _codeLength = 4;

  late final TextEditingController _roomNameCtrl;
  final _topicCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _codeFocus = FocusNode();
  bool _roomNameCtrlInit = false;

  /// Index of the circle that most recently received a digit, so only that
  /// one pops rather than the whole row re-animating on every keystroke.
  int? _poppedIndex;

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  /// Drives the empty-slot cursor. Runs only while the field has focus and
  /// the code is incomplete — an always-on repeating controller would keep
  /// the screen rebuilding every frame for no visual gain.
  late final AnimationController _cursor = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _codeFocus.addListener(_syncCursor);
    _codeCtrl.addListener(_onCodeChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_roomNameCtrlInit) {
      _roomNameCtrlInit = true;
      _roomNameCtrl =
          TextEditingController(text: context.l10n.studyRoom_roomNameDefault);
    }
  }

  @override
  void dispose() {
    _codeFocus.removeListener(_syncCursor);
    _codeCtrl.removeListener(_onCodeChanged);
    _roomNameCtrl.dispose();
    _topicCtrl.dispose();
    _codeCtrl.dispose();
    _codeFocus.dispose();
    _shake.dispose();
    _cursor.dispose();
    super.dispose();
  }

  bool get _codeComplete => _codeCtrl.text.length == _codeLength;

  void _syncCursor() {
    final wantsCursor = _codeFocus.hasFocus && !_codeComplete;
    if (wantsCursor && !_cursor.isAnimating) {
      _cursor.repeat(reverse: true);
    } else if (!wantsCursor && _cursor.isAnimating) {
      _cursor.stop();
      _cursor.value = 0;
    }
  }

  int _previousLength = 0;

  void _onCodeChanged() {
    final length = _codeCtrl.text.length;
    final grew = length > _previousLength;
    _previousLength = length;

    if (grew) {
      HapticFeedback.selectionClick();
      // The digit that just landed is the last one typed.
      _poppedIndex = length - 1;
      if (length == _codeLength) HapticFeedback.mediumImpact();
    } else {
      _poppedIndex = null;
    }

    setState(_syncCursor);
  }

  void _submitCode() {
    if (!_codeComplete) {
      // Refuse, visibly. Previously this navigated with an empty code.
      HapticFeedback.heavyImpact();
      _codeFocus.requestFocus();
      _shake.forward(from: 0);
      return;
    }
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/joined-room');
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
                  _TapIcon(
                    onTap: () => Navigator.pop(context),
                    icon: Icons.arrow_back,
                  ),
                  Text(
                    l10n.studyRoom_peerLearning,
                    style: AppTextStyles.font(
                      context,
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
                    StaggerIn(
                      index: 0,
                      child: _Card(
                        borderColor: AppColors.pink,
                        bgColor: const Color(0xFFFFF0F3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.studyRoom_startYourOwnRoom,
                              style: AppTextStyles.font(
                                context,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.studyRoom_createRoomSubtitle,
                              style: AppTextStyles.font(
                                context,
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
                                    style: AppTextStyles.font(
                                      context,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: l10n.studyRoom_roomNameEditable,
                                    style: AppTextStyles.font(
                                      context,
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
                              hint: l10n.studyRoom_roomNameFieldHint,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n.studyRoom_roomTopicLabel,
                              style: AppTextStyles.font(
                                context,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _Field(
                              controller: _topicCtrl,
                              hint: l10n.studyRoom_roomTopicHint,
                            ),
                            const SizedBox(height: 20),
                            _PressButton(
                              label: l10n.studyRoom_createMyRoom,
                              filled: true,
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                Navigator.pushNamed(context, '/my-room');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Team Up with Friends ─────────────────────────────
                    StaggerIn(
                      index: 1,
                      child: _Card(
                        borderColor: AppColors.blue,
                        bgColor: const Color(0xFFEAF6FF),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.studyRoom_teamUpTitle,
                              style: AppTextStyles.font(
                                context,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.studyRoom_teamUpSubtitle,
                              style: AppTextStyles.font(
                                context,
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.studyRoom_enterCode,
                              style: AppTextStyles.font(
                                context,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Hidden text field drives the digit circles.
                            // Sized to zero rather than merely transparent so
                            // it cannot intercept taps meant for the circles.
                            SizedBox(
                              width: 0,
                              height: 0,
                              child: Opacity(
                                opacity: 0,
                                child: TextField(
                                  controller: _codeCtrl,
                                  focusNode: _codeFocus,
                                  keyboardType: TextInputType.number,
                                  maxLength: _codeLength,
                                  // Reject anything that isn't a digit at the
                                  // source, so the circles never render a
                                  // stray character from a paste or an IME.
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _submitCode(),
                                ),
                              ),
                            ),

                            _CodeRow(
                              code: _codeCtrl.text,
                              length: _codeLength,
                              poppedIndex: _poppedIndex,
                              shake: _shake,
                              cursor: _cursor,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                FocusScope.of(context).requestFocus(_codeFocus);
                              },
                            ),
                            const SizedBox(height: 20),

                            _PressButton(
                              label: l10n.studyRoom_teamUpButton,
                              filled: false,
                              // Dimmed, not removed: the button stays visible
                              // and tappable so tapping it can explain itself
                              // by shaking the code row.
                              dimmed: !_codeComplete,
                              onTap: _submitCode,
                            ),
                          ],
                        ),
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

// ─── Code entry ────────────────────────────────────────────────────────────

/// The four digit circles. Rebuilds only when the code changes; the pop,
/// shake and cursor all run as paint-time transforms driven by listenables,
/// so typing a digit does not relayout the card.
class _CodeRow extends StatelessWidget {
  final String code;
  final int length;
  final int? poppedIndex;
  final Animation<double> shake;
  final Animation<double> cursor;
  final VoidCallback onTap;

  const _CodeRow({
    required this.code,
    required this.length,
    required this.poppedIndex,
    required this.shake,
    required this.cursor,
    required this.onTap,
  });

  /// Preferred circle diameter and gap. Both shrink together on narrow
  /// screens rather than overflowing — four 58px circles plus their gaps need
  /// 274px, which a 320px phone does not have once card and screen padding
  /// are taken out.
  static const _preferredSize = 58.0;
  static const _preferredGap = 14.0;
  static const _minSize = 40.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedBuilder(
        animation: shake,
        builder: (context, child) {
          // Damped oscillation: amplitude decays as the controller runs.
          final dx = 10 *
              (1 - shake.value) *
              ((shake.value * 6).floor().isEven ? 1 : -1);
          return Transform.translate(offset: Offset(dx, 0), child: child);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            var size = _preferredSize;
            var gap = _preferredGap;

            if (constraints.hasBoundedWidth) {
              final needed =
                  _preferredSize * length + _preferredGap * (length - 1);
              if (needed > constraints.maxWidth) {
                // Scale circles and gaps by the same factor so the row keeps
                // its proportions, then floor the diameter so it stays
                // tappable.
                final scale = constraints.maxWidth / needed;
                size = (_preferredSize * scale).clamp(_minSize, _preferredSize);
                gap = (_preferredGap * scale).clamp(4.0, _preferredGap);
              }
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(length, (i) {
                return _CodeCircle(
                  digit: i < code.length ? code[i] : null,
                  isActive: i == code.length,
                  popping: poppedIndex == i,
                  cursor: cursor,
                  size: size,
                  gap: i == length - 1 ? 0 : gap,
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _CodeCircle extends StatelessWidget {
  final String? digit;
  final bool isActive;
  final bool popping;
  final Animation<double> cursor;

  /// Diameter, computed by [_CodeRow] to fit the available width.
  final double size;

  /// Trailing gap; zero on the last circle.
  final double gap;

  const _CodeCircle({
    required this.digit,
    required this.isActive,
    required this.popping,
    required this.cursor,
    required this.size,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    final filled = digit != null;

    return Container(
      margin: EdgeInsetsDirectional.only(end: gap),
      width: size,
      height: size,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : (filled ? AppColors.blue : AppColors.border),
            width: isActive ? 2.5 : 1.5,
          ),
          boxShadow: [
            // The active slot glows in brand orange; the rest keep the
            // original flat drop shadow.
            BoxShadow(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.28)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isActive ? 10 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          // Digit and caret track the circle so a shrunk row stays
          // proportionate instead of a small circle around full-size text.
          child: filled
              ? _PopDigit(
                  key: ValueKey(digit),
                  digit: digit!,
                  animate: popping,
                  fontSize: size * 0.34,
                )
              : _Cursor(
                  cursor: cursor,
                  visible: isActive,
                  height: size * 0.38,
                ),
        ),
      ),
    );
  }
}

/// A digit that scales in from 1.6x when it first lands.
///
/// [animate] is false for digits that were already present, so backspacing
/// does not re-pop every earlier digit.
class _PopDigit extends StatelessWidget {
  final String digit;
  final bool animate;
  final double fontSize;

  const _PopDigit({
    super.key,
    required this.digit,
    required this.animate,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      digit,
      style: AppTextStyles.font(
        context,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );

    if (!animate) return text;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.elasticOut,
      builder: (context, t, child) =>
          Transform.scale(scale: 0.6 + 0.4 * t, child: child),
      child: text,
    );
  }
}

/// Blinking caret in the slot awaiting the next digit.
class _Cursor extends StatelessWidget {
  final Animation<double> cursor;
  final bool visible;
  final double height;

  const _Cursor({
    required this.cursor,
    required this.visible,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return FadeTransition(
      opacity: cursor,
      child: Container(
        width: 2,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// ─── Shared widgets ────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Color borderColor;
  final Color bgColor;
  final Widget child;
  const _Card({
    required this.borderColor,
    required this.bgColor,
    required this.child,
  });

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

/// Back/close icon with a press response, replacing a bare [GestureDetector]
/// around an [Icon] that gave no feedback at all.
class _TapIcon extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  const _TapIcon({required this.onTap, required this.icon});

  @override
  State<_TapIcon> createState() => _TapIconState();
}

class _TapIconState extends State<_TapIcon> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(widget.icon, color: AppColors.textPrimary, size: 22),
        ),
      ),
    );
  }
}

class _Field extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  const _Field({required this.controller, required this.hint});

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        // The focused field outlines itself in brand orange — previously
        // there was no visual difference between focused and idle.
        border: Border.all(
          color: focused ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: focused
                ? AppColors.primary.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: focused ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        style: AppTextStyles.font(
          context,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: AppTextStyles.font(
            context,
            fontSize: 14,
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

/// Pill button that presses down on tap.
///
/// [filled] picks the solid orange treatment (create) versus the outline
/// (team up); [dimmed] fades it to signal "not yet" without disabling the
/// tap, so the button can still explain why nothing happened.
class _PressButton extends StatefulWidget {
  final String label;
  final bool filled;
  final bool dimmed;
  final VoidCallback onTap;

  const _PressButton({
    required this.label,
    required this.filled,
    required this.onTap,
    this.dimmed = false,
  });

  @override
  State<_PressButton> createState() => _PressButtonState();
}

class _PressButtonState extends State<_PressButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final filled = widget.filled;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: widget.dimmed ? 0.55 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: filled ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: filled ? Colors.white : AppColors.primary,
                width: 2,
              ),
              boxShadow: filled
                  ? [
                      BoxShadow(
                        color: AppColors.primary
                            .withValues(alpha: _pressed ? 0.18 : 0.35),
                        blurRadius: _pressed ? 4 : 8,
                        offset: Offset(0, _pressed ? 2 : 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                widget.label,
                style: AppTextStyles.font(
                  context,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
