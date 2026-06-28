import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';

class SnapHwExplainScreen extends StatefulWidget {
  const SnapHwExplainScreen({super.key});

  @override
  State<SnapHwExplainScreen> createState() => _SnapHwExplainScreenState();
}

class _SnapHwExplainScreenState extends State<SnapHwExplainScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  // How many correct steps the user has explained (0, 1, 2 = done)
  int _correctSteps = 0;
  bool _waitingForReply = false;

  final List<_Msg> _messages = [
    const _Msg(
      text: 'Hi there!\nexplain the resolution in your own words',
      isUser: false,
      time: '16:00',
      showActions: true,
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

  void _clearActions() {
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].showActions) {
        _messages[i] = _messages[i].copyWith(showActions: false);
      }
    }
  }

  void _addAiMessage(String text, {bool showActions = true}) {
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _clearActions();
        _messages.add(_Msg(
          text: text,
          isUser: false,
          time: _now(),
          showActions: showActions,
        ));
        _waitingForReply = false;
      });
      _scrollToBottom();
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty || _waitingForReply) return;
    _controller.clear();

    setState(() {
      _clearActions();
      _messages.add(_Msg(text: text, isUser: true, time: _now()));
      _waitingForReply = true;
    });
    _scrollToBottom();

    if (_correctSteps == 0) {
      _correctSteps++;
      _addAiMessage('Great!\nWhat\'s next?');
    } else if (_correctSteps == 1) {
      _addAiMessage(
          'There is a little confusion.\nThe step you\'ve done is not correct.');
    }
  }

  void _onGetHint() {
    if (_waitingForReply) return;
    setState(() {
      _clearActions();
      _waitingForReply = true;
    });

    if (_correctSteps == 0) {
      _addAiMessage(
          'Hint:\nStep 1 — We need to isolate x.\nStep 2 — Subtract 5 from both sides.\nStep 3 — Divide both sides by 2.');
    } else {
      _addAiMessage(
          'Hint:\nRemember to subtract 5 from both sides first:\n2x + 5 - 5 = 15 - 5\nSo 2x = 10.');
    }
  }

  void _onDontKnow() {
    Navigator.pushReplacementNamed(context, '/snap-hw-success');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final hasBack = _messages.length > 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  if (hasBack) ...[
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.textPrimary, size: 24),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Image.asset(
                    'assets/images/fox_sunglasses.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, e, _) => const Icon(
                        Icons.pets_rounded,
                        color: AppColors.primary,
                        size: 26),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l.snap_hw_explain_title,
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
                  return _ChatRow(
                    msg: msg,
                    onGetHint: _onGetHint,
                    onDontKnow: _onDontKnow,
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

// ─── Message model ────────────────────────────────────────────────────────────

class _Msg {
  final String text;
  final bool isUser;
  final String time;
  final bool showActions;

  const _Msg({
    required this.text,
    required this.isUser,
    required this.time,
    this.showActions = false,
  });

  _Msg copyWith({bool? showActions}) => _Msg(
        text: text,
        isUser: isUser,
        time: time,
        showActions: showActions ?? this.showActions,
      );
}

// ─── Chat row ─────────────────────────────────────────────────────────────────

class _ChatRow extends StatelessWidget {
  final _Msg msg;
  final VoidCallback onGetHint;
  final VoidCallback onDontKnow;

  const _ChatRow({
    required this.msg,
    required this.onGetHint,
    required this.onDontKnow,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: msg.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Bubble
          Align(
            alignment:
                msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
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
                    child: Text(
                      msg.time,
                      style: AppTextStyles.font(context,
                        fontSize: 10,
                        color: msg.isUser
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons below AI messages
          if (!msg.isUser && msg.showActions) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _ActionPill(
                  label: l.snap_hw_explain_getHint,
                  color: AppColors.green,
                  onTap: onGetHint,
                ),
                const SizedBox(width: 8),
                _ActionPill(
                  label: l.snap_hw_explain_dontKnow,
                  color: AppColors.primary,
                  onTap: onDontKnow,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      decoration: const BoxDecoration(
        border:
            Border(top: BorderSide(color: AppColors.cardBorder, width: 0.5)),
      ),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: AppTextStyles.font(context,
                    fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l.snap_hw_explain_typeHint,
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
            const SizedBox(width: 4),
            const Icon(Icons.mic_none_rounded,
                color: AppColors.primary, size: 22),
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
