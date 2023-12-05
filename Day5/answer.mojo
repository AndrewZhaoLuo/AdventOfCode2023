@always_inline
fn max(a: Int, b: Int) -> Int:
    if a > b:
        return a 
    return b 

@always_inline 
fn min(a: Int, b: Int) -> Int:
    if a < b:
        return a 
    return b

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
fn parse_next_number_stop_at_colon(data: String, inout i: Int) -> Int:
    var cur_num = -1

    while i < len(data):
        if data[i] == ":":
            return -1

        let digit = get_digit(data[i])
        if digit == -1:
            if cur_num != -1:
                return cur_num

            i += 1
            continue

        if cur_num == -1:
            cur_num = 0

        cur_num = cur_num * 10 + digit  
        i += 1
    return cur_num

@register_passable("trivial")
struct RangeData:
    var s1: Int 
    var s2: Int 
    var n: Int 

    fn __init__(s1: Int, s2: Int, n: Int) -> Self:
        return Self {s1: s1, s2: s2, n: n}

fn part1(data: String):
    fn parse_seeds(inout i: Int) -> DynamicVector[Int]:
        var answer = DynamicVector[Int]()

        # Grab first colon
        let _tmp = parse_next_number_stop_at_colon(data, i)
        i += 1

        var next_num = parse_next_number_stop_at_colon(data, i)
        while next_num != -1:
            answer.push_back(next_num)
            next_num = parse_next_number_stop_at_colon(data, i)
        return answer 

    fn parse_range_data(inout i: Int) -> DynamicVector[RangeData]:
        var answer = DynamicVector[RangeData]()
        while True:
            let start = parse_next_number_stop_at_colon(data, i)
            if start == -1:
                break
            let end = parse_next_number_stop_at_colon(data, i)
            let num = parse_next_number_stop_at_colon(data, i)
            let rdata = RangeData(start, end, num)
            answer.push_back(rdata)
        return answer 

    fn advance_state(inout cur_state: DynamicVector[Int], transition: DynamicVector[RangeData]):
        for i in range(len(cur_state)):
            var answer = cur_state[i]
            for j in range(len(transition)):
                let cur_transition = transition[j]
                let lbound = cur_transition.s2
                let rbound = cur_transition.s2 + cur_transition.n - 1
                if (answer >= lbound and answer <= rbound):
                    let diff = answer - lbound
                    answer = diff + cur_transition.s1
                    break
            cur_state[i] = answer

    var i: Int = 0
    var cur_state = parse_seeds(i) # stop at colon
    i += 1 # get off colon

    # seven stages 
    for _ in range(7):
        let range_data = parse_range_data(i) 
        i += 1 # get off colon
        advance_state(cur_state, range_data)

    var answer = cur_state[0]
    for i in range(len(cur_state)):
        if cur_state[i] < answer:
            answer = cur_state[i]
    print("Part 1:", answer)


fn part2(data: String):
    fn parse_seeds(inout i: Int) -> DynamicVector[RangeData]:
        var answer = DynamicVector[RangeData]()

        # Grab first colon
        let _tmp = parse_next_number_stop_at_colon(data, i)
        i += 1

        var num1 = parse_next_number_stop_at_colon(data, i)
        var num2 = parse_next_number_stop_at_colon(data, i)
        while True:
            answer.push_back(RangeData(num1, num1 + num2 - 1, 0))
            num1 = parse_next_number_stop_at_colon(data, i)
            if num1 == -1:
                break
            num2 = parse_next_number_stop_at_colon(data, i)
        return answer 

    fn parse_range_data(inout i: Int) -> DynamicVector[RangeData]:
        var answer = DynamicVector[RangeData]()
        while True:
            let start = parse_next_number_stop_at_colon(data, i)
            if start == -1:
                break
            let end = parse_next_number_stop_at_colon(data, i)
            let num = parse_next_number_stop_at_colon(data, i)
            let rdata = RangeData(start, end, num)
            answer.push_back(rdata)
        return answer 

    fn advance_state(inout init_state: DynamicVector[RangeData], transition: DynamicVector[RangeData]) -> DynamicVector[RangeData]:
        var answer = DynamicVector[RangeData]()

        while len(init_state) > 0:
            let cur_state = init_state.pop_back()
            let cur_lbound = cur_state.s1 
            let cur_rbound = cur_state.s2 

            var did_replace = False 
            for j in range(len(transition)):
                let cur_transition = transition[j]
                let t_lbound = cur_transition.s2
                let t_rbound = cur_transition.s2 + cur_transition.n - 1

                let intersect_left = max(cur_lbound, t_lbound)
                let intersect_right = min(cur_rbound, t_rbound)
                if (intersect_left <= intersect_right):
                    let diff = intersect_left - t_lbound
                    let n_lbound = cur_transition.s1 + diff 
                    let n_rbound = n_lbound + (intersect_right - intersect_left)
                    answer.push_back(RangeData(n_lbound, n_rbound, 0))

                    # re-add left and right intersections
                    let r_lbound = intersect_right + 1
                    let r_rbound = cur_rbound
                    if (r_lbound <= r_rbound):
                        init_state.push_back(RangeData(r_lbound, r_rbound, 0))

                    let l_lbound = cur_lbound
                    let l_rbound = intersect_left - 1
                    if (l_lbound <= l_rbound):
                        init_state.push_back(RangeData(l_lbound, l_rbound, 0))
                    did_replace = True 
                    break
            
            if not did_replace:
                answer.push_back(cur_state)

        return answer

    var i: Int = 0
    var cur_state = parse_seeds(i) # stop at colon
    i += 1 # get off colon

    # seven stages 
    for _ in range(7):
        let range_data = parse_range_data(i)  
        i += 1 # get off colon
        cur_state = advance_state(cur_state, range_data)

    var answer = cur_state[0].s1
    for i in range(len(cur_state)):
        let cur = cur_state[i]
        answer = min(answer, cur.s1)

    print("Part 2:", answer)


fn main() raises:
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        # part1(lines)
        part2(lines)
