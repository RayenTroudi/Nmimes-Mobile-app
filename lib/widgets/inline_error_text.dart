import 'package:flutter/material.dart';

class InlineErrorText extends StatelessWidget {
  final String? message;

  const InlineErrorText({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message!,
        style: const TextStyle(color: Colors.red, fontSize: 13),
      ),
    );
  }
}
