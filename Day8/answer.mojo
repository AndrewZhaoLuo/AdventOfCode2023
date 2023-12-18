@register_passable("trivial")
struct Paths(CollectionElement):
    var left_node: Int 
    var right_node: Int 

    fn __init__() -> Paths:
        return Self{left_node: -1, right_node: -1}

    fn __init__(left_node: Int, right_node: Int) -> Paths:
        return Self{left_node: left_node, right_node: right_node}

fn is_alpha(one_char: String) -> Int:
    # Returns -1 if not digit, otherwise the value of symbol in base 26
    let cur_ord = ord(one_char)
    alias l_bound = ord('A')
    alias r_bound = ord('Z')
    if cur_ord > r_bound or cur_ord < l_bound: 
        return -1 
    return cur_ord - l_bound

# AAA == 0, AAB == 1, AAC == 2, ... ZZZ = 26 * 26 * 26 - 1 
alias MAX_NODE_INDEX = 26 * 26 * 26
struct ProblemState:
    var directions: String
    var nodes: DynamicVector[Paths]

    fn __init__(inout self, raw_data: String):
        self.directions = String("")
        self.nodes = DynamicVector[Paths](MAX_NODE_INDEX + 1)
        for i in range(MAX_NODE_INDEX + 1):
            self.nodes[i] = Paths()

        var cur_i = 0

        # Parse directions
        while cur_i < len(raw_data):
            if raw_data[cur_i] != 'L' and raw_data[cur_i] != 'R':
                break
            self.directions += raw_data[cur_i]
            cur_i += 1

        # Parse node index, 0 == base, 1 == left, 2 == right
        var parse_state = StaticIntTuple[3]()
        parse_state[0] = 0
        parse_state[1] = 0
        parse_state[2] = 0
        var cur_state = 0
        while cur_i < len(raw_data):
            let cur_alpha = is_alpha(raw_data[cur_i])
            if cur_alpha >= 0:
                parse_state[cur_state] *= 26 
                parse_state[cur_state] += cur_alpha 
            elif raw_data[cur_i] == '=':
                cur_state = 1 
            elif raw_data[cur_i] == ',':
                cur_state = 2 
            elif raw_data[cur_i] == ')':
                # cannot manually assign or else mojo hangs
                self.nodes[parse_state[0]] = Paths(parse_state[1], parse_state[2])

                # Reset state
                cur_state = 0
                parse_state[0] = 0
                parse_state[1] = 0
                parse_state[2] = 0
            cur_i += 1

fn index_ends_with_Z(index: Int) -> Bool:
    return index % 26 == 25

alias index_AAA = 0
alias index_ZZZ = 26 * 26 * 26 - 1
fn part1(problem: ProblemState, start_index: Int = index_AAA, exact_ZZZ: Bool = True) -> Tuple[Int, Int]:
    # exact_ZZZ if on requires exact ZZZ match, else just end in ZZZ
    var num_steps = 0
    var cur_dir_index = 0
    var cur_node_index = start_index
    while True:
        let paths = problem.nodes[cur_node_index]
        let cur_instruction = problem.directions[cur_dir_index]
        if cur_instruction == 'R':
            cur_node_index = paths.right_node
        else:
            cur_node_index = paths.left_node

        num_steps += 1
        cur_dir_index += 1
        cur_dir_index %= len(problem.directions) 

        if cur_node_index == index_ZZZ:
            break
        elif not exact_ZZZ and index_ends_with_Z(cur_node_index):
            break

    return (num_steps, cur_node_index)

fn part2(problem: ProblemState):
    let num_steps = 0
    let cur_dir_index = 0
    var start_nodes = DynamicVector[Int]()

    # Starts with A
    for i in range(0, MAX_NODE_INDEX + 1, 26):
        if problem.nodes[i].left_node != -1:
            start_nodes.push_back(i)

    # Find first time to Z
    var first_steps = DynamicVector[Int](len(start_nodes))
    var middle_nodes = DynamicVector[Int](len(start_nodes))
    print("FIRST STEPS")
    for i in range(len(start_nodes)):
        let local_answer = part1(problem, start_nodes[i], exact_ZZZ=False)
        first_steps[i] = local_answer.get[0, Int]()
        middle_nodes[i] = local_answer.get[1, Int]()
        print('Start Index:', start_nodes[i], 'Steps:', local_answer.get[0, Int](), 'Final Node:', local_answer.get[1, Int]())

    # for each Z node, calculate time to reach next node
    var Z_nodes = DynamicVector[Int]()
    for i in range(25, MAX_NODE_INDEX + 1, 26):
        if problem.nodes[i].left_node != -1:
            Z_nodes.push_back(i)

    # index 0 --> num steps, index 1 --> next node index
    print("LAST STEPS")
    var next_nodes = DynamicVector[Tuple[Int, Int]]()
    for i in range(len(Z_nodes)):
        let cur_z_node = Z_nodes[i]
        let local_answer = part1(problem, cur_z_node, exact_ZZZ=False)
        next_nodes.push_back(local_answer)
        print('Start Index:', Z_nodes[i], 'Steps:', local_answer.get[0, Int](), 'Final Node:', local_answer.get[1, Int]())


fn main() raises:
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let lines = f.read()
        let problem = ProblemState(lines)
        print(part1(problem).get[0, Int]())

        # We note here that from the start position and thereafter, it takes each 
        # ghost 21883, 11911, 16897, 19667, 13019, and 18559
        # To re-reach a Z node. 
        # The answer is the LCM of the numbers (which I just used wolfram)
        '''
        FIRST STEPS
        Start Index: 0 Steps: 21883 Final Node: 17575
        Start Index: 858 Steps: 11911 Final Node: 4263
        Start Index: 5226 Steps: 16897 Final Node: 3821
        Start Index: 7670 Steps: 19667 Final Node: 13259
        Start Index: 9022 Steps: 13019 Final Node: 5355
        Start Index: 16146 Steps: 18559 Final Node: 10711
        LAST STEPS
        Start Index: 3821 Steps: 16897 Final Node: 3821
        Start Index: 4263 Steps: 11911 Final Node: 4263
        Start Index: 5355 Steps: 13019 Final Node: 5355
        Start Index: 10711 Steps: 18559 Final Node: 10711
        Start Index: 13259 Steps: 19667 Final Node: 13259
        Start Index: 17575 Steps: 21883 Final Node: 17575
        '''
        part2(problem)
