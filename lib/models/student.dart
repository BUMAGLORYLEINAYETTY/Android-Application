import 'package:excel/excel.dart' as excel;
 
// ==================== OOP: Grade Calculator Class ====================
class GradeCalculator {
  static const Map<String, int> gradeBoundaries = {
    'A': 90,
    'B': 80,
    'C': 70,
    'D': 60,
  };
 
  // ✅ LAMBDA FUNCTION — a function stored in a variable
  final String Function(int?) calculateGrade = (int? score) {
    if (score == null) return 'N/A';
    for (var entry in gradeBoundaries.entries) {
      if (score >= entry.value) return entry.key;
    }
    return 'F';
  };
 
  String getGradeWithDescription(int? score) {
    String grade = calculateGrade(score);
    Map<String, String> descriptions = {
      'A':   'Excellent',
      'B':   'Very Good',
      'C':   'Good',
      'D':   'Satisfactory',
      'F':   'Needs Improvement',
      'N/A': 'No Score Provided',
    };
    return descriptions[grade] ?? grade;
  }
}
 
// ==================== Student Model ====================
class Student {
  final int    id;
  final String name;
  final String email;
  final String studentId;
  final int?   score;
 
  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    this.score,
  });
 
  // ✅ GETTERS — computed from score automatically
  String get grade {
    final calculator = GradeCalculator();
    return calculator.calculateGrade(score);
  }
 
  String get description {
    final calculator = GradeCalculator();
    return calculator.getGradeWithDescription(score);
  }
 
  // ✅ FACTORY CONSTRUCTOR from Excel row
  factory Student.fromExcelRow(List<excel.Data?> row, int id) {
    String name = row[0]?.value?.toString().trim() ?? 'Unknown';
    int?   score;
    if (row.length > 1 && row[1]?.value != null) {
      var val = row[1]!.value.toString().trim();
      if (val.isNotEmpty) score = int.tryParse(val);
    }
    return Student(
      id:        id,
      name:      name,
      email:     '',
      studentId: 'IMP${id.toString().padLeft(3, '0')}',
      score:     score,
    );
  }
 
  Map<String, dynamic> toMap() => {
    'name':        name,
    'score':       score?.toString() ?? 'No Score',
    'grade':       grade,
    'description': description,
  };
 
  Student copyWith({int? score}) => Student(
    id:        id,
    name:      name,
    email:     email,
    studentId: studentId,
    score:     score ?? this.score,
  );
}
 