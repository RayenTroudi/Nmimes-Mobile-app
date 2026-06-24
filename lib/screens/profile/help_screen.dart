import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  final List<_Msg> _messages = [
    const _Msg(
      text: 'Hi, i need to ask something about my profile setup.',
      isUser: true,
      time: '16:00',
    ),
    const _Msg(
      text: 'Sure! 😄 Go ahead, I\'ll be happy to help you.',
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

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add(_Msg(text: text, isUser: true, time: _now()));
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add(const _Msg(
          text: 'Thanks for reaching out! Our team will get back to you shortly.',
          isUser: false,
          time: '16:01',
        ));
      });
      Future.delayed(const Duration(milliseconds: 120), () {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7E8),
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
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF2E2E2E), size: 22),
                  ),
                  const Spacer(),
                  // Fox avatar + Nmimes title
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/nmimes_matcha.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                            Icons.pets_rounded,
                            color: AppColors.primary,
                            size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nmimes',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2E2E2E),
                    ),
                  ),
                  const Spacer(),
                  // Balance the back arrow
                  const SizedBox(width: 22),
                ],
              ),
            ),

            // Date separator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Today',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF5A6677),
                ),
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _BubbleRow(msg: _messages[i]),
              ),
            ),

            // Input bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: const Color(0xFFA8A8A8)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF2E2E2E)),
                      decoration: InputDecoration(
                        hintText: 'Type here...',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFFA8A8A8)),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  // Attachment
                  const Icon(Icons.attach_file_rounded,
                      color: Color(0xFF5A6677), size: 20),
                  const SizedBox(width: 4),
                  // Vertical divider
                  Container(
                      width: 1, height: 24, color: const Color(0xFFE0E0E0)),
                  const SizedBox(width: 4),
                  // Mic
                  const Icon(Icons.mic_none_rounded,
                      color: AppColors.primary, size: 22),
                  const SizedBox(width: 6),
                  // Send
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 36,
                      height: 36,
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isUser;
  final String time;
  const _Msg({required this.text, required this.isUser, required this.time});
}

class _BubbleRow extends StatelessWidget {
  final _Msg msg;
  const _BubbleRow({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment:
            msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            decoration: BoxDecoration(
              color: msg.isUser ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                bottomRight: Radius.circular(msg.isUser ? 4 : 18),
              ),
              border: msg.isUser
                  ? null
                  : Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: msg.isUser
                        ? Colors.white
                        : const Color(0xFF2E2E2E),
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
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: msg.isUser
                              ? const Color(0xFFE0E0E0)
                              : const Color(0xFF5A6677),
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
          ),
        ),
      ),
    );
  }
}
