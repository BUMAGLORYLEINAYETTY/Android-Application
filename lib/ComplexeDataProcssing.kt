data class Person(val name: String, val age: Int)

val people = listOf(
    Person("Alice", 25),
    Person("Bob", 30),
    Person("Charles", 35),
    Person("Anna", 22),
    Person("Ben", 28)
)

val startWithAB = people.filter { it.name.startsWith("A") || it.name.startsWith("B") }
val result = startWithAB.forEach { it.name }

fun main(){
    println(result)
}