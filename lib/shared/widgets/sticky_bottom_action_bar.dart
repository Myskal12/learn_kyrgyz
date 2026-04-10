import 'package:flutter/material.dart';

class StickyBottomActionBar extends StatelessWidget {
  const StickyBottomActionBar({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomInset = media.viewInsets.bottom;
    final safeBottom = media.padding.bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.9)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding:
              padding ??
              EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12 + (bottomInset > 0 ? bottomInset : safeBottom),
              ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth ?? double.infinity,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
