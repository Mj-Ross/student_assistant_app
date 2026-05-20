// GROUP MEMBERS: [TH MOSIA 222040802, MC MOGOTSI 221023182, TL MOLOI 222004939, SM NKOSI 222020350, K LETELE 223053487]
import 'package:flutter/material.dart';

enum ApplicationStatus {
  pending,
  approved,
  rejected,
}

extension ApplicationStatusExt on ApplicationStatus {
  String get value {
    switch (this) {
      case ApplicationStatus.pending:
        return 'pending';
      case ApplicationStatus.approved:
        return 'approved';
      
    case ApplicationStatus.rejected:
      return 'rejected';
    }
  }

  static ApplicationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return ApplicationStatus.approved;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'pending':
      default:
        return ApplicationStatus.pending;
     }
  }
}  
