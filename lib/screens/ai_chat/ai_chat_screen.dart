import 'dart:math';

import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/responsive.dart';
import '../../theme/text_styles.dart';
import 'ai_chat_side_menu_screen.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  bool _chatStarted = false;
  final List<_Msg> _messages = [];
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  int _explainStep = 0;
  int _wrongCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _now() {
    final t = TimeOfDay.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  void _clearActions() {
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].showActions) {
        _messages[i] = _messages[i].copyWith(showActions: false);
      }
    }
  }

  void _addAi(_AiKey key,
      {_BubbleType type = _BubbleType.normal, bool showActions = false}) {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _clearActions();
        _messages.add(_Msg.ai(
          key: key,
          time: _now(),
          type: type,
          showActions: showActions,
        ));
      });
      _scrollToBottom();
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {
      _clearActions();
      _messages.add(_Msg.user(text: text, time: _now()));
    });
    _scrollToBottom();

    if (_explainStep == 0) {
      _addAi(_AiKey.freeReply);
    }
  }

  void _onExplainReply(String text) {
    setState(() {
      _clearActions();
      _messages.add(_Msg.user(text: text, time: _now()));
    });
    _scrollToBottom();
    _controller.clear();

    if (_explainStep == 1) {
      _wrongCount++;
      if (_wrongCount == 1) {
        _addAi(_AiKey.wrong, type: _BubbleType.wrong, showActions: true);
      }
    } else if (_explainStep == 2) {
      _wrongCount++;
      if (_wrongCount <= 1) {
        _addAi(_AiKey.wrong, type: _BubbleType.wrong, showActions: true);
      } else {
        _addAi(_AiKey.wrong, type: _BubbleType.wrongWithSolution, showActions: true);
      }
    }
  }

  void _onGetHint() {
    setState(() => _clearActions());
    if (_explainStep == 1) {
      _addAi(_AiKey.hint1);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        _explainStep = 2;
        _wrongCount = 0;
        _addAi(_AiKey.step2);
      });
    } else if (_explainStep == 2) {
      _addAi(_AiKey.hint2);
    }
  }

  void _onGetSolution() {
    setState(() => _clearActions());
    _addAi(_AiKey.solution);
  }

  void _startExplaining() {
    setState(() {
      _clearActions();
      _chatStarted = true;
      _explainStep = 1;
      _wrongCount = 0;
    });
    _addAi(_AiKey.greeting);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.rs(16),
                vertical: context.rs(12),
              ),
              child: Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: Row(
                  children: [
                    if (Navigator.canPop(context)) ...[
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          isRtl
                              ? Icons.arrow_forward_ios_rounded
                              : Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary,
                          size: context.rs(22),
                        ),
                      ),
                      SizedBox(width: context.rs(12)),
                    ],
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          opaque: false,
                          barrierColor: Colors.transparent,
                          pageBuilder: (ctx, a, b) =>
                              const AIChatSideMenuScreen(),
                        ),
                      ),
                      child: Icon(
                        Icons.menu,
                        color: AppColors.textPrimary,
                        size: context.rs(26),
                      ),
                    ),
                    if (_chatStarted) ...[
                      SizedBox(width: context.rs(12)),
                      Image.asset(
                        'assets/images/fox_sunglasses.png',
                        width: context.rs(32),
                        height: context.rs(32),
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.pets_rounded,
                          color: AppColors.primary,
                          size: context.rs(28),
                        ),
                      ),
                      SizedBox(width: context.rs(8)),
                      Text(
                        l10n.aiChat_title,
                        style: AppTextStyles.font(
                          context,
                          fontSize: context.rs(15),
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Expanded(
              child: _chatStarted
                  ? _ChatView(
                      messages: _messages,
                      controller: _controller,
                      scroll: _scroll,
                      isRtl: isRtl,
                      onSend: () {
                        final text = _controller.text.trim();
                        if (text.isEmpty) return;
                        if (_explainStep > 0) {
                          _onExplainReply(text);
                        } else {
                          _send();
                        }
                      },
                      onVoice: () =>
                          Navigator.pushNamed(context, '/ai-chat-voice'),
                      onGetHint: _onGetHint,
                      onGetSolution: _onGetSolution,
                    )
                  : _WelcomeView(
                      onStart: _startExplaining,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Message model ────────────────────────────────────────────────────────────

enum _BubbleType { normal, wrong, wrongWithSolution }

// Keys for AI messages — resolved at render time so language switches work.
enum _AiKey { greeting, freeReply, wrong, hint1, step2, hint2, solution }

class _Msg {
  final String? userText;   // non-null for user messages
  final _AiKey? aiKey;      // non-null for AI messages
  final bool isUser;
  final String time;
  final _BubbleType type;
  final bool showActions;

  const _Msg.user({
    required String text,
    required this.time,
  })  : userText = text,
        aiKey = null,
        isUser = true,
        type = _BubbleType.normal,
        showActions = false;

  const _Msg.ai({
    required _AiKey key,
    required this.time,
    this.type = _BubbleType.normal,
    this.showActions = false,
  })  : aiKey = key,
        userText = null,
        isUser = false;

  String resolveText(BuildContext context) {
    if (isUser) return userText!;
    final l10n = context.l10n;
    return switch (aiKey!) {
      _AiKey.greeting  => l10n.aiChat_ai_greeting,
      _AiKey.freeReply => l10n.aiChat_ai_freeReply,
      _AiKey.wrong     => l10n.aiChat_ai_wrong,
      _AiKey.hint1     => l10n.aiChat_ai_hint1,
      _AiKey.step2     => l10n.aiChat_ai_step2,
      _AiKey.hint2     => l10n.aiChat_ai_hint2,
      _AiKey.solution  => l10n.aiChat_ai_solution,
    };
  }

  _Msg copyWith({bool? showActions}) => isUser
      ? _Msg.user(text: userText!, time: time)
      : _Msg.ai(
          key: aiKey!,
          time: time,
          type: type,
          showActions: showActions ?? this.showActions,
        );
}

// ─── Welcome view ─────────────────────────────────────────────────────────────

class _WelcomeView extends StatelessWidget {
  final VoidCallback onStart;
  const _WelcomeView({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.rs(32)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/fox_sunglasses.png',
            width: context.rs(160),
            height: context.rs(160),
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(
              Icons.pets_rounded,
              color: AppColors.primary,
              size: context.rs(120),
            ),
          ),
          SizedBox(height: context.rs(24)),
          Text(
            l10n.aiChat_title,
            style: AppTextStyles.font(
              context,
              fontSize: context.rs(22),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.rs(12)),
          Text(
            l10n.aiChat_welcome_subtitle,
            style: AppTextStyles.font(
              context,
              fontSize: context.rs(14),
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.rs(40)),
          GestureDetector(
            onTap: onStart,
            child: Container(
              width: double.infinity,
              height: context.rs(56),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(context.rs(16)),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.primaryDark,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  l10n.aiChat_button_letsChat,
                  style: AppTextStyles.font(
                    context,
                    fontSize: context.rs(16),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat view ────────────────────────────────────────────────────────────────

class _ChatView extends StatelessWidget {
  final List<_Msg> messages;
  final TextEditingController controller;
  final ScrollController scroll;
  final bool isRtl;
  final VoidCallback onSend;
  final VoidCallback onVoice;
  final VoidCallback onGetHint;
  final VoidCallback onGetSolution;

  const _ChatView({
    required this.messages,
    required this.controller,
    required this.scroll,
    required this.isRtl,
    required this.onSend,
    required this.onVoice,
    required this.onGetHint,
    required this.onGetSolution,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: scroll,
            padding: EdgeInsets.symmetric(
              horizontal: context.rs(16),
              vertical: context.rs(12),
            ),
            itemCount: messages.length,
            itemBuilder: (_, i) => _BubbleRow(
              msg: messages[i],
              isRtl: isRtl,
              onGetHint: onGetHint,
              onGetSolution: onGetSolution,
            ),
          ),
        ),
        _InputBar(
          controller: controller,
          onSend: onSend,
          onVoice: onVoice,
          isRtl: isRtl,
        ),
      ],
    );
  }
}

// ─── Bubble row ───────────────────────────────────────────────────────────────

class _BubbleRow extends StatelessWidget {
  final _Msg msg;
  final bool isRtl;
  final VoidCallback onGetHint;
  final VoidCallback onGetSolution;

  const _BubbleRow({
    required this.msg,
    required this.isRtl,
    required this.onGetHint,
    required this.onGetSolution,
  });

  @override
  Widget build(BuildContext context) {
    // Figma: bubbles are 240px wide on a 375px screen.
    // User bubble → right-aligned, AI bubble → left-aligned (same in both LTR and RTL).
    // Bubbles scale with screen width on phones but are capped on tablets so
    // they don't stretch edge-to-edge on a wide screen.
    final bubbleWidth = context.isTablet
        ? min(context.wp(0.72), 560.0)
        : context.wp(0.72);

    return Padding(
      padding: EdgeInsets.only(bottom: context.rs(12)),
      child: Align(
        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: SizedBox(width: bubbleWidth, child: _buildBubble(isRtl)),
      ),
    );
  }

  Widget _buildBubble(bool isRtl) {
    if (msg.type == _BubbleType.wrong ||
        msg.type == _BubbleType.wrongWithSolution) {
      return _WrongBubble(
        msg: msg,
        isRtl: isRtl,
        onGetHint: onGetHint,
        onGetSolution: onGetSolution,
      );
    }
    return _NormalBubble(msg: msg, isRtl: isRtl);
  }
}

class _NormalBubble extends StatelessWidget {
  final _Msg msg;
  final bool isRtl;
  const _NormalBubble({required this.msg, required this.isRtl});

  @override
  Widget build(BuildContext context) {
    // User bubble: always right-aligned → tail always bottom-right (small corner).
    // AI bubble: always left-aligned → tail always bottom-left (small corner).
    // RTL does NOT change physical position, only text direction inside.
    const userTailLeft  = Radius.circular(18);
    const userTailRight = Radius.circular(4);   // user tail: bottom-right
    const aiTailLeft    = Radius.circular(18);
    const aiTailRight   = Radius.circular(18);

    // Figma: timestamp on user bubble is #e0e0e0 (grey), not white
    final timeColor = msg.isUser
        ? const Color(0xFFE0E0E0)
        : AppColors.textHint;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          context.rs(14),
          context.rs(12),
          context.rs(14),
          context.rs(10),
        ),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: msg.isUser
                ? const Radius.circular(18)
                : const Radius.circular(4),
            topRight: const Radius.circular(18),
            bottomLeft: msg.isUser ? userTailLeft : aiTailLeft,
            bottomRight: msg.isUser ? userTailRight : aiTailRight,
          ),
          border: msg.isUser
              ? null
              : Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: msg.isUser
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.resolveText(context),
              style: AppTextStyles.font(
                context,
                fontSize: context.rs(14),
                color: msg.isUser ? Colors.white : AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            SizedBox(height: context.rs(4)),
            // Figma: timestamp row always sits at bottom-right of bubble
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg.time,
                    style: AppTextStyles.font(
                      context,
                      fontSize: context.rs(10),
                      color: timeColor,
                    ),
                  ),
                  if (msg.isUser) ...[
                    SizedBox(width: context.rs(4)),
                    Icon(
                      Icons.done_all,
                      size: context.rs(13),
                      color: timeColor,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WrongBubble extends StatelessWidget {
  final _Msg msg;
  final bool isRtl;
  final VoidCallback onGetHint;
  final VoidCallback onGetSolution;

  const _WrongBubble({
    required this.msg,
    required this.isRtl,
    required this.onGetHint,
    required this.onGetSolution,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          context.rs(14),
          context.rs(12),
          context.rs(14),
          context.rs(10),
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF2C4B0),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4), // tail — AI is always left-aligned
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: const Color(0x33000000)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.resolveText(context),
              style: AppTextStyles.font(
                context,
                fontSize: context.rs(14),
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
            SizedBox(height: context.rs(8)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _InlinePill(
                  label: l10n.aiChat_button_getHint,
                  color: AppColors.primary,
                  onTap: onGetHint,
                ),
                if (msg.type == _BubbleType.wrongWithSolution) ...[
                  SizedBox(width: context.rs(8)),
                  _InlinePill(
                    label: l10n.aiChat_button_getSolution,
                    color: AppColors.green,
                    onTap: onGetSolution,
                  ),
                ],
              ],
            ),
            SizedBox(height: context.rs(6)),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                msg.time,
                style: AppTextStyles.font(
                  context,
                  fontSize: context.rs(10),
                  color: AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlinePill extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _InlinePill(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.rs(16),
          vertical: context.rs(8),
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(context.rs(8)),
        ),
        child: Text(
          label,
          style: AppTextStyles.font(
            context,
            fontSize: context.rs(13),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onVoice;
  final bool isRtl;

  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.onVoice,
    required this.isRtl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final sendButton = GestureDetector(
      onTap: onSend,
      child: Container(
        width: context.rs(36),
        height: context.rs(36),
        margin: isRtl
            ? EdgeInsets.only(left: context.rs(8))
            : EdgeInsets.only(right: context.rs(8)),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: context.rs(17),
        ),
      ),
    );

    final voiceIcon = GestureDetector(
      onTap: onVoice,
      child: Icon(
        Icons.mic_none_rounded,
        color: AppColors.primary,
        size: context.rs(24),
      ),
    );

    final attachIcon = Icon(
      Icons.attach_file_rounded,
      color: AppColors.textHint,
      size: context.rs(20),
    );

    final textField = Expanded(
      child: TextField(
        controller: controller,
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        textAlign: isRtl ? TextAlign.right : TextAlign.left,
        keyboardType: TextInputType.text,
        style: AppTextStyles.font(
          context,
          fontSize: context.rs(14),
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: l10n.aiChat_input_hint,
          hintStyle: AppTextStyles.font(
            context,
            fontSize: context.rs(14),
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.rs(18),
            vertical: context.rs(14),
          ),
        ),
        onSubmitted: (_) => onSend(),
      ),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.rs(16),
        context.rs(10),
        context.rs(16),
        context.rs(16),
      ),
      child: Container(
        height: context.rs(52),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.rs(30)),
          border: Border.all(color: AppColors.border, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: Row(
            children: [
              textField,
              attachIcon,
              SizedBox(width: context.rs(2)),
              voiceIcon,
              SizedBox(width: context.rs(6)),
              sendButton,
            ],
          ),
        ),
      ),
    );
  }
}
