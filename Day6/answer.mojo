from math import ceil, floor

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
fn parse_all_ints_on_line(lines: String, inout i: Int) -> DynamicVector[Int]:
    var cur_num = -1
    var answer = DynamicVector[Int]()
    while lines[i] != "\n" and i < len(lines):
        let cur_digit = get_digit(lines[i])
        if cur_digit == -1:
            if cur_num != -1:
                answer.push_back(cur_num)
            cur_num = -1
        else:
            if cur_num == -1:
                cur_num = 0
            cur_num = cur_num * 10 + cur_digit
        i += 1

    if cur_num != -1:
        answer.push_back(cur_num)
    return answer 

@always_inline
fn parse_all_ints_on_line_smushed(lines: String, inout i: Int) -> Int:
    var cur_num = 0 
    while lines[i] != "\n" and i < len(lines):
        let cur_digit = get_digit(lines[i])
        if cur_digit != -1:
            cur_num = cur_num * 10 + cur_digit
        i += 1

    return cur_num 

fn part1and2(lines: String):
    var offset_i = 0
    let times = parse_all_ints_on_line(lines, offset_i)
    offset_i += 1
    let distance = parse_all_ints_on_line(lines, offset_i)

    # part 1
    var p1_answer = 1
    for i in range(len(times)):
        let cur_time = times[i]
        let cur_distance = distance[i]

        var num_wins = 0
        for speed in range(0, cur_time + 1):
            if speed * (cur_time - speed) > cur_distance:
                num_wins += 1
        p1_answer *= num_wins
    print("Part 1:", p1_answer)

    # part 2
    offset_i = 0
    let true_time = parse_all_ints_on_line_smushed(lines, offset_i) 
    offset_i += 1
    let true_distance = parse_all_ints_on_line_smushed(lines, offset_i) 
    
    let quadratic = (true_time * true_time - 4 * true_distance) ** 0.5
    
    let low_answer = (true_time - quadratic) / 2.0
    let hi_answer = (true_time + quadratic) / 2.0
    let p2_answer = floor(Float64(hi_answer)) - ceil(Float64(low_answer)) + 1
    print("Part 2:", p2_answer)


fn main() raises:
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        part1and2(lines)
