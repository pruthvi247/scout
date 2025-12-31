/// User roles in the system
enum UserRole {
  admin,
  incharge,
  activist,
  volunteer;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.incharge:
        return 'Incharge';
      case UserRole.activist:
        return 'Activist';
      case UserRole.volunteer:
        return 'Volunteer';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'incharge':
        return UserRole.incharge;
      case 'activist':
        return UserRole.activist;
      case 'volunteer':
        return UserRole.volunteer;
      default:
        throw ArgumentError('Invalid role: $role');
    }
  }
}

/// Activity status
enum ActivityStatus {
  pending,
  verified,
  rejected;

  String get displayName {
    switch (this) {
      case ActivityStatus.pending:
        return 'Pending';
      case ActivityStatus.verified:
        return 'Verified';
      case ActivityStatus.rejected:
        return 'Rejected';
    }
  }

  static ActivityStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ActivityStatus.pending;
      case 'verified':
        return ActivityStatus.verified;
      case 'rejected':
        return ActivityStatus.rejected;
      default:
        throw ArgumentError('Invalid status: $status');
    }
  }
}

/// Post type
enum PostType {
  nominated,
  elected,
  volunteer;

  String get displayName {
    switch (this) {
      case PostType.nominated:
        return 'Nominated';
      case PostType.elected:
        return 'Elected';
      case PostType.volunteer:
        return 'Volunteer';
    }
  }

  static PostType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'nominated':
        return PostType.nominated;
      case 'elected':
        return PostType.elected;
      case 'volunteer':
        return PostType.volunteer;
      default:
        throw ArgumentError('Invalid post type: $type');
    }
  }
}
