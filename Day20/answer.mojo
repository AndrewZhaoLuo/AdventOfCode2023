let PULSE_LO = 0
let PULSE_HI = 1
let PULSE_NONE = -1

let FLIP_OFF = 0
let FLIP_ON = 1

let PART_FLIP_FLOP = 0
let PART_CONJUNCTION = 1
let PART_NONE = -1
let PART_BROADCAST = -2

# Nested DynamicVector's don't seem to work
alias MAX_VECTOR_SIZE = 8
struct Part(CollectionElement):
    var part_type: Int 

    var inputs: DynamicVector[Int] 
    var last_inputs: DynamicVector[Int] 
    var outputs: DynamicVector[Int] 
    
    var flip_state: Int 

    fn __init__(inout self):
        self.__init__(PART_NONE)

    fn __init__(inout self, part_type: Int):
        self.part_type = part_type 
        self.inputs = DynamicVector[Int] ()
        self.last_inputs = DynamicVector[Int]()
        self.outputs = DynamicVector[Int]()
        self.flip_state = FLIP_OFF

    fn __copyinit__(inout self, existing: Self):
        self.part_type = existing.part_type
        self.inputs = existing.inputs
        self.outputs = existing.outputs
        self.last_inputs = existing.last_inputs
        self.flip_state = existing.flip_state

    fn __moveinit__(inout self, owned existing: Self):
        self.part_type = existing.part_type
        self.inputs = existing.inputs ^
        self.outputs = existing.outputs ^
        self.last_inputs = existing.last_inputs ^
        self.flip_state = existing.flip_state ^

    fn add_output(inout self, output_i: Int):
        self.outputs.push_back(output_i)

    fn add_input(inout self, input_i: Int):
        self.inputs.push_back(input_i)
        self.last_inputs.push_back(PULSE_LO)

    fn equals_state(self, other: Part) -> Bool:
        if self.flip_state != other.flip_state:
            return False 
        if len(self.last_inputs) != len(other.last_inputs):
            return False 

        for i in range(len(self.last_inputs)):
            if self.last_inputs[i] != other.last_inputs[i]:
                return False 

        return True 

    # output is the pulse type outputted, modifies internal state
    fn run_part(inout self, pulse: Int, src: Int) -> Int:
        if self.part_type == PART_FLIP_FLOP:
            if pulse == PULSE_HI:
                return PULSE_NONE

            # must be PULSE_LO, remember update state
            if self.flip_state == FLIP_OFF:
                self.flip_state = FLIP_ON
                return PULSE_HI
            else:
                self.flip_state = FLIP_OFF
                return PULSE_LO
        elif self.part_type == PART_CONJUNCTION:
            # must be conjunction module
            # update relevant state
            for i in range(len(self.last_inputs)):
                if src == self.inputs[i]:
                    self.last_inputs[i] = pulse 
                    break

            for i in range(len(self.last_inputs)):
                if self.last_inputs[i] != PULSE_HI:
                    return PULSE_HI
            return PULSE_LO
        return PULSE_NONE

# Classic idea, base 26 where a == 0, b == 1, ..., z == 25
fn text_to_index(name: String) -> Int:
    var answer = 0
    for i in range(len(name)):
        let v = ord(name[i])
        let local_answer = v - ord('a')
        if local_answer >= 0 and local_answer < 26:
            answer *= 26
            answer += local_answer
    return answer 

# If I embed this in `State`, it fails :'(. TODO: mojo bug?
fn get_broadcast_outputs(lines: DynamicVector[String]) raises -> DynamicVector[Int]:
    for i in range(len(lines)):
        let cur_line = lines[i]
        let split = cur_line.split(" -> ")
        let part_name = split[0]
        let output_names = split[1].split(", ")

        if part_name[0] == "b":
            var outputs = DynamicVector[Int]()
            for j in range(len(output_names)):
                outputs.push_back(text_to_index(output_names[j]))
            return outputs

    return DynamicVector[Int]()

let MAX_LENGTH = 26 * 26 * 26
struct State(CollectionElement):
    var parts: DynamicVector[Part]

    fn __init__(inout self, lines: DynamicVector[String]) raises:
        self.parts = DynamicVector[Part]() 
        for i in range(MAX_LENGTH):
            self.parts.push_back(Part())

        # Handle parsing 
        for i in range(len(lines)):
            let cur_line = lines[i]
            let split = cur_line.split(" -> ")
            let part_name = split[0]
            let output_names = split[1].split(", ")

            # Parse input and output indices
            let part_index = text_to_index(part_name)
            var outputs = DynamicVector[Int]()
            for j in range(len(output_names)):
                outputs.push_back(text_to_index(output_names[j]))

            # -1 means the broadcast 
            let part_type: Int
            if part_name[0] == "%":
                part_type = PART_FLIP_FLOP
            elif part_name[0] == "&":
                part_type = PART_CONJUNCTION
            else:
                part_type = PART_BROADCAST

            if part_type != PART_BROADCAST:
                self.parts[part_index].part_type = part_type 
                for j in range(len(outputs)):
                    self.parts[outputs[j]].add_input(part_index)
                self.parts[part_index].outputs = outputs^

    fn __copyinit__(inout self, existing: Self):
        self.parts = existing.parts

    fn __moveinit__(inout self, owned existing: Self):
        self.parts = existing.parts ^

struct Queue[T: CollectionElement]:
    var b1: DynamicVector[T]
    var b2: DynamicVector[T] 

    fn __init__(inout self):
        self.b1 = DynamicVector[T]()
        self.b2 = DynamicVector[T]()

    fn push_back(inout self, owned value: T):
        self.b1.push_back(value)

    fn pop_front(inout self) -> T:
        if len(self.b2) == 0:
            while len(self.b1) > 0:
                self.b2.push_back(self.b1.pop_back())
        return self.b2.pop_back()

    fn size(inout self) -> Int:
        return len(self.b1) + len(self.b2)

# Sends a canary signal (-1, -1) when src node emits target signal
fn run_press(
    inout state: State, 
    broadcast_state: DynamicVector[Int], 
    target_src_node: Int = -1,
    target_src_signal: Int = -1
) -> Tuple[Int, Int]:
    var hi_signal = 0

    # broadcast counts as one
    var lo_signal = 1 

    # Tuple is src, target, pulse_type
    var fringe = Queue[Tuple[Int, Int, Int]]()
    for i in range(len(broadcast_state)):
        fringe.push_back((-1, broadcast_state[i], PULSE_LO))

    var canary = False 

    while fringe.size() > 0:
        let cur = fringe.pop_front()
        let src = cur.get[0, Int]()
        let target = cur.get[1, Int]()
        let pulse = cur.get[2, Int]()

        if pulse == PULSE_NONE:
            continue 
        if pulse == PULSE_HI:
            hi_signal += 1
        if pulse == PULSE_LO:
            lo_signal += 1

        if pulse == target_src_signal and src == target_src_node:
            canary = True

        # print(src, "->", target, " of signal ", pulse)
        let output = state.parts[target].run_part(pulse, src)
        let part_outputs = state.parts[target].outputs
        for i in range(len(part_outputs)):
            fringe.push_back((target, part_outputs[i], output))

    if canary:
        return (-1, -1)

    return (hi_signal, lo_signal)

fn part1(inout state: State, broadcast_state: DynamicVector[Int]) -> Int:
    var hi_signal = 0
    var lo_signal = 0
    for i in range(1000):
        let result = run_press(state, broadcast_state)
        hi_signal += result.get[0, Int]()
        lo_signal += result.get[1, Int]()

    return hi_signal * lo_signal

fn presses_to_emit(
    inout state: State, 
    broadcast_state: DynamicVector[Int],
    target_src_node: Int, 
    target_signal: Int, 
) -> Int:
    var answer = 0
    for i in range(1000000000):
        let result = run_press(state, broadcast_state, target_src_node, target_signal)
        answer += 1
        if (result.get[0, Int]() == -1):
            return answer
    return answer

fn main() raises:
    # NOTE: Does not work due to bu in dynamic vector?
    # NOTE: remember a newline at end of input manually
    with open('input.txt', 'r') as f:
        let raw_text = f.read()
        let lines = raw_text.split("\n")

        var initial_state_p1 = State(lines)
        let broadcast_state = get_broadcast_outputs(lines)
        print("Part1:", part1(initial_state_p1, broadcast_state))

        # Part 2 by hand
        var initial_state_p2 = State(lines)
        print("Period kl")
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("kl"), PULSE_HI))
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("kl"), PULSE_HI))
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("kl"), PULSE_HI))
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("kl"), PULSE_HI))

        initial_state_p2 = State(lines)
        print("Period vm")
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("vm"), PULSE_HI))
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("vm"), PULSE_HI))
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("vm"), PULSE_HI))
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("vm"), PULSE_HI))

        initial_state_p2 = State(lines)
        print("Period kv")
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("kv"), PULSE_HI))
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("kv"), PULSE_HI))
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("kv"), PULSE_HI))
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("kv"), PULSE_HI))

        initial_state_p2 = State(lines)
        print("Period vb")
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("vb"), PULSE_HI))
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("vb"), PULSE_HI))
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("vb"), PULSE_HI))
        print(presses_to_emit(initial_state_p2, broadcast_state, text_to_index("vb"), PULSE_HI))

        # Results: periods are 3917, 4051, 4013, 3793 and are perfect, lcm is
        # 241528184647003 by wolfram