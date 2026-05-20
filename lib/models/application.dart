// GROUP MEMBERS: [Full Names and Student Numbers]

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
      default:
        return ApplicationStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case ApplicationStatus.pending:
        return Colors.orange;
      case ApplicationStatus.approved:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
    }
  }
}

class ModuleSelection {
  final int academicLevel;
  final String moduleCode;
  final String moduleName;
  final bool meetsRequirements;

  ModuleSelection({
    required this.academicLevel,
    required this.moduleCode,
    required this.moduleName,
    required this.meetsRequirements,
  });

  factory ModuleSelection.fromJson(Map<String, dynamic> json) {
    return ModuleSelection(
      academicLevel: json['academic_level'],
      moduleCode: json['module_code'],
      moduleName: json['module_name'],
      meetsRequirements: json['meets_requirements'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'academic_level': academicLevel,
      'module_code': moduleCode,
      'module_name': moduleName,
      'meets_requirements': meetsRequirements,
    };
  }
}

class StudentApplication {
  final String id;
  final String userId;
  final int yearOfStudy;
  final List<ModuleSelection> selectedModules;
  final ApplicationStatus status;
  final String? adminComment;
  final DateTime submittedAt;
  final DateTime? updatedAt;
  final List<String> supportingDocuments;

  StudentApplication({
    required this.id,
    required this.userId,
    required this.yearOfStudy,
    required this.selectedModules,
    required this.status,
    this.adminComment,
    required this.submittedAt,
    this.updatedAt,
    this.supportingDocuments = const [],
  });

  factory StudentApplication.fromJson(Map<String, dynamic> json) {
    List<ModuleSelection> modules = [];
    
    if (json['selected_modules'] != null) {
      modules = (json['selected_modules'] as List).map((m) => 
        ModuleSelection.fromJson(m)
      ).toList();
    }
    
    return StudentApplication(
      id: json['id'],
      userId: json['user_id'],
      yearOfStudy: json['year_of_study'],
      selectedModules: modules,
      status: ApplicationStatusExt.fromString(json['status'] ?? 'pending'),
      adminComment: json['admin_comment'],
      submittedAt: DateTime.parse(json['submitted_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      supportingDocuments: List<String>.from(json['supporting_documents'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'year_of_study': yearOfStudy,
      'selected_modules': selectedModules.map((m) => m.toJson()).toList(),
      'status': status.value,
      'admin_comment': adminComment,
      'submitted_at': submittedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'supporting_documents': supportingDocuments,
    };
  }

  bool get isPending => status == ApplicationStatus.pending;
  bool get isApproved => status == ApplicationStatus.approved;
  bool get isRejected => status == ApplicationStatus.rejected;
  bool get canBeEdited => isPending;
}