
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
fn get_value(first_digit: Int, second_digit: Int) -> Int:
    # Get's the answer given the first and second digit
    if first_digit == -1:
        return 0
    if second_digit == -1:
        return first_digit * 10 + first_digit
    return first_digit * 10 + second_digit

fn p1(lines: String):
    var total_answer = 0
    var first_digit = -1
    var second_digit = -1
    for i in range(len(lines)):
        let cur_char = lines[i]
        let digit = get_digit(cur_char)
        if digit > 0:
            if first_digit == -1:
                first_digit = digit 
            else:
                second_digit = digit 

        if cur_char == "\n":
            total_answer += get_value(first_digit, second_digit)
            first_digit = -1 
            second_digit = -1

    total_answer += get_value(first_digit, second_digit)
    print("Part1: ", total_answer)

@always_inline
fn reset_parser_state(inout state: StaticIntTuple[10]):
    for i in range(0, 10):
        state[i] = 0

# all lower
let str_digits = StaticTuple[10, StringLiteral](" ", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine")

@always_inline
fn update_parser_state(inout state: StaticIntTuple[10], one_char: StringRef) -> Int:
    '''Updates parser state based on char and returns digit parsed, else returns -1.'''
    let is_digit = get_digit(one_char) 
    if is_digit != -1:
        reset_parser_state(state)
        return is_digit
    
    @unroll
    for c in range(10):
        let string_ref: StringRef = str_digits[c]
        let cur_state: Int = state[c]
        if string_ref[cur_state] == one_char:
            state[c] += 1
        elif string_ref[0] == one_char:
            state[c] = 1
        else:
            state[c] = 0

    # Only one digit may fire
    @unroll 
    for c in range(10):
        let string_ref: StringRef = str_digits[c]
        let cur_state: Int = state[c]
        if cur_state == len(string_ref):
            state[c] = 0
            return c

    return -1

fn p2(lines: String):
    # parser_state[c] points to the next expected char in the string representation of c
    # ie if parser_state[0] = 1, then we want the first 'e' in 'zero'
    var parser_state: StaticIntTuple[10] = StaticIntTuple[10]()
    reset_parser_state(parser_state)

    var total_answer = 0
    var first_digit = -1
    var second_digit = -1
    for i in range(len(lines)):

        # only sometimes segfaults!
        let cur_char = StringRef(lines._buffer.data)[i]
        let result = update_parser_state(parser_state, cur_char)

        if result != -1:
            if first_digit == -1:
                first_digit = result 
            else:
                second_digit = result

        if cur_char == "\n":
            let local_answer = get_value(first_digit, second_digit)
            total_answer += local_answer
            first_digit = -1 
            second_digit = -1
            reset_parser_state(parser_state)

    total_answer += get_value(first_digit, second_digit)
    print("Part2: ", total_answer)

fn main() raises:
    with open('input.txt', 'r') as f:
        let lines = f.read()
        p1(lines)
        p2(lines)
