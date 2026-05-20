// GROUP MEMBERS: [TH MOSIA 222040802, MC MOGOTSI 221023182, TL MOLOI 222004939, SM NKOSI 222020350, K LETELE 223053487]
// lib/views/admin/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../models/application.dart';
import 'application_review_screen.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _selectedFilter = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<ApplicationProvider>(context, listen: false);
      await provider.loadAllApplications();
      
      // Debug print
      final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
      print('📊 Total applications loaded: ${appProvider.allApplications.length}');
      print('📊 Pending: ${appProvider.allApplications.where((a) => a.isPending).length}');
      print('📊 Approved: ${appProvider.allApplications.where((a) => a.isApproved).length}');
      print('📊 Rejected: ${appProvider.allApplications.where((a) => a.isRejected).length}');
    } catch (e) {
      print('❌ Error loading applications: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ApplicationProvider>(context);
    
    // Debug print current state
    print('🔍 Building Admin Dashboard with ${provider.allApplications.length} applications');
    
    List<StudentApplication> filteredApps = [];
    switch (_selectedFilter) {
      case 'pending':
        filteredApps = provider.allApplications.where((a) => a.isPending).toList();
        break;
      case 'approved':
        filteredApps = provider.allApplications.where((a) => a.isApproved).toList();
        break;
      case 'rejected':
        filteredApps = provider.allApplications.where((a) => a.isRejected).toList();
        break;
      default:
        filteredApps = provider.allApplications;
    }

    final total = provider.allApplications.length;
    final pending = provider.allApplications.where((a) => a.isPending).length;
    final approved = provider.allApplications.where((a) => a.isApproved).length;
    final rejected = provider.allApplications.where((a) => a.isRejected).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadApplications,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadApplications,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Stats Cards
              Row(
                children: [
                  _buildStatCard('Total', total, const Color(0xFF1A237E), Icons.description),
                  _buildStatCard('Pending', pending, Colors.orange, Icons.pending_actions),
                  _buildStatCard('Approved', approved, Colors.green, Icons.check_circle),
                  _buildStatCard('Rejected', rejected, Colors.red, Icons.cancel),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Pending', 'pending'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Approved', 'approved'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Rejected', 'rejected'),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Applications List
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredApps.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                _selectedFilter == 'all' 
                                    ? 'No applications found' 
                                    : 'No $_selectedFilter applications',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Students haven\'t submitted any applications yet',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredApps.length,
                          itemBuilder: (context, index) {
                            final app = filteredApps[index];
                            return _buildApplicationCard(app);
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => setState(() => _selectedFilter = value),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF1A237E).withValues(alpha: 0.1),
      checkmarkColor: const Color(0xFF1A237E),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1A237E) : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ApplicationReviewScreen(applicationId: app.id),
              ),
            ).then((_) => _loadApplications());
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        app.status == ApplicationStatus.approved
                            ? Colors.green
                            : app.status == ApplicationStatus.rejected
                                ? Colors.red
                                : Colors.orange,
                        app.status == ApplicationStatus.approved
                            ? Colors.green.shade300
                            : app.status == ApplicationStatus.rejected
                                ? Colors.red.shade300
                                : Colors.orange.shade300,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Y${app.yearOfStudy}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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
                        'Application #${app.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${app.selectedModules.length} modules selected',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Student ID: ${app.userId.substring(0, 8)}...',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: app.status.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        app.status == ApplicationStatus.approved
                            ? Icons.check_circle
                            : app.status == ApplicationStatus.rejected
                                ? Icons.cancel
                                : Icons.pending,
                        size: 14,
                        color: app.status.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        app.status.displayName,
                        style: TextStyle(color: app.status.color, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
