import 'package:flutter/material.dart';

class FoxMascot extends StatelessWidget {
  final double size;
  // variant: 'front' (default sitting), 'peek' (peeking over edge), 'sunglasses', 'snap', 'teach', 'gift', 'happy', 'thumbsup'
  final String variant;

  const FoxMascot({super.key, required this.size, this.variant = 'front'});

  String get _asset {
    switch (variant) {
      case 'peek':       return 'assets/images/char_auth.png';
      case 'sunglasses': return 'assets/images/fox_sunglasses.png';
      case 'snap':       return 'assets/images/fox_snap.png';
      case 'teach':      return 'assets/images/fox_teach.png';
      case 'gift':       return 'assets/images/fox_gift.png';
      case 'happy':      return 'assets/images/fox_happy.png';
      case 'thumbsup':   return 'assets/images/fox_thumbsup.png';
      case 'pvp':        return 'assets/images/fox_pvp.png';
      default:           return 'assets/images/nmimes_front.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}
