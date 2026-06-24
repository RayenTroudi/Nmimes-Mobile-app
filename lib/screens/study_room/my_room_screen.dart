import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class MyRoomScreen extends StatefulWidget {
  const MyRoomScreen({super.key});

  @override
  State<MyRoomScreen> createState() => _MyRoomScreenState();
}

class _MyRoomScreenState extends State<MyRoomScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  final List<_Msg> _messages = [
    const _Msg(
      text: "Hi! I have a question from my lesson. I don't get this Geometry problem",
      isUser: true,
      time: '16:00',
      type: _MsgType.text,
    ),
    const _Msg(
      isUser: true,
      time: '16:00',
      type: _MsgType.image,
    ),
    const _Msg(
      sender: 'Richard',
      isUser: false,
      time: '16:05',
      type: _MsgType.voice,
      duration: '0:09',
    ),
    const _Msg(
      sender: 'Guy',
      isUser: false,
      time: '16:07',
      type: _MsgType.voice,
      duration: '0:04',
      isPlaying: true,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add(_Msg(
        text: text,
        isUser: true,
        time: _now(),
        type: _MsgType.text,
      ));
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  String _now() {
    final t = TimeOfDay.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _RoomMenu(
        onEndRoom: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/end-room');
        },
        onInvite: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/invite-code');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
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
                  const SizedBox(width: 4),
                  _GradCapIcon(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peer Learning',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.group,
                                size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '3 students joined',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showMenu,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.more_vert,
                          color: AppColors.textPrimary, size: 22),
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
                itemBuilder: (_, i) => _ChatRow(msg: _messages[i]),
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

enum _MsgType { text, image, voice }

class _Msg {
  final String? text;
  final String? sender;
  final bool isUser;
  final String time;
  final _MsgType type;
  final String? duration;
  final bool isPlaying;

  const _Msg({
    this.text,
    this.sender,
    required this.isUser,
    required this.time,
    required this.type,
    this.duration,
    this.isPlaying = false,
  });
}

// ─── Chat row ─────────────────────────────────────────────────────────────────

class _ChatRow extends StatelessWidget {
  final _Msg msg;
  const _ChatRow({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment:
            msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78),
          child: _bubble(),
        ),
      ),
    );
  }

  Widget _bubble() {
    switch (msg.type) {
      case _MsgType.text:
        return _TextBubble(msg: msg);
      case _MsgType.image:
        return _ImageBubble(msg: msg);
      case _MsgType.voice:
        return _VoiceBubble(msg: msg);
    }
  }
}

class _TextBubble extends StatelessWidget {
  final _Msg msg;
  const _TextBubble({required this.msg});

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
          if (msg.isUser)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'You',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          Text(
            msg.text ?? '',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: msg.isUser ? Colors.white : AppColors.textPrimary,
              height: 1.4,
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

class _ImageBubble extends StatelessWidget {
  final _Msg msg;
  const _ImageBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            child: Container(
              color: AppColors.primary.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'In △ABC, m∠A = 15°, a = 9, and b = 12. Find c\nto the nearest tenth.',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    CustomPaint(
                      size: const Size(80, 60),
                      painter: _TrianglePainter(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 10,
            child: Row(
              children: [
                Text(
                  msg.time,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.done_all,
                    size: 13, color: Colors.white.withValues(alpha: 0.8)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.65, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);

    final tp = GoogleFonts.poppins(fontSize: 8, color: Colors.white);
    void label(String t, double x, double y) {
      TextPainter(
          text: TextSpan(text: t, style: tp), textDirection: TextDirection.ltr)
        ..layout()
        ..paint(canvas, Offset(x, y));
    }

    label('A', -4, size.height - 4);
    label('B', size.width * 0.6 - 2, -12);
    label('C', size.width + 2, size.height - 4);
    label('a', size.width * 0.87, size.height * 0.45);
    label('b', size.width * 0.28, size.height * 0.45);
    label('c', size.width * 0.58, size.height * 0.7);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _VoiceBubble extends StatelessWidget {
  final _Msg msg;
  const _VoiceBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: [
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
            msg.sender ?? '',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: msg.isPlaying
                      ? AppColors.primary
                      : Colors.transparent,
                  border: msg.isPlaying
                      ? null
                      : Border.all(color: AppColors.textSecondary, width: 1.5),
                ),
                child: Icon(
                  msg.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: msg.isPlaying ? Colors.white : AppColors.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _Waveform(active: msg.isPlaying)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                msg.duration ?? '0:00',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                msg.time,
                style: GoogleFonts.poppins(
                    fontSize: 10, color: AppColors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Waveform extends StatelessWidget {
  final bool active;
  const _Waveform({required this.active});

  @override
  Widget build(BuildContext context) {
    final heights = [
      6.0, 12.0, 18.0, 10.0, 22.0, 14.0, 8.0, 20.0, 16.0,
      10.0, 6.0, 14.0, 20.0, 8.0, 16.0, 12.0, 18.0, 10.0,
      22.0, 6.0, 14.0, 18.0, 8.0, 12.0
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: heights.map((h) {
        return Container(
          width: 3,
          height: h,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : const Color(0xFFBBBBBB),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Room context menu ────────────────────────────────────────────────────────

class _RoomMenu extends StatelessWidget {
  final VoidCallback onEndRoom;
  final VoidCallback onInvite;
  const _RoomMenu({required this.onEndRoom, required this.onInvite});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: onEndRoom,
            title: Text(
              'End Room',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.red,
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            onTap: onInvite,
            title: Text(
              'Invite Friends',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Grad cap icon ────────────────────────────────────────────────────────────

class _GradCapIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF3A8FD6),
      ),
      child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
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
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Type here...',
                  hintStyle: GoogleFonts.poppins(
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
                margin: const EdgeInsets.only(right: 8),
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
