import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

// ─── Message model ────────────────────────────────────────────────────────────

class _Msg {
  final String text;
  final bool isUser;
  final String time;
  final bool isWrong;
  final bool showGetHint;
  final bool showGetSolution;
  const _Msg(
    this.text, {
    required this.isUser,
    required this.time,
    this.isWrong = false,
    this.showGetHint = false,
    this.showGetSolution = false,
  });
}

// ─── Scripted reply model ─────────────────────────────────────────────────────

class _Reply {
  final String text;
  final bool isWrong;
  final bool showGetHint;
  final bool showGetSolution;
  const _Reply(
    this.text, {
    this.isWrong = false,
    this.showGetHint = false,
    this.showGetSolution = false,
  });
}

const _replies = [
  _Reply(
    'Wrong answer\nLet\'s learn together.',
    isWrong: true,
    showGetHint: true,
  ),
  _Reply(
    'Hint:\nThe problem has 3 constant\nand 1 variable like:\n2x + 5 = 15',
  ),
  _Reply('Great!\nWhat was the first step?'),
  _Reply(
    'Wrong answer\nLet\'s learn together.',
    isWrong: true,
    showGetHint: true,
  ),
  _Reply(
    'Hint:\nWe have to perform action on\nboth sides of equation.',
  ),
  _Reply(
    'Wrong answer\nLet\'s learn together.',
    isWrong: true,
    showGetHint: true,
    showGetSolution: true,
  ),
];

// ─── Main screen ──────────────────────────────────────────────────────────────

class SnapExplainScreen extends StatefulWidget {
  const SnapExplainScreen({super.key});

  @override
  State<SnapExplainScreen> createState() => _SnapExplainScreenState();
}

class _SnapExplainScreenState extends State<SnapExplainScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  int _replyIndex = 0;

  final List<_Msg> _messages = [
    const _Msg(
      'Hi there!\nWhich formula was used?',
      isUser: false,
      time: '16:00',
    ),
  ];

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
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add(_Msg(text, isUser: true, time: _now()));
    });
    _scrollToBottom();
    _addNextReply();
  }

  void _addNextReply() {
    if (_replyIndex >= _replies.length) return;
    final r = _replies[_replyIndex++];
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(
          r.text,
          isUser: false,
          time: _now(),
          isWrong: r.isWrong,
          showGetHint: r.showGetHint,
          showGetSolution: r.showGetSolution,
        ));
      });
      _scrollToBottom();
    });
  }

  void _onGetHint() {
    final last = _messages.last;
    setState(() {
      _messages[_messages.length - 1] = _Msg(
        last.text,
        isUser: last.isUser,
        time: last.time,
        isWrong: last.isWrong,
        showGetHint: false,
        showGetSolution: false,
      );
    });
    _addNextReply();
  }

  void _onGetSolution() {
    Navigator.pushReplacementNamed(context, '/snap-success');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary, size: 24),
                  ),
                  const SizedBox(width: 10),
                  ClipOval(
                    child: Image.asset(
                      'assets/images/nmimes_inlove.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, _) => const Text(
                        '🦊',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.snap_explain_title,
                    style: AppTextStyles.font(context,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (_, i) {
                  final msg = _messages[i];
                  final isLast = i == _messages.length - 1;
                  return _ChatRow(
                    msg: msg,
                    showActions: !msg.isUser && isLast,
                    onGetHint: _onGetHint,
                    onGetSolution: _onGetSolution,
                  );
                },
              ),
            ),

            // Input bar
            _InputBar(controller: _controller, onSend: _send),
          ],
        ),
      ),
    );
  }
}

// ─── Chat row ─────────────────────────────────────────────────────────────────

class _ChatRow extends StatelessWidget {
  final _Msg msg;
  final bool showActions;
  final VoidCallback onGetHint;
  final VoidCallback onGetSolution;

  const _ChatRow({
    required this.msg,
    required this.showActions,
    required this.onGetHint,
    required this.onGetSolution,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isUser = msg.isUser;

    final Color bubbleBg;
    final Color textColor;
    if (isUser) {
      bubbleBg = AppColors.primary;
      textColor = Colors.white;
    } else if (msg.isWrong) {
      bubbleBg = const Color(0xFFEDC4B3);
      textColor = AppColors.textPrimary;
    } else {
      bubbleBg = Colors.white;
      textColor = AppColors.textPrimary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: bubbleBg,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    boxShadow: (!isUser && !msg.isWrong)
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: AppTextStyles.font(context,
                            fontSize: 14,
                            color: textColor,
                            height: 1.45),
                      ),
                      if (msg.time.isNotEmpty) ...[
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
                                  color: isUser
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : AppColors.textHint,
                                ),
                              ),
                              if (isUser) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.done_all_rounded,
                                  size: 12,
                                  color:
                                      Colors.white.withValues(alpha: 0.7),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Get Hint / Get Solution buttons inside wrong bubble
          if (showActions && (msg.showGetHint || msg.showGetSolution)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (msg.showGetHint)
                  _ActionPill(
                    label: l.snap_explain_getHint,
                    color: AppColors.primary,
                    onTap: onGetHint,
                  ),
                if (msg.showGetHint && msg.showGetSolution)
                  const SizedBox(width: 8),
                if (msg.showGetSolution)
                  _ActionPill(
                    label: l.snap_explain_getSolution,
                    color: const Color(0xFF35A468),
                    onTap: onGetSolution,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionPill(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTextStyles.font(context,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
      ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
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
                  hintText: l.snap_explain_typeHint,
                  hintStyle: AppTextStyles.font(context,
                      fontSize: 14, color: AppColors.textHint),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            // Attach icon
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.attach_file_rounded,
                  color: AppColors.textHint, size: 20),
            ),
            // Divider
            Container(
                width: 1, height: 24, color: AppColors.cardBorder),
            // Mic icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: onSend,
                child: Icon(Icons.mic_rounded,
                    color: AppColors.primary, size: 22),
              ),
            ),
            // Send arrow
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: onSend,
                child: Icon(Icons.send_rounded,
                    color: AppColors.primary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
