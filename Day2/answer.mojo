alias R = 0
alias G = 1
alias B = 2

@always_inline
fn get_digit(one_char: String) -> Int:
    # Returns -1 if not digit, otherwise returns the digit
    let cur_ord = ord(one_char)
    alias l_bound = ord('0')
    alias r_bound = ord('9')
    if cur_ord > r_bound or cur_ord < l_bound: 
        return -1
    return cur_ord - l_bound

@always_inline
fn max(a: Int, b: Int) -> Int:
    if a > b:
        return a
    return b

fn p1_and_p2(lines: String):
    var p1_answer = 0
    var p2_answer = 0

    var cur_num = 0
    var in_game = False 
    var possible = True

    var game_num = 0
    var max_values = StaticIntTuple[3](0, 0, 0)

    for i in range(len(lines)):
        let cur_char = lines[i]
        if cur_char == ':':
            in_game = True 
            continue 

        # Ignore all nums until you get to a ':'
        if cur_char == 'G':
            in_game = False 
            possible = True 
            max_values[R] = 0
            max_values[G] = 0
            max_values[B] = 0
            game_num += 1
            continue

        # Ignore blah blah, likely will bite us in the butt
        if not in_game: 
            continue 

        let parsed_digit = get_digit(cur_char) 
        if get_digit(cur_char) != -1:
            cur_num = cur_num * 10 + parsed_digit
        if cur_char == "r": # blue
            max_values[R] = max(max_values[R], cur_num)
            cur_num = 0
        if cur_char == "g": # green
            max_values[G] = max(max_values[G], cur_num)
            cur_num = 0
        if cur_char == "b": # blue
            max_values[B] = max(max_values[B], cur_num)
            cur_num = 0

        # NOTE: Manually add a \n to input please
        if cur_char == "\n":
            if max_values[R] <= 12 and max_values[G] <= 13 and max_values[B] <= 14:
                p1_answer += game_num

            let power = max_values[R] * max_values[G] * max_values[B]
            p2_answer += power

    print("Part 1:", p1_answer)
    print("Part 2:", p2_answer)

fn main() raises:
    with open('input.txt', 'r') as f:
        let lines = f.read()
        p1_and_p2(lines)
