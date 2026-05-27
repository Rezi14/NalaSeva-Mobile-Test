import 'package:flutter/material.dart';

class DateTimeParser {
  static DateTime? parseDateOnly(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    if (normalized.isEmpty) return null;

    final dateTime = DateTime.tryParse(normalized);
    if (dateTime == null) return null;
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static DateTime? parseDateTime(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    if (normalized.isEmpty) return null;

    return DateTime.tryParse(normalized);
  }

  static int? parseMinutesOfDay(String? value) {
    if (value == null) return null;
    final normalized = value.trim();
    if (normalized.isEmpty) return null;

    final parts = normalized.split(':');
    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0].trim());
    final minute = int.tryParse(parts[1].trim());
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return hour * 60 + minute;
  }

  static TimeOfDay? parseTimeOfDay(String? value) {
    final minutes = parseMinutesOfDay(value);
    if (minutes == null) return null;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }
}
