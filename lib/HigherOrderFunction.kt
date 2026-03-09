
fun processList(
    numbers: List<Int>,
    predicate: (Int) -> Boolean
): List<Int> {
    val result = mutableListOf<Int>()
    for (item in numbers){
        if (predicate(item)){
            result.add(item)
        }
    }
    return result
}

fun main(){
    val nums = listOf(1, 2, 3, 4, 5, 6)
    val even = processList(nums) { it % 2 == 0 }
    println(even)
}