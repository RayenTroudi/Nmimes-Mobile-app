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
      _visited.add(args);
    }
  }

  static const _tabs = [
    HomeScreen(),
    AIChatScreen(),
    ChallengesScreen(),
    ProfileScreen(),
  ];

  /// Tabs the user has actually opened. An [IndexedStack] builds every child
  /// up front, so all four screens used to mount — and run their entry
  /// animations and any startup work — while the user was still on home.
  /// Building a tab only once it is first selected keeps startup to one
  /// screen; [IndexedStack] then preserves its state as before.
  final _visited = <int>{0};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverscrollReveal(
        childIsScrollable: true,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            for (var i = 0; i < _tabs.length; i++)
              if (_visited.contains(i)) _tabs[i] else const SizedBox.shrink(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() {
          _currentIndex = i;
          _visited.add(i);
        }),
      ),
    );
  }
}
