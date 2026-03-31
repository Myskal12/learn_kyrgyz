import 'dart:math' as math;

import 'package:flutter/material.dart';

class AdaptivePanelGrid extends StatelessWidget {
  const AdaptivePanelGrid({
    super.key,
    required this.children,
    this.maxColumns = 2,
    this.minItemWidth = 160,
    this.spacing = 12,
    this.runSpacing,
  });

  final List<Widget> children;
  final int maxColumns;
  final double minItemWidth;
  final double spacing;
  final double? runSpacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        if (availableWidth <= 0 || !availableWidth.isFinite) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        }

        final resolvedColumns = math.max(
          1,
          math.min(
            maxColumns,
            ((availableWidth + spacing) / (minItemWidth + spacing)).floor(),
          ),
        );
        final itemWidth =
            (availableWidth - (spacing * (resolvedColumns - 1))) /
            resolvedColumns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing ?? spacing,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}
