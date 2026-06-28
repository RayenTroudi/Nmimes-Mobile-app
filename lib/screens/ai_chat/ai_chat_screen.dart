import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

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

  // Explaining-back sub-flow state
  // 0 = not started, 1..n = step index
  int _explainStep = 0;
  // how many times user was wrong on current step
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

  void _addAi(String text,
      {_BubbleType type = _BubbleType.normal, bool showActions = false}) {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _clearActions();
        _messages.add(_Msg(
          text: text,
          isUser: false,
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
      _messages.add(_Msg(text: text, isUser: true, time: _now()));
    });
    _scrollToBottom();

    // Normal free chat — just echo a helpful response
    if (_explainStep == 0) {
      _addAi(
          "That's a great question! Let me help you understand that better.");
    }
    // Explaining back flow responses handled by _onExplainReply
  }

  // Called when user taps send during explain-back flow
  void _onExplainReply(String text) {
    setState(() {
      _clearActions();
      _messages.add(_Msg(text: text, isUser: true, time: _now()));
    });
    _scrollToBottom();
    _controller.clear();

    if (_explainStep == 1) {
      // First question about formula
      // Wrong answer → show feedback
      _wrongCount++;
      if (_wrongCount == 1) {
        _addAi('Wrong answer\nLet\'s learn together.',
            type: _BubbleType.wrong, showActions: true);
      }
    } else if (_explainStep == 2) {
      // First step question
      _wrongCount++;
      if (_wrongCount <= 1) {
        _addAi('Wrong answer\nLet\'s learn together.',
            type: _BubbleType.wrong, showActions: true);
      } else {
        _addAi('Wrong answer\nLet\'s learn together.',
            type: _BubbleType.wrongWithSolution, showActions: true);
      }
    }
  }

  void _onGetHint() {
    setState(() => _clearActions());
    if (_explainStep == 1) {
      _addAi(
          'Hint:\nThe problem has 3 constant\nand 1 variable like:\n2x + 5 = 15');
      // After hint, progress to next step
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        _explainStep = 2;
        _wrongCount = 0;
        _addAi('Great!\nWhat was the first step?');
      });
    } else if (_explainStep == 2) {
      _addAi(
          'Hint:\nWe have to perform action on\nboth sides of equation.');
    }
  }

  void _onGetSolution() {
    setState(() => _clearActions());
    _addAi(
        'Solution:\nStep 1: 2x + 5 - 5 = 15 - 5\nStep 2: 2x = 10\nStep 3: x = 5');
  }

  void _startExplaining() {
    setState(() {
      _clearActions();
      _chatStarted = true;
      _explainStep = 1;
      _wrongCount = 0;
    });
    _addAi('Hi there!\nWhich formula was used?');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/ai-chat-menu'),
                    child: const Icon(Icons.menu,
                        color: AppColors.textPrimary, size: 26),
                  ),
                  if (_chatStarted) ...[
                    const SizedBox(width: 12),
                    Image.asset(
                      'assets/images/fox_sunglasses.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                          Icons.pets_rounded,
                          color: AppColors.primary,
                          size: 28),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.aiChat_title,
                      style: AppTextStyles.font(context,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Expanded(
              child: _chatStarted
                  ? _ChatView(
                      messages: _messages,
                      controller: _controller,
                      scroll: _scroll,
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

class _Msg {
  final String text;
  final bool isUser;
  final String time;
  final _BubbleType type;
  final bool showActions;

  const _Msg({
    required this.text,
    required this.isUser,
    required this.time,
    this.type = _BubbleType.normal,
    this.showActions = false,
  });

  _Msg copyWith({bool? showActions}) => _Msg(
        text: text,
        isUser: isUser,
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
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/fox_sunglasses.png',
            width: 160,
            height: 160,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(Icons.pets_rounded,
                color: AppColors.primary, size: 120),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.aiChat_title,
            style: AppTextStyles.font(context,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.aiChat_welcome_subtitle,
            style: AppTextStyles.font(context,
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          GestureDetector(
            onTap: onStart,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(50),
                border: const Border.fromBorderSide(
                    BorderSide(color: Colors.white, width: 2.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  l10n.aiChat_button_letsChat,
                  style: AppTextStyles.font(context,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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
  final VoidCallback onSend;
  final VoidCallback onVoice;
  final VoidCallback onGetHint;
  final VoidCallback onGetSolution;

  const _ChatView({
    required this.messages,
    required this.controller,
    required this.scroll,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: messages.length,
            itemBuilder: (_, i) => _BubbleRow(
              msg: messages[i],
              onGetHint: onGetHint,
              onGetSolution: onGetSolution,
            ),
          ),
        ),
        _InputBar(
            controller: controller, onSend: onSend, onVoice: onVoice),
      ],
    );
  }
}

// ─── Bubble row ───────────────────────────────────────────────────────────────

class _BubbleRow extends StatelessWidget {
  final _Msg msg;
  final VoidCallback onGetHint;
  final VoidCallback onGetSolution;

  const _BubbleRow(
      {required this.msg,
      required this.onGetHint,
      required this.onGetSolution});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: msg.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: msg.isUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75),
              child: _buildBubble(),
            ),
          ),
          if (!msg.isUser && msg.showActions) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _ActionBtn(
                  label: l10n.aiChat_button_getHint,
                  color: AppColors.primary,
                  onTap: onGetHint,
                ),
                if (msg.type == _BubbleType.wrongWithSolution) ...[
                  const SizedBox(width: 8),
                  _ActionBtn(
                    label: l10n.aiChat_button_getSolution,
                    color: AppColors.green,
                    onTap: onGetSolution,
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBubble() {
    if (msg.type == _BubbleType.wrong ||
        msg.type == _BubbleType.wrongWithSolution) {
      return _WrongBubble(msg: msg);
    }
    return _NormalBubble(msg: msg);
  }
}

class _NormalBubble extends StatelessWidget {
  final _Msg msg;
  const _NormalBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: msg.isUser ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
          bottomRight: Radius.circular(msg.isUser ? 4 : 18),
        ),
        boxShadow: msg.isUser
            ? null
            : [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            msg.text,
            style: AppTextStyles.font(context,
              fontSize: 14,
              color: msg.isUser ? Colors.white : AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.time,
                  style: AppTextStyles.font(context,
                    fontSize: 10,
                    color: msg.isUser
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.textHint,
                  ),
                ),
                if (msg.isUser) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.done_all,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.8)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WrongBubble extends StatelessWidget {
  final _Msg msg;
  const _WrongBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF2C4B0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            msg.text,
            style: AppTextStyles.font(context,
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              msg.time,
              style: AppTextStyles.font(context,
                  fontSize: 10, color: AppColors.textHint),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTextStyles.font(context,
            fontSize: 13,
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
  const _InputBar(
      {required this.controller,
      required this.onSend,
      required this.onVoice});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: AppTextStyles.font(context,
                    fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.aiChat_input_hint,
                  hintStyle: AppTextStyles.font(context,
                      fontSize: 14, color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const Icon(Icons.attach_file_rounded,
                color: AppColors.textHint, size: 20),
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onVoice,
              child: const Icon(Icons.mic_none_rounded,
                  color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsetsDirectional.only(end: 8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
