@always_inline
fn get_digit(one_char: String) -> Int:
    # Returns -1 if not digit, otherwise returns the digit
    let cur_ord = ord(one_char)
    alias l_bound = ord('0')
    alias r_bound = ord('9')
    if cur_ord > r_bound or cur_ord < l_bound: 
        return -1
    return cur_ord - l_bound

fn part1(data: String, height: Int, width: Int):
    @always_inline
    fn getch(row: Int, col: Int) -> String:
        let flat_index = row * (width + 1) + col
        return data[flat_index]

    @always_inline
    fn is_symbol(row: Int, col: Int) -> Bool:
        if row < 0 or col < 0 or row >= height or col >= width:
            return False 
        let cur_char = getch(row, col)
        return cur_char != "." and cur_char != '\n' and get_digit(cur_char) == -1

    @always_inline
    fn is_adj(row: Int, col: Int) -> Bool:
        for dr in range(-1, 2, 1):
            for dc in range(-1, 2, 1):
                if dr == 0 and dc == 0:
                    continue 
                let cur_r = dr + row 
                let cur_c = dc + col 
                if is_symbol(cur_r, cur_c):
                    return True 
        return False 

    var answer = 0
    var cur_num = 0
    var touch_digit = False
    for r in range(height):

        # + 1 to hit the "\n" and reset things
        for c in range(width + 1):
            let digit = get_digit(getch(r, c))
            if digit == -1:
                if touch_digit:
                    answer += cur_num
                cur_num = 0
                touch_digit = False 
            else:
                cur_num = cur_num * 10 + digit 
                touch_digit = touch_digit or is_adj(r, c)

    print("Part 1:", answer)

fn part2(data: String, height: Int, width: Int):
    @always_inline
    fn getch(row: Int, col: Int) -> String:
        let flat_index = row * (width + 1) + col
        return data[flat_index]

    @always_inline
    fn is_gear(row: Int, col: Int) -> Bool:
        if row < 0 or col < 0 or row >= height or col >= width:
            return False 
        let cur_char = getch(row, col)
        return cur_char == '*'

    @always_inline
    fn is_adj(row: Int, col: Int) -> StaticIntTuple[8]:
        var result = StaticIntTuple[8](-1, -1, -1, -1, -1, -1, -1, -1)
        var next_index = 0
        for dr in range(-1, 2, 1):
            for dc in range(-1, 2, 1):
                if dr == 0 and dc == 0:
                    continue 
                let cur_r = dr + row 
                let cur_c = dc + col 
                if is_gear(cur_r, cur_c):
                    let flat_index = cur_r * (width + 1) + cur_c 
                    result[next_index] = flat_index
                    next_index += 1
        return result

    var counted = DynamicVector[Bool](len(data))
    var gear_num_count = DynamicVector[Int](len(data))
    var gear_ratio = DynamicVector[Int](len(data))
    for i in range(len(data)):
        gear_num_count[i] = 0
        gear_ratio[i] = 1
        counted[i] = False 

    var answer = 0
    var cur_num = 0
    var current_gears = DynamicVector[Int]()

    # Process gears
    for r in range(height):
        # + 1 to hit the "\n" and reset things
        for c in range(width + 1):
            let digit = get_digit(getch(r, c))
            if digit == -1:
                if cur_num != 0:
                    for i in range(len(current_gears)):
                        if (counted[current_gears[i]]):
                            continue
                        counted[current_gears[i]] = True 
                        gear_num_count[current_gears[i]] += 1
                        gear_ratio[current_gears[i]] *= cur_num
                    for i in range(len(current_gears)):
                        counted[current_gears[i]] = False 
                cur_num = 0
                current_gears.clear()
            else:
                cur_num = cur_num * 10 + digit 
                let gear_indices = is_adj(r, c)
                for i in range(len(gear_indices)):
                    if gear_indices[i] == -1:
                        break 
                    current_gears.push_back(gear_indices[i])

    for i in range(len(data)):
        if gear_num_count[i] == 2:
            answer += gear_ratio[i]

    print("Part 2:", answer)


fn main() raises:
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        var width = 0
        for i in range(len(lines)):
            if lines[i] == "\n":
                break
            width += 1
        let height = len(lines) // (width + 1)

        # part1(lines, height, width)
        part2(lines, height, width)
