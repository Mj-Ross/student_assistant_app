// GROUP MEMBERS: [Full Names and Student Numbers]

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../models/application.dart';

class ApplicationReviewScreen extends StatefulWidget {
  final String applicationId;

  const ApplicationReviewScreen({super.key, required this.applicationId});

  @override
  State<ApplicationReviewScreen> createState() => _ApplicationReviewScreenState();
}

class _ApplicationReviewScreenState extends State<ApplicationReviewScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  StudentApplication? _application;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApplication();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadApplication() async {
    setState(() => _isLoading = true);

    final applicationProvider = Provider.of<ApplicationProvider>(
      context,
      listen: false,
    );

    final app = await applicationProvider.getApplicationById(widget.applicationId);

    setState(() {
      _application = app;
      if (app?.adminComment != null) {
        _commentController.text = app!.adminComment!;
      }
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(ApplicationStatus newStatus) async {
    if (_application == null) return;

    setState(() => _isProcessing = true);

    final applicationProvider = Provider.of<ApplicationProvider>(
      context,
      listen: false,
    );

    final success = await applicationProvider.updateApplicationStatus(
      _application!.id,
      newStatus,
      _commentController.text.isNotEmpty ? _commentController.text : null,
    );

    setState(() => _isProcessing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application ${newStatus.displayName.toLowerCase()}'),
          backgroundColor: newStatus == ApplicationStatus.approved ? Colors.green : Colors.orange,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update application status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application Not Found')),
        body: const Center(child: Text('Application could not be found')),
      );
    }

    final app = _application!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Application'),
        centerTitle: true,
        actions: [
          if (app.status == ApplicationStatus.pending)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'approve') {
                  _updateStatus(ApplicationStatus.approved);
                } else if (value == 'reject') {
                  _updateStatus(ApplicationStatus.rejected);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'approve',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Approve Application'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reject',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Reject Application'),
                    ],
                  ),
                ),
              ],
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text('Actions'),
                    Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: app.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: app.status.color),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(app.status),
                          color: app.status.color,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Status: ${app.status.displayName}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: app.status.color,
                                ),
                              ),
                              if (app.adminComment != null)
                                Text(
                                  'Comment: ${app.adminComment}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Application Details
                  const Text(
                    'Application Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.school, 'Year of Study', 'Year ${app.yearOfStudy}'),
                          const Divider(),
                          _buildDetailRow(
                            Icons.calendar_today,
                            'Submitted Date',
                            _formatDate(app.submittedAt),
                          ),
                          if (app.updatedAt != null) ...[
                            const Divider(),
                            _buildDetailRow(
                              Icons.update,
                              'Last Updated',
                              _formatDate(app.updatedAt!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Modules
                  const Text(
                    'Selected Modules',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: app.selectedModules.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final module = app.selectedModules[index];
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${module.moduleCode} - ${module.moduleName}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: module.meetsRequirements
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      module.meetsRequirements ? Icons.check_circle : Icons.warning,
                                      color: module.meetsRequirements ? Colors.green : Colors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        module.meetsRequirements
                                            ? 'Meets minimum requirements'
                                            : 'Does NOT meet minimum requirements',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Admin Comment Section
                  if (app.status == ApplicationStatus.pending) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Admin Comment',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: _commentController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment about this application...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _updateStatus(ApplicationStatus.approved),
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _updateStatus(ApplicationStatus.rejected),
                            icon: const Icon(Icons.cancel),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 16),
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  IconData _getStatusIcon(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return Icons.pending;
      case ApplicationStatus.approved:
        return Icons.check_circle;
      case ApplicationStatus.rejected:
        return Icons.cancel;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}