
import java.util.Locale.getDefault

// Data Class
data class Student(
    val name: String,
    val grades: MutableMap<String, Double?> = mutableMapOf()
) {
    // Using when
    fun getGrade(score: Double?): String {
        val s = score ?: 0.0
        return when {
            s >= 75 -> "A+"
            s >= 70 -> "A"
            s >= 65 -> "B+"
            s >= 60 -> "B"
            s >= 55 -> "C+"
            s >= 50 -> "C"
            s >= 45 -> "D+"
            s >= 40 -> "D"
            else -> "F"
        }
    }

    // For average
    fun getAverage(): Double {
        val validGrade = grades.values.filterNotNull()
        return if (validGrade.isNotEmpty()) validGrade.average() else 0.0
    }
}

fun main(){

    println("WELCOME TO YOUR GRADE APP CALCULATOR")

    println("Enter a name student name : ")
    val studentName = readLine() ?: "Anonymous"
    val currentStudent = Student(studentName)

    println("Enter a number of subjects : ")
    val nbSubjects = readLine()?.toIntOrNull() ?: 0

    for (i in 1..nbSubjects){
        println("Subject number $i")

        println("Enter the name of the subject : ")
        val subjectName = readLine() ?: "Subject $i"

        println("Enter a grade for $subjectName")
        val subjectGrade = readLine()?.toDoubleOrNull()

        currentStudent.grades[subjectName] = subjectGrade
    }

    println("\nGRADE OF STUDENT ${currentStudent.name.uppercase(getDefault())}")
    println("Number of subjects : ${currentStudent.grades.size}")

    // Student Grade
    currentStudent.grades.forEach { (subject, grade) ->
        val gradeLetter = currentStudent.getGrade(grade)
        println("$subject : ${grade ?: 0} / 100 -> Grade : $gradeLetter")
    }

    // Average
    val average = currentStudent.getAverage()
    val averageLetter = currentStudent.getGrade(average)
    println("\nAverage: ${"%.2f".format(average)} / 100 -> Grade : $averageLetter")

}
