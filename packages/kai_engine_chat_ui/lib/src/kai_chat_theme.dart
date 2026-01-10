import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// A small ThemeExtension to customize the built-in chat widgets.
class KaiChatTheme extends ThemeExtension<KaiChatTheme> {
  final double maxBubbleWidthMobile;
  final double maxBubbleWidthDesktop;
  final double bubbleRadius;
  final EdgeInsets bubblePadding;
  final EdgeInsets listPadding;
  final double itemSpacing;

  final Color? userBubbleColor;
  final Color? aiBubbleColor;
  final Color? userTextColor;
  final Color? aiTextColor;

  const KaiChatTheme({
    this.maxBubbleWidthMobile = 280,
    this.maxBubbleWidthDesktop = 400,
    this.bubbleRadius = 16,
    this.bubblePadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    this.listPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    this.itemSpacing = 12,
    this.userBubbleColor,
    this.aiBubbleColor,
    this.userTextColor,
    this.aiTextColor,
  });

  @override
  KaiChatTheme copyWith({
    double? maxBubbleWidthMobile,
    double? maxBubbleWidthDesktop,
    double? bubbleRadius,
    EdgeInsets? bubblePadding,
    EdgeInsets? listPadding,
    double? itemSpacing,
    Color? userBubbleColor,
    Color? aiBubbleColor,
    Color? userTextColor,
    Color? aiTextColor,
  }) {
    return KaiChatTheme(
      maxBubbleWidthMobile: maxBubbleWidthMobile ?? this.maxBubbleWidthMobile,
      maxBubbleWidthDesktop: maxBubbleWidthDesktop ?? this.maxBubbleWidthDesktop,
      bubbleRadius: bubbleRadius ?? this.bubbleRadius,
      bubblePadding: bubblePadding ?? this.bubblePadding,
      listPadding: listPadding ?? this.listPadding,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      userBubbleColor: userBubbleColor ?? this.userBubbleColor,
      aiBubbleColor: aiBubbleColor ?? this.aiBubbleColor,
      userTextColor: userTextColor ?? this.userTextColor,
      aiTextColor: aiTextColor ?? this.aiTextColor,
    );
  }

  @override
  KaiChatTheme lerp(ThemeExtension<KaiChatTheme>? other, double t) {
    if (other is! KaiChatTheme) return this;
    return KaiChatTheme(
      maxBubbleWidthMobile: lerpDouble(maxBubbleWidthMobile, other.maxBubbleWidthMobile, t)!,
      maxBubbleWidthDesktop: lerpDouble(maxBubbleWidthDesktop, other.maxBubbleWidthDesktop, t)!,
      bubbleRadius: lerpDouble(bubbleRadius, other.bubbleRadius, t)!,
      bubblePadding: EdgeInsets.lerp(bubblePadding, other.bubblePadding, t)!,
      listPadding: EdgeInsets.lerp(listPadding, other.listPadding, t)!,
      itemSpacing: lerpDouble(itemSpacing, other.itemSpacing, t)!,
      userBubbleColor: Color.lerp(userBubbleColor, other.userBubbleColor, t),
      aiBubbleColor: Color.lerp(aiBubbleColor, other.aiBubbleColor, t),
      userTextColor: Color.lerp(userTextColor, other.userTextColor, t),
      aiTextColor: Color.lerp(aiTextColor, other.aiTextColor, t),
    );
  }
}

extension KaiChatThemeX on BuildContext {
  KaiChatTheme get kaiChatTheme => Theme.of(this).extension<KaiChatTheme>() ?? const KaiChatTheme();
}
