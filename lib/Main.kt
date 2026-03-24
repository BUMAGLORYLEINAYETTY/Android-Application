import org.apache.poi.xssf.usermodel.XSSFWorkbook
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

data class Student(
    val name: String,
    val score: Int?,
    val grade: String
)

class GradeCalculator {

    fun calculateGrade(score: Int?): String {

        if (score == null) return "No Score"

        return when {
            score >= 75 -> "A"
            score >= 70 -> "B+"
            score >= 65 -> "B"
            score >= 60 -> "C+"
            score >= 55 -> "C+"
            score >= 50 -> "C"
            score >= 45 -> "D+"
            score >= 40 -> "D"
            else -> "F"
        }

    }
}

fun readStudents(filePath: String): List<Student> {

    val students = mutableListOf<Student>()

    val calculator = GradeCalculator()

    val workbook = XSSFWorkbook(FileInputStream(File(filePath)))

    val sheet = workbook.getSheetAt(0)

    for (row in sheet.drop(1)) {

        val name = row.getCell(0)?.stringCellValue ?: continue

        val score = try {
            row.getCell(1)?.numericCellValue?.toInt()
        } catch (e: Exception) {
            null
        }

        val grade = calculator.calculateGrade(score)

        students.add(Student(name, score, grade))

    }

    workbook.close()

    return students
}

fun writeResults(students: List<Student>, outputPath: String) {

    val workbook = XSSFWorkbook()

    val sheet = workbook.createSheet("Grades")

    var rowIndex = 0

    val header = sheet.createRow(rowIndex++)

    header.createCell(0).setCellValue("Name")
    header.createCell(1).setCellValue("Score")
    header.createCell(2).setCellValue("Grade")
    header.createCell(3).setCellValue("Description")

    for (student in students) {

        val row = sheet.createRow(rowIndex++)

        row.createCell(0).setCellValue(student.name)

        row.createCell(1).setCellValue(student.score?.toDouble() ?: 0.0)

        row.createCell(2).setCellValue(student.grade)

    }

    val fileOut = FileOutputStream(outputPath)

    workbook.write(fileOut)

    fileOut.close()

    workbook.close()
}

fun main() {
    var returnFile: String


    val inputFile = "students.xlsx"

    val outputFile = "results.xlsx"

    val students = readStudents(inputFile)

    writeResults(students, outputFile)

    println("Grades calculated successfully!")

}