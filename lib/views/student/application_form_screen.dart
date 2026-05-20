// lib/views/student/application_form_screen.dart
// GROUP MEMBERS: [TH MOSIA 222040802, MC MOGOTSI 221023182, TL MOLOI 222004939, SM NKOSI 222020350, K LETELE 223053487]

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/application_provider.dart';
import '../../models/application.dart';
import '../../services/supabase_service.dart';

class ApplicationFormScreen extends StatefulWidget {
  final StudentApplication? existingApplication;
  
  const ApplicationFormScreen({super.key, this.existingApplication});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _yearOfStudy = 1;
  bool _includeSecondModule = false;
  
  // Module 1
  String? _selectedModule1;
  bool _meetsRequirements1 = false;
  
  // Module 2 (optional)
  String? _selectedModule2;
  bool _meetsRequirements2 = false;
  
  final List<String> _availableModules = [
    'TPG311C - Technical Programming I',
    'DBS311C - Database Systems I',
    'NWP311C - Network Programming I',
    'WEB311C - Web Development I',
    'MAT311C - Mathematics for Computing',
    'TPG316C - Technical Programming III',
    'DBS316C - Database Systems III',
    'SFT316C - Software Testing',
    'PRJ316C - Project Management',
    'SAD316C - Systems Analysis and Design',
    'ADV401C - Advanced Programming',
    'CLD401C - Cloud Computing',
    'SEC401C - Cyber Security',
    'IOT401C - Internet of Things',
  ];
  
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadExistingApplication();
  }

  void _loadExistingApplication() {
    if (widget.existingApplication != null) {
      final app = widget.existingApplication!;
      _yearOfStudy = app.yearOfStudy;
      
      if (app.selectedModules.isNotEmpty) {
        final module1 = app.selectedModules[0];
        _selectedModule1 = '${module1.moduleCode} - ${module1.moduleName}';
        _meetsRequirements1 = module1.meetsRequirements;
      }
      
      if (app.selectedModules.length > 1) {
        _includeSecondModule = true;
        final module2 = app.selectedModules[1];
        _selectedModule2 = '${module2.moduleCode} - ${module2.moduleName}';
        _meetsRequirements2 = module2.meetsRequirements;
      }
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedModule1 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one module')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUserId;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated. Please login again.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final modules = <ModuleSelection>[
      ModuleSelection(
        academicLevel: _yearOfStudy,
        moduleCode: _selectedModule1!.split(' - ')[0],
        moduleName: _selectedModule1!.split(' - ')[1],
        meetsRequirements: _meetsRequirements1,
      ),
    ];
    
    if (_includeSecondModule && _selectedModule2 != null) {
      modules.add(ModuleSelection(
        academicLevel: _yearOfStudy,
        moduleCode: _selectedModule2!.split(' - ')[0],
        moduleName: _selectedModule2!.split(' - ')[1],
        meetsRequirements: _meetsRequirements2,
      ));
    }

    // Check if we're editing or creating new
    if (widget.existingApplication != null) {
      // UPDATE existing application
      try {
        await SupabaseService.client
            .from('applications')
            .update({
              'year_of_study': _yearOfStudy,
              'selected_modules': modules.map((m) => m.toJson()).toList(),
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', widget.existingApplication!.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application updated successfully!')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating: $e')),
        );
      }
    } else {
      // CREATE new application
      final application = StudentApplication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        yearOfStudy: _yearOfStudy,
        selectedModules: modules,
        status: ApplicationStatus.pending,
        submittedAt: DateTime.now(),
        supportingDocuments: [],
      );

      final appProvider = Provider.of<ApplicationProvider>(context, listen: false);
      final success = await appProvider.submitApplication(application);
      
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );
        Navigator.pop(context, true);
      }
    }
    
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingApplication != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Application' : 'New Application'),
        centerTitle: true,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year of Study Section
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Academic Information',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: _yearOfStudy,
                              decoration: const InputDecoration(
                                labelText: 'Current Year of Study',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('Year 1')),
                                DropdownMenuItem(value: 2, child: Text('Year 2')),
                                DropdownMenuItem(value: 3, child: Text('Year 3')),
                              ],
                              onChanged: (value) => setState(() => _yearOfStudy = value!),
                              validator: (value) => value == null ? 'Please select your year of study' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Module 1 (Required)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'First Module (Required)',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedModule1,
                              decoration: const InputDecoration(
                                labelText: 'Select Module',
                                border: OutlineInputBorder(),
                              ),
                              items: _availableModules.map((module) {
                                return DropdownMenuItem(
                                  value: module,
                                  child: Text(module),
                                );
                              }).toList(),
                              onChanged: (value) => setState(() => _selectedModule1 = value),
                              validator: (value) => value == null ? 'Please select a module' : null,
                            ),
                            const SizedBox(height: 16),
                            CheckboxListTile(
                              value: _meetsRequirements1,
                              onChanged: (value) => setState(() => _meetsRequirements1 = value!),
                              title: const Text('I confirm that I meet the minimum requirements for this module'),
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Module 2 (Optional)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: _includeSecondModule ? Colors.green : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '2',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Second Module (Optional)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _includeSecondModule ? Colors.black : Colors.grey,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: _includeSecondModule,
                                  onChanged: (value) {
                                    setState(() {
                                      _includeSecondModule = value;
                                      if (!value) _selectedModule2 = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (_includeSecondModule) ...[
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _selectedModule2,
                                decoration: const InputDecoration(
                                  labelText: 'Select Second Module',
                                  border: OutlineInputBorder(),
                                ),
                                items: _availableModules
                                    .where((m) => m != _selectedModule1)
                                    .map((module) {
                                  return DropdownMenuItem(
                                    value: module,
                                    child: Text(module),
                                  );
                                }).toList(),
                                onChanged: (value) => setState(() => _selectedModule2 = value),
                              ),
                              const SizedBox(height: 16),
                              CheckboxListTile(
                                value: _meetsRequirements2,
                                onChanged: (value) => setState(() => _meetsRequirements2 = value!),
                                title: const Text('I confirm that I meet the minimum requirements for this module'),
                                controlAffinity: ListTileControlAffinity.leading,
                                activeColor: Colors.green,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitApplication,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isEditing ? 'Update Application' : 'Submit Application', style: const TextStyle(fontSize: 16)),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}
