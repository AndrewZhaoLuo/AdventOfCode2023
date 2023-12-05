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
fn reset_state(inout is_win: StaticTuple[100, Bool]):
    for i in range(100):
        is_win[i] = False 

@always_inline
fn get_score(num_right: Int) -> Int:
    if num_right <= 1:
        return num_right
    return 1 << (num_right - 1)

fn part1and2(data: String):
    var is_win = StaticTuple[100, Bool]()
    reset_state(is_win)

    var num_cards = DynamicVector[Int](300)
    for i in range(300):
        num_cards[i] = 1

    var p1_answer = 0
    var game_num = 0
    var cur_num = -1
    var past_colon = False 
    var past_divider = False
    var p1_local_answer = 0 
    for i in range(len(data)):
        let cur_char = data[i]

        # new line 
        if cur_char == "C": 
            let num_cur_card = num_cards[game_num]
            for offset in range(p1_local_answer):
                num_cards[game_num + offset + 1] += num_cur_card

            p1_answer += get_score(p1_local_answer)
            cur_num = -1
            past_colon = False 
            past_divider = False 
            p1_local_answer = 0
            game_num += 1
            reset_state(is_win)
            continue 

        if cur_char == ":":
            past_colon = True 
            continue 

        if cur_char == "|":
            past_divider = True 
            continue 

        if not past_colon:
            continue 

        let digit = get_digit(cur_char)
        if digit == -1:
            if cur_num != -1 and not past_divider:
                is_win[cur_num] = True 
            if cur_num != -1 and past_divider:
                if is_win[cur_num]:
                    p1_local_answer += 1
            cur_num = -1
            continue 

        if cur_num == -1:
            cur_num = 0
        cur_num = cur_num * 10 + digit

    p1_answer += get_score(p1_local_answer)
    print("Part 1:", p1_answer)

    var p2_answer = 0
    for i in range(game_num):
        p2_answer += num_cards[i]
    print("Part 2:", p2_answer)

fn main() raises:
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        part1and2(lines)
