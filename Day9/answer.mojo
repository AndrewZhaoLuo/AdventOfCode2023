@always_inline
fn get_digit(one_char: String) -> Int:
    # Returns -1 if not digit, otherwise returns the digit
    let cur_ord = ord(one_char)
    alias l_bound = ord('0')
    alias r_bound = ord('9')
    if cur_ord > r_bound or cur_ord < l_bound: 
        return -1
    return cur_ord - l_bound

struct Row(CollectionElement):
    var data: DynamicVector[Int]

    fn __init__(inout self):
        self.data = DynamicVector[Int]()

    fn __copyinit__(inout self, existing: Self):
        self.data = existing.data

    fn __moveinit__(inout self, owned existing: Self):
        self.__copyinit__(existing)

struct Readings(CollectionElement):
    var rows: DynamicVector[Row]

    fn __init__(inout self, text: String):
        self.rows = DynamicVector[Row]()

        var cur_num = 0
        var is_neg = False 
        var cur_row = Row()
        for i in range(len(text)):
            let digit = get_digit(text[i])
            if digit != -1:
                cur_num = cur_num * 10 + digit 
            elif text[i] == "-":
                is_neg = True 
            else:
                if is_neg:
                    cur_num *= -1
                cur_row.data.push_back(cur_num)
                cur_num = 0
                is_neg = False 

            if text[i] == "\n":
                self.rows.push_back(cur_row ^)
                cur_row = Row()

    fn __copyinit__(inout self, existing: Self):
        self.rows = existing.rows

    fn __moveinit__(inout self, owned existing: Self):
        self.__copyinit__(existing)

fn get_differentials(initial_row: Row) -> DynamicVector[Row]:
    var answer = DynamicVector[Row]()
    answer.push_back(initial_row)

    var next_row = Row()
    var all_zero = False
    while not all_zero:
        # let prevents a copy right?
        let last_row = answer[answer.size - 1]
        all_zero = True 

        for i in range(len(last_row.data) - 1):
            let local_answer = last_row.data[i + 1] - last_row.data[i]
            next_row.data.push_back(local_answer)
            all_zero = all_zero and (local_answer == 0)
        answer.push_back(next_row ^)
        next_row = Row()

    return answer 

fn part1(readings: Readings) -> Int:
    var answer = 0
    for i in range(len(readings.rows)):
        let cur_row = readings.rows[i]
        let differentials = get_differentials(cur_row)
        var local_answer = 0
        for j in range(len(differentials)):
            let cur_row = differentials[differentials.size - 1 - j]
            if (cur_row.data.size > 0):
                local_answer = local_answer + cur_row.data[cur_row.data.size - 1]
        answer += local_answer
    return answer 

fn part2(readings: Readings) -> Int:
    var answer = 0
    for i in range(len(readings.rows)):
        let cur_row = readings.rows[i]
        let differentials = get_differentials(cur_row)
        var local_answer = 0
        for j in range(len(differentials)):
            let cur_row = differentials[differentials.size - 1 - j]
            if (cur_row.data.size > 0):
                local_answer = cur_row.data[0] - local_answer
        answer += local_answer
    return answer 

fn main() raises:
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        let readings = Readings(lines)
        print("Part 1:", part1(readings))
        print("Part 2:", part2(readings))
