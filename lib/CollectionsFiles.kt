
fun main () {

    val words = listOf("apple", "cat", "banana", "dog", "elephant")

    val wordLength = words.associateWith { it.length }

    val toPrint = wordLength.filter { it.value < 4 }

    println(toPrint.keys)
}
