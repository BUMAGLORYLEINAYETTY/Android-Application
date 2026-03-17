import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/student.dart';
import '../providers/app_provider.dart';
 
class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});
 
  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}
 
class _StudentListScreenState extends State<StudentListScreen> {
  String _searchQuery   = '';
  String _selectedGrade = 'All';
 
  final List<String> _gradeFilters = ['All', 'A', 'B', 'C', 'D', 'F', 'N/A'];
 
  Color _gradeColor(String grade) {
    switch (grade) {
      case 'A':  return const Color(0xFF4CAF50);
      case 'B':  return const Color(0xFF8BC34A);
      case 'C':  return const Color(0xFFFFC107);
      case 'D':  return const Color(0xFFFF9800);
      case 'F':  return const Color(0xFFF44336);
      default:   return Colors.grey;
    }
  }
 
  // ── Show snackbar helper ──────────────────────────────────
  void _showMessage(String msg, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ));
  }
 
  // ── Import handler ────────────────────────────────────────
  Future<void> _handleImport() async {
    final provider = context.read<AppProvider>();
    final result   = await provider.importFile();
 
    if (result == 'cancelled') return;
 
    if (result.startsWith('success')) {
      _showMessage('✅ ${result.replaceFirst('success: ', '')}');
    } else {
      _showMessage('❌ ${result.replaceFirst('error: ', '')}', isSuccess: false);
    }
  }
 
  // ── Export handler ────────────────────────────────────────
  Future<void> _handleExport() async {
    final provider = context.read<AppProvider>();
    final result   = await provider.exportToExcel();
 
    if (result.startsWith('success')) {
      _showMessage('✅ ${result.replaceFirst('success: ', '')}');
    } else {
      _showMessage('❌ ${result.replaceFirst('error: ', '')}', isSuccess: false);
    }
  }
 
  // ── Delete confirmation ───────────────────────────────────
  void _confirmDelete(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_forever, color: Colors.red, size: 36),
        title: const Text('Remove Student?'),
        content: Text('Remove ${student.name} from the system?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteStudent(student);
              Navigator.pop(ctx);
              _showMessage('${student.name} removed');
            },
            child: const Text('Remove',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
 
    final filtered = provider.students.where((s) {
      final matchSearch = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.studentId.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchGrade = _selectedGrade == 'All' || s.grade == _selectedGrade;
      return matchSearch && matchGrade;
    }).toList();
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${provider.students.length} total',
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: provider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1565C0)),
                  SizedBox(height: 16),
                  Text('Processing file...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
 
                // ── Import / Export Buttons ───────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleImport,
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text('Import Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: provider.students.isEmpty ? null : _handleExport,
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Export Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
 
                // ── Search Bar ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by name or ID...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xFF1565C0), width: 2),
                      ),
                    ),
                  ),
                ),
 
                const SizedBox(height: 10),
 
                // ── Grade Filter Chips ────────────────────────
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _gradeFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final grade    = _gradeFilters[i];
                      final selected = _selectedGrade == grade;
                      return FilterChip(
                        label: Text(grade),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _selectedGrade = grade),
                        selectedColor: const Color(0xFF1565C0),
                        labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500),
                        checkmarkColor: Colors.white,
                      );
                    },
                  ),
                ),
 
                const SizedBox(height: 8),
 
                // ── Stats Strip ───────────────────────────────
                if (provider.students.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MiniStat('Average', provider.averageScore.toStringAsFixed(1)),
                        _MiniStat('Highest', '${provider.highestScore}'),
                        _MiniStat('Lowest',  '${provider.lowestScore}'),
                        _MiniStat('Showing', '${filtered.length}'),
                      ],
                    ),
                  ),
 
                const SizedBox(height: 8),
 
                // ── Student List ──────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                provider.students.isEmpty
                                    ? 'No students yet.\nImport an Excel file or enroll manually.'
                                    : 'No students match your search',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final student = filtered[index];
                            final color   = _gradeColor(student.grade);
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Grade circle
                                    CircleAvatar(
                                      radius: 26,
                                      backgroundColor: color,
                                      child: Text(
                                        student.grade == 'N/A'
                                            ? '?' : student.grade,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(student.name,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15)),
                                          const SizedBox(height: 2),
                                          Text(student.studentId,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  student.score != null
                                                      ? 'Score: ${student.score}'
                                                      : 'No Score',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: color,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  '• ${student.description}',
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Delete button
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.redAccent),
                                      onPressed: () =>
                                          _confirmDelete(context, student),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
 
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat(this.label, this.value);
 
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1565C0))),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
 