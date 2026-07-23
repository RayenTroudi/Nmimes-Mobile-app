import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An invisible, keyboard-connected [TextField] used behind the row of PIN /
/// access-code circles across the auth and join-code screens. The visible
/// circles render the digits; this field captures the actual keystrokes and
/// raises the soft keyboard when focused.
///
/// It must stay laid out at a real, non-zero size. A focused [TextField] with
/// a live IME connection asserts if its render object is forced to zero size —
/// the previous `SizedBox(height: 0) > OverflowBox(maxHeight: 0)` trick threw
/// `BoxConstraints(w=0.0, h=0.0)` the moment the keyboard attached, crashing
/// the screen on submit. Here the field lays out at its natural size inside an
/// [OverflowBox], is fully transparent, and is clipped to a 1×1 footprint by
/// the outer [SizedBox] + [ClipRect] — invisible, but never zero-sized.
class HiddenCodeField extends StatelessWidget {
  const HiddenCodeField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.maxLength,
    this.keyboardType = TextInputType.number,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final int? maxLength;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
      height: 1,
      child: ClipRect(
        child: Opacity(
          opacity: 0,
          child: OverflowBox(
            minWidth: 0,
            maxWidth: double.infinity,
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 200,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                maxLength: maxLength,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                onChanged: onChanged,
                onSubmitted: onSubmitted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
