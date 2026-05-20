// GROUP MEMBERS: [TH MOSIA 222040802, MC MOGOTSI 221023182, TL MOLOI 222004939, SM NKOSI 222020350, K LETELE 223053487]
// lib/views/student/application_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/application.dart';
import '../../providers/application_provider.dart';
import '../../services/supabase_service.dart';
import '../../shared/constants/app_colors.dart';
import 'application_form_screen.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final StudentApplication application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  State<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  Future<void> _deleteApplication() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Application'),
        content: const Text('Are you sure you want to delete this application? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
      
      try {
        await SupabaseService.client
            .from('applications')
            .delete()
            .eq('id', widget.application.id);
        
        await appProvider.loadUserApplications(widget.application.userId);
        await appProvider.loadAllApplications();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application deleted successfully!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete application')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final application = widget.application;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Application Details'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      application.status == ApplicationStatus.approved
                          ? Colors.green.shade700
                          : application.status == ApplicationStatus.rejected
                              ? Colors.red.shade700
                              : AppColors.primary,
                      AppColors.primaryLight,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        application.status == ApplicationStatus.approved
                            ? Icons.check_circle
                            : application.status == ApplicationStatus.rejected
                                ? Icons.cancel
                                : Icons.pending,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        application.status.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              if (application.canBeEdited)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApplicationFormScreen(existingApplication: application),
                      ),
                    ).then((_) => Navigator.pop(context, true));
                  },
                ),
              if (application.canBeEdited)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: _deleteApplication,
                ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Application Info Card
                  _buildInfoCard(application),
                  const SizedBox(height: 16),
                  
                  // Modules Card
                  _buildModulesCard(application),
                  
                  // Admin Comment
                  if (application.adminComment != null)
                    _buildAdminCommentCard(application),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(StudentApplication application) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.info_outline, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Application Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.school, 'Year of Study', 'Year ${application.yearOfStudy}'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.calendar_today, 'Submitted', _formatDate(application.submittedAt)),
            if (application.updatedAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(Icons.update, 'Last Updated', _formatDate(application.updatedAt!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModulesCard(StudentApplication application) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.book, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Selected Modules',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...application.selectedModules.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final module = entry.value;
              return _buildModuleCard(index, module);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(int index, ModuleSelection module) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: module.meetsRequirements
              ? [Colors.green.shade50, Colors.green.shade100]
              : [Colors.red.shade50, Colors.red.shade100],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: module.meetsRequirements ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: module.meetsRequirements ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.moduleCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      module.moduleName,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                module.meetsRequirements ? Icons.check_circle : Icons.warning,
                color: module.meetsRequirements ? Colors.green : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: module.meetsRequirements
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              module.meetsRequirements
                  ? '✓ Meets minimum requirements'
                  : '⚠ Does not meet minimum requirements',
              style: TextStyle(
                color: module.meetsRequirements ? Colors.green : Colors.red,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCommentCard(StudentApplication application) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.comment, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Admin Comment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    application.adminComment!,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(label, style: TextStyle(color: Colors.grey.shade600)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
