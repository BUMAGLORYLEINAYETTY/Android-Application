import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../routes/app_routes.dart';
 
class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});
 
  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}
 
class _EnrollmentScreenState extends State<EnrollmentScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _nameCtrl      = TextEditingController();
  final _emailCtrl     = TextEditingController();
  final _studentIdCtrl = TextEditingController();
  final _scoreCtrl     = TextEditingController();
 
  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _studentIdCtrl.dispose();
    _scoreCtrl.dispose();
    super.dispose();
  }
 
  // ── Validators ─────────────────────────────────────────────
  String? _validateName(String? v) {
    if (v == null || v.isEmpty) return 'Name is required';
    if (v.trim().length < 2)    return 'Name must be at least 2 characters';
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(v.trim()))
      return 'Name can only contain letters';
    return null;
  }
 
  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(v))     return 'Enter a valid email address';
    return null;
  }
 
  String? _validateStudentId(String? v) {
    if (v == null || v.isEmpty) return 'Student ID is required';
    if (v.trim().length < 3)    return 'Student ID must be at least 3 characters';
    return null;
  }
 
  String? _validateScore(String? v) {
    if (v == null || v.isEmpty) return null; // Optional
    final parsed = int.tryParse(v);
    if (parsed == null)         return 'Score must be a number';
    if (parsed < 0 || parsed > 100) return 'Score must be between 0 and 100';
    return null;
  }
 
  // ── Grade Preview Helper ───────────────────────────────────
  String _gradePreview(int score) {
    if (score >= 90) return 'A — Excellent';
    if (score >= 80) return 'B — Very Good';
    if (score >= 70) return 'C — Good';
    if (score >= 60) return 'D — Satisfactory';
    return 'F — Needs Improvement';
  }
 
  Color _gradeColor(int score) {
    if (score >= 90) return const Color(0xFF4CAF50);
    if (score >= 80) return const Color(0xFF8BC34A);
    if (score >= 70) return const Color(0xFFFFC107);
    if (score >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
 
  // ── Submit ─────────────────────────────────────────────────
  void _handleEnroll() {
    if (!_formKey.currentState!.validate()) return;
 
    final provider = context.read<AppProvider>();
    provider.enrollStudent(
      name:      _nameCtrl.text,
      email:     _emailCtrl.text,
      studentId: _studentIdCtrl.text,
      score:     _scoreCtrl.text.isNotEmpty
                 ? int.tryParse(_scoreCtrl.text)
                 : null,
    );
 
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 48),
        title: const Text('Student Enrolled! 🎉',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          '${_nameCtrl.text} has been successfully enrolled.',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.studentList,
                (route) => route.settings.name == AppRoutes.mainMenu,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('View Students'),
          ),
        ],
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final scoreText    = _scoreCtrl.text;
    final scorePreview = int.tryParse(scoreText);
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enroll Student',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
 
              // Header Banner
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Row(
                    children: [
                      Icon(Icons.person_add, color: Colors.white, size: 40),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('New Enrollment',
                              style: TextStyle(color: Colors.white,
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Fill in all required fields',
                              style: TextStyle(color: Colors.white70,
                                  fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
 
              const SizedBox(height: 16),
 
              // Form Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
 
                      const Text('Student Information',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0))),
 
                      const SizedBox(height: 16),
 
                      // Name
                      TextFormField(
                        controller: _nameCtrl,
                        validator: _validateName,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                        decoration: _inputDecoration(
                            'Full Name *', Icons.person),
                      ),
 
                      const SizedBox(height: 16),
 
                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                            'Email Address *', Icons.email),
                      ),
 
                      const SizedBox(height: 16),
 
                      // Student ID
                      TextFormField(
                        controller: _studentIdCtrl,
                        validator: _validateStudentId,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                            'Student ID *', Icons.badge),
                      ),
 
                      const SizedBox(height: 20),
 
                      const Divider(),
 
                      const SizedBox(height: 12),
 
                      const Text('Grade Information',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0))),
 
                      const SizedBox(height: 16),
 
                      // Score (optional)
                      TextFormField(
                        controller: _scoreCtrl,
                        validator: _validateScore,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                        decoration: _inputDecoration(
                            'Score 0-100 (Optional)', Icons.grade),
                      ),
 
                      // Grade Preview
                      if (scorePreview != null &&
                          scorePreview >= 0 &&
                          scorePreview <= 100) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _gradeColor(scorePreview).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: _gradeColor(scorePreview).withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.stars,
                                  color: _gradeColor(scorePreview)),
                              const SizedBox(width: 8),
                              Text(
                                'Grade Preview: ${_gradePreview(scorePreview)}',
                                style: TextStyle(
                                    color: _gradeColor(scorePreview),
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
 
              const SizedBox(height: 16),
 
              // Enroll Button
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton.icon(
                  onPressed: _handleEnroll,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Enroll Student',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
 
              const SizedBox(height: 12),
 
              // Cancel Button
              SizedBox(
                width: double.infinity, height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 15)),
                ),
              ),
 
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
 
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
      ),
    );
  }
}
 