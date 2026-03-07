import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'dart:html' as html;
import 'dart:convert';

void main() {
  runApp(const GradeCalculatorApp());
}

// ==================== OOP: Grade Calculator Class ====================
class GradeCalculator {
  // Constants for grade boundaries
  static const Map<String, int> gradeBoundaries = {
    'A': 90,
    'B': 80,
    'C': 70,
    'D': 60,
  };

  // Lambda function for grade calculation
  final String Function(int?) calculateGrade = (int? score) {
    if (score == null) return 'No Score';
    
    for (var entry in gradeBoundaries.entries) {
      if (score >= entry.value) {
        return entry.key;
      }
    }
    return 'F';
  };

  // Method to get grade with description
  String getGradeWithDescription(int? score) {
    String grade = calculateGrade(score);
    
    Map<String, String> descriptions = {
      'A': 'Excellent',
      'B': 'Very Good',
      'C': 'Good',
      'D': 'Satisfactory',
      'F': 'Needs Improvement',
      'No Score': 'No Score Provided',
    };
    
    return descriptions[grade] ?? grade;
  }
}

// ==================== OOP: Student Model Class ====================
class Student {
  final String name;
  final int? score;
  late final String grade;
  late final String description;

  Student({required this.name, this.score}) {
    var calculator = GradeCalculator();
    grade = calculator.calculateGrade(score);
    description = calculator.getGradeWithDescription(score);
  }

  // Factory constructor from Excel row
  factory Student.fromExcelRow(List<excel.Data?> row) {
    String name = row[0]?.value?.toString().trim() ?? 'Unknown';
    int? score;
    
    if (row.length > 1 && row[1]?.value != null) {
      var scoreValue = row[1]!.value.toString().trim();
      if (scoreValue.isNotEmpty) {
        score = int.tryParse(scoreValue);
      }
    }
    
    return Student(name: name, score: score);
  }

  // To map for display
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'score': score?.toString() ?? 'No Score',
      'grade': grade,
      'description': description,
    };
  }
}

// ==================== Main App ====================
class GradeCalculatorApp extends StatelessWidget {
  const GradeCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grade Calculator Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const GradeCalculatorHome(),
    );
  }
}

// ==================== Home Page ====================
class GradeCalculatorHome extends StatefulWidget {
  const GradeCalculatorHome({super.key});

  @override
  State<GradeCalculatorHome> createState() => _GradeCalculatorHomeState();
}

class _GradeCalculatorHomeState extends State<GradeCalculatorHome> {
  List<Student> students = [];
  bool isLoading = false;
  String? fileName;

  // Statistics using higher-order functions
  Map<String, dynamic> get statistics {
    if (students.isEmpty) return {};
    
    var validScores = students
        .where((s) => s.score != null)
        .map((s) => s.score!)
        .toList();
    
    if (validScores.isEmpty) return {};
    
    return {
      'total': students.length,
      'average': validScores.reduce((a, b) => a + b) / validScores.length,
      'highest': validScores.reduce((a, b) => a > b ? a : b),
      'lowest': validScores.reduce((a, b) => a < b ? a : b),
      'gradeDistribution': students.fold<Map<String, int>>({}, (map, student) {
        map[student.grade] = (map[student.grade] ?? 0) + 1;
        return map;
      }),
    };
  }

  // Import Excel/CSV file (Web compatible with better error handling)
  Future<void> _importExcel() async {
    setState(() => isLoading = true);
    
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        allowMultiple: false,
      );

      if (result != null) {
        Uint8List? bytes = result.files.single.bytes;
        fileName = result.files.single.name;
        
        if (bytes != null) {
          try {
            // Clear existing students
            students.clear();
            
            // Check if it's a CSV file (by extension)
            if (fileName!.toLowerCase().endsWith('.csv')) {
              _importCSV(bytes);
            } else {
              _importExcelFile(bytes);
            }
            
          } catch (e) {
            _showMessage('Error reading file: $e', isSuccess: false);
          }
        }
      }
    } catch (e) {
      _showMessage('❌ Error picking file: $e', isSuccess: false);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Import CSV file
  void _importCSV(Uint8List bytes) {
    try {
      String csvContent = utf8.decode(bytes);
      List<String> lines = csvContent.split('\n');
      
      // Skip header line
      for (int i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isNotEmpty) {
          List<String> parts = line.split(',');
          if (parts.isNotEmpty) {
            String name = parts[0].trim();
            if (name.isNotEmpty) {
              int? score;
              if (parts.length > 1 && parts[1].trim().isNotEmpty) {
                score = int.tryParse(parts[1].trim());
              }
              students.add(Student(name: name, score: score));
            }
          }
        }
      }
      
      if (students.isEmpty) {
        _showMessage('No valid data found in CSV file', isSuccess: false);
      } else {
        setState(() {});
        _showMessage('✅ Imported ${students.length} students from $fileName', isSuccess: true);
      }
    } catch (e) {
      _showMessage('Error parsing CSV: $e', isSuccess: false);
    }
  }

  // Import Excel file
  void _importExcelFile(Uint8List bytes) {
    try {
      var excelFile = excel.Excel.decodeBytes(bytes);
      bool hasData = false;
      
      for (var table in excelFile.tables.keys) {
        var sheet = excelFile.tables[table];
        if (sheet != null && sheet.rows.length > 1) {
          // Skip header row (first row)
          for (int i = 1; i < sheet.rows.length; i++) {
            var row = sheet.rows[i];
            if (row.isNotEmpty && row.length > 0) {
              // Get name from first column
              String name = row[0]?.value?.toString().trim() ?? '';
              if (name.isNotEmpty) {
                hasData = true;
                // Get score from second column if exists
                int? score;
                if (row.length > 1 && row[1]?.value != null) {
                  var scoreValue = row[1]!.value.toString().trim();
                  if (scoreValue.isNotEmpty) {
                    score = int.tryParse(scoreValue);
                  }
                }
                students.add(Student(name: name, score: score));
              }
            }
          }
        }
        break; // Process only first sheet
      }
      
      if (!hasData) {
        _showMessage('No valid data found in Excel file', isSuccess: false);
      } else {
        setState(() {});
        _showMessage('✅ Imported ${students.length} students from $fileName', isSuccess: true);
      }
    } catch (e) {
      _showMessage('Error parsing Excel: $e', isSuccess: false);
    }
  }

  // Export to Excel (Web compatible - downloads file)
  Future<void> _exportToExcel() async {
    if (students.isEmpty) {
      _showMessage('No data to export', isSuccess: false);
      return;
    }

    setState(() => isLoading = true);

    try {
      var excelFile = excel.Excel.createExcel();
      var sheet = excelFile['Grades'];

      // Headers with styling
      sheet.appendRow(['Student Name', 'Score', 'Grade', 'Description']);
      
      // Data rows
      students.forEach((student) {
        sheet.appendRow([
          student.name, 
          student.score?.toString() ?? 'No Score', 
          student.grade, 
          student.description
        ]);
      });

      // Add summary sheet
      var summarySheet = excelFile['Summary'];
      summarySheet.appendRow(['Grade Calculator Summary']);
      summarySheet.appendRow(['Total Students', students.length.toString()]);
      
      if (statistics.isNotEmpty) {
        summarySheet.appendRow(['Average Score', statistics['average'].toStringAsFixed(2)]);
        summarySheet.appendRow(['Highest Score', statistics['highest'].toString()]);
        summarySheet.appendRow(['Lowest Score', statistics['lowest'].toString()]);
        summarySheet.appendRow([]);
        summarySheet.appendRow(['Grade Distribution']);
        
        (statistics['gradeDistribution'] as Map<String, int>).forEach((grade, count) {
          summarySheet.appendRow(['Grade $grade', count.toString()]);
        });
      }

      // Save file (web download)
      var fileBytes = excelFile.encode();
      if (fileBytes != null) {
        final datetime = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final bytes = fileBytes as Uint8List;
        
        // Create a blob and trigger download
        final anchor = html.AnchorElement(
          href: 'data:application/octet-stream;base64,${base64Encode(bytes)}',
        );
        anchor.download = 'Grade_Results_$datetime.xlsx';
        anchor.click();
        
        _showMessage('✅ Excel file downloaded!', isSuccess: true);
      }
    } catch (e) {
      _showMessage('❌ Error exporting: $e', isSuccess: false);
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Add single student manually
  void _addManualStudent() {
    showDialog(
      context: context,
      builder: (context) => _ManualEntryDialog(
        onAdd: (name, score) {
          setState(() {
            students.add(Student(name: name, score: score));
          });
          _showMessage('✅ Added $name', isSuccess: true);
        },
      ),
    );
  }

  // Clear all students
  void _clearAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All'),
        content: const Text('Are you sure you want to remove all students?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                students.clear();
                fileName = null;
              });
              Navigator.pop(context);
              _showMessage('All students cleared', isSuccess: true);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Show message helper
  void _showMessage(String msg, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grade Calculator Pro',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          if (students.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearAll,
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: isLoading 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Processing...',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: Column(
                children: [
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.upload_file,
                                    label: 'Import Excel',
                                    color: Colors.blue,
                                    onPressed: _importExcel,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.add,
                                    label: 'Add Manual',
                                    color: Colors.green,
                                    onPressed: _addManualStudent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.download,
                                    label: 'Export Excel',
                                    color: Colors.orange,
                                    onPressed: _exportToExcel,
                                  ),
                                ),
                              ],
                            ),
                            // File name if imported
                            if (fileName != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.insert_drive_file, color: Colors.blue.shade700),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Imported: $fileName',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Statistics Cards
                  if (students.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Statistics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem('Total', '${statistics['total']}', Icons.people),
                                  _buildStatItem('Average', '${(statistics['average'] as double?)?.toStringAsFixed(1) ?? "0"}', Icons.calculate),
                                  _buildStatItem('Highest', '${statistics['highest'] ?? 0}', Icons.trending_up),
                                  _buildStatItem('Lowest', '${statistics['lowest'] ?? 0}', Icons.trending_down),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: (statistics['gradeDistribution'] as Map<String, int>)
                                      .entries
                                      .map((entry) => Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getGradeColor(entry.key).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(color: _getGradeColor(entry.key)),
                                            ),
                                            child: Text(
                                              '${entry.key}: ${entry.value}',
                                              style: TextStyle(
                                                color: _getGradeColor(entry.key),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Students List Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Student Records',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (students.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${students.length} total',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Students List
                  Expanded(
                    child: students.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.school,
                                    size: 60,
                                    color: Colors.blue.shade400,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No Students Added',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Import an Excel file or add manually',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _importExcel,
                                  icon: const Icon(Icons.upload_file),
                                  label: const Text('Import Excel'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              return _buildStudentCard(students[index], index);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getGradeColor(String grade) {
    switch(grade) {
      case 'A': return Colors.green;
      case 'B': return Colors.lightGreen;
      case 'C': return Colors.amber;
      case 'D': return Colors.orange;
      case 'F': return Colors.red;
      default: return Colors.grey;
    }
  }

  Widget _buildStudentCard(Student student, int index) {
    Color gradeColor = _getGradeColor(student.grade);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shadowColor: gradeColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: gradeColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        student.grade == 'No Score' ? '?' : student.grade,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
              content: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.score, 'Score', student.score?.toString() ?? 'No Score'),
                    const Divider(),
                    _buildDetailRow(Icons.grade, 'Grade', student.grade),
                    const Divider(),
                    _buildDetailRow(Icons.description, 'Description', student.description),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: gradeColor.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: gradeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradeColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    student.grade == 'No Score' ? '?' : student.grade,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      student.score != null 
                          ? 'Score: ${student.score} • ${student.description}'
                          : 'No score provided',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                onPressed: () {
                  setState(() {
                    students.removeAt(index);
                  });
                  _showMessage('Removed ${student.name}', isSuccess: true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Manual Entry Dialog ====================
class _ManualEntryDialog extends StatefulWidget {
  final Function(String, int?) onAdd;
  const _ManualEntryDialog({required this.onAdd});

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  final _nameController = TextEditingController();
  final _scoreController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Student Manually'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Student Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _scoreController,
              decoration: const InputDecoration(
                labelText: 'Score (0-100)',
                border: OutlineInputBorder(),
                hintText: 'Leave empty for no score',
                prefixIcon: Icon(Icons.score),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              String name = _nameController.text;
              int? score;
              
              if (_scoreController.text.isNotEmpty) {
                score = int.tryParse(_scoreController.text);
                if (score != null && (score < 0 || score > 100)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Score must be between 0 and 100'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
              }
              
              widget.onAdd(name, score);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}