import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../challenges/challenges_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/overscroll_reveal.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && _currentIndex == 0) {
      _currentIndex = args;
    }
  }

  static const _tabs = [
    HomeScreen(),
    AIChatScreen(),
    ChallengesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverscrollReveal(
        childIsScrollable: true,
        child: IndexedStack(
          index: _currentIndex,
          children: _tabs,
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
