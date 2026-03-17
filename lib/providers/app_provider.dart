import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../models/student.dart';
 
class AppProvider extends ChangeNotifier {
 
  // ==================== Auth State ====================
  bool   _isLoggedIn   = false;
  String _loggedInUser = '';
  String _loginError   = '';
 
  bool   get isLoggedIn   => _isLoggedIn;
  String get loggedInUser => _loggedInUser;
  String get loginError   => _loginError;
 
  bool _isLoading = false;
  bool get isLoading => _isLoading;
 
  // ==================== Students ====================
  final List<Student> _students = [
    Student(id: 1, name: 'Alice Johnson', email: 'alice@school.com', studentId: 'STU001', score: 92),
    Student(id: 2, name: 'Bob Smith',     email: 'bob@school.com',   studentId: 'STU002', score: 85),
    Student(id: 3, name: 'Carol White',   email: 'carol@school.com', studentId: 'STU003', score: 73),
    Student(id: 4, name: 'David Brown',   email: 'david@school.com', studentId: 'STU004', score: 60),
    Student(id: 5, name: 'Eve Davis',     email: 'eve@school.com',   studentId: 'STU005', score: 45),
  ];
 
  List<Student> get students => List.unmodifiable(_students);
 
  double get averageScore {
    final scores = _students.where((s) => s.score != null).map((s) => s.score!).toList();
    if (scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }
 
  int get highestScore =>
      _students.where((s) => s.score != null).map((s) => s.score!).fold(0, (a, b) => a > b ? a : b);
 
  int get lowestScore =>
      _students.where((s) => s.score != null).map((s) => s.score!).fold(100, (a, b) => a < b ? a : b);
 
  Map<String, int> get gradeDistribution {
    final map = <String, int>{};
    for (var s in _students) {
      map[s.grade] = (map[s.grade] ?? 0) + 1;
    }
    return map;
  }
 
  // ==================== Auth ====================
  bool login(String email, String password) {
    if (email == 'admin@school.com' && password == 'admin123') {
      _isLoggedIn   = true;
      _loggedInUser = email;
      _loginError   = '';
      notifyListeners();
      return true;
    }
    _loginError = 'Invalid email or password';
    notifyListeners();
    return false;
  }
 
  void logout() {
    _isLoggedIn   = false;
    _loggedInUser = '';
    _loginError   = '';
    notifyListeners();
  }
 
  void clearLoginError() {
    _loginError = '';
    notifyListeners();
  }
 
  // ==================== Enrollment ====================
  void enrollStudent({
    required String name,
    required String email,
    required String studentId,
    int? score,
  }) {
    _students.add(Student(
      id:        _students.length + 1,
      name:      name.trim(),
      email:     email.trim(),
      studentId: studentId.trim(),
      score:     score,
    ));
    notifyListeners();
  }
 
  void deleteStudent(Student student) {
    _students.remove(student);
    notifyListeners();
  }
 
  // ==================== IMPORT EXCEL / CSV ====================
  Future<String> importFile() async {
    _isLoading = true;
    notifyListeners();
 
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
        allowMultiple: false,
      );
 
      if (result == null) {
        _isLoading = false;
        notifyListeners();
        return 'cancelled';
      }
 
      Uint8List? bytes    = result.files.single.bytes;
      String     fileName = result.files.single.name;
 
      if (bytes == null) {
        _isLoading = false;
        notifyListeners();
        return 'error: Could not read file';
      }
 
      _students.clear();
 
      if (fileName.toLowerCase().endsWith('.csv')) {
        _parseCSV(bytes);
      } else {
        _parseExcel(bytes);
      }
 
      _isLoading = false;
      notifyListeners();
      return 'success: Imported ${_students.length} students from $fileName';
 
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'error: $e';
    }
  }
 
  void _parseCSV(Uint8List bytes) {
    String content     = utf8.decode(bytes);
    List<String> lines = content.split('\n');
    for (int i = 1; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isEmpty) continue;
      List<String> parts = line.split(',');
      if (parts.isEmpty) continue;
      String name = parts[0].trim();
      if (name.isEmpty) continue;
      int? score;
      if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        score = int.tryParse(parts[1].trim());
      }
      _students.add(Student(
        id:        _students.length + 1,
        name:      name,
        email:     '',
        studentId: 'IMP${(_students.length + 1).toString().padLeft(3, '0')}',
        score:     score,
      ));
    }
  }
 
  void _parseExcel(Uint8List bytes) {
    var excelFile = excel.Excel.decodeBytes(bytes);
    for (var table in excelFile.tables.keys) {
      var sheet = excelFile.tables[table];
      if (sheet == null || sheet.rows.length <= 1) continue;
      for (int i = 1; i < sheet.rows.length; i++) {
        var row = sheet.rows[i];
        if (row.isEmpty) continue;
        String name = row[0]?.value?.toString().trim() ?? '';
        if (name.isEmpty) continue;
        // Uses factory constructor from Student model
        _students.add(Student.fromExcelRow(row, _students.length + 1));
      }
      break;
    }
  }
 
  // ==================== EXPORT TO EXCEL ====================
  Future<String> exportToExcel() async {
    if (_students.isEmpty) return 'error: No students to export';
 
    _isLoading = true;
    notifyListeners();
 
    try {
      var excelFile    = excel.Excel.createExcel();
      var gradesSheet  = excelFile['Grades'];
 
      // Header row
      gradesSheet.appendRow([
        excel.TextCellValue('Student Name'),
        excel.TextCellValue('Score'),
        excel.TextCellValue('Grade'),
        excel.TextCellValue('Description'),
      ]);
 
      // Data rows using lambda via student.grade and student.description
      for (var student in _students) {
        gradesSheet.appendRow([
          excel.TextCellValue(student.name),
          excel.TextCellValue(student.score?.toString() ?? 'No Score'),
          excel.TextCellValue(student.grade),
          excel.TextCellValue(student.description),
        ]);
      }
 
      // Summary sheet
      var summarySheet = excelFile['Summary'];
      summarySheet.appendRow([excel.TextCellValue('Grade Calculator Summary')]);
      summarySheet.appendRow([excel.TextCellValue('Total Students'), excel.TextCellValue('${_students.length}')]);
      summarySheet.appendRow([excel.TextCellValue('Average Score'),  excel.TextCellValue(averageScore.toStringAsFixed(2))]);
      summarySheet.appendRow([excel.TextCellValue('Highest Score'),  excel.TextCellValue('$highestScore')]);
      summarySheet.appendRow([excel.TextCellValue('Lowest Score'),   excel.TextCellValue('$lowestScore')]);
      summarySheet.appendRow([excel.TextCellValue('')]);
      summarySheet.appendRow([excel.TextCellValue('Grade Distribution')]);
      gradeDistribution.forEach((grade, count) {
        summarySheet.appendRow([
          excel.TextCellValue('Grade $grade'),
          excel.TextCellValue('$count students'),
        ]);
      });
 
      // Trigger browser download
      var fileBytes = excelFile.encode();
      if (fileBytes != null) {
        final datetime = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final bytes    = Uint8List.fromList(fileBytes);
        final anchor   = html.AnchorElement(
          href: 'data:application/octet-stream;base64,${base64Encode(bytes)}',
        );
        anchor.download = 'Grade_Results_$datetime.xlsx';
        anchor.click();
        _isLoading = false;
        notifyListeners();
        return 'success: File downloaded!';
      }
 
      _isLoading = false;
      notifyListeners();
      return 'error: Could not encode file';
 
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'error: $e';
    }
  }
}
 