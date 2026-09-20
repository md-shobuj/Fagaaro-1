import 'package:flutter/material.dart';

/// Enum defining the available user roles in Fagaaro.
enum UserRole {
  attendee,
  organizer,
}

extension UserRoleExtension on UserRole {
  String get title {
    switch (this) {
      case UserRole.attendee:
        return 'Attendee';
      case UserRole.organizer:
        return 'Organizer';
    }
  }

  String get description {
    switch (this) {
      case UserRole.attendee:
        return 'Discover, pay, and join events that matter to you.';
      case UserRole.organizer:
        return 'Create and host meaningful events that bring people together.';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.attendee:
        return Icons.assignment_ind_rounded;
      case UserRole.organizer:
        return Icons.edit_calendar_rounded;
    }
  }
}
