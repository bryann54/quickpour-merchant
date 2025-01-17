// lib/core/utils/time_range_utils.dart

import 'package:flutter/material.dart';

class StoreHours {
  final TimeOfDay opening;
  final TimeOfDay closing;
  final bool is24Hours;

  StoreHours({
    required this.opening,
    required this.closing,
    this.is24Hours = false,
  });

  bool isCurrentlyOpen() {
    if (is24Hours) return true;

    final now = TimeOfDay.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final openMinutes = opening.hour * 60 + opening.minute;
    final closeMinutes = closing.hour * 60 + closing.minute;

    if (closeMinutes > openMinutes) {
      // Same day operation (e.g., 9 AM to 5 PM)
      return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
    } else {
      // Overnight operation (e.g., 9 PM to 5 AM)
      return currentMinutes >= openMinutes || currentMinutes <= closeMinutes;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'is24Hours': is24Hours,
      'opening': is24Hours ? null : '${opening.hour}:${opening.minute}',
      'closing': is24Hours ? null : '${closing.hour}:${closing.minute}',
    };
  }

  static StoreHours fromJson(Map<String, dynamic> json) {
    if (json['is24Hours'] == true) {
      return StoreHours(
        opening: const TimeOfDay(hour: 0, minute: 0),
        closing: const TimeOfDay(hour: 23, minute: 59),
        is24Hours: true,
      );
    }

    final openingParts = json['opening'].split(':');
    final closingParts = json['closing'].split(':');

    return StoreHours(
      opening: TimeOfDay(
        hour: int.parse(openingParts[0]),
        minute: int.parse(openingParts[1]),
      ),
      closing: TimeOfDay(
        hour: int.parse(closingParts[0]),
        minute: int.parse(closingParts[1]),
      ),
      is24Hours: false,
    );
  }

  String getDisplayText() {
    if (is24Hours) return '24 Hours';
    return '${_formatTime(opening)} - ${_formatTime(closing)}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
            ? time.hour - 12
            : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
