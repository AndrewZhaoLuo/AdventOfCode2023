from math import abs, min

struct Row[T: CollectionElement](CollectionElement):
    var data: DynamicVector[T]

    fn __init__(inout self):
        self.data = DynamicVector[T]()

    fn __copyinit__(inout self, existing: Self):
        self.data = existing.data

    fn __moveinit__(inout self, owned existing: Self):
        self.__copyinit__(existing)

fn can_start_chain(
    data: DynamicVector[Int], 
    index: Int,
    group_size: Int
) -> Bool:
    # Check before can be capped by a . 
    var back_is_capped = False 
    if index - 1 < 0:
        back_is_capped = True 
    elif data[index - 1] == 2 or data[index - 1] == 0:
        back_is_capped = True 

    if not back_is_capped:
        return False 

    # Check front can be capped by a .
    let front_cap_index = index + group_size
    if front_cap_index > len(data):
        return False 
    if front_cap_index != len(data) and data[front_cap_index] == 1:
        return False 

    # Check everything in between can be # 
    for i in range(index, index + group_size):
        if data[i] == 0:
            return False 

    return True 

alias UPPER_N = 20
fn solve(
    data: DynamicVector[Int], 
    numbers: DynamicVector[Int], 
) -> Int:
    # g[i][j] is the number of ways such that 
    # data[:i] matches the first j indices in numbers (+ include the cap)
    # we add one extra padding 
    #
    # Transitions for g for index:
    # if able to become '.', g[i + 1][j] += g[i][j] for all j 
    #     as we can move the prefixes offset by one 
    #
    # if able to become '#', check if we can start a chain of length numbers[j], then
    #    g[i + n + 1][j] += g[i][j - 1]
    #
    # Note we have to bootstrap filling g[i][0], the rule is once we see the first '#', we can
    # process it, but cannot further modify `dp[i][0]``
    var dp = DynamicVector[Row[Int]]()
    for i in range(len(data) + 1):
        var cur_row = Row[Int]()
        for j in range(len(numbers)):
            cur_row.data.push_back(0)
        dp.push_back(cur_row ^)

    # once we have a '#' we cannot bootstrap the first "number" after
    for i in range(len(data)):
        if data[i] == 0:
            continue 
        if can_start_chain(data, i, numbers[0]):
            # Min handles the case where the end is capped by going off the board
            dp[min(i + numbers[0] + 1, len(data))].data[0] += 1
        if data[i] == 1:
            break

    # Fill in dp
    for i in range(len(data)):
        let cur = data[i]

        # Case '#'
        if cur == 1 or cur == 2:
            for j in range(len(numbers) - 1):
                if dp[i].data[j] == 0:
                    continue 
                let next_number = numbers[j + 1]
                if not can_start_chain(data, i, next_number):
                    continue 
                # Min handles the case where the end is capped by going off the board
                dp[min(i + next_number + 1, len(data))].data[j + 1] += dp[i].data[j]

        # Case '.'
        if cur == 0 or cur == 2:
            for j in range(len(numbers)):
                dp[i + 1].data[j] += dp[i].data[j]

    let answer = dp[len(data)].data[len(numbers) - 1]

    return answer 

@always_inline
fn solve_local_p1_and_p2(conditions: String, numbers: DynamicVector[Int]) -> Tuple[Int, Int]:
    # 0 = ".", 1 = "#", 2 = "?"
    var data_p1 = DynamicVector[Int]()
    for i in range(len(conditions)):
        if conditions[i] == ".":
            data_p1.push_back(0)
        elif conditions[i] == "#":
            data_p1.push_back(1)
        else: # == "?"
            data_p1.push_back(2)
    let answer_p1 = solve(data_p1, numbers)

    var data_p2 = data_p1 
    for i in range(4):
        data_p2.push_back(2)
        for j in range(len(data_p1)):
            data_p2.push_back(data_p1[j])
    var numbers_p2 = numbers 
    for i in range(4):
        for j in range(len(numbers)):
            numbers_p2.push_back(numbers[j])
    let answer_p2 = solve(data_p2, numbers_p2)
    return (answer_p1, answer_p2)

@always_inline
fn part1_and_part2(data: DynamicVector[String]) raises:
    var answer_p1 = 0
    var answer_p2 = 0

    for i in range(len(data)):
        let cur_row = data[i].split(' ')
        let conditions = cur_row[0]
        let numbers_text = cur_row[1].split(',')
        var numbers = DynamicVector[Int]()
        for j in range(len(numbers_text)):
            numbers.push_back(atol(numbers_text[j]))
        let local_answer = solve_local_p1_and_p2(conditions, numbers)

        let local_p1 = local_answer.get[0, Int]()
        let local_p2 = local_answer.get[1, Int]()
        answer_p1 += local_p1
        answer_p2 += local_p2
        # print(i + 1, "/", len(data), "=", local_p1, local_p2)

    print("Part1:", answer_p1)
    print("Part2:", answer_p2)

fn main() raises:
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        let data = lines.split("\n")
        part1_and_part2(data)