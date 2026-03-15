import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // Default durations (minutes)
  static const int defaultFocusDuration = 25;
  static const int defaultShortBreak = 5;
  static const int defaultLongBreak = 15;
  static const int defaultLongBreakInterval = 4;

  // Colors
  static const Color focusColor = Color(0xFFE53935);
  static const Color shortBreakColor = Color(0xFF43A047);
  static const Color longBreakColor = Color(0xFF1E88E5);

  // Strings
  static const String appName = 'PomoLocal';
  static const String focusLabel = 'Focus';
  static const String shortBreakLabel = 'Short Break';
  static const String longBreakLabel = 'Long Break';
}
