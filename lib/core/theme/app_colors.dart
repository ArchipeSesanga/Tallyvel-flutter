import 'package:flutter/material.dart';

/// Brand colours from the TallyVel logo kit and onboarding designs.
abstract final class AppColors {
  /// Deep Green, the primary brand colour.
  static const green = Color(0xFF0F5C4A);

  /// Ink Green, used for dark backgrounds.
  static const ink = Color(0xFF0F3D32);

  /// Stokvel Gold, the accent colour.
  static const gold = Color(0xFFE8A93B);

  /// Page background on light screens.
  static const background = Color(0xFFF6F8F7);

  /// Near-black text.
  static const text = Color(0xFF14231F);

  /// Secondary text.
  static const textMuted = Color(0xFF4A5A55);

  /// Hairline borders and dividers.
  static const border = Color(0xFFE3E9E6);

  /// Inactive indicator dots and track fills.
  static const track = Color(0xFFD3DCD8);

  /// Light green tint (paid, create).
  static const greenTint = Color(0xFFDDF2E8);

  /// Light gold tint (pending, join).
  static const goldTint = Color(0xFFFCEBC8);

  /// Dark gold text on gold tints.
  static const goldDark = Color(0xFF7A4B00);

  /// Light red tint (missed).
  static const redTint = Color(0xFFFADADA);

  /// Red text on red tints.
  static const red = Color(0xFFB3261E);

  /// Light blue tint (locked badge).
  static const blueTint = Color(0xFFE1EAF8);

  /// Blue text on blue tints.
  static const blue = Color(0xFF1F4E96);
}
